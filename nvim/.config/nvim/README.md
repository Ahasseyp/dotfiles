# Neovim Configuration

Personal Neovim config built on [lazy.nvim](https://github.com/folke/lazy.nvim), organized under the `ahasseyp` namespace.

## Requirements

**Required**
- Neovim >= 0.12
- `git`
- A C compiler (`clang` or `gcc`) — for Treesitter parsers
- `tree-sitter` CLI — required by `nvim-treesitter` on its `main` branch
- `ripgrep` — Telescope live grep
- `fd` — Telescope find files
- Node.js + npm — Mason installs many JS-based LSPs and formatters
- A [Nerd Font](https://www.nerdfonts.com/) — required by `nvim-web-devicons`, `lualine`, `bufferline`, and `neo-tree`

**Optional**
- `lazygit` CLI — for `lazygit.nvim`
- `pyenv` + Python 3 — `options.lua` points `python3_host_prog` at `$HOME/.pyenv/shims/python`
- `OPENAI_API_KEY` and/or `ANTHROPIC_API_KEY` — for `avante.nvim`

## Installation

1. Install Neovim and the required CLI tools. On macOS:
   ```sh
   brew install neovim ripgrep fd node
   ```
2. Install a Nerd Font and set it as your terminal font.
3. Back up any existing Neovim state:
   ```sh
   mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null
   mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null
   mv ~/.local/state/nvim ~/.local/state/nvim.bak 2>/dev/null
   mv ~/.cache/nvim ~/.cache/nvim.bak 2>/dev/null
   ```
4. Clone this config:
   ```sh
   git clone git@github.com:Ahasseyp/nvim-dotfiles.git ~/.config/nvim
   ```
5. Launch `nvim`. `lazy.nvim` self-bootstraps and installs every plugin; Mason then auto-installs LSPs, formatters, and linters. Wait for both to finish.
6. Restart `nvim` once, then run `:checkhealth` to verify dependencies.
