-- ~/.config/nvim/init.lua

-- Set leader key
vim.g.mapleader = ' '

-- General settings
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.scrolloff = 8
vim.opt.wrap = false
vim.opt.termguicolors = true

-- Terminal buffer settings
vim.opt.scrollback = 50000
vim.opt.equalalways = false

-- Clipboard integration
vim.opt.clipboard = 'unnamedplus'

-- Filetype detection
vim.cmd('filetype plugin indent on')

-- Keymaps for copy/paste (e.g., for macOS)
vim.keymap.set('v', '<D-c>', '"+y')      -- Visual mode copy
vim.keymap.set('n', '<D-c>', '"+yy')     -- Normal mode copy line
vim.keymap.set('n', '<D-v>', '"+P')      -- Normal mode paste
vim.keymap.set('i', '<D-v>', '<C-r>+')   -- Insert mode paste
vim.keymap.set('v', '<D-v>', '"_dP')      -- Visual mode paste

-- 📦 Plugin Management with Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- This line tells lazy to load plugin specs from the lua/plugins/ directory
require("lazy").setup("plugins")

-- Load centralized keymaps (VSCode/Cursor-like)
require("config.keymaps")

-- File Definitions
vim.cmd [[autocmd BufNewFile,BufRead *.tf,*.tfvars set filetype=terraform]]
