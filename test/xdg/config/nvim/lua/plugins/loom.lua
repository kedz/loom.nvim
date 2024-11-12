return {
    dir = "test/xdg/local/share/nvim/site/pack/testing/start/loom.nvim",
	dependencies = {
        { dir = "test/xdg/local/share/nvim/site/pack/testing/start/plenary.nvim" },
        { dir = "test/xdg/local/share/nvim/site/pack/testing/start/uuid-nvim" },
	},
	lazy = false,
	config = function()
		require("loom").setup({
			config = {
				["host"] = "localhost",
				["port"] = "11434",
				["model"] = "llama3.2" --#."llama3:70b", --"llama3.2",
			},
		})
	end,
}
