---@class ulf.log.util
local M = {}

local mods = {
	table = require("ulf.log.util.table"),
	log = require("ulf.log.util.log"),
	fs = require("ulf.log.util.fs"),
}

setmetatable(M, {
	__index = function(t, k)
		---@type any
		local v
		for _, mod in pairs(mods) do
			---@type any
			v = mod[k]
			if v then
				rawset(t, k, v)
				return v
			end
		end
	end,
})

return M
