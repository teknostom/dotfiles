local map = vim.keymap.set

-- General keymaps (non-plugin specific)
map('n', '<leader>7', '<cmd>noh<cr>', { noremap = true, silent = true, desc = "Clear highlights" })

-- Window navigation (Swedish keyboard layout)
map('n', '<leader>j', '<C-w>h', { noremap = true, silent = true, desc = "Window left" })
map('n', '<leader>k', '<C-w>j', { noremap = true, silent = true, desc = "Window down" })
map('n', '<leader>l', '<C-w>k', { noremap = true, silent = true, desc = "Window up" })
map('n', '<leader>ö', '<C-w>l', { noremap = true, silent = true, desc = "Window right" })

-- Window creation
map('n', '<leader>n', ':vnew<CR>', { noremap = true, silent = true, desc = "New vertical split" })
map('n', '<leader>m', ':new<CR>', { noremap = true, silent = true, desc = "New horizontal split" })

-- Terminal mode escape
map('t', '<Esc>', '<C-\\><C-n>', { noremap = true, silent = true, desc = "Exit terminal mode" })
