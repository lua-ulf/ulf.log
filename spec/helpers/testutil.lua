local luaassert = require("luassert")
local uv = vim and vim.uv or require("luv")

local M = {}

function M.eq(expected, actual, context)
	return luaassert.are.same(expected, actual, context)
end
function M.neq(expected, actual, context)
	return luaassert.are_not.same(expected, actual, context)
end

--- Asserts that `cond` is true, or prints a message.
---
--- @param cond (boolean) expression to assert
--- @param expected (any) description of expected result
--- @param actual (any) description of actual result
function M.ok(cond, expected, actual)
	luaassert(
		(not expected and not actual) or (expected and actual),
		'if "expected" is given, "actual" is also required'
	)
	local msg = expected and ("expected %s, got: %s"):format(expected, tostring(actual)) or nil
	return luaassert(cond, msg)
end

--- @param pat string
--- @param actual string
--- @return boolean
function M.matches(pat, actual)
	if nil ~= string.match(actual, pat) then
		return true
	end
	error(string.format("Pattern does not match.\nPattern:\n%s\nActual:\n%s", pat, actual))
end

--- @param fn fun(...): any
--- @param ... any
--- @return boolean, any
function M.pcall(fn, ...)
	luaassert(type(fn) == "function")
	local status, rv = pcall(fn, ...)
	if status then
		return status, rv
	end

	-- From:
	--    C:/long/path/foo.lua:186: Expected string, got number
	-- to:
	--    .../foo.lua:0: Expected string, got number
	local errmsg = tostring(rv)
		:gsub("([%s<])vim[/\\]([^%s:/\\]+):%d+", "%1\xffvim\xff%2:0")
		:gsub("[^%s<]-[/\\]([^%s:/\\]+):%d+", ".../%1:0")
		:gsub("\xffvim\xff", "vim/")

	-- Scrub numbers in paths/stacktraces:
	--    shared.lua:0: in function 'gsplit'
	--    shared.lua:0: in function <shared.lua:0>'
	errmsg = errmsg:gsub("([^%s].lua):%d+", "%1:0")
	--    [string "<nvim>"]:0:
	--    [string ":lua"]:0:
	--    [string ":luado"]:0:
	errmsg = errmsg:gsub('(%[string "[^"]+"%]):%d+', "%1:0")

	-- Scrub tab chars:
	errmsg = errmsg:gsub("\t", "    ")
	-- In Lua 5.1, we sometimes get a "(tail call): ?" on the last line.
	--    We remove this so that the tests are not lua dependent.
	errmsg = errmsg:gsub("%s*%(tail call%): %?", "")

	return status, errmsg
end

-- Invokes `fn` and returns the error string (with truncated paths), or raises
-- an error if `fn` succeeds.
--
-- Replaces line/column numbers with zero:
--     shared.lua:0: in function 'gsplit'
--     shared.lua:0: in function <shared.lua:0>'
--
-- Usage:
--    -- Match exact string.
--    eq('e', pcall_err(function(a, b) error('e') end, 'arg1', 'arg2'))
--    -- Match Lua pattern.
--    matches('e[or]+$', pcall_err(function(a, b) error('some error') end, 'arg1', 'arg2'))
--
--- @param fn function
--- @return string
function M.pcall_err_withfile(fn, ...)
	luaassert(type(fn) == "function")
	local status, rv = M.pcall(fn, ...)
	if status == true then
		error("expected failure, but got success")
	end
	return rv
end

--- @param fn function
--- @param ... any
--- @return string
function M.pcall_err_withtrace(fn, ...)
	local errmsg = M.pcall_err_withfile(fn, ...)

	return (
		errmsg
			:gsub("^%.%.%./testnvim%.lua:0: ", "")
			:gsub("^Error executing lua:- ", "")
			:gsub('^%[string "<nvim>"%]:0: ', "")
	)
end

--- @param fn function
--- @param ... any
--- @return string
function M.pcall_err(fn, ...)
	return M.remove_trace(M.pcall_err_withtrace(fn, ...))
end

--- @param s string
--- @return string
function M.remove_trace(s)
	return (s:gsub("\n%s*stack traceback:.*", ""))
end

return M
