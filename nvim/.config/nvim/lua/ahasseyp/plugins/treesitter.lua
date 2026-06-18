return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		require("nvim-treesitter").setup()

		local parsers = {
			"astro",
			"bash",
			"c",
			"css",
			"dockerfile",
			"go",
			"html",
			"javascript",
			"json",
			"lua",
			"markdown",
			"markdown_inline",
			"prisma",
			"python",
			"query",
			"svelte",
			"tsx",
			"typescript",
			"vim",
			"vimdoc",
			"yaml",
		}

		require("nvim-treesitter").install(parsers)

		require("nvim-ts-autotag").setup()

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "*",
			callback = function()
				local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
				if lang and vim.tbl_contains(parsers, lang) then
					pcall(vim.treesitter.start)
				end
			end,
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "*",
			callback = function()
				local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
				if lang and vim.tbl_contains(parsers, lang) then
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})
	end,
}
