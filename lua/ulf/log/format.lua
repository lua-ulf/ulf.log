---@class ulf.log.format.exports
local M = {}

local log_util = require("ulf.log.util.log")
local trim = log_util.trim

---@type ulf.log.Inspect
local Inspect = require("ulf.log.inspect")

---@alias ulf.log.record_column_formatters {[string]:fun(rec:ulf.log.Record,opts:ulf.log.FormatterOptions?):string}
---@alias ulf.log.record_line_formatter fun(rec:ulf.log.Record,formatter:ulf.log.Formatter,opts:ulf.log.format.exports?):string
---
---@class ulf.log.Formatter
---@field column ulf.log.record_column_formatters
---@field line ulf.log.record_line_formatter
M.formatter = {
	---@type ulf.log.record_column_formatters
	column = {},
}

M.formatter.column.timestamp = function(rec)
	return tostring(rec.timestamp) .. " "
end

M.formatter.column.severity = function(rec)
	return string.format("%-2s %-5s ", rec.severity.icon, rec.severity.name)
end

M.formatter.column.app_name = function(rec, opts)
	return string.format("[%-" .. opts.line.app_name_maxlen .. "s", rec.app_name:upper())
end

M.formatter.column.context = function(rec, opts)
	return string.format("%-" .. opts.line.context_name_maxlen .. "s ", rec.context.name:upper())
end

M.formatter.column.logger = function(rec, opts)
	return string.format("%-2s %-" .. opts.line.logger_name_maxlen .. "s] ", rec.logger.icon, rec.logger.name)
end

M.formatter.column.message = function(rec)
	return rec.message .. " "
end

M.formatter.column.data = function(rec, opts)
	local lines = {}

	local fmt_data = function(v)
		---@type string
		local data
		if type(v) == "string" then
			data = v
		else
			data = Inspect(v)
		end
		if not rec.context.multi_line_output then
			---@type string
			data = data:gsub("\n", ""):gsub("%s+", " ")
		end
		return data
	end

	for i = 1, #rec.data do
		local v = rec.data[i]
		---@type string
		lines[#lines + 1] = "[" .. tostring(i) .. " (" .. type(v) .. ") " .. fmt_data(v) .. "]"
	end
	local line = table.concat(lines, " ")
	return trim(line, opts.line.max_length)
end

M.formatter.column.debug_info = function(rec)
	return string.format("{ %s }", rec.debug_info.short_src)
end

---@alias ulf.log.format_line_opts {field:ulf.log.RecordFieldOptions,formatter:ulf.log.FormatterOptions}
---comment
---@param rec ulf.log.Record
---@param formatter ulf.log.Formatter
---@param opts ulf.log.format_line_opts
---@return string
M.formatter.line = function(rec, formatter, opts)
	---@type string[]
	local columns = {}
	for _, field in ipairs(opts.field.order) do
		if formatter.column[field] then
			columns[#columns + 1] = formatter.column[field](rec, opts.formatter)
		end
	end

	return table.concat(columns, "")
end

return M
