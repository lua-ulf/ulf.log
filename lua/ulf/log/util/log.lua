---@class ulf.log.util
local M = {}

local Severity = require("ulf.log.severity")
local Term = require("ulf.log.term")

local uv = vim and vim.uv or require("luv")

function M.is_busted_running()
	-- Check if the Busted module is loaded
	if package.loaded["busted"] then
		return true
	end

	-- Optionally, check for other identifiers that Busted typically loads
	-- For example, `describe`, `it`, etc., might be available globally
	if _G.describe or _G.it then
		return true
	end

	return false
end
function M.called_via_test()
	-- Patterns to identify test files
	local test_patterns = { "_spec.lua", "_test.lua" }

	-- Traverse the stack up to 5 levels
	for level = 3, 6 do
		local info = debug.getinfo(level, "Sl")
		if not info then
			break
		end

		-- Check if the source file name matches any test pattern
		for _, pattern in ipairs(test_patterns) do
			if info.short_src and string.match(info.short_src, pattern) then
				return true
			end
		end
	end

	return false
end
local log_methods = {
	trace = true,
	debug = true,
	info = true,
	warn = true,
	error = true,
	log = true,
}

---@type boolean
local init_done

if not init_done then
	init_done = true
	for key, value in pairs(log_methods) do
		log_methods[key .. "_ml"] = true
		log_methods[key .. "_fmt"] = true
	end
end

function M.is_log_method_name(s)
	assert(type(s) == "string", "ulf.log.util.is_log_method_name: s must be a string")

	if log_methods[s] then
		return true
	end

	return false
end

---@param context ulf.log.Context
---@param severity ulf.log.SeverityLevelType
---@param line string
---@return string
function M.colorize(context, severity, line)
	-- local color_name = Severity.colors[severity]
	return Term.color(line, severity.color)
end

---@param s string
---@param len integer
function M.trim(s, len)
	if #s >= len then
		---@type string
		s = s:sub(1, len)
	end

	return s
end

return M
