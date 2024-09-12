local M = {}

local uv = vim and vim.uv or require("luv")

M.is_windows = package.config:find("\\") and true or false
M.pathsep = M.is_windows and "\\" or "/"
M.pathsep_pattern = M.is_windows and [[%\%\]] or "%/"

---@param ... string
---@return string?
function M.joinpath(...)
	return (table.concat({ ... }, M.pathsep):gsub(M.pathsep .. M.pathsep .. "+", M.pathsep))
end

--- @param path string
--- @return string?
function M.basename(path)
	return path:match(".*" .. M.pathsep_pattern .. "(.+)$")
end

--- @param path string
--- @return string?
function M.dirname(path)
	return path:match("(.*)" .. M.pathsep_pattern .. ".+$")
end

--- @param path string
--- @return boolean?
function M.mkdir(path)
	-- 493 is 0755 in decimal
	local err, res = uv.fs_mkdir(path, 493)

	if err and type(err) ~= "boolean" then
		error(err)
	end
	return true
end

---@param path string
function M.rmdir(path)
	assert(uv.fs_rmdir(path))
end

--- @param path string
--- @return boolean?
function M.dir_exists(path)
	local stat = uv.fs_stat(path)

	if not stat then
		return false
	end
	if type(stat) == "table" then
		return stat.type == "directory"
	end
end

--- @param kind "config"|"data"|"cache"|"state"
--- @param ... string
--- @return string?
function M.stdpath(kind, ...)
	---@type string?
	local env_var
	if kind == "config" then
		env_var = "XDG_CONFIG_HOME"
	elseif kind == "data" then
		env_var = "XDG_DATA_HOME"
	elseif kind == "state" then
		env_var = "XDG_STATE_HOME"
	elseif kind == "cache" then
		env_var = "XDG_CACHE_HOME"
	end
	if env_var then
		return M.joinpath(os.getenv(env_var), ...)
	end
end

---comment
---@param app_name string
---@param config ulf.log.config.Config
---@return string
function M.logfile_path(app_name, config)
	return M.joinpath(M.stdpath("data") --[[@as string]], "ulf", "log", app_name .. ".log")
end

return M
