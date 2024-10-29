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
	local row = 0
	local col = 0
	local index = 1
	vim.api.nvim_create_autocmd("User", {
		pattern = "LmRequestUpdate",
		callback = function(opts)
            -- TODO make a separate module to handle this logic
            -- TODO fix the algo
            -- TODO figure out whether to keep the old one.
			--			if opts.data.guid == lm_request.guid then
			--				lines = {}
			--				for s in lm_request.response_text:gmatch("[^\n]*") do
			--					table.insert(lines, s)
			--				end
			--				vim.api.nvim_buf_set_lines(buffer, 0, -1, true, lines)
			--			end
			--
			if opts.data.guid ~= lm_request.guid then
				return
			end
            local win = vim.api.nvim_get_current_win()
			local next_text = lm_request.response_texts[index]:gsub("\n", " ")
			index = index + 1
			local line = vim.api.nvim_buf_get_lines(buffer, row, row + 1, false)[1]
			if #line + #next_text > 80 then 
                row = row + 1 
                col = 0
	            line = "" --vim.api.nvim_buf_get_lines(buffer, row, row + 1, false)[1]
            end
            local new_line = line:sub(0, col) .. next_text .. line:sub(col + 1)
			col = col + next_text:len()
			vim.api.nvim_buf_set_lines(buffer, row, row + 1, false, { new_line })
            
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
