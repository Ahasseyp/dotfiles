return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		prioriy = 1000,
		config = function()
			vim.cmd("colorscheme catppuccin")
		end,
	},
}
