local M = {}

M.str_split_lines = function(str)
	local lines = {}
	local i, _ = string.find(str, "\n", 1, true)
	while i do
		table.insert(lines, str:sub(1, i - 1))
		str = str:sub(i + 1)
		i, _ = string.find(str, "\n", 1, true)
	end

	--if #str > 0 then
		table.insert(lines, str)
	--end
	return lines
end

M.str_insert_lines = function(dest_string, dest_col, replacement_lines)
	-- TODO Add check/exception throw if new line in one of the replacement lines or dest_string.
	-- TODO Add range check on dest_col
	local prefix = dest_string:sub(1, dest_col - 1)
	local suffix = dest_string:sub(dest_col)

	local output = {}
	table.insert(output, prefix .. replacement_lines[1])

	for i = 2, #replacement_lines do
		table.insert(output, replacement_lines[i])
	end

	output[#output] = output[#output] .. suffix

	return output
end

return M
