-- Configuration constants for floating window sizes
local HEIGHT_RATIO = 0.8
local WIDTH_RATIO = 0.5

return {
    -- ============================================================
    -- Core Utilities
    -- ============================================================
    {
        "willothy/flatten.nvim",
        config = true,
        lazy = false,
        priority = 1001,
    },

    -- Database client
    {
        "kndndrj/nvim-dbee",
        dependencies = {
            "MunifTanjim/nui.nvim",
        },
        build = function()
            require("dbee").install()
        end,
        config = function()
            require("dbee").setup()
            vim.api.nvim_create_user_command('DB', function()
                vim.cmd('tabnew')
                require('dbee').open()
            end, {})
        end,
    },

    -- ============================================================
    -- Formatting & LSP
    -- ============================================================

    -- Code formatting
    {
        "stevearc/conform.nvim",
        opts = {},
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    typescript = { stop_after_first = true },
                    typescriptreact = { stop_after_first = true },
                    javascript = { stop_after_first = true },
                    javascriptreact = { stop_after_first = true },
                    vue = { stop_after_first = true },
                    json = { stop_after_first = true },
                    html = { stop_after_first = true },
                    css = { stop_after_first = true },
                    java = { lsp_format = "prefer" },
                },
                default_format_opts = {
                    lsp_format = "fallback",
                },
            })
        end,
    },

    -- ============================================================
    -- File Navigation & Search
    -- ============================================================
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


    -- LSP package manager
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end
    },

    -- ============================================================
    -- UI Enhancements
    -- ============================================================

    -- Color highlighting
    {
        "brenoprata10/nvim-highlight-colors",
        config = function()
            require("nvim-highlight-colors").setup {}
        end
    },

    -- Git blame
    {
        "f-person/git-blame.nvim",
    },

    -- File browser
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
                },
            })
            vim.keymap.set('n', '<C-b>', ':NvimTreeToggle<CR>', {})
        end
    },


    -- ============================================================
    -- LSP Configuration
    -- ============================================================

    -- LSP setup helper
    {
        "VonHeikemen/lsp-zero.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "pmizio/typescript-tools.nvim",
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
            local lspconfig = require('lspconfig')

            -- Language servers
            lspconfig.rust_analyzer.setup({})
            lspconfig.lua_ls.setup({})
            lspconfig.basedpyright.setup({})
            lspconfig.cssls.setup({})
            lspconfig.biome.setup({})
            lspconfig.eslint.setup({})
            lspconfig.cssmodules_ls.setup({})

            -- TypeScript with Vue support
            require("typescript-tools").setup({
                on_attach = lsp_attach,
                filetypes = { "javascript", "typescript", "vue" },
                settings = {
                    tsserver_plugins = {
                        "@vue/typescript-plugin"
                    },
                }
            })
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
        end
    },

    -- Java LSP
    {
        "mfussenegger/nvim-jdtls",
        ft = "java",
        init = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "java",
                callback = function()
                    local jdtls_setup = require('jdtls.setup')
                    local config = {
                        cmd = { 'jdtls' },
                        root_dir = jdtls_setup.find_root({ 'gradlew', 'mvnw', '.git', 'pom.xml', 'build.gradle' }),
                        settings = {
                            java = {
                                format = {
                                    enabled = true,
                                },
                            },
                        },
                    }
                    require('jdtls').start_or_attach(config)
                end,
            })
        end,
    },

    -- ============================================================
    -- Editor Enhancements
    -- ============================================================

    -- Auto-pairing brackets
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true
    },

    -- Commenting utility
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end
    },

    -- TODO comments highlighting
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
        keys = {
            {
                "<leader>xt",
                "<cmd>TodoTrouble<cr>",
                desc = "Diagnostics (Trouble)",
            },
        }
    },

    -- ============================================================
    -- Syntax & Highlighting
    -- ============================================================

    -- Treesitter for better syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup {
                ensure_installed = { "lua", "javascript", "typescript", "java", "python", "c", "cpp", "css", "dockerfile", "yaml", "php", "make", "html", "vimdoc", "rust", "vue" },
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

    -- Icon support
    "nvim-tree/nvim-web-devicons",

    -- ============================================================
    -- Git Integration
    -- ============================================================

    -- Git signs in gutter
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

    -- ============================================================
    -- Diagnostics & Debugging
    -- ============================================================

    -- Diagnostic viewer
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

    -- ============================================================
    -- UI & Notifications
    -- ============================================================

    -- Better UI/notifications
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

    -- Status line
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

    -- ============================================================
    -- Color Scheme
    -- ============================================================

    -- Catppuccin theme
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
