---@diagnostic disable:lowercase-global

rockspec_format = "3.0"
package = "ulf.log"
version = "scm-1"
source = {
	url = "https://github.com/lua-ulf/ulf.log/archive/refs/tags/scm-1.zip",
}

description = {
	summary = "ulf.log is a logger module for Luajit and Neovim.",
	detailed = "ulf.log is a logger module for Luajit and Neovim.",
	labels = { "log", "neovim", "luajit" },
	homepage = "http://github.com/lua-ulf/ulf.log",
	license = "MIT",
}

dependencies = {
	"lua >= 5.1",
}
build = {
	type = "builtin",
	modules = {},
	copy_directories = {},
	platforms = {},
}
test_dependencies = {
	"busted",
	"busted-htest",
	"luacov",
	"luacov-html",
	"luacov-multiple",
	"luacov-console",
	"luafilesystem",
}
test = {
	type = "busted",
}
