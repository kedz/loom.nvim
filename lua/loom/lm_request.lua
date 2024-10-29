local Job = require("plenary.job")
local Uuid = require("uuid-nvim")

M = {}

function M.new(prompt, config)
	local obj = {}

	obj.guid = Uuid.get_v4({ quotes = "none" })
	obj.is_started = false
	obj.start_time = nil
	obj.is_finished = false
	obj.finish_time = nil
	obj.token_ids = {}
	obj.response_text = ""
	obj.responses = {}
	obj.prompt = prompt
	obj.config = config

	obj.start = function(self)
        -- TOOD make request data and job command pluggable. 
		local request_data = {
			["model"] = self.config.model,
			["prompt"] = self.prompt,
			["stream"] = true,
		}

		local encoded_data = vim.json.encode(request_data)
		self.response_text = ""
		self.response_texts = {}

		Job:new({
			command = "curl",
			args = {
				string.format("http://%s:%s/api/generate", self.config.host, self.config.port),
                "-N",
				"-d",
				encoded_data,
			},
			on_stdout = function(error, line, job)
				local data = vim.json.decode(line)
				self.response_text = self.response_text .. data["response"]
				table.insert(self.response_texts, data["response"])
				vim.schedule(function()
					vim.api.nvim_exec_autocmds("User", { pattern = "LmRequestUpdate", data = { guid = self.guid } })
				end)
			end,
			on_exit = function(job, return_val)
                -- TODO print that job has finished.
				vim.schedule(function()
					self.is_finished = true
					self.finish_time = vim.fn.strftime("%Y-%m-%dT%H:%M:%S")
					vim.api.nvim_exec_autocmds("User", { pattern = "LmRequestComplete", data = { guid = self.guid } })
				end)
			end,
		}):start(10000)
		-- TODO make timeout time configurable
		self.is_started = true
		self.start_time = vim.fn.strftime("%Y-%m-%dT%H:%M:%S")
	end

	return obj
end

return M
