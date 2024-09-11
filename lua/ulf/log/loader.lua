local deepcopy = require("ulf.log.util.table").deepcopy

---comment
---@return function[]
local loaders = function()
	return package.loaders or package.searchers
end

---comment
---@param root_module string
---@param config table
---@param load_path any
---@return fun(name:string):any
local make_loader = function(root_module, config, load_path)
	if load_path == nil then
		load_path = package.path
	end

	---comment
	---@param mod_name string
	---@param _config any
	---@return ulf.log.Manager
	local handler = function(mod_name, _config)
		local p = package.searchpath("ulf.log.client", package.path)

		---@type fun(app:string,config:ulf.log.config.ConfigOptions):ulf.log.Manager
		local v = loadfile(p)()

		---@type string
		local name = mod_name:match("(.*)%.logger")

		local client = deepcopy(v(name, _config))
		return client
	end

	---@param name string
	---@return ulf.log.Manager
	return function(name)
		if name:match("^" .. root_module .. "%.logger") then
			return handler(name, config)
		end
	end
end

---@type {[string]:function}
local registered_handlers = {}

---comment
---@param root_module string
---@param config table
---@param pos? integer
---@return boolean
local register = function(root_module, config, pos)
	if pos == nil then
		pos = 2
	end

	assert(root_module, "missing root_module")
	assert(config, "missing config")

	local loader_fn = make_loader(root_module, config)
	---@type function
	local wrapped_loader
	wrapped_loader = function(name)
		local res, err = loader_fn(name) ---@diagnostic disable-line: no-unknown
		if res ~= nil then
			return function()
				return res
			end
		else
			return err or ("could not load `" .. tostring(name) .. ".logger`")
		end
	end
	table.insert(loaders(), pos, wrapped_loader)
	registered_handlers[root_module] = wrapped_loader
	return true
end

---comment
---@param root_module string
---@return boolean?
---@return string?
local unregister = function(root_module)
	local loader_fn = registered_handlers[root_module]
	if not loader_fn then
		return nil, "can't find existing loader `" .. tostring(root_module) .. "`"
	end
	for i, l in pairs(loaders()) do
		if l == loader_fn then
			table.remove(loaders(), i)
			return true
		end
	end
	return nil, "loader `" .. tostring(root_module) .. "` is no longer in searchers"
end

---comment
---@param ext string
---@return boolean
local is_registered = function(ext)
	return not not registered_handlers[ext]
end
return {
	register = register,
	unregister = unregister,
	is_registered = is_registered,
	make_loader = make_loader,
	_registered_handlers = registered_handlers,
}
