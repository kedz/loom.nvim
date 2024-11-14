local jobopts = { rpc = true, width = 80, height = 24 }

describe("Util", function()
	local nvim -- Channel of the embedded Neovim process

	before_each(function()
		-- Start a new Neovim process
		nvim = vim.fn.jobstart({ "nvim", "--embed", "--headless" }, jobopts)
	end)

	after_each(function()
		-- Terminate the Neovim process
		vim.fn.jobstop(nvim)
	end)

	it(".buffer.new_with_defaults", function()
		local buffer_id = vim.rpcrequest(nvim, "nvim_exec_lua", 'return require("loom.util").buffer.new()', {})

		local buffer_name =
			vim.rpcrequest(nvim, "nvim_exec_lua", string.format("return vim.api.nvim_buf_get_name(%d)", buffer_id), {})

		assert.is.equal("", buffer_name)

		local buffer_filetype = vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format("return vim.api.nvim_get_option_value('filetype', { buf = %d })", buffer_id),
			{}
		)

		assert.is.equal("markdown", buffer_filetype)
	end)

	it(".buffer.new_with_args", function()
		local buffer_id = vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			'return require("loom.util").buffer.new({ name = "foo", filetype = "python" })',
			{}
		)

		local buffer_name =
			vim.rpcrequest(nvim, "nvim_exec_lua", string.format("return vim.api.nvim_buf_get_name(%d)", buffer_id), {})

		-- TODO(kedz): Better to get cwd here.
		assert.is.equal("foo", buffer_name:sub(-3))

		local buffer_filetype = vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format("return vim.api.nvim_get_option_value('filetype', { buf = %d })", buffer_id),
			{}
		)

		assert.is.equal("python", buffer_filetype)
	end)

	it(".buffer.set_text and .buffer.get_text", function()
		local buffer_id = vim.rpcrequest(nvim, "nvim_exec_lua", 'return require("loom.util").buffer.new()', {})

		vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format('return require("loom.util").buffer.set_text(%d, "foo\\nbar\\nbaz")', buffer_id),
			{}
		)

		local buffer_text = vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format('return require("loom.util").buffer.get_text(%d)', buffer_id),
			{}
		)

		assert.is.equal("foo\nbar\nbaz", buffer_text)

        vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format('return require("loom.util").buffer.set_text(%d, "foo\\nbar")', buffer_id),
			{}
		)

		local overwritten_buffer_text = vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format('return require("loom.util").buffer.get_text(%d)', buffer_id),
			{}
		)

		assert.is.equal("foo\nbar", overwritten_buffer_text)

	end)
end)
