-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.number = true  -- Show line numbers
vim.opt.expandtab = true  -- Use spaces instead of tabs
vim.opt.shiftwidth = 4  -- Number of spaces to use for auto-indent
vim.opt.tabstop = 4  -- Number of spaces that a <Tab> in the file counts for
vim.opt.softtabstop = 4  -- Number of spaces that a <Tab> counts for while editing

-- Setup lazy.nvim
require("lazy").setup({
    ui = {
        icons = {
            cmd = ">_",
            config = "⛭",
            event = "☇",
            favorite = "★",
            ft = "⎗",
            init = "⛭",
            import = "⎘",
            keys = "⌨",
            lazy = "𝒵𝓏𝓏",
            loaded = "●",
            not_loaded = "○",
            plugin = "❒",
            runtime = "𝕍",
            require = "⧂",
            source = "</>",
            start = "|>",
            task = "✔",
            list = { "●", "➜", "★", "‒", },
        },
    },
    default = {
        version = "*",  -- Use the latest version of the plugins
        lazy = true,  -- Lazy load plugins by default
    },
    spec = {  -- add your plugins here

        -- One Half: Theme
        {
            "sonph/onehalf",  -- https://github.com/sonph/onehalf
            lazy = false,  -- Load this at startup
            priority = 1000,  -- Load this first
            config = function()  -- Load the colorscheme here
                local rtp = vim.fn.stdpath('data') ..
                '/lazy/onehalf/vim'  -- Path of the color scheme subfolder in the project folder
                vim.opt.rtp:append(rtp)  -- Add the path to Run-Time Path
                vim.cmd([[colorscheme onehalfdark]])  -- Apply the color scheme
            end,
        },

        -- Treesitter: Syntax highlighting
        {
            "nvim-treesitter/nvim-treesitter",  -- https://github.com/nvim-treesitter/nvim-treesitter
            lazy = true,
            event = "BufRead",
            build = ":TSUpdate",
            config = function()
                require("nvim-treesitter.configs").setup({
                    ensure_installed = { "bash", "c", "cpp", "css", "diff", "html", "ini", "java", "javascript", "jsdoc", "json", "jsonc", "go", "lua", "luadoc", "luap", "markdown", "markdown_inline", "php", "printf", "python", "query", "regex", "rust", "toml", "tsx", "typescript", "vim", "vimdoc", "xml", "yaml", },
                    highlight = { enable = true },
                    indent = { enable = true },
                })
            end,
        },

        -- nvim-notify: Better notifications
        {
            "rcarriga/nvim-notify",  -- https://github.com/rcarriga/nvim-notify
            config = function()
                vim.notify = require("notify").setup({  -- Replace the default `vim.notify` with the one from `nvim-notify`
                    icons = {
                        DEBUG = "⛏",
                        ERROR = "✗",
                        INFO = "➤",
                        TRACE = "✎",
                        WARN = "⚠",
                    },
                    -- render = "minimal",  -- Minimal notifications. default|simple|minimal|compact|wrapped-compact
                })
            end,
        },

        -- nui.nvim: UI window frames
        {
            "MunifTanjim/nui.nvim",  -- https://github.com/MunifTanjim/nui.nvim
            lazy = true,
        },

        -- noice.nvim: UI preset
        {
            "folke/noice.nvim",  -- https://github.com/folke/noice.nvim
            event = "VeryLazy",  -- Load this after Nvim has loaded.
            dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
            opts = {
                presets = {
                    bottom_search = true,  -- Enable the bottom cmdline for search
                    command_palette = false,  -- Position the cmdline and popupmenu together or not
                    long_message_to_split = true,  -- Split long messages
                },
                cmdline = {
                    format = {
                        cmdline = { icon = ":" },  -- set the icon for cmdline to `:`
                        search_down = { icon = "/" },  -- set the icon for search_down to `/`
                        search_up = { icon = "?" },  -- set the icon for search_up to `?`
                        filter = { icon = ":!" },  -- set the icon for filter to `!`
                        lua = { icon = ":lua" },  -- set the icon for lua to `:lua`
                        help = { icon = ":help" },  -- set the icon for help to `:help`
                        input = { icon = ">" },  -- set the icon for input to `>>`
                    },
                },
            },
        },

        -- bufferline.nvim: Show tabs at the top
        {
            "akinsho/bufferline.nvim",  -- https://github.com/akinsho/bufferline.nvim
            -- dependencies = {"nvim-tree/nvim-web-devicons"},
            opts = {
                options = {
                    close_icon = "⛌",
                    buffer_close_icon = "⛌",
                    left_trunc_marker = "◀",
                    right_trunc_marker = "▶",
                    show_buffer_icons = false,  -- Disable buffer icons (need `nvim-web-devicons` and Nerd Font)
                },
            },
        },

        -- nvim-lualine: Status line
        {
            "nvim-lualine/lualine.nvim",  -- https://github.com/nvim-lualine/lualine.nvim
            -- dependencies = {"nvim-tree/nvim-web-devicons"},
            opts = {
                options = {
                    icons_enabled = false,  -- Disable icons (need `nvim-web-icons` and Nerd Font)
                },
            },
        },

        -- indent-blankline.nvim: Show indent lines
        {
            "lukas-reineke/indent-blankline.nvim",  -- https://github.com/lukas-reineke/indent-blankline.nvim
            main = "ibl",
            opts = {},
        },

        -- nvim-cmp: auto completion
        {
            "hrsh7th/nvim-cmp",  -- https://github.com/hrsh7th/nvim-cmp
            event = "InsertEnter",
            main = "cmp",
            dependencies = {
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-path",
            },
            opts = function()
                vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
                local cmp = require("cmp")
                local defaults = require("cmp.config.default")()
                return {
                    sources = cmp.config.sources({
                        { name = "path" },
                    }, {
                        { name = "buffer" },
                    }),
                    sorting = defaults.sorting,
                }
            end,
        },
    },  -- $spec
    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    install = { colorscheme = { "habamax" } },
    -- automatically check for plugin updates
    checker = { enabled = true },
})
