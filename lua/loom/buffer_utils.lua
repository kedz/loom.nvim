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
	local buffer_number = buffer_number or vim.fn.winbufnr(0)
	local lines = vim.api.nvim_buf_get_lines(buffer_number, 0, -1, false)
	return table.concat(lines, "\n")
end

M.insert_buffer_lines = function(buffer_number, line, col, replacement_lines)
	local lines = vim.api.nvim_buf_get_lines(buffer_number, 0, -1, false)
	local line_to_insert = lines[line]
	local repl_lines = M.str_insert_lines(line_to_insert, col, replacement_lines)
end



M.open_buffer_in_window = function(buffer)
	-- TODO Add options to control how this is opened.
    vim.cmd.vsplit()
	local window = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(window, buffer)

end

return M
