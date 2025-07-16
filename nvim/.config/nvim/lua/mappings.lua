local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', opts)
map('n', '<leader>7', '<cmd>noh<cr>', opts)
vim.keymap.set('n', '<leader>j', '<C-w>h', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>k', '<C-w>j', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>l', '<C-w>k', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>ö', '<C-w>l', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>n', ':vnew<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>m', ':new<CR>', { noremap = true, silent = true })
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true })
