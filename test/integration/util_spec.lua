local assert = require("busted").assert

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

    it(".buffer.insert_text (insert single line text at beginning of line)", function()
		local buffer_id = vim.rpcrequest(nvim, "nvim_exec_lua", 'return require("loom.util").buffer.new()', {})

		vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format('return require("loom.util").buffer.set_text(%d, "foo\\nalphaomega\\nbar")', buffer_id),
			{}
		)

		local end_position = vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format('return require("loom.util").buffer.insert_text(%d, 1, 0, "*")', buffer_id),
			{}
		)

		local buffer_text = vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format('return require("loom.util").buffer.get_text(%d)', buffer_id),
			{}
		)

        assert.is.True(end_position ~= nil)
        assert.is.True(end_position.line ~= nil)
        assert.is.True(end_position.column ~= nil)
        assert.is.equal(1, end_position.line)
        assert.is.equal(1, end_position.column)
		assert.is.equal("foo\n*alphaomega\nbar", buffer_text)

	end)

    it(".buffer.insert_text (insert single line text in middle of line)", function()
		local buffer_id = vim.rpcrequest(nvim, "nvim_exec_lua", 'return require("loom.util").buffer.new()', {})

		vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format('return require("loom.util").buffer.set_text(%d, "foo\\nalphaomega\\nbar")', buffer_id),
			{}
		)

		local end_position = vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format('return require("loom.util").buffer.insert_text(%d, 1, 5, " middle ")', buffer_id),
			{}
		)

        print("\n")
        print("line   >>" .. end_position.replacement_line .. "<<")
        print("prefix >>" .. end_position.prefix .. "<<")
        print("suffix >>" .. end_position.suffix .. "<<")

		local buffer_text = vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format('return require("loom.util").buffer.get_text(%d)', buffer_id),
			{}
		)
        print("buffer text >>" .. buffer_text .. "<<")
        print("\n")
        assert.is.True(end_position ~= nil)
        assert.is.True(end_position.line ~= nil)
        assert.is.True(end_position.column ~= nil)
        assert.is.equal(1, end_position.line)
        assert.is.equal(13, end_position.column)
		assert.is.equal("foo\nalpha middle omega\nbar", buffer_text)

	end)

    it(".buffer.insert_text (insert single line text at end of line)", function()
		local buffer_id = vim.rpcrequest(nvim, "nvim_exec_lua", 'return require("loom.util").buffer.new()', {})

		vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format('return require("loom.util").buffer.set_text(%d, "foo\\nalphaomega\\nbar")', buffer_id),
			{}
		)

		local end_position = vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format('return require("loom.util").buffer.insert_text(%d, 1, 10, "*")', buffer_id),
			{}
		)

		local buffer_text = vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format('return require("loom.util").buffer.get_text(%d)', buffer_id),
			{}
		)

        assert.is.True(end_position ~= nil)
        assert.is.True(end_position.line ~= nil)
        assert.is.True(end_position.column ~= nil)
        assert.is.equal(1, end_position.line)
        assert.is.equal(11, end_position.column)
		assert.is.equal("foo\nalphaomega*\nbar", buffer_text)

	end)

    it(".buffer.insert_text (insert 0 length line)", function()
		local buffer_id = vim.rpcrequest(nvim, "nvim_exec_lua", 'return require("loom.util").buffer.new()', {})

		vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format('return require("loom.util").buffer.set_text(%d, "foo\\nalphaomega\\nbar")', buffer_id),
			{}
		)

		local end_position = vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format('return require("loom.util").buffer.insert_text(%d, 1, 5, "")', buffer_id),
			{}
		)

		local buffer_text = vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format('return require("loom.util").buffer.get_text(%d)', buffer_id),
			{}
		)
        assert.is.True(end_position ~= nil)
        assert.is.True(end_position.line ~= nil)
        assert.is.True(end_position.column ~= nil)
        assert.is.equal(1, end_position.line)
        assert.is.equal(5, end_position.column)
		assert.is.equal("foo\nalphaomega\nbar", buffer_text)

	end)

    it(".buffer.insert_text (insert multi line text in middle of line)", function()
		local buffer_id = vim.rpcrequest(nvim, "nvim_exec_lua", 'return require("loom.util").buffer.new()', {})

		vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format('return require("loom.util").buffer.set_text(%d, "foo\\nalphaomega\\nbar")', buffer_id),
			{}
		)

		local end_position = vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format('return require("loom.util").buffer.insert_text(%d, 1, 5, " line1\\nline2 ")', buffer_id),
			{}
		)

        -- TODO(kedz): Remove extra return arguments.
        print("\n")
        print("line   >>" .. end_position.replacement_line .. "<<")
        print("prefix >>" .. end_position.prefix .. "<<")
        print("suffix >>" .. end_position.suffix .. "<<")

		local buffer_text = vim.rpcrequest(
			nvim,
			"nvim_exec_lua",
			string.format('return require("loom.util").buffer.get_text(%d)', buffer_id),
			{}
		)
        print("buffer text >>" .. buffer_text .. "<<")
        print("\n")
        assert.is.True(end_position ~= nil)
        assert.is.True(end_position.line ~= nil)
        assert.is.True(end_position.column ~= nil)
        assert.is.equal(2, end_position.line)
        assert.is.equal(6, end_position.column)
		assert.is.equal("foo\nalpha line1\nline2 omega\nbar", buffer_text)

	end)

end)
