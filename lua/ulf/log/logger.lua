---TODO:
---* make it async
---* replace vim functions with pure Lua functions
---* create rocks

---@class ulf.log.LoggerModule
local M = {}

local Util = require("ulf.log.util")
local Writer = require("ulf.log.writer")
local Record = require("ulf.log.record").Record

M.inspect = require("ulf.log.inspect")

local Logger = {}
M.Logger = Logger

--- Logger provides a logging interface with multiple log writers
---@class ulf.log.Logger:ulf.log.config.Logger
---@field app ulf.log.Manager
---@overload fun(config:ulf.log.config.Logger):ulf.log.Logger
Logger = setmetatable(Logger, {
	__call = function(t, ...)
		return t.new(...)
	end,
})

---comment
---@param app ulf.log.Manager
---@param config ulf.log.config.Logger
---@return ulf.log.Logger
function Logger.new(app, config)
	local self = setmetatable({}, { __index = Logger })
	self.app = app
	self.name = config.name
	self.icon = config.icon
	self.enabled = config.enabled
	self.writer = config.writer
	return self
end

function Logger:endpoint(context)
	local obj = {}

	local methods = {
		trace = 0,
		debug = 1,
		info = 2,
		warn = 3,
		error = 4,
		off = 5,
	}

	obj = setmetatable(obj, {
		__index = function(_, k)
			local method_name = k

			if not Util.is_log_method_name(method_name) then
				error("invalid log method '" .. tostring(method_name) .. "'")
			end

			---@type string
			local meth = method_name:match("(.*)_ml$")
			if methods[meth] then
				method_name = meth
				context.multi_line_output = true
			end

			local log_fn = function(severity, msg, ...)
				---@type ulf.IDebugInfo
				local info = debug.getinfo(2, "nSl") ---@diagnostic disable-line: assign-type-mismatch
				context.is_busted_running = Util.is_busted_running()
				context.called_via_test = Util.called_via_test()
				context.debug_info = info

				if self.enabled then
					local record = Record({
						severity_level = severity,
						app_name = self.app.name,
						context = context,
						logger_name = self.name,
						logger = self,
						debug_info = context.debug_info,
						message = msg,
						data = { ... },
					})

					Writer.dispatch(self, context, severity, record)
				end
			end

			if method_name == "log" then
				return function(severity, msg, ...)
					return log_fn(severity, msg, ...)
				end
			end
			local severity = methods[method_name]
			if type(severity) == "number" then
				return function(msg, ...)
					return log_fn(severity, msg, ...)
				end
			end
		end,
	})

	return obj
end

return M
