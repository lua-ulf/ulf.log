local Util = require("ulf.log.util")

---@class ulf.log.StdoutWriter:ulf.log.IWriter
local Writer = {}

---comment
---@param logger ulf.log.Logger
function Writer.new(logger)
	local self = setmetatable({}, { __index = Writer })
	self.logger = logger
	return self
end

---@param context ulf.log.Context
---@param severity integer
---@param record ulf.log.Record
function Writer:write(context, severity, record)
	local data = record:line(require("ulf.log.format").formatter)
	data = Util.colorize(context, severity, data)
	io.write(data .. "\n")
	io.flush()
end

return Writer
