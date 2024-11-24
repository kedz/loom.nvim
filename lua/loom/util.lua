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

-- Array utilities.

Util.array = {}

function Util.array.replace_item_with_array(array, item, insert_array)
	local item1 = item + 1
	local output = {}
	for i, orig_item in ipairs(array) do
		if i < item1 or i > item1 then
			table.insert(output, orig_item)
		else
			for _, insert_item in ipairs(insert_array) do
				table.insert(output, insert_item)
			end
		end
	end
	return output
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
	vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {}) -- TODO(kedz): Check if this is necessary.
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
function Util.buffer.insert_text(buffer, line, col, replacement_text)
	local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, true)

	local replacement_lines = require("loom.string_utils").str_split_lines(replacement_text)
	local orig_line = lines[line + 1]
	local prefix = orig_line:sub(1, col)
	local suffix = orig_line:sub(col + 1)
	local end_line
	local end_column
	if #replacement_lines == 1 then
		lines[line + 1] = prefix .. replacement_lines[1] .. suffix
		vim.api.nvim_buf_set_lines(buffer, 0, -1, true, lines)
		end_line = line
		end_column = #prefix + #replacement_lines[1]
	else
		replacement_lines[1] = prefix .. replacement_lines[1]
		replacement_lines[#replacement_lines] = replacement_lines[#replacement_lines] .. suffix
		local final_lines = Util.array.replace_item_with_array(lines, line, replacement_lines)
		vim.api.nvim_buf_set_lines(buffer, 0, -1, true, final_lines)
		end_line = line + #replacement_lines - 1
		end_column = #replacement_lines[#replacement_lines] - #suffix
	end

	-- TODO test case where insert is beyond buffer lines
	-- TODO test validation if insert is before buffer line
	-- TODO test validation if col is beyond buffer cols
	--
	return { line = end_line, column = end_column, replacement_line = orig_line, prefix = prefix, suffix = suffix }
end

-- TODO(kedz): Add tests.
function Util.buffer.open_buffer_in_window(buffer)
	-- TODO Add options to control how this is opened.
	vim.cmd.vsplit()
	local window = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(window, buffer)
end

return Util
