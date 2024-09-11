package.path = package.path .. ";" .. "/Users/al/config/nvim/lua/?.lua;" .. "/Users/al/config/nvim/lua/?/init.lua"
package.path = package.path .. ";" .. os.getenv("PWD") .. "/../?.lua;" .. os.getenv("PWD") .. "/../?/init.lua"
local Busted = require("corevim.core.busted")
Busted.project_init()

-- local TestSuite = {}
-- _G.TestSuite = TestSuite
-- _G.inspect = require("spec.helpers.inspect")
--
-- function _G.P(v)
-- 	print("============ test debug ===========")
-- 	print(_G.inspect(v))
-- end
