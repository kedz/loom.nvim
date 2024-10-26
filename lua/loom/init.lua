local Job = require("plenary.job")
local Defaults = require("loom.defaults")

local M = {}

local function send_llm(message)
	local message_data = {
		["model"] = M.config.model,
		["prompt"] = message,
		["stream"] = true,
	}

	local encoded_data = vim.json.encode(message_data)
	local resp = ""

	Job:new({
		command = "curl",
		args = {
			string.format("http://%s:%s/api/generate", M.config.host, M.config.port),
			"-d",
			encoded_data,
		},
		on_stdout = function(error, line, job)
			local data = vim.json.decode(line)
			resp = resp .. data["response"]
		end,
		on_exit = function(job, return_val)
			vim.print(resp)
		end,
	}):sync(10000) -- or start()
	return resp
end

vim.api.nvim_create_user_command("LMCurBuf", function()
	local bufnr = vim.fn.winbufnr(0)
	local buflines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local prompt = table.concat(buflines, "\n")
	local result = send_llm(prompt)

	lines = {}
	for s in result:gmatch("[^\n]*") do
		table.insert(lines, s)
	end
	vim.cmd("vsplit")
	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_win_set_buf(win, buf)
	vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
end, {})

vim.api.nvim_create_user_command("LMInput", function(opts)
	local bufnr = vim.fn.winbufnr(0)
	local buflines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local prompt = table.concat(buflines, "\n")
	local result = send_llm(opts["args"])
	lines = {}
	for s in result:gmatch("[^\n]*") do
		table.insert(lines, s)
	end
	vim.cmd("vsplit")
	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_win_set_buf(win, buf)
	vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
end, { nargs = 1 })

vim.api.nvim_create_user_command("LMConfig", function(opts)
    vim.print(vim.inspect(M.config))
end, {})

M.setup = function(opts)
	opts = opts or {}
	llm_config = opts.config or Defaults:config()
	M.config = llm_config
end

return M
