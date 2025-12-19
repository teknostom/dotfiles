-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- UI
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"

-- Editing
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 4
vim.opt.encoding = "utf-8"

-- Performance
vim.opt.updatetime = 500

-- System integration
vim.cmd('set clipboard=unnamedplus')

-- Disable netrw (since you use nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- File handling
vim.cmd('set nofixeol')
vim.cmd('set noeol')

-- Diagnostics
vim.diagnostic.config {
  virtual_text = false,
  float = {
    header = false,
    border = 'rounded',
    focusable = true,
  },
}
