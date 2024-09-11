local fs = require("spec.helpers.fs")

local function lua_path_testapp1(s)
	return fs.git_root() .. "/spec/fixtures/modules/lua" .. s .. ";"
end

package.path = package.path .. ";" .. lua_path_testapp1("/?.lua") .. lua_path_testapp1("/?/init.lua")

describe("#ulf", function()
	describe("#ulf.log", function()
		describe("LogManager", function()
			---@type ulf.log.Manager
			local LogManager1 = require("testapp1.log").Logger
			---@type ulf.log.Manager
			local LogManager2 = require("testapp2.log").Logger

			-- local LogManager1 = require("testapp1.logger")
			-- ---@type ulf.log.Manager
			-- local LogManager2 = require("testapp2.logger")
			--
			before_each(function() end)

			---comment
			---@param log ulf.ILogger
			---@param data {log_msg:string}
			---@param expect? table
			local function validate_logger(log, data, expect)
				assert.Function(log.trace)
				assert.Function(log.debug)
				assert.Function(log.info)
				assert.Function(log.warn)
				assert.Function(log.error)

				assert.has_no_error(function()
					log.trace(data.log_msg)
					log.debug(data.log_msg)
					log.info(data.log_msg)
					log.warn(data.log_msg)
					log.error(data.log_msg)
				end)
			end

			describe("get", function()
				it("returns a logger", function()
					---@type ulf.ILogger
					local log = LogManager1:get("testapp1")
					validate_logger(log, { log_msg = "test via logger.get" })
				end)
			end)

			describe("default_logger", function()
				it("returns the configured default logger", function()
					local log = LogManager1:default_logger()
					validate_logger(log, { log_msg = "test via logger.default_logger" })
				end)
			end)

			describe("__index", function()
				it("provides logging methods of the default logger", function()
					assert.has_no_error(function()
						LogManager1.trace("test via LogManager.trace")
						LogManager1.debug("test via LogManager.debug")
						LogManager1.info("test via LogManager.info")
						LogManager1.warn("test via LogManager.warn")
						LogManager1.error("test via LogManager.error")
					end)
				end)
			end)

			describe("config", function()
				it("returns the config", function()
					assert.Table(LogManager1.config)
				end)

				describe("config.writer.fs", function()
					it("returns the config for the filesystem writer", function()
						assert.Table(LogManager1.config.writer.fs)
						assert.Table(LogManager2.config.writer.fs)

						local logmanager1_logfile_path = LogManager1.config.writer.fs.logfile
						local logmanager2_logfile_path = LogManager2.config.writer.fs.logfile

						assert(logmanager1_logfile_path)
						assert(logmanager2_logfile_path)

						assert(logmanager1_logfile_path:match("ulf%/log%/testapp1"))
						assert(logmanager2_logfile_path:match("ulf%/log%/testapp2"))

						LogManager1.config.writer.fs.logfile = nil
						LogManager2.config.writer.fs.logfile = nil

						local wanted = {
							enabled = true,
							leave_fd_open = false,
							level = 1,
						}
						assert.same(wanted, LogManager1.config.writer.fs)
						assert.same(wanted, LogManager2.config.writer.fs)
						LogManager1.config.writer.fs.logfile = logmanager1_logfile_path
						LogManager2.config.writer.fs.logfile = logmanager2_logfile_path
					end)
				end)
			end)
			it("returns a logger manager", function()
				assert.equal("testapp1", LogManager1.name)

				assert.Table(LogManager1)
				assert.Table(LogManager1.config)
				assert.Table(LogManager1.config.logger)
				assert.Table(LogManager1.config.logger.testapp1)

				local wanted_logger_config = {
					enabled = true,
					icon = "󰀻 ",
					name = "testapp1",
					writer = {
						fs = {
							enabled = true,
							level = 1,
						},
						stdout = {
							enabled = true,
							level = 1,
						},
					},
				}
				assert.same(wanted_logger_config, LogManager1.config.logger.testapp1)
				local mt = getmetatable(LogManager1)
				assert.Table(mt)
				-- assert.equal("Manager", mt.__name)

				---@type ulf.ILogger
				local log = LogManager1:get("testapp1")
				assert.Table(log)
				log.debug("test")
				-- P(require("ulf.log.loader")._registered_handlers)
				-- assert.Function(log)
			end)
		end)
	end)
end)
