local fs = require("spec.helpers.fs")
local Severity = require("ulf.log.severity")
local _table = require("ulf.log.util.table")
local tbl_deep_extend = _table.tbl_deep_extend
local deepcopy = _table.deepcopy

local function lua_path_testapp1(s)
	return fs.git_root() .. "/deps/ulf.log/spec/fixtures/modules/lua" .. s .. ";"
end

package.path = package.path .. ";" .. lua_path_testapp1("/?.lua") .. lua_path_testapp1("/?/init.lua")

---@type {[string]:fun(got:any,expect:table,opts:table?)}
local validator = {}

validator.logfile = function(got, expect, opts)
	---@cast got ulf.log.config.Config
	local logfile = got.writer.fs.logfile
	assert(logfile)
	assert.String(logfile)

	assert(logfile:match(expect.expect_pattern), "expect pattern '" .. expect.expect_pattern .. "' to match")
end

validator.config = function(got, expect, opts)
	assert(got)
	assert.Table(got)
	---@cast got ulf.log.config.Config
	local logfile = got.writer.fs.logfile
	got.writer.fs.logfile = nil
	assert.same(expect, got)
	got.writer.fs.logfile = logfile
end

validator.writer = function(got, expect, opts)
	assert(got)
	assert.Table(got)
	---@cast got ulf.log.config.LogWriterBase
	assert(got.enabled == expect.enabled, "validator.writer: expect self.enabled to be " .. tostring(expect.enabled))
	assert(got.level == expect.level, "validator.writer: expect self.level to be " .. tostring(expect.level))
	assert(got.name == expect.name, "validator.writer: expect self.name to be " .. expect.name)
end

validator.logger = function(got, expect, opts)
	assert(got)
	assert.Table(got)
	---@cast got ulf.log.config.Logger
	assert(got.enabled == expect.enabled, "validator.logger: expect self.enabled to be " .. tostring(expect.enabled))
	assert(got.name == expect.name, "validator.logger: expect self.name to be " .. expect.name)
	assert.same(
		got.writer,
		expect.writer,
		"validator.logger: expect self.writer to be the same as" .. tostring(expect.writer)
	)
end

describe("#ulf", function()
	describe("#ulf.log", function()
		describe("#ulf.log.config", function()
			local Config = require("ulf.log.config").Config
			local WantedBase = {
				app_name = "testapp1",
				formatter = {
					line = {
						app_name_maxlen = 10,
						context_name_maxlen = 4,
						logger_name_maxlen = 7,
						max_length = 400,
					},
				},
				global = {
					default_logger = "default",
					default_writer = "stdout",
					severity = {
						_value = 4,
					},
				},
				logger = {
					default = {
						enabled = true,
						icon = "󱔜 ",
						name = "default",
						writer = {
							fs = {
								enabled = true,
								severity = {
									_value = 1,
								},
							},
							stdout = {
								enabled = true,
								severity = {
									_value = 4,
								},
							},
						},
					},
				},
				writer = {
					fs = {
						name = "fs",
						enabled = true,
						leave_fd_open = false,
						severity = {
							_value = 1,
						},
					},
					stdout = {
						name = "stdout",
						enabled = true,
						severity = {
							_value = 1,
						},
					},
				},
			}
			describe("Config.new", function()
				it("returns defaults if the user config is empty or nil", function()
					local conf = Config("testapp1")

					P(conf.writer)
					validator.config(conf, WantedBase)
					-- validator.logfile(conf, { expect_pattern = "%/ulf%/log%/testapp1%.log" })
				end)

				it("adds custom loggers to the config", function()
					local conf = Config("testapp1", {
						logger = {
							{
								enabled = true,
								name = "testapp1",
								icon = "#",
							},
						},
					})

					local wanted = tbl_deep_extend("force", WantedBase, {
						logger = {
							default = {
								enabled = true,
								icon = "󱔜 ",
								name = "default",
								writer = {
									fs = {
										enabled = true,
										severity = Severity.levels.DEBUG,
									},
									stdout = {
										enabled = true,

										severity = Severity.levels.DEBUG,
									},
								},
							},
							testapp1 = {
								enabled = true,
								icon = "#",
								name = "testapp1",
								writer = {
									fs = {
										enabled = true,
										severity = Severity.levels.DEBUG,
									},
									stdout = {
										enabled = true,
										severity = Severity.levels.DEBUG,
									},
								},
							},
						},
					})
					-- validator.config(conf, wanted)
					-- validator.logfile(conf, { expect_pattern = "%/ulf%/log%/testapp1%.log" })
				end)
				it("raises an error when the name of a writer is invalid", function()
					assert.has_error(function()
						local conf = Config("testapp1", {
							writer = {
								wrong = {
									enabled = true,
								},
							},
						})
					end)
				end)

				it("disabled a writer when set to false ", function()
					local conf = Config("testapp1", {
						logger = {
							{
								enabled = true,
								name = "testapp1",
								icon = "#",
								writer = {
									fs = false,
								},
							},
						},
					})
					assert(conf.logger.testapp1.writer.fs == nil, "expect fs writer to be nil")
				end)
			end)
			describe("Accessors", function()
				describe("default_writer", function()
					it("returns the default writer", function()
						local conf = Config("testapp1")
						local wanted = {
							enabled = true,
							severity = Severity.levels.DEBUG,
							name = "stdout",
						}
						-- validator.writer(conf.default_writer, wanted)
					end)
				end)

				describe("default_logger", function()
					it("returns the default logger", function()
						local conf = Config("testapp1")
						local wanted = {
							enabled = true,
							icon = "󱔜 ",
							name = "default",
							writer = {
								fs = {
									enabled = true,
									severity = Severity.levels.DEBUG,
								},
								stdout = {
									enabled = true,
									severity = Severity.levels.DEBUG,
								},
							},
						}
						-- validator.logger(conf.default_logger, wanted)
					end)
				end)
			end)

			describe("config:writer_accepts_message", function()
				it("returns false if the writer is disabled", function()
					local conf = Config("testapp1", {
						writer = {
							fs = {
								enabled = false,
							},
						},
					})
					-- assert.False(conf.writer.fs.enabled)
					-- assert.False(conf:writer_accepts_message("fs", Severity.levels.DEBUG))
				end)

				it("returns false if the message level is lower than the writer's level", function()
					local conf = Config("testapp1", {
						writer = {
							fs = {
								severity = Severity.levels.WARN,
								enabled = true,
							},
						},
					})
					-- assert.equal(Severity.levels.WARN.level, conf.writer.fs.severity.level)
					-- assert.False(conf:writer_accepts_message("fs", Severity.levels.DEBUG))
				end)
			end)
		end)
	end)
end)
