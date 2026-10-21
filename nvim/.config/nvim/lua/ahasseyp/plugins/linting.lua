return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			python = { "pylint" },
			astro = { "eslint_d" },
		}

		-- Monorepo ESLint configs set `parserOptions.project: './tsconfig.json'` relative to the
		-- process cwd, so eslint_d must run from the package that owns the file.
		local eslint_config_files = {
			".eslintrc.js",
			".eslintrc.cjs",
			".eslintrc.json",
			".eslintrc",
			"eslint.config.js",
			"eslint.config.mjs",
		}

		local function lint_current_buffer()
			local root = vim.fs.root(0, eslint_config_files)
			lint.try_lint(nil, { cwd = root })
		end

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = lint_current_buffer,
		})

		vim.keymap.set("n", "<leader>l", lint_current_buffer, { desc = "Trigger linting for current file" })
	end,
}
