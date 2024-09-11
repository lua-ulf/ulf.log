---@class testapp1.log
---@field Logger ulf.ILogManager
return setmetatable({}, {
	__index = function(t, k)
		require("ulf.log").register("testapp1", require("testapp1.config").logging_defaults)
		---@type ulf.ILogManager
		local Logger = require("testapp1.logger")
		rawset(t, k, Logger)
		setmetatable(t, nil)
		return Logger
	end,
})
