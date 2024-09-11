---@class spec.fixtures.modules.testapp1.config
local M = {}
local Severity = require("ulf.log.severity")

M.logging_defaults = {

	logger = {
		{
			name = "testapp2",
			icon = "󰀻 ",
			enabled = true,
		},
	},
}

return M
