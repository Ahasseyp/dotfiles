local function toggleFugitiveGit()
	if vim.fn.buflisted(vim.fn.bufname("fugitive:///*/.git//$")) ~= 0 then
		vim.cmd([[ execute ":bdelete" bufname('fugitive:///*/.git//$') ]])
	else
		vim.cmd([[
        vert bo Git
        " setlocal winfixwidth
        vertical resize 70
        ]])
	end
end
vim.keymap.set("n", "<leader>g", toggleFugitiveGit)

return {
	"tpope/vim-fugitive",
}
