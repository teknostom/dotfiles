return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        dim_inactive = {
          enabled = true,
          percentage = 0.15,
        },
        no_italic = true,
        integrations = {
          noice = true,
          gitsigns = true,
          cmp = true,
          nvimtree = true,
          treesitter = true,
        },
      })
      vim.cmd.colorscheme "catppuccin"
    end
  },
}