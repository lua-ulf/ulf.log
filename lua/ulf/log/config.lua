---@class ulf.log.config.exports
local M = {}

local _table = require("ulf.log.util.table")
local fs = require("ulf.log.util.fs")
local tbl_deep_extend = _table.tbl_deep_extend
local deepcopy = _table.deepcopy

local Severity = require("ulf.log.severity")
local Defaults = require("ulf.log.defaults")

local Config = {}
M.Config = Config

---@class ulf.log.config.Config: ulf.log.config.ConfigOptionsBase
---@field logger {[string]:ulf.log.config.Logger}
---@field writer ulf.log.config.LogWriters
Config = setmetatable(Config, {
	__call = function(t, ...)
		return t:new(...)
	end,
})

---comment
---@param name string
---@param config ulf.log.config.ConfigOptions
---@return ulf.log.config.Config
function Config:new(name, config)
	local obj = {}

	---@type ulf.log.config.Logger[]
	-- local conf_logger = config.logger

	-- config.logger = nil
	---@type ulf.log.config.Config
	local conf = tbl_deep_extend("force", Defaults, config)
	-- P(conf_logger, config.logger)

	---@type {[string]:ulf.log.config.Logger}
	obj.logger = {}
	for _, logger_config in ipairs(config.logger) do
		obj.logger[logger_config.name] = tbl_deep_extend("force", Defaults.logger, logger_config)

		if not obj.logger[logger_config.name].writer.fs then
			obj.logger[logger_config.name].writer.fs = {
				enabled = true,
				level = Severity.levels.DEBUG,
			}
		end

		for writer_name, writer_conf in pairs(obj.logger[logger_config.name].writer) do
			if type(writer_conf) == "boolean" and writer_conf == false then
				obj.logger[logger_config.name].writer[writer_name] = nil
			end
		end
	end
	obj.logger.default = tbl_deep_extend("force", {}, Defaults.logger)

	obj.default_writer = conf.default_writer
	obj.writer = deepcopy(conf.writer)
	obj.formatter = deepcopy(conf.formatter)
	obj.format = deepcopy(conf.format)
	obj.global = deepcopy(conf.global)
	if obj.global.default_logger == nil then
		obj.global.default_logger = obj.logger[1].name
	end

	if obj.writer.fs and not obj.writer.fs.logfile then
		local logfile_path = fs.logfile_path(name .. ".log", conf)
		obj.writer.fs.logfile = logfile_path
	end

	Config.reindex(obj)
	Config.ensure_logdir(obj)

	self.__index = self
	return setmetatable(obj, self)
end

-- ---@type table<string,any>
local ConfigAccessors = {
	---@param t ulf.log.config.ConfigOptions
	---@return ulf.log.config.LogWriterBase
	default_writer = function(t)
		return t.writer[t.global.default_writer]
	end,
}

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
--
-- ---@param conf ulf.log.config.ConfigOptions
function Config.reindex(self)
	local max_len = 0
	for i, logger in pairs(self.logger) do
		-- self.logger[i].app_name = self.global.app_name
		if not logger.writer then
			self.logger[i].writer = {
				[self.global.default_writer] = {
					---@type integer
					level = self.writer[self.global.default_writer].level,
					enabled = true,
					async = self.writer[self.global.default_writer].async,
				},
			}
		else
			for writer_name, writer_config in pairs(logger.writer) do
				self.logger[i].writer[writer_name].async = self.writer[writer_name].async
				if type(writer_config.enabled) ~= "boolean" then
					---@type boolean
					self.logger[i].writer[writer_name].enabled = true
				end
			end
		end

		ConfigAccessors[logger.name] = logger
		if #logger.name > max_len then
			max_len = #logger.name
		end
	end
	self.format.logger.name_maxlen = max_len
end

return M
