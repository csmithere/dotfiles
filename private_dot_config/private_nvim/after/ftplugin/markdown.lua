-- Markdown-specific settings
-- This file is automatically loaded when opening .md files

-- Enable spell checking
vim.opt_local.spell = true
vim.opt_local.spelllang = 'en_us'

-- Text wrapping settings for better writing experience
vim.opt_local.wrap = true          -- Enable line wrap
vim.opt_local.linebreak = true     -- Break at word boundaries
vim.opt_local.breakindent = true   -- Maintain indent when wrapping
vim.opt_local.showbreak = '↪ '     -- Show wrapped line indicator

-- Softer text width for markdown
vim.opt_local.textwidth = 80

-- Concealment for cleaner markdown display
vim.opt_local.conceallevel = 2     -- Hide markup syntax
vim.opt_local.concealcursor = 'nc' -- But show it in insert mode

-- Use 2-space indentation for markdown (common convention)
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.expandtab = true

-- Markdown-specific keymaps
local opts = { noremap = true, silent = true, buffer = true }

-- Toggle spell check
vim.keymap.set('n', '<leader>ms', function()
  vim.opt_local.spell = not vim.opt_local.spell:get()
  print('Spell check: ' .. (vim.opt_local.spell:get() and 'ON' or 'OFF'))
end, vim.tbl_extend('force', opts, { desc = 'Toggle spell check' }))

-- Insert common markdown elements
vim.keymap.set('n', '<leader>mb', 'viw<esc>a**<esc>hbi**<esc>lel',
  vim.tbl_extend('force', opts, { desc = 'Bold word' }))
vim.keymap.set('n', '<leader>mi', 'viw<esc>a*<esc>hbi*<esc>lel',
  vim.tbl_extend('force', opts, { desc = 'Italic word' }))
vim.keymap.set('n', '<leader>mc', 'viw<esc>a`<esc>hbi`<esc>lel',
  vim.tbl_extend('force', opts, { desc = 'Code word' }))

-- Visual mode markdown formatting
vim.keymap.set('v', '<leader>mb', '<esc>`>a**<esc>`<i**<esc>',
  vim.tbl_extend('force', opts, { desc = 'Bold selection' }))
vim.keymap.set('v', '<leader>mi', '<esc>`>a*<esc>`<i*<esc>',
  vim.tbl_extend('force', opts, { desc = 'Italic selection' }))
vim.keymap.set('v', '<leader>mc', '<esc>`>a`<esc>`<i`<esc>',
  vim.tbl_extend('force', opts, { desc = 'Code selection' }))

-- Insert link
vim.keymap.set('n', '<leader>ml', 'viw<esc>a]()<esc>i[<esc>pa',
  vim.tbl_extend('force', opts, { desc = 'Insert link' }))

-- Better navigation for wrapped lines
vim.keymap.set('n', 'j', 'gj', opts)
vim.keymap.set('n', 'k', 'gk', opts)
vim.keymap.set('n', '0', 'g0', opts)
vim.keymap.set('n', '$', 'g$', opts)

-- Enable better list formatting
vim.opt_local.formatoptions:append('n')  -- Recognize numbered lists
vim.opt_local.formatlistpat = [[^\s*\d\+[\]:.)}\t ]\s*]]  -- Pattern for numbered lists
