local M = {}

---@type {[string]:ulf.log.IWriter}
local writer_classes = setmetatable({}, {
	__index = function(t, k)
		local ok, mod = pcall(require, "ulf.log.writer." .. k) ---@diagnostic disable-line: no-unknown
		if ok then
			-- rawset(t, k, mod)
			return mod
		end
	end,
})

---@type {[string]:{[string]:ulf.log.IWriter}}
local _instances = {}

---@param logger ulf.log.Logger
---@param kind string
---@return ulf.log.IWriter
function M.get_writer(logger, kind)
	local app = logger.name
	local app_writers = _instances[app] or {}
	local writer_instance = app_writers[kind]

	if not writer_instance then
		local writer_class = writer_classes[kind]
		if writer_class then
			writer_instance = writer_class.new(logger)
			app_writers[kind] = writer_instance
		end
	end

	return writer_instance
end

---

---@param logger ulf.log.Logger
---@param context ulf.log.Context
---@param severity integer
---@param record ulf.log.Record
function M.dispatch(logger, context, severity, record)
	for key, writer_config in pairs(logger.writer) do ---@diagnostic disable-line: no-unknown
		---@type ulf.log.IWriter
		local w = M.get_writer(logger, key)
		if not w then
			print(string.format("M.dispatch: skipping invalid writer %s", key))
		else
			if severity >= writer_config.level and writer_config.enabled then
				w:write(context, severity, record)
			end
		end
	end
end

return M
