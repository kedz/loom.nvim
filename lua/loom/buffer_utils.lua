local M = {}

M.create_buffer = function(name)
	-- TODO test a default name.
	-- TODO make filetype an option..
	local buffer = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_buf_set_name(buffer, name)
	vim.api.nvim_set_option_value("filetype", "md", { buf = buffer })
	return buffer
end

M.get_buffer_text = function(buffer_number)
	buffer_number = buffer_number or vim.fn.winbufnr(0)
	local lines = vim.api.nvim_buf_get_lines(buffer_number, 0, -1, false)
	return table.concat(lines, "\n")
end

return M
