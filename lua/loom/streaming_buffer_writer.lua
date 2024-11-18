local Util = require("loom.util")

-- TODO(kedz): Follow standard practices for defining classes in Lua.
local StreamingBufferWriter = {}

StreamingBufferWriter.new = function(buffer, lm_request, opts)
	local obj = {}
	obj.buffer = buffer
	obj.lm_request = lm_request
	obj.line = 0 -- TODO(kedz): Allow specifying line in opts.
	obj.col = 0 -- TODO(kedz): Allow specifying column in opts.
	obj.index = 0
	-- TODO(kedz): Add validation of arguments.
    -- TODO(kedz): Add exception handling.

	obj.next_write = function(self)
		self.index = self.index + 1
		local next_text_unsafe = self.lm_request.response_strings[self.index]
        local write_position = Util.buffer.insert_text(self.buffer, self.line, self.col, next_text_unsafe)
        self.line = write_position.line
        self.col = write_position.column
	end

	return obj
end

return StreamingBufferWriter
