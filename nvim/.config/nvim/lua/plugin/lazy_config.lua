local HEIGHT_RATIO = 0.8 -- You can change this
local WIDTH_RATIO = 0.5  -- You can change this too

return {
    -- Lazy.nvim is configured by itself above
    "Exafunction/windsurf.vim",
    {
        "willothy/flatten.nvim",
        config = true,
        lazy = false,
        priority = 1001,
    },
    {
        "stevearc/conform.nvim",
        opts = {},
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    typescript = { 'prettierd', "prettier", stop_after_first = true },
                    typescriptreact = { 'prettierd', "prettier", stop_after_first = true },
                    javascript = { 'prettierd', "prettier", stop_after_first = true },
                    javascriptreact = { 'prettierd', "prettier", stop_after_first = true },
                    json = { 'prettierd', "prettier", stop_after_first = true },
                    html = { 'prettierd', "prettier", stop_after_first = true },
                    css = { 'prettierd', "prettier", stop_after_first = true },

                },
            })
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = "*.js,*.tsx,*.ts,*.json,*.css",
                callback = function(args)
                    require("conform").format({ bufnr = args.buf })
                end,
            })
        end,
    },
    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local builtin = require("telescope.builtin")
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
            vim.keymap.set("n", "<leader>fb", builtin.find_files, {})
            require('telescope').setup()
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
    {
        "f-person/git-blame.nvim",
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
                renderer = {
                    group_empty = true,
                }
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
                local opts = { buffer = bufnr }
                vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
                vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
                vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
                vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
                vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
                vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
                vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
                vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
                vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
                vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
            end
            lsp_zero.extend_lspconfig({
                sign_text = true,
                lsp_attach = lsp_attach,
                capabilities = require('cmp_nvim_lsp').default_capabilities(),
            })
            require('lspconfig').rust_analyzer.setup({})
            -- require('lspconfig').jdtls.setup({})
            require('lspconfig').lua_ls.setup({})
            require('lspconfig').ts_ls.setup({})
            require('lspconfig').basedpyright.setup({})
            require('lspconfig').cssls.setup({})
            require('lspconfig').biome.setup({})
            require('lspconfig').eslint.setup({})
            require('lspconfig').cssmodules_ls.setup({})
            local cmp = require('cmp')

            cmp.setup({
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                sources = {
                    { name = 'nvim_lsp' },
                },
                snippet = {
                    expand = function(args)
                        vim.snippet.expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({}),
            })
            vim.api.nvim_create_autocmd({ "CursorHold" }, {
                pattern = "*",
                callback = function()
                    for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
                        if vim.api.nvim_win_get_config(winid).zindex then
                            return
                        end
                    end
                    vim.diagnostic.open_float({
                        scope = "cursor",
                        focusable = false,
                        close_events = {
                            "CursorMoved",
                            "CursorMovedI",
                            "BufHidden",
                            "InsertCharPre",
                            "WinLeave",
                        },
                    })
                    vim.lsp.buf.hover()
                end
            })
        end
    },

    {
        "scalameta/nvim-metals",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        ft = { "scala", "sbt", "java" },
        opts = function()
            local metals_config = require("metals").bare_config()
            metals_config.on_attach = function(client, bufnr)
                local opts = { buffer = bufnr }
                vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
                vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
                vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
                vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
                vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
                vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
                vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
                vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
                vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
                vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
            end
            return metals_config
        end,
        config = function(self, metals_config)
            local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
            vim.api.nvim_create_autocmd("FileType", {
                pattern = self.ft,
                callback = function()
                    require("metals").initialize_or_attach(metals_config)
                end,
                group = nvim_metals_group,
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
                ensure_installed = { "lua", "javascript", "java", "python", "c", "cpp", "css", "dockerfile", "yaml", "php", "make", "html", "vimdoc", "rust", }, -- Add other languages as needed
                highlight = { enable = true }
            }
            vim.api.nvim_create_autocmd("BufEnter", {
                pattern = "Jenkinsfile*",
                callback = function()
                    vim.cmd("set filetype=groovy")
                end,
            })
        end
    },

    -- NerdIcons for better icon support
    "nvim-tree/nvim-web-devicons",

    -- Git signs
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns

                    vim.keymap.set("n", "<leader>gb", ":Gitsigns blame<cr>")
                end
            })
        end
    },

    -- Trouble for better diagnostics
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local actions = require("telescope.actions")
            local open_with_trouble = require("trouble.sources.telescope").open

            -- Use this to add more results without clearing the trouble list
            local add_to_trouble = require("trouble.sources.telescope").add

            local telescope = require("telescope")
            telescope.setup({
                defaults = {
                    mappings = {
                        i = { ["<c-t>"] = open_with_trouble },
                        n = { ["<c-t>"] = open_with_trouble },
                    },
                },
            })

            require("trouble").setup {}
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
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
        keys = {
            {
                "<leader>xt",
                "<cmd>TodoTrouble<cr>",
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
        dependencies = { "MunifTanjim/nui.nvim", "hrsh7th/nvim-cmp" },
        config = function()
            require("noice").setup({
                views = {
                    cmdline_popup = {
                        position = {
                            row = 5,
                            col = "50%",
                        },
                        size = {
                            width = 60,
                            height = "auto",
                        },
                    },
                    popupmenu = {
                        relative = "editor",
                        position = {
                            row = 8,
                            col = "50%",
                        },
                        size = {
                            width = 60,
                            height = 10,
                        },
                        border = {
                            style = "rounded",
                            padding = { 0, 1 },
                        },
                        win_options = {
                            winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
                        },
                    },
                },
                popupmenu = {
                    enabled = true,
                    backend = "cmp",
                },

                lsp = {
                    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                    override = {
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                        ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
                    },
                },
                presets = {
                    long_message_to_split = true,
                    lsp_doc_border = true,
                }
            })
        end
    },

    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            local trouble = require("trouble")
            local symbols = trouble.statusline({
                mode = "lsp_document_symbols",
                groups = {},
                title = false,
                filter = { range = true },
                format = "{kind_icon}{symbol.name:Normal}",
                -- The following line is needed to fix the background color
                -- Set it to the lualine section you want to use
                hl_group = "lualine_c_normal",
            })
            require("lualine").setup({
                options = {
                    theme = "catppuccin"
                },
                sections = {
                    lualine_x = {
                        {
                            require("noice").api.status.message.get_hl,
                            cond = require("noice").api.status.message.has,
                        },
                        {
                            require("noice").api.status.command.get,
                            cond = require("noice").api.status.command.has,
                            color = { fg = "#99FF99" },
                        },
                        {
                            require("noice").api.status.search.get,
                            cond = require("noice").api.status.search.has,
                            color = { fg = "#99FF99" },
                        },
                        {
                            require("noice").api.statusline.mode.get,
                            cond = require("noice").api.statusline.mode.has,
                            color = { fg = "#99FF99" },
                        }
                    },
                },
            })
        end,
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
                    gitsigns = true,
                    cmp = true,
                    nvimtree = true,
                    treesitter = true,
                },
            })
            vim.cmd.colorscheme "catppuccin"
        end
    },

    {
        "nvim-neotest/neotest",
        dependencies = {
            "stevanmilic/neotest-scala",
            "nvim-tree/nvim-web-devicons",
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter"
        },
        config = function()
            require("neotest").setup({
                adapters = {
                    require("neotest-scala")({
                        runner = "sbt",
                        framework = "scalatest",
                    })
                }
            })
            vim.keymap.set('n', '<leader>tt', ':lua require("neotest").run.run(vim.fn.expand("%"))<CR>', {})
        end
    }
}
