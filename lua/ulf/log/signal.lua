local uv = require("luv")

local SignalHandler = {
	handlers = {}, -- Store handlers for each signal
}

-- Register a signal handler
---@param signal string The signal to register a handler for (e.g., "sigint", "sigterm")
---@param handler function The handler function to call when the signal is received
function SignalHandler.register(signal, handler)
	-- Ensure there's a list of handlers for this signal
	if not SignalHandler.handlers[signal] then
		SignalHandler.handlers[signal] = {}

		-- Create the signal handler in luv the first time
		local signal_handle = uv.new_signal()
		uv.signal_start(signal_handle, signal, function()
			-- Call all registered handlers when the signal is received
			for _, h in ipairs(SignalHandler.handlers[signal]) do
				P("exxecuting signal handler", signal)
				h()
			end
		end)
	end

	-- Add the new handler to the list of handlers for this signal
	table.insert(SignalHandler.handlers[signal], handler)
end

return SignalHandler
