
local augroup = vim.api.nvim_create_augroup("Loom", { clear = true })

local function create_buffer()
	local buf = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_buf_set_name(buf, "*scratch*")
	vim.api.nvim_set_option_value("filetype", "md", { buf = buf })
	return buf
end

--local function send_ollama(
--    input_prompt,
--    context_prompt,
--    call_params,
--)
--
--
--
--end

local function main()
	--print("Hello from Loom")
	local buf = create_buffer()
end


vim.print("Looking for data in " .. vim.fn.stdpath("data"))
--{ setup = setup, send_buffer = send_buffer, send_llm = send_llm }
--local function setup()
	vim.api.nvim_create_autocmd(
		"VimEnter",
		{ group = augroup, desc = "Set up defaul Loom buffer on load", once = true, callback = main }
	)
end


