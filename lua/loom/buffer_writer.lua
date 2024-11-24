local Util = require("loom.util")

local BufferWriterRegistry = {
	active_listeners = {},
	finished_listeners = {},
}

vim.api.nvim_create_autocmd("User", {
	pattern = "LmRequestUpdate",
	callback = function(opts)
		for _, sbw in ipairs(BufferWriterRegistry.active_listeners[opts.data.guid]) do
			sbw:next_write()
		end
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "LmRequestComplete",
	callback = function(opts)
		BufferWriterRegistry.finished_listeners[opts.data.guid] = BufferWriterRegistry.active_listeners[opts.data.guid]
		BufferWriterRegistry.active_listeners[opts.data.guid] = nil
	end,
})

local BufferWriter = {}
-- TODO(kedz): Follow standard practices for defining classes in Lua.

BufferWriter.registry = BufferWriterRegistry

BufferWriter.new = function(buffer, lm_request, opts)
	local obj = {}
	obj.buffer = buffer
	obj.lm_request = lm_request
	obj.line = 0 -- TODO(kedz): Allow specifying line in opts.
	obj.col = 0 -- TODO(kedz): Allow specifying column in opts.
	obj.index = 0
	-- TODO(kedz): Add validation of arguments.
	-- TODO(kedz): Add exception handling.

	if BufferWriterRegistry.active_listeners[lm_request.guid] == nil then
		BufferWriterRegistry.active_listeners[lm_request.guid] = {}
	end
	table.insert(BufferWriterRegistry.active_listeners[lm_request.guid], obj)

	obj.next_write = function(self)
		self.index = self.index + 1
		local next_text_unsafe = self.lm_request.response_strings[self.index]
		local write_position = Util.buffer.insert_text(self.buffer, self.line, self.col, next_text_unsafe)
		self.line = write_position.line
		self.col = write_position.column
	end

	return obj
end

return BufferWriter
