local Job = require("plenary.job")
local Defaults = require("loom.defaults")
local LMRequest = require("loom.lm_request")
local BufferUtils = require("loom.buffer_utils")

local M = {}

M.requests = {}
-- TODO move requests management to separate module.
-- TODO move buffer listeners to separate module.

M.attach_request_to_buffer = function(lm_request, buffer)
	-- TODO allow specifying the line and column number to start writing.
	-- TODO support streaming.
	-- TODO delete listener after finish.
	buffer = buffer or BufferUtils.create_buffer(lm_request.guid)
	vim.api.nvim_create_autocmd("User", {
		pattern = "LmRequestComplete",
		callback = function(opts)
			if opts.data.guid == lm_request.guid then
				lines = {}
				for s in lm_request.response_text:gmatch("[^\n]*") do
					table.insert(lines, s)
				end
				vim.api.nvim_buf_set_lines(buffer, 0, -1, true, lines)
			end
		end,
	})
end

M.lm_current_buffer = function(self)
	local prompt = BufferUtils.get_buffer_text()
	self:lm_prompt(prompt)
end

M.lm_prompt = function(self, prompt)
	local lr = LMRequest.new(prompt, self.config)
	local buffer = BufferUtils.create_buffer("scratch-" .. lr.guid)
	self.attach_request_to_buffer(lr, buffer)
	lr:start()
	table.insert(self.requests, lr)
	-- TODO make this a function in buffer utils.
	vim.cmd.vsplit()
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, buffer)
end

vim.api.nvim_create_user_command("LMCurBuf", function()
	M:lm_current_buffer()
end, {})

vim.api.nvim_create_user_command("LMInput", function(opts)
	M:lm_prompt(opts.args)
end, { nargs = 1 })

vim.api.nvim_create_user_command("LMConfig", function(opts)
	vim.print(vim.inspect(M.config))
end, {})

vim.api.nvim_create_user_command("LMRequests", function(opts)
	vim.print(vim.inspect(M.requests))
end, {})

M.setup = function(opts)
	opts = opts or {}
	lm_config = opts.config or Defaults:config()
	M.config = lm_config
end

return M
