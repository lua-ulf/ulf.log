---@class ulf.log.manager.exports
local M = {}

local Logger = require("ulf.log.logger").Logger
local Config = require("ulf.log.config").Config
local Util = require("ulf.log.util")

local Context = {}

---@class ulf.log.ContextOptions
---@field name string
---@field enabled boolean

--- Logger provides a logging interface with multiple log writers
---@class ulf.log.Context
---@field name string
---@field enabled boolean
---@field debug_info? ulf.IDebugInfo
---@field called_via_test? boolean
---@field is_busted_running? boolean
---@field multi_line_output? boolean
---@overload fun(config:ulf.log.config.Logger):ulf.log.Logger
Context = setmetatable(Context, {
	__call = function(t, ...)
		return t.new(...)
	end,
})

---comment
---@param opts ulf.log.ContextOptions
---@return ulf.log.Context
function Context.new(opts)
	local self = setmetatable({}, { __index = Context })
	opts = opts or {}
	self.name = opts.name or "code"
	self.enabled = opts.enabled or true
	self.multi_line_output = false
	return self
end

---@type {[string]:ulf.log.Manager}
M.apps = {}

local Manager = {
	__name = "Manager",
}

--- Manager represents an application which has multiple
--- loggers
---@class ulf.log.Manager
---@field name string
---@field config ulf.log.config.Config
---@field logger {[string]:ulf.log.Logger}
---@overload fun(app:string,config:ulf.log.config.ConfigOptions):ulf.log.Manager
Manager = setmetatable(Manager, {
	__call = function(t, ...)
		return t.new(...)
	end,
})

---comment
---@param app string
---@param config ulf.log.config.ConfigOptions
function Manager.new(app, config)
	local self = setmetatable({}, {
		__index = function(t, k)
			local v = rawget(t, k) or rawget(Manager, k)
			if v then
				return v
			end

			if Util.is_log_method_name(k) then
				return t:default_logger()[k]
			end
		end,
	})
	self.config = Config:new(app, config)
	self.name = app

	self.logger = setmetatable({}, {
		__index = function(t, k)
			---@type any
			local logger_config = self.config.logger[k]
			if logger_config then
				local logger = Logger.new(self, logger_config)
				rawset(t, k, logger)
				return logger
			end
		end,
	})

	return self
end

function Manager:default_logger()
	return self:get()
end

---@param name? string
---@param context? ulf.log.Context
---@return ulf.ILogger
function Manager:get(name, context)
	context = context or Context(context)
	name = name or self.config.global.default_logger

	local logger = self.logger[name]

	assert(type(logger) == "table", "ulf.log Log.get: invalid logger, name='" .. tostring(name) .. "'")

	return logger:endpoint(context)
end

---@param app string
---@param config ulf.log.config.ConfigOptions
function M.register(app, config)
	local manager = Manager.new(app, config)
	M.apps[app] = manager

	return manager
end

return M
