local HEIGHT_RATIO = 0.8 -- You can change this
local WIDTH_RATIO = 0.5  -- You can change this too

return {
    -- Lazy.nvim is configured by itself above

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local builtin = require("telescope.builtin")
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
        end,
    },

    -- Mason for LSP management
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end
    },

    -- Colorizer
    {
        "norcalli/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup()
        end,
    },

    -- Nvim-tree for browsing files
    {
        "nvim-tree/nvim-tree.lua",
        config = function()
            require("nvim-tree").setup({
                hijack_netrw = true,
                view = {
                    relativenumber = true,
                    float = {
                      enable = true,
                      open_win_config = function()
                        local screen_w = vim.opt.columns:get()
                        local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
                        local window_w = screen_w * WIDTH_RATIO
                        local window_h = screen_h * HEIGHT_RATIO
                        local window_w_int = math.floor(window_w)
                        local window_h_int = math.floor(window_h)
                        local center_x = (screen_w - window_w) / 2
                        local center_y = ((vim.opt.lines:get() - window_h) / 2)
                                         - vim.opt.cmdheight:get()
                        return {
                          border = "rounded",
                          relative = "editor",
                          row = center_y,
                          col = center_x,
                          width = window_w_int,
                          height = window_h_int,
                        }
                        end,
                    },
                    width = function()
                      return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
                    end,
                  },
            })
            vim.keymap.set('n', '<C-b>', ':NvimTreeToggle<CR>', {})
        end
    },

    -- LSP-Zero for easier LSP setup
    {
        "VonHeikemen/lsp-zero.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "L3MON4D3/LuaSnip"
        },
        config = function()
            local lsp_zero = require('lsp-zero')
            local lsp_attach = function(client, bufnr)
              local opts = {buffer = bufnr}
              vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
              vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
              vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
              vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
              vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
              vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
              vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
              vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
              vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
              vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
            end
            lsp_zero.extend_lspconfig({
              sign_text = true,
              lsp_attach = lsp_attach,
              capabilities = require('cmp_nvim_lsp').default_capabilities(),
            })
            require('lspconfig').rust_analyzer.setup({})
            require('lspconfig').lua_ls.setup({})
            local cmp = require('cmp')

            cmp.setup({
              sources = {
                {name = 'nvim_lsp'},
              },
              snippet = {
                expand = function(args)
                  vim.snippet.expand(args.body)
                end,
              },
              mapping = cmp.mapping.preset.insert({}),
            })
        end
    },

    -- Auto pair
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true
        -- use opts = {} for passing setup options
        -- this is equivalent to setup({}) function
    },


    -- Treesitter for better syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup {
                ensure_installed = { "lua", "javascript", "python", "rust"}, -- Add other languages as needed
                highlight = { enable = true }
            }
        end
    },

    -- NerdIcons for better icon support
    "nvim-tree/nvim-web-devicons",

    -- Git signs
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup()
        end
    },

    -- Trouble for better diagnostics
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("trouble").setup {}
        end,
        keys = {
            {
                "<leader>xx",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            },
        }
    },

    -- Commenting utility
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end
    },

    -- Noice for better UI/notifications
    {
        "folke/noice.nvim",
        dependencies = { "MunifTanjim/nui.nvim" },
        config = function()
            require("noice").setup()
        end
    },

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
                },
            })
            vim.cmd.colorscheme "catppuccin"
        end
    }

}

