local Util = require("ulf.log.util")
local Severity = require("ulf.log.severity")

---@class ulf.log.config.LogWriterBase
---@field level integer
---@field enabled boolean
---@field async boolean

---@class ulf.log.config.LogWriterStdout:ulf.log.config.LogWriterBase

---@class ulf.log.config.LogWriterFs:ulf.log.config.LogWriterBase
---@field leave_fd_open boolean
---@field logfile? string|fun(...):string

---@class ulf.log.config.LogWriters
---@field stdout ulf.log.config.LogWriterStdout
---@field fs ulf.log.config.LogWriterFs
--- field default string

---@class ulf.log.config.Logger
---@field icon string
---@field writer? table<string,{level:integer,enabled:boolean}>
---@field name string
---@field enabled boolean

---@class ulf.log.config.GlobalConfigOptions
---@field level string
---@field default_writer string
---@field default_logger string

---@class ulf.log.config.ConfigOptions
local options

---@class ulf.log.config.ConfigOptionsBase
---@field global ulf.log.config.GlobalConfigOptions
---@field default_writer ulf.log.config.LogWriterBase
---@field writer ulf.log.config.LogWriters
---@field format? {logger:{name_maxlen:number}}
---@field formatter? ulf.log.FormatterOptions

---@class ulf.log.config.ConfigOptionsSetup:ulf.log.config.ConfigOptionsBase

---@class ulf.log.config.ConfigOptions:ulf.log.config.ConfigOptionsBase
---@field logger ulf.log.config.Logger[]
local defaults = {

	---@type ulf.log.config.LogWriters
	writer = {
		fs = {
			-- TODO: better default when not using neovim
			-- logfile = function(app_name, config)
			-- 	return Util.joinpath(Util.stdpath("data") --[[@as string]], "ulf", "log", app_name)
			-- end,
			enabled = true,
			level = Severity.levels.DEBUG,
			async = false,
			leave_fd_open = false,
		},

		stdout = {
			enabled = true,
			level = Severity.levels.DEBUG,
			async = false,
		},

		default = "stdout",
	},
	format = {
		logger = {
			name_maxlen = 5,
		},
	},
}

defaults.global = {
	level = "info",
	default_logger = "default",
	default_writer = "stdout",
}
---@class ulf.log.FormatterOptions
defaults.formatter = {
	line = {
		app_name_maxlen = 10,
		context_name_maxlen = 4,
		logger_name_maxlen = 7,
		max_length = 400,
	},
}

defaults.logger = {
	name = "default",
	icon = "󱔜 ",
	enabled = true,
	writer = {
		fs = { level = Severity.levels.DEBUG },
		stdout = { level = Severity.levels.DEBUG },
	},
}

return defaults
