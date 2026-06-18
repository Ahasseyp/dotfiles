local opt = vim.opt

opt.number = true

-- tabs & indentation
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

opt.wrap = false

-- search settings
opt.ignorecase = true
opt.smartcase = true

opt.cursorline = true

-- colors
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- clipboard
opt.clipboard:append("unnamedplus")

opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile = true

opt.hlsearch = false
opt.incsearch = true

opt.scrolloff = 8

opt.colorcolumn = "121"

opt.foldmethod = "indent"
opt.foldlevel = 20

vim.g.mapleader = " "
vim.g.python3_host_prog = "$HOME/.pyenv/shims/python"
vim.g.black_linelength = 120

vim.g.user_emmet_leader_key = ","
vim.g.user_emmet_install_global = 0
