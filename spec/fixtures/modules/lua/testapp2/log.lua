---@class testapp2.log
---@field Logger ulf.ILogManager
return setmetatable({}, {
	__index = function(t, k)
		require("ulf.log").register("testapp2", require("testapp1.config").logging_defaults)
		---@type ulf.ILogManager
		local Logger = require("testapp2.logger")
		rawset(t, k, Logger)
		setmetatable(t, nil)
		return Logger
	end,
})
