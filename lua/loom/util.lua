local Util = {}

-- Table Utilities

function Util.table_deep_copy(obj, seen)
	-- Deep copy a table. Code taken from: https://gist.github.com/tylerneylon/81333721109155b2d244

	-- Handle non-tables and previously-seen tables.
	if type(obj) ~= "table" then
		return obj
	end
	if seen and seen[obj] then
		return seen[obj]
	end

	-- New table; mark it as seen and copy recursively.
	local s = seen or {}
	local res = {}
	s[obj] = res
	for k, v in pairs(obj) do
		res[Util.table_deep_copy(k, s)] = Util.table_deep_copy(v, s)
	end
	return setmetatable(res, getmetatable(obj))
end

-- Buffer utilities.

Util.buffer = {}

function Util.buffer.new(opts)
	opts = opts or {}

	local buffer = vim.api.nvim_create_buf(true, true)
	if opts.name ~= nil then
		vim.api.nvim_buf_set_name(buffer, opts.name)
	end

	local filetype = opts.filetype
	if filetype == nil then
		filetype = "markdown"
	end
	vim.api.nvim_set_option_value("filetype", filetype, { buf = buffer })
	return buffer
end

function Util.buffer.set_text(buffer, text)
	vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {})
	local lines = require("loom.string_utils").str_split_lines(text)
	vim.api.nvim_buf_set_lines(buffer, 0, #lines, false, lines)
end

function Util.buffer.get_text(buffer)
	-- Get text from current buffer if no argument provided.
	if buffer == nil then
		buffer = vim.fn.winbufnr(0)
	end
	local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
	return table.concat(lines, "\n")
end

-- TODO(kedz): Add tests.
function Util.buffer.insert_buffer_lines(buffer_number, line, col, replacement_lines)
	local lines = vim.api.nvim_buf_get_lines(buffer_number, 0, -1, false)
	local line_to_insert = lines[line]
	local repl_lines = M.str_insert_lines(line_to_insert, col, replacement_lines)
end

-- TODO(kedz): Add tests.
function Util.buffer.open_buffer_in_window(buffer)
	-- TODO Add options to control how this is opened.
	vim.cmd.vsplit()
	local window = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(window, buffer)
end

return Util
