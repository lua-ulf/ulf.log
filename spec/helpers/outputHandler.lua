return function(options)
	local busted = require("spec.busted_helper")
	local handler = require("busted.outputHandlers.utfTerminal")(options)

	local promiseUnhandledError = {}

	busted.subscribe({ "test", "end" }, function(element, parent)
		while #promiseUnhandledError > 0 do
			local res = table.remove(promiseUnhandledError, 1)
			handler.successesCount = handler.successesCount - 1
			handler.failuresCount = handler.failuresCount + 1
			busted.publish({ "failure", element.descriptor }, element, parent, tostring(res))
		end
	end)

	return handler
end
