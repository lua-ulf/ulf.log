# ULF.log

`ulf.log` is a logger module for Luajit and Neovim.

## Key Features

- Supports multiple applications
- No other dependencies besides `libuv`
- Logging destinations:
  - Terminal
  - Logfile
  - Neovim (not finished)
  - Busted integration (not finished)

## Usage

```lua

---@class ulf.log.ConfigOptions
local config = {

 logger = {
  {
   name = "testapp1",
   icon = "󰀻 ",
   enabled = true,
  },
 },
}

require("ulf.log").register("testapp1", config)
local Logger = require("testapp1.logger")

-- use the default logger
Logger.info("A log message")

-- use the testapp1 logger
Logger:get("testapp1").info("A log message")
```

## TODO

- Documentation
