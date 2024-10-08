---@meta
---
---@class ulf.log.IWriter
---@field write fun(self:ulf.log.IWriter,context:ulf.log.Context,severity:ulf.log.SeverityLevelType,data:ulf.log.Record)
---@field new fun(logger:ulf.log.Logger):ulf.log.IWriter

---@class ulf.ILogger
---@field trace fun(...)
---@field debug fun(...)
---@field info fun(...)
---@field warn fun(...)
---@field error fun(...)
---@field log fun(...)
---@field trace_ml fun(...)
---@field debug_ml fun(...)
---@field info_ml fun(...)
---@field warn_ml fun(...)
---@field error_ml fun(...)
---@field log_ml fun(...)
---@field trace_fmt fun(...)
---@field debug_fmt fun(...)
---@field info_fmt fun(...)
---@field warn_fmt fun(...)
---@field error_fmt fun(...)
---@field log_fmt fun(...)

---
---@class ulf.IDebugInfo
---@field linedefined integer
---@field short_src string
---@field source string
---@field what string
---
---
---@class ulf.ILoggerContextOptions
---@field name string
---@field enabled boolean

---
---@class ulf.ILogManager:ulf.ILogger
---@field default_logger fun():ulf.ILogger
---@field get fun(name:string, context:ulf.ILoggerContextOptions?):ulf.ILogger
