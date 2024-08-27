local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', opts)
map('n', '<leader>7', '<cmd>noh<cr>', opts)
