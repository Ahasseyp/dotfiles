local keymap = vim.keymap

-- Function to close all buffers except those open in tabs
local function close_buffers_except_tabs()
	-- Get all tab pages
	local tab_pages = vim.api.nvim_list_tabpages()
	local buffers_to_keep = {}

	-- Collect all buffers that are open in any tab
	for _, tab in ipairs(tab_pages) do
		local windows = vim.api.nvim_tabpage_list_wins(tab)
		for _, win in ipairs(windows) do
			local buf = vim.api.nvim_win_get_buf(win)
			buffers_to_keep[buf] = true
		end
	end

	-- Get all buffers and close those not in tabs
	local all_buffers = vim.api.nvim_list_bufs()
	for _, buf in ipairs(all_buffers) do
		if vim.api.nvim_buf_is_valid(buf) and not buffers_to_keep[buf] then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end
end

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

-- buffer management
keymap.set("n", "<leader>bx", close_buffers_except_tabs, { desc = "Close all buffers except those in tabs" })

-- move text in visual mode
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- preserve register when pasting over another
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Past while preserving register" })

-- maintain search at the middle of the screen
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- yank text to computer clipboard
keymap.set("n", "<leader>y", '"+y')
keymap.set("n", "<leader>y", '"+y')
keymap.set("n", "<leader>Y", '"+Y')

keymap.set("n", "<leader>cp", ':let @+ = expand("%")<CR>', { desc = "Copy relative path" })
keymap.set("n", "<leader>cP", ':let @+ = expand("%:p")<CR>', { desc = "Copy absolute path" })

keymap.set("n", "<leader>sw", [[:%s/\<<C-r><C-w>\>//gI<Left><Left><Left>]], { desc = "Subsitute word under cursor" })

-- tailwind
keymap.set("n", "<leader>tw", "<cmd>TailwindSort<CR>", { desc = "Sort tailwind classes" }) -- sort tailwind classes
keymap.set("n", "<leader>cd", "<cmd>CodeDiff<cr>", { desc = "Toggle code diff review" })
