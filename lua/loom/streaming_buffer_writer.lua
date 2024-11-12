local StringUtils = require("loom.string_utils")

local M = {}

M.new = function(buffer, lm_request, opts)
	local obj = {}
	obj.buffer = buffer
	obj.lm_request = lm_request
	obj.line = 0 -- TODO(kedz) fix this I don't think it works
	obj.col = 1 -- TODO(kedz) this might not work either
	obj.index = 0
	-- TODO add validation.
    -- This will not work if there are lines after the insert line.

	obj.next_write = function(self)
		self.index = self.index + 1
		local next_text_unsafe = self.lm_request.response_strings[self.index]
		local next_text_lines = StringUtils.str_split_lines(next_text_unsafe)
		local line_to_insert = vim.api.nvim_buf_get_lines(self.buffer, self.line, self.line + 1, false)[1]
		local dest_lines = StringUtils.str_insert_lines(line_to_insert, self.col, next_text_lines)
		vim.api.nvim_buf_set_lines(self.buffer, self.line, self.line + #dest_lines, false, dest_lines)
		self.line = self.line + #dest_lines - 1
		self.col = #dest_lines[#dest_lines] - (#line_to_insert - self.col)
		return
	end

	return obj
end

return M
