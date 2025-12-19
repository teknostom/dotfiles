require("settings")
require("mappings")
require("plugins")

-- Terminal wrapping for better readability
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.wo.wrap = true
    vim.wo.linebreak = true
  end,
})
