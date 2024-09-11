local fs = require("ulf.log.util.fs")

local uv = vim and vim.uv or require("luv")

---@class ulf.log.FSWriter:ulf.log.IWriter
---@field logger ulf.log.Logger
---@field _ {fd:integer}
local Writer = {
	---@type {[string]:string}
	_logfiles = {},
}

---comment
---@param logger ulf.log.Logger
function Writer.new(logger)
	local self = setmetatable({}, { __index = Writer })
	self.logger = logger
	self.leave_fd_open = logger.app.config.writer.fs.leave_fd_open

	self:ensure_logdir()

	self._ = setmetatable({}, {
		---comment
		---@param t ulf.log.FSWriter
		---@param k string
		---@return integer
		__index = function(t, k)
			if k == "fd" then
				local fd = self:open_logfile()
				if self.leave_fd_open then
					rawset(t, "fd", fd)
				end
				return fd
			end
		end,
	})
	if self.leave_fd_open then
		local signal_handle = uv.new_signal()
		uv.signal_start(signal_handle, "sigterm", function()
			self:close_logfile()
			uv.signal_stop(signal_handle)
			os.exit(0)
		end)

		-- Signal.register("SIGTERM", function()
		-- 	uv.fs_close(self.fd)
		-- end)
	end
	return self
end

function Writer:ensure_logdir()
	local dir = fs.dirname(self.logger.app.config.writer.fs.logfile --[[@as string]])
	local stat = uv.fs_stat(dir)
	if not stat then
		uv.fs_mkdir(dir, 448, function(err)
			if err then
				error(err)
			end
		end)
	end
end

---comment
function Writer:open_logfile()
	local fd, err = uv.fs_open(self.logger.app.config.writer.fs.logfile, "a+", 438)
	-- --- TODO: better error handling
	if err then
		error(err)
	end
	--
	return fd
end

function Writer:close_logfile()
	assert(uv.fs_close(self._.fd))
end

---@param context ulf.log.Context
---@param severity integer
---@param record ulf.log.Record
function Writer:write(context, severity, record)
	if type(record) ~= "table" then
		return
	end

	local data = record:line(require("ulf.log.format").formatter)
	uv.fs_write(self._.fd, data .. "\n", function(err, bytes)
		assert(err == nil)
		assert(bytes > 0)
	end)
	if not self.leave_fd_open then
		self:close_logfile()
	end
	-- ---@type any
	-- local data
	-- ---@diagnostic disable-next-line
	-- uva.write(self.fd, msg .. "\n")
	-- 	:on("error", function(err)
	-- 		error(err)
	-- 	end)
	-- 	:wait()
	-- return data
end

return Writer
