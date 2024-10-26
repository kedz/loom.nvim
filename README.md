# Loom.nvim
A hopefully not useless nvim plugin for calling LLMs with buffers.

# Install

## lazy.nvim

```lua
return {
	"kedz/loom.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	lazy = false,
	config = function()
		require("loom").setup({
			config = {
				["host"] = "localhost",
				["port"] = "11434",
				["model"] = "llama3.2",
			},
		})
	end,
}
```

# Example Keymaps

```lua
vim.keymap.set("n", "<leader>lb", "<cmd>LMCurBuf<CR>", { desc = "Send current buffer to language model" })
vim.keymap.set("n", "<leader>li", function()
	local prompt = vim.fn.input("LM <<< ")
	vim.cmd({
		cmd = "LMInput",
		args = { prompt },
	})
end, { desc = "Send user input to language model" })
```
