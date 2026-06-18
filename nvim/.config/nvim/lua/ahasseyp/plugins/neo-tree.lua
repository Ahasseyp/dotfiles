local keymap = vim.keymap

keymap.set('n', '<leader>ee', ':Neotree toggle<CR>')
keymap.set('n', '<leader>ef', ':Neotree reveal_file=%<CR>')

return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    -- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  opts = {
    window = {
      position = "right",
      width = 35,
      mapping_options = {
        noremap = true,
        nowait = true,
      },
      mappings = {},
    },
  },
}
