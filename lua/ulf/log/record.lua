---@class ulf.log.record.exports
local M = {}

local Severity = require("ulf.log.severity")

local Timestamp = {}
M.Timestamp = Timestamp

---@class ulf.log.TimestampOptions

---@class ulf.log.Timestamp:ulf.log.TimestampOptions
---@field year integer
---@field month integer
---@field day integer
---@field hour integer
---@field minute integer
---@field second integer
---@field ms integer
---@overload fun(opts:ulf.log.TimestampOptions?):ulf.log.Timestamp
Timestamp = setmetatable(Timestamp, {
	__call = function(t, ...)
		return t:new(...)
	end,
})

---@param opts? ulf.log.TimestampOptions
---@return ulf.log.Timestamp
function Timestamp:new(opts)
	opts = opts or {}
	local obj = {}

	local date_table = os.date("*t")
	obj.ms = string.match(tostring(os.clock()), "%d%.(%d+)")

	obj.hour, obj.minute, obj.second = date_table.hour, date_table.min, date_table.sec
	obj.year, obj.month, obj.day = date_table.year, date_table.month, date_table.day -- date_table.wday to date_table.day

	self.__index = self
	self.__tostring = self.tostring
	return setmetatable(obj, self)
end

---@return string
function Timestamp:tostring()
	return string.format(
		"%04d-%02d-%02d %02d:%02d:%02d:%06d",
		self.year,
		self.month,
		self.day,
		self.hour,
		self.minute,
		self.second,
		self.ms
	)
end

---@type ulf.log.Record
local Record = {} ---@diagnostic disable-line: missing-fields

M.Record = Record

---@class ulf.log.RecordOptions
---@field severity_name? string
---@field severity_level? integer
---@field severity_icon? string
---@field app_name string
---@field logger_name string
---@field logger ulf.log.Logger
---@field context ulf.log.Context
---@field timestamp? ulf.log.Timestamp
---@field debug_info ulf.IDebugInfo
---@field message string
---@field data table[]

---@class ulf.log.Record
---@field logger ulf.log.Logger
---@field context ulf.log.Context
---@field debug_info ulf.IDebugInfo
---@field timestamp ulf.log.Timestamp
---@field data table[]
---@field message string
---@field app_name string
---@field severity {name:string,icon:string,level:integer}
---@overload fun(opts:ulf.log.RecordOptions):ulf.log.Record
Record = setmetatable(Record, {
	__call = function(t, ...)
		return t:new(...)
	end,
})

---@class ulf.log.RecordFieldOptions
Record.field = {
	order = {
		"timestamp",
		"severity",
		"app_name",
		"context",
		"logger",
		"message",
		"data",
		"debug_info",
	},
	names = {
		severity = true,
	},
}

---@param opts ulf.log.RecordOptions
---@return ulf.log.Record
function Record:new(opts)
	assert(type(opts) == "table", "ulf.log.Record.new opts must be a table")
	local obj = {
		timestamp = Timestamp(),
		severity = {
			level = opts.severity_level,
			icon = opts.severity_icon or Severity.icons[opts.severity_level],
			name = opts.severity_name or Severity.names[opts.severity_level],
		},
		context = opts.context,
		app_name = opts.logger.app.name,
		debug_info = opts.debug_info,
		message = opts.message,
		data = opts.data,
		logger = opts.logger,
	}

	self.__index = self
	return setmetatable(obj, self)
end

---@param formatter ulf.log.Formatter
---@return string
function Record:line(formatter)
	return formatter.line(self, formatter, { formatter = self.logger.app.config.formatter, field = Record.field })
end

return M
