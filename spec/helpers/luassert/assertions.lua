-- module will not return anything, only register assertions with the main assert engine

-- assertions take 2 parameters;
-- 1) state
-- 2) arguments list. The list has a member 'n' with the argument count to check for trailing nils
-- 3) level The level of the error position relative to the called function
-- returns; boolean; whether assertion passed

local assert = require("luassert.assert")
local util = require("luassert.util")

local function set_failure_message(state, message)
	if message ~= nil then
		state.failure_message = message
	end
end

--- Returns true if object `f` can be called as a function.
---
---@param f any Any object
---@return boolean `true` if `f` is callable, else `false`
local function is_callable(f)
	if type(f) == "function" then
		return true
	end
	local m = getmetatable(f)
	if m == nil then
		return false
	end
	return type(rawget(m, "__call")) == "function"
end

local function callable(state, arguments, level)
	util.tinsert(arguments, 2, "type " .. "callable")
	arguments.nofmt = arguments.nofmt or {}
	arguments.nofmt[2] = true
	local function test_callable()
		if type(arguments[1]) == "table" then
			local _state = is_callable(arguments[1])
			arguments.fmtargs = arguments.fmtargs or {}
			arguments.fmtargs[1] = { crumbs = arguments[1] }
			return _state
		end
	end

	local function test_func()
		return type(arguments[1]) == "function"
	end
	arguments[3] = "expect a function or callable object"

	set_failure_message(state, arguments[3])
	return arguments.n > 1 and (test_callable() or test_func())
end

assert:register("assertion", "Callable", callable, "assertion.callable.positive", "assertion.callable.negative")
assert:register("assertion", "callable", callable, "assertion.callable.positive", "assertion.callable.negative")
