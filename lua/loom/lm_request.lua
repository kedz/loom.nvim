local Job = require("plenary.job")
local Uuid = require("uuid-nvim")

local M = {}

function M.new(prompt, config)
	local obj = {}

	obj.guid = Uuid.get_v4({ quotes = "none" })
	obj.is_started = false
	obj.start_time = nil
	obj.is_finished = false
	obj.finish_time = nil
	obj.response_strings = {}
	obj.prompt = prompt
	obj.config = config

    if config.stream == nil then
        -- TODO(kedz) Centralize declaration of defaults
        config.stream = true
    end

	-- TOOD make request data and job command pluggable.
	local request_data = {
		["model"] = config.model,
		["prompt"] = prompt,
		["stream"] = config.stream,
	}

	local encoded_data = vim.json.encode(request_data)

	obj._job = Job:new({
		command = "curl",
		args = {
            -- TODO(kedz) make path configurable.
			string.format("http://%s:%s/api/generate", config.host, config.port),
			"-N",
			"-d",
			encoded_data,
		},
		on_stdout = function(_, line, _) -- error, line, job
			local data = vim.json.decode(line)
			table.insert(obj.response_strings, data["response"])
			vim.schedule(function()
				vim.api.nvim_exec_autocmds("User", { pattern = "LmRequestUpdate", data = { guid = obj.guid } })
			end)
		end,
--        on_stderr = function(_, data, _) -- error, line, job
--            -- TODO(kedz): Added error handling.
--        end,
		on_exit = function(_, _) -- job, return_val
			vim.schedule(function()
				obj.is_finished = true
				obj.finish_time = vim.fn.strftime("%Y-%m-%dT%H:%M:%S")
				vim.api.nvim_exec_autocmds("User", { pattern = "LmRequestComplete", data = { guid = obj.guid } })
			end)
		end,
	})

	obj.start = function(self)
		self.is_started = true
		self.start_time = vim.fn.strftime("%Y-%m-%dT%H:%M:%S")
		self._job:start(10000)
		-- TODO make timeout time configurable
		return self
	end

	obj.sync = function(self)
		self.is_started = true
		self.start_time = vim.fn.strftime("%Y-%m-%dT%H:%M:%S")
		self._job:sync(10000)
		-- TODO make timeout time configurable
		return self
	end

	return obj
end

return M
