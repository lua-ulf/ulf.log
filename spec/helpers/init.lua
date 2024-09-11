local M = {}
local uv = vim and vim.uv or require("luv")
function M.set_timeout(timeout, callback)
	local timer = uv.new_timer()
	timer:start(timeout, 0, function()
		timer:stop()
		timer:close()
		callback()
	end)
	return timer
end

function M.rm(path)
	local res, err = uv.fs_unlink(path)
end

return M
