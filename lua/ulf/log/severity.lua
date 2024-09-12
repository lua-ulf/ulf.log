---@class ulf.log.Severity
---@field levels {TRACE:ulf.log.SeverityLevelType,DEBUG:ulf.log.SeverityLevelType,INFO:ulf.log.SeverityLevelType,WARN:ulf.log.SeverityLevelType,ERROR:ulf.log.SeverityLevelType,OFF:ulf.log.SeverityLevelType }
---@field names {[0]:'TRACE',[1]:'DEBUG',[2]:'INFO',[3]:'WARN',[4]:'ERROR',[5]:'OFF' }
---@field colors {[0]:string,[1]:string,[2]:string,[3]:string,[4]:string,[5]:string}
---@field icons {[0]:string,[1]:string,[2]:string,[3]:string,[4]:string,[5]:string}
local Severity = {}

---@class ulf.log.SeverityLevelType
---@field dynamic_level integer The log level which might be overriden by environment variables
---@field level integer The log level
---@field name string The log level name
---@field icon string The log level icon
---@field color string The log level color

---@param init integer
---@return ulf.log.SeverityLevelType
local function create_severity_level(init)
	local severity_level = {
		_value = init,
	}
	return setmetatable(severity_level, {
		__index = function(t, k)
			local value = rawget(t, "_value")
			if k == "dynamic_level" then
				local env_override = os.getenv("ULF_GLOBAL_LOG_LEVEL")
				return tonumber(env_override) or value
			elseif k == "level" then
				return value
			elseif k == "name" then
				return Severity.names[value]
			elseif k == "icon" then
				return Severity.icons[value]
			elseif k == "color" then
				return Severity.colors[value]
			end
		end,
	})
end

Severity.names = {
	[0] = "TRACE",
	[1] = "DEBUG",
	[2] = "INFO",
	[3] = "WARN",
	[4] = "ERROR",
	[5] = "OFF",
}
Severity.colors = {
	[0] = "blue",
	[1] = "blue",
	[2] = "green",
	[3] = "yellow",
	[4] = "red",
	[5] = "white",
}
Severity.icons = {

	[0] = " ",
	[1] = " ",
	[2] = " ",
	[3] = " ",
	[4] = " ",
	[5] = "  ",
}

Severity.create_severity_level = create_severity_level
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

Severity.levels = {
	TRACE = create_severity_level(0),
	DEBUG = create_severity_level(1),
	INFO = create_severity_level(2),
	WARN = create_severity_level(3),
	ERROR = create_severity_level(4),
	OFF = create_severity_level(5),
}

return Severity
