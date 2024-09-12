---@type ulf.log.config.ConfigOptions
local M = {} ---@diagnostic disable-line: missing-fields

local Util = require("ulf.log.util")
local Severity = require("ulf.log.severity")
local _table = require("ulf.log.util.table")
local fs = require("ulf.log.util.fs")
local tbl_deep_extend = _table.tbl_deep_extend

---@class ulf.log.config.LogWriterBase
---@field severity ulf.log.SeverityLevelType
---@field enabled boolean
---@field name string
---@field async boolean

---@class ulf.log.config.LogWriterStdout:ulf.log.config.LogWriterBase

---@class ulf.log.config.LogWriterFs:ulf.log.config.LogWriterBase
---@field leave_fd_open boolean
---@field logfile? string|fun(...):string

---@class ulf.log.config.LogWriters
---@field stdout ulf.log.config.LogWriterStdout
---@field fs ulf.log.config.LogWriterFs
--- field default string

---@class ulf.log.config.LoggerWriterSettings
---@field enabled boolean
---@field severity ulf.log.SeverityLevelType

---@class ulf.log.config.DefaultLoggerOptions
---@field writer {[string]:ulf.log.config.LoggerWriterSettings}
---@field enabled boolean

---@class ulf.log.config.Logger
---@field icon string
---@field writer? {[string]:ulf.log.config.LoggerWriterSettings|boolean}
---@field name string
---@field enabled boolean

---@class ulf.log.config.GlobalConfigOptions
---@field severity ulf.log.SeverityLevelType
---@field default_writer string
---@field default_logger string

---@class ulf.log.config.LineFormatterOptions
---@field app_name_maxlen integer
---@field context_name_maxlen integer
---@field logger_name_maxlen integer
---@field max_length integer
---
---
---@class ulf.log.config.FormatterOptions
---@field line ulf.log.config.LineFormatterOptions

---@class ulf.log.config.ConfigOptions
local options = {}

---@class ulf.log.config.ConfigOptionsBase
---@field global ulf.log.config.GlobalConfigOptions
---@field default_writer ulf.log.config.LogWriterBase
---@field writer ulf.log.config.LogWriters
---@field format? {logger:{name_maxlen:number}}
---@field formatter? ulf.log.config.FormatterOptions

---@class ulf.log.config.ConfigOptionsSetup:ulf.log.config.ConfigOptionsBase

---@class ulf.log.config.ConfigOptions:ulf.log.config.ConfigOptionsBase
---@field logger? ulf.log.config.Logger[]
local _defaults = {}

---@type ulf.log.config.LogWriters
_defaults.writer = {
	fs = {
		-- TODO: better default when not using neovim
		-- logfile = function(app_name, config)
		-- 	return Util.joinpath(Util.stdpath("data") --[[@as string]], "ulf", "log", app_name)
		-- end,
		enabled = true,
		severity = Severity.levels.DEBUG,
		leave_fd_open = false,
	},

	stdout = {
		enabled = true,
		severity = Severity.levels.DEBUG,
	},
}

---@type ulf.log.config.GlobalConfigOptions
_defaults.global = {
	severity = Severity.levels.ERROR,
	default_logger = "default",
	default_writer = "stdout",
}

---@type ulf.log.config.FormatterOptions
_defaults.formatter = {
	line = {
		app_name_maxlen = 10,
		context_name_maxlen = 4,
		logger_name_maxlen = 7,
		max_length = 400,
	},
}

---@type ulf.log.config.DefaultLoggerOptions
_defaults.logger_options = {
	enabled = true,
	writer = {
		fs = { severity = Severity.levels.DEBUG, enabled = true },
		stdout = { severity = Severity.levels.ERROR, enabled = true },
	},
}

---@class ulf.log.config.DefaultLogger:ulf.log.config.DefaultLoggerOptions
_defaults.logger = {
	name = "default",
	icon = "󱔜 ",
	enabled = true,
}

local ObjectAccessors = {
	---@return ulf.log.config.LogWriters
	writer = _defaults.writer,
	---@return ulf.log.config.GlobalConfigOptions
	global = _defaults.global,
	---@return ulf.log.config.FormatterOptions
	formatter = _defaults.formatter,
	---@return ulf.log.config.DefaultLoggerOptions
	logger_options = _defaults.logger_options,
	---@return ulf.log.config.DefaultLogger
	logger = function()
		return tbl_deep_extend("force", _defaults.logger, _defaults.logger_options)
	end,
}

---@type ulf.log.config.ConfigOptions
setmetatable(M, {
	__index = function(_, k)
		local accessor = ObjectAccessors[k]
		if accessor then
			if type(accessor) == "function" then
				return accessor()
			end
			return accessor
		end
	end,
})

-- M.defaults = _defaults
return M
