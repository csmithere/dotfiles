-- YAML-specific settings
-- This file is automatically loaded when opening .yaml/.yml files

-- Use 2-space indentation (YAML standard)
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.expandtab = true

-- Auto-format on save with LSP
local format_on_save = vim.api.nvim_create_augroup("YAMLFormat", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = format_on_save,
  pattern = "*.yaml,*.yml",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Better list handling for YAML
vim.opt_local.formatoptions:append('n')

-- Enable folding based on indentation
vim.opt_local.foldmethod = 'indent'
vim.opt_local.foldlevel = 99  -- Start with all folds open

-- YAML-specific keymaps
local opts = { noremap = true, silent = true, buffer = true }

-- Format current file
vim.keymap.set('n', '<leader>yf', function()
  vim.lsp.buf.format({ async = false })
end, vim.tbl_extend('force', opts, { desc = 'YAML format' }))
