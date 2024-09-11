--[[

Copyright 2014 The Luvit Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS-IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

--]]

-- exports.name = "luvit/tap"
-- exports.version = "0.1.1"
-- exports.dependencies = {
-- 	"luvit/pretty-print@1.0.2",
-- }
-- exports.license = "Apache 2"
-- exports.homepage = "https://github.com/luvit/luvit/blob/master/tests/libs/tap.lua"
-- exports.description = "Libuv loop based test runner with tap output."
-- exports.tags = { "test", "tap" }

---@alias tap.expect_arg fun(fn:fun(...))
---@alias tap.expect_fact fun(fn:function,count:number?):fun(...)
---@alias tap.test_fn fun(expect:tap.expect_fact)
---@alias tap.test {name:string,fn:tap.test_init}
---@alias tap.tests tap.test_fact[]
---
---
---@alias tap.test_fact {name:string,fn:function}
---@alias tap.test_init fun(name:string,fn:tap.expect_arg)
---@alias tap.suite_init fun(fn:tap.test_init)
---@alias tap.suite string|boolean|tap.suite_init|tap.test_init)
---
local uv = vim and vim.uv or require("luv")
local colorize = require("spec.libs.pretty-print").colorize

-- Capture output from global print and prefix with two spaces
local print = _G.print
_G.print = function(...)
	local n = select("#", ...)
	---@type any[]
	local arguments = { ... }
	for i = 1, n do
		arguments[i] = tostring(arguments[i])
	end

	local text = table.concat(arguments, "\t")
	text = "  " .. string.gsub(text, "\n", "\n  ")
	print(text)
end

---@type tap.tests
local tests = {}

local function run()
	local passed = 0

	if #tests < 1 then
		error("No tests specified!")
	end

	print("1.." .. #tests)
	for i = 1, #tests do
		local test = tests[i]
		local cwd = uv.cwd()

		---@alias tap.poly_handle  uv_fs_event_t|uv_fs_poll_t|uv_handle_t|uv_pipe_t|uv_stream_t
		---@alias tap.handle_map  table<tap.poly_handle,boolean>

		---@type tap.handle_map
		local preexisting = {}
		uv.walk(function(handle)
			preexisting[handle] = true
		end)
		print("\n# Starting Test: " .. colorize("highlight", test.name))
		local pass, err = xpcall(function()
			local expected = 0
			---@type string
			local err
			---@type tap.expect_fact
			local function expect(fn, count)
				expected = expected + (count or 1)
				return function(...)
					expected = expected - 1
					---@type boolean
					local success
					---@type any
					local ret
					success, ret = pcall(fn, ...) ---@diagnostic disable-line: no-unknown
					---@cast ret any
					if not success then
						err = ret
					end
					collectgarbage()
					return ret
				end
			end

			---
			test.fn(expect)
			collectgarbage()
			uv.run()
			collectgarbage()
			if err then
				error(err)
			end
			if expected > 0 then
				error("Missing " .. expected .. " expected call" .. (expected == 1 and "" or "s"))
			elseif expected < 0 then
				error("Found " .. -expected .. " unexpected call" .. (expected == -1 and "" or "s"))
			end
			collectgarbage()
			local unclosed = 0
			uv.walk(function(handle)
				if preexisting[handle] then
					return
				end
				unclosed = unclosed + 1
				print("UNCLOSED", handle)
			end)
			if unclosed > 0 then
				error(unclosed .. " unclosed handle" .. (unclosed == 1 and "" or "s"))
			end
			if uv.cwd() ~= cwd then
				error("Test moved cwd from " .. cwd .. " to " .. uv.cwd())
			end
			collectgarbage()
		end, debug.traceback)

		-- Flush out any more opened handles
		uv.stop()
		uv.walk(function(handle)
			if preexisting[handle] or uv.is_closing(handle) then
				return
			end
			uv.close(handle)
		end)
		-- Wait for the close calls to finish
		uv.run()
		-- Reset the cwd if the script changed it.
		uv.chdir(cwd)

		if pass then
			print("ok " .. i .. " " .. colorize("success", test.name))
			passed = passed + 1
		else
			_G.print(colorize("err", err))
			print("not ok " .. i .. " " .. colorize("failure", test.name))
		end
	end

	local failed = #tests - passed
	if failed == 0 then
		print("# All tests passed")
	else
		print("#" .. failed .. " failed test" .. (failed == 1 and "" or "s"))
	end

	-- Close all then handles, including stdout
	uv.walk(function(handle)
		if not uv.is_closing(handle) then
			uv.close(handle)
		end
	end)
	uv.run()

	os.exit(-failed)
end

local single = true
---@type string?
local prefix

---@param suite tap.suite
local function tap(suite)
	if type(suite) == "function" then
		-- Pass in suite directly for single mode
		---comment
		suite(function(name, fn)
			if prefix then
				name = prefix .. " - " .. name
			end
			tests[#tests + 1] = {
				name = name,
				fn = fn,
			}
		end)
		prefix = nil
	elseif type(suite) == "string" then
		prefix = suite
		single = false
	else
		-- Or pass in false to collect several runs of tests
		-- And then pass in true in a later call to flush tests queue.
		single = suite
	end

	if single then
		run()
	end
end

return tap
