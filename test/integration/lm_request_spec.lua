local jobopts = { rpc = true, width = 80, height = 24 }

local TestConfig = { host = "localhost", port = 64507 }

-- TODO(kedz) add more tests for other Ollama returned properties like tokens.
-- TODO(kedz) create centralized test config.
-- TODO(kedz) automatically setup and shutdown mock server.
-- TODO(kedz) move this to a unit test without needing to setup nvim process.
-- TODO(kedz) swap order of assert args.

describe("The LmRequest", function()
	local nvim -- Channel of the embedded Neovim process

	before_each(function()
		-- Start a new Neovim process
		nvim = vim.fn.jobstart({ "nvim", "--embed", "--headless" }, jobopts)
	end)

	after_each(function()
		-- Terminate the Neovim process
		vim.fn.jobstop(nvim)
	end)

	it("can receive streaming responses from a language model API.", function()
		local response_strings = vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format(
				'return require("loom"):sync_lm_request("Result with 3 responses", { host = "%s", port = %s } ).response_strings',
				TestConfig.host,
				TestConfig.port
			),
			{}
		)
		assert.is.equal(3, #response_strings)
		assert.is.equal("resp1", response_strings[1])
		assert.is.equal("resp2", response_strings[2])
		assert.is.equal("resp3", response_strings[3])
	end)

	it("can receive non-streaming responses from a language model API.", function()
		local response_strings = vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format(
				'return require("loom"):sync_lm_request("Result with 3 responses", { stream = false, host = "%s", port = %s } ).response_strings',
				TestConfig.host,
				TestConfig.port
			),

			{}
		)
		assert.is.equal(1, #response_strings)
		assert.is.equal("resp1resp2resp3", response_strings[1])
	end)
end)
