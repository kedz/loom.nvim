local jobopts = { rpc = true, width = 80, height = 24 }

local TestConfig = { host = "localhost", port = 64507 }

-- TODO(kedz) create centralized test config.
-- TODO(kedz) automatically setup and shutdown mock server.
--
-- TODO(kedz) Test response with newlines
-- TODO(kedz) Test response inserting into existing buffer in middle with content before and after (both cols and
-- lines).
-- TODO(kedz) determine expected behavior and add tests for inserting to specific lines, columns when
--            out of bounds

describe("loom.nvim api", function()
	local nvim -- Channel of the embedded Neovim process

	before_each(function()
		-- Start a new Neovim process
		nvim = vim.fn.jobstart({ "nvim", "--embed", "--headless" }, jobopts)
	end)

	after_each(function()
		-- Terminate the Neovim process
		vim.fn.jobstop(nvim)
	end)

	it("lm_prompt_to_buffer", function()
		vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format(
				'return require("loom"):lm_prompt_to_buffer("Result with 3 responses", { host = "%s", port = %s } )',
				TestConfig.host,
				TestConfig.port
			),
			{}
		)
		vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			'return require("plenary.job").join(require("loom").requests[1]._job)',
			{}
		)
		local buffer_text =
			vim.rpcrequest(nvim, "nvim_exec_lua", 'return require("loom.util").buffer.get_text()', {})
		assert.is.equal("resp1resp2resp3", buffer_text)
	end)

	it("lm_prompt_to_buffer (no streaming)", function()
		vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format(
				'return require("loom"):lm_prompt_to_buffer("Result with 3 responses", { stream = false, host = "%s", port = %s } )',
				TestConfig.host,
				TestConfig.port
			),
			{}
		)
		vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			'return require("plenary.job").join(require("loom").requests[1]._job)',
			{}
		)

		local buffer_text =
			vim.rpcrequest(nvim, "nvim_exec_lua", 'return require("loom.util").buffer.get_text()', {})
		assert.is.equal("resp1resp2resp3", buffer_text)
	end)

	it("lm_prompt_to_buffer with newlines", function()
	    vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format(
				'return require("loom"):lm_prompt_to_buffer("Result with newlines", { host = "%s", port = %s } )',
				TestConfig.host,
				TestConfig.port
			),
			{}
		)
		vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			'return require("plenary.job").join(require("loom").requests[1]._job)',
			{}
		)
		local buffer_text =
			vim.rpcrequest(nvim, "nvim_exec_lua", 'return require("loom.util").buffer.get_text()', {})
		assert.is.equal("foo\nbar\nbazbiz\n", buffer_text)
	end)
end)
