local busted = require("busted")

local function debug_print(msg, ...)
	local inspect = require("ulf.log.inspect")
	msg = msg or ""
	if type(msg) ~= "string" then
		msg = inspect(msg)
	end
	local busted = require("busted")
	-- print("============ test debug ===========")
	local argv = { ... }

	local lines = {}
	for index, value in ipairs(argv) do
		lines[#lines + 1] = string.format("[%s]: %s", index, inspect(value))
	end

	-- busted.subscribe({ "test", "end" }, function(element, parent)
	io.write(msg .. " " .. table.concat(lines, " ") .. "\n")
	io.flush()
	-- end)
end

_G.P = debug_print

local _done
local co = _G.co

-- busted.subscribe({ "test", "start" }, handler.baseTestStart, { priority = 1, predicate = handler.cancelOnPending })
busted.subscribe({ "test", "start" }, function(element, parent)
	_done = false
end)

local function getDone()
	return _done
end

function _G.done()
	_done = true
	return _done
end

---------------------------------------------------------------------
---Need to implement _G.wait to pass tests

local defaultTimeout = 1000

---Should override this function to customize EventLoop to pass tests
---@param ms? number
---@return boolean
function _G.wait(ms)
	if getDone() then
		return true
	end
	local interval = 5
	local timer = require("luv").new_timer()
	local cnt = 0
	ms = ms or defaultTimeout

	timer:start(interval, interval, function()
		cnt = cnt + interval
		local d = getDone()
		-- P { "timer start function", d = d }
		if cnt >= ms or d then
			timer:stop()
			timer:close()
			local thread = coroutine.running()
			if thread ~= co then
				require("spec.helpers").set_timeout(0, function()
					coroutine.resume(co, d)
				end)
			end
		end
	end)
	return coroutine.yield()
end
