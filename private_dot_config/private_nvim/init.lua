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

-- Black-hole register remaps: d/c/x delete without yanking (VS Code behavior)
-- Use "_ prefix so delete/change never touch the clipboard; only y/yy copies.
-- Escape hatch: "+d or "ad to explicitly yank-delete into a register.
local bh = { noremap = true, silent = true }

-- Normal mode delete operators → black hole
vim.keymap.set('n', 'd', '"_d', bh)
vim.keymap.set('n', 'dd', '"_dd', bh)
vim.keymap.set('n', 'D', '"_D', bh)

-- Normal mode change operators → black hole
vim.keymap.set('n', 'c', '"_c', bh)
vim.keymap.set('n', 'cc', '"_cc', bh)
vim.keymap.set('n', 'C', '"_C', bh)

-- Normal mode character delete → black hole
vim.keymap.set('n', 'x', '"_x', bh)
vim.keymap.set('n', 'X', '"_X', bh)

-- Visual mode delete/change → black hole
vim.keymap.set('v', 'd', '"_d', bh)
vim.keymap.set('v', 'c', '"_c', bh)
vim.keymap.set('v', 'x', '"_x', bh)

-- Visual mode paste: replace selection without yanking replaced text
vim.keymap.set('v', 'p', '"_dP', bh)
vim.keymap.set('v', 'P', '"_dP', bh)

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
