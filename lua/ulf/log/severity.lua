---@class ulf.log.Severity
---@field levels {['TRACE']:0,['DEBUG']:1,['INFO']:2,['WARN']:3,['ERROR']:4,['OFF']:5 }
---@field names {[0]:'TRACE',[1]:'DEBUG',[2]:'INFO',[3]:'WARN',[4]:'ERROR',[5]:'OFF' }
---@field colors {[0]:string,[1]:string,[2]:string,[3]:string,[4]:string,[5]:string}
---@field icons {[0]:string,[1]:string,[2]:string,[3]:string,[4]:string,[5]:string}
return {
	levels = {
		TRACE = 0,
		DEBUG = 1,
		INFO = 2,
		WARN = 3,
		ERROR = 4,
		OFF = 5,
	},
	names = {
		[0] = "TRACE",
		[1] = "DEBUG",
		[2] = "INFO",
		[3] = "WARN",
		[4] = "ERROR",
		[5] = "OFF",
	},
	colors = {
		[0] = "blue",
		[1] = "blue",
		[2] = "green",
		[3] = "yellow",
		[4] = "red",
		[5] = "white",
	},
	icons = {

		[0] = " ",
		[1] = " ",
		[2] = " ",
		[3] = " ",
		[4] = " ",
		[5] = "  ",
	},

	-- level = {
	-- 	trace = 0,
	-- 	debug = 1,
	-- 	info = 2,
	-- 	warn = 3,
	-- 	error = 4,
	-- 	off = 5,
	-- },
	-- name = {
	-- 	[0] = "trace",
	-- 	[1] = "debug",
	-- 	[2] = "info",
	-- 	[3] = "warn",
	-- 	[4] = "error",
	-- 	[5] = "off",
	-- },
}
