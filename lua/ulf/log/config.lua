---@class ulf.log.config.exports
local M = {}

local _table = require("ulf.log.util.table")
local fs = require("ulf.log.util.fs")
local tbl_deep_extend = _table.tbl_deep_extend
local deepcopy = _table.deepcopy
local tbl_map = _table.tbl_map

local Severity = require("ulf.log.severity")
local Defaults = require("ulf.log.defaults")

---@type ulf.log.config.Config
local Config = {} ---@diagnostic disable-line: missing-fields

---@type ulf.log.config.Config
M.Config = Config

---@class ulf.log.config.Config
---@field app_name string
---@field logger {[string]:ulf.log.config.Logger}
---@field formatter ulf.log.config.FormatterOptions
---@field writer ulf.log.config.LogWriters
---@field global ulf.log.config.GlobalConfigOptions
---@field default_writer ulf.log.config.LogWriterBase
---@field default_logger ulf.log.config.Logger
---@overload fun(name:string,user_config:ulf.log.config.ConfigOptions?):ulf.log.config.Config
Config = setmetatable(Config, {
	__call = function(t, ...)
		---@type ulf.log.config.Config
		return t:new(...)
	end,
})

---@type {[string]:fun(t:ulf.log.config.ConfigOptions):any}
local ConfigAccessors = {

	---@return ulf.log.config.LogWriterBase
	default_writer = function(t)
		return t.writer[t.global.default_writer]
	end,

	---comment
	---@return ulf.log.config.Logger
	default_logger = function(t)
		return t.logger[t.global.default_logger]
	end,
}

---comment
---@param name string
---@param user_config ulf.log.config.ConfigOptions
---@return ulf.log.config.Config
function Config:new(name, user_config)
	user_config = user_config or {}

	---@type ulf.log.config.Config
	local config = { ---@diagnostic disable-line: missing-fields
		app_name = name,
	}

	---@type {[string]:fun(obj:ulf.log.config.Config,user_conf:ulf.log.config.ConfigOptions)}
	local creator = {}

	--- type ulf.log.config.Config
	-- local conf = tbl_deep_extend("force", Defaults, user_config)
	function creator.writer(obj, user_conf)
		user_conf.writer = user_conf.writer or {}
		for key, _ in
			pairs(user_conf.writer --[[@as {[string]:ulf.log.config.LogWriterBase} ]])
		do
			if not Defaults.writer[key] then
				error("invalid writer name '" .. tostring(key) .. "'")
			end
		end

		obj.writer = tbl_deep_extend("force", Defaults.writer, user_conf.writer or {})
		for key, value in
			pairs(obj.writer --[[@as {[string]:ulf.log.config.LogWriterBase} ]])
		do
			---@type string
			obj.writer[key].name = key
		end
	end

	function creator.global(obj, user_conf)
		---@type ulf.log.config.GlobalConfigOptions
		obj.global = tbl_deep_extend("force", Defaults.global, user_conf.global or {})
	end

	function creator.formatter(obj, user_conf)
		---@type ulf.log.config.FormatterOptions
		obj.formatter = tbl_deep_extend("force", Defaults.formatter, user_conf.formatter or {})
	end

	---comment
	function creator.logger(obj, user_conf)
		user_conf.logger = user_conf.logger or {}
		---@type {[string]:ulf.log.config.Logger}
		obj.logger = {}
		for _, logger_config in ipairs(user_conf.logger) do
			obj.logger[logger_config.name] = tbl_deep_extend("force", Defaults.logger, logger_config or {})

			-- TODO: remove enabled field?
			-- either writer is present (enabled) or not (disabled).
			--
			-- disable (delete) a writer when set to false. This results in the
			-- dispatcher not sending to this writer.
			for writer_name, writer_config in pairs(obj.logger[logger_config.name].writer) do
				if not writer_config then
					obj.logger[logger_config.name].writer[writer_name] = nil
				end
			end
		end

		-- user did not provide settings for the default logger
		--
		if not obj.logger.default then
			obj.logger.default = tbl_deep_extend("force", {}, Defaults.logger)
		end
	end

	creator.writer(config, user_config)
	creator.global(config, user_config)
	creator.formatter(config, user_config)
	creator.logger(config, user_config)

	if config.writer.fs and not config.writer.fs.logfile then
		config.writer.fs.logfile = fs.logfile_path(name, config)
	end

	Config.ensure_logdir(config)

	self.__index = function(t, k)
		local v = rawget(t, k) or rawget(Config, k)
		if v then
			return v
		end

		local accessor = ConfigAccessors[k]
		if accessor then
			if type(accessor) == "function" then
				return accessor(t)
			end
		end
	end
	return setmetatable(config, self)
end

function Config.ensure_logdir(conf)
	local basedir_logfile = fs.dirname(conf.writer.fs.logfile)
	local parent_dir_basedir = fs.dirname(basedir_logfile)
	if not fs.dir_exists(parent_dir_basedir) then
		fs.mkdir(parent_dir_basedir)
	end
	if not fs.dir_exists(basedir_logfile) then
		fs.mkdir(basedir_logfile)
	end
end

--- Tests if writer 'name' accepts a message with a given
--- level
--- @param writer_name string
--- @param severity ulf.log.SeverityLevelType
function Config:writer_accepts_message(writer_name, severity)
	---@type ulf.log.config.LogWriterBase
	local writer = self.writer[writer_name]
	if not writer then
		--- TODO: handle error
		return false
	end

	if not writer.enabled then
		return false
	end

	if severity.level < writer.severity.dynamic_level then
		return false
	end

	return true
end

--
-- -- ---@param conf ulf.log.config.ConfigOptions
-- function Config.reindex(self)
-- 	local max_len = 0
-- 	for i, logger in pairs(self.logger) do
-- 		-- self.logger[i].app_name = self.global.app_name
-- 		if not logger.writer then
-- 			self.logger[i].writer = {
-- 				[self.global.default_writer] = {
-- 					---@type integer
-- 					level = self.writer[self.global.default_writer].level,
-- 					enabled = true,
-- 				},
-- 			}
-- 		else
-- 			for writer_name, writer_config in pairs(logger.writer) do
-- 				-- self.logger[i].writer[writer_name].async = self.writer[writer_name].async
-- 				if type(writer_config.enabled) ~= "boolean" then
-- 					---@type boolean
-- 					self.logger[i].writer[writer_name].enabled = true
-- 				end
-- 			end
-- 		end
--
-- 		-- ConfigAccessors[logger.name] = logger
-- 		-- if #logger.name > max_len then
-- 		-- 	max_len = #logger.name
-- 		-- end
-- 	end
-- 	-- self.format.logger.name_maxlen = max_len
-- end

return M
