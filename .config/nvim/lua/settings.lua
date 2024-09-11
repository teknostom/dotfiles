vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.updatetime = 500
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 4
vim.opt.encoding = "utf-8"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.cmd('set clipboard=unnamedplus')
vim.diagnostic.config {
  virtual_text = false,
  float = {
    header = false,
    border = 'rounded',
    focusable = true,
  },
}

