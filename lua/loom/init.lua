local Defaults = require("loom.defaults")
local LMRequest = require("loom.lm_request")
local BufferWriter = require("loom.buffer_writer")
local Util = require("loom.util")

local M = {}
M.requests = {}

-- TODO move requests management to separate module.
-- TODO move buffer listeners to separate module.
-- TODO(kedz) separate opts into server data to send vs and config about host location/route.

M.sync_lm_request = function(self, prompt, opts)
	local config = Util.table_deep_copy(self.config)
	if opts ~= nil then
		for key, value in pairs(opts) do
			config[key] = value
		end
	end
	return LMRequest.new(prompt, config):sync()
end

M.async_lm_request = function(self, prompt, opts)
	local config = Util.table_deep_copy(self.config)
	if opts ~= nil then
		for key, value in pairs(opts) do
			config[key] = value
		end
	end
	return LMRequest.new(prompt, config):start()
end

M.attach_request_to_buffer = function(lm_request, buffer)
	-- TODO allow specifying the line and column number to start writing.
	-- TODO support streaming.
	-- TODO delete listener after finish.
	-- TODO(kedz) determine if this should create a buffer if passed an empty one?
	-- like so (but this will break on 0): buffer = buffer or BufferUtils.create_buffer(lm_request.guid)
	local row = 0
	local col = 0
	local index = 1
	BufferWriter.new(buffer, lm_request, {})
end

M.lm_current_buffer = function(self)
	local prompt = Util.buffer.get_text()
	self:lm_prompt_to_buffer(prompt)
end

M.lm_prompt_to_buffer = function(self, prompt, opts)
	local config = Util.table_deep_copy(self.config)
	if opts ~= nil then
		for key, value in pairs(opts) do
			config[key] = value
		end
	end
	local lr = LMRequest.new(prompt, config)
	local buffer = Util.buffer.new({ name = "scratch-" .. lr.guid })
	self.attach_request_to_buffer(lr, buffer)
	lr:start()
	table.insert(self.requests, lr)
	Util.buffer.open_buffer_in_window(buffer)
end

vim.api.nvim_create_user_command("LMCurBuf", function()
	M:lm_current_buffer()
end, {})

vim.api.nvim_create_user_command("LMInput", function(opts)
	M:lm_prompt_to_buffer(opts.args)
end, { nargs = 1 })

vim.api.nvim_create_user_command("LMConfig", function(opts)
	vim.print(vim.inspect(M.config))
end, {})

vim.api.nvim_create_user_command("LMRequests", function(opts)
	vim.print(vim.inspect(M.requests))
end, {})

vim.api.nvim_create_user_command("LMWriters", function(opts)
	vim.print(vim.inspect(BufferWriter.registry.active_listeners))
end, {})

M.setup = function(opts)
	opts = opts or {}
	local lm_config = opts.config or Defaults:config()
	M.config = lm_config
end

return M
