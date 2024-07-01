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

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- add your plugins here
    {  -- One Half: Theme
      "sonph/onehalf",
      lazy = false, -- Load this at startup
      priority = 1000, -- Load this first
      config = function()  -- Load the colorscheme here
        local rtp = vim.fn.stdpath('data') .. '/lazy/onehalf/vim'  -- Path of the color scheme subfolder in the project folder
        vim.opt.rtp:append(rtp)  -- Add the path to Run-Time Path
        vim.cmd([[colorscheme onehalfdark]])  -- Apply the color scheme
      end,
    },
    {  -- Treesitter: Syntax Highlighting
      "nvim-treesitter/nvim-treesitter",
      lazy = true,
      event = "BufRead",
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({
          highlight = { enable = true },
          indent = { enable = true },
        })
      end,
    },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
