---@class ulf.log.client
return setmetatable({}, {
	__class = "ulf.log.client",
	__call = function(t, name, config)
		return require("ulf.log.manager").register(name, config)
	end,
})
