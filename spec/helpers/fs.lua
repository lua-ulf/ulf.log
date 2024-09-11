local M = {}
local uv = vim and vim.uv or require("luv")
function M.rm(path)
	local res, err = uv.fs_unlink(path)
	assert(res)
	assert(err == nil)
end

-- Function to get the git root directory
---@return string|nil
function M.git_root()
	---@type string
	local git_root
	---@type file*
	local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
	if handle then
		---@type string
		git_root = handle:read("*a"):gsub("\n", "")
		handle:close()
	end
	return git_root
end

return M
