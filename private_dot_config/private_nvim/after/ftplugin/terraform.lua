-- Terraform-specific settings
-- This file is automatically loaded when opening .tf files

-- Use 2-space indentation (Terraform standard)
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.expandtab = true

-- Enable auto-formatting on save with terraform fmt
local format_on_save = vim.api.nvim_create_augroup("TerraformFormat", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  group = format_on_save,
  pattern = "*.tf,*.tfvars",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Terraform-specific keymaps
local opts = { noremap = true, silent = true, buffer = true }

-- Format current file
vim.keymap.set('n', '<leader>tf', function()
  vim.cmd('!terraform fmt %')
  vim.cmd('edit!')
end, vim.tbl_extend('force', opts, { desc = 'Terraform format' }))

-- Validate configuration
vim.keymap.set('n', '<leader>tv', function()
  vim.cmd('!terraform validate')
end, vim.tbl_extend('force', opts, { desc = 'Terraform validate' }))

-- Initialize terraform
vim.keymap.set('n', '<leader>ti', function()
  vim.cmd('!terraform init')
end, vim.tbl_extend('force', opts, { desc = 'Terraform init' }))

-- Plan
vim.keymap.set('n', '<leader>tp', function()
  vim.cmd('!terraform plan')
end, vim.tbl_extend('force', opts, { desc = 'Terraform plan' }))

-- Folding for better navigation of large terraform files
vim.opt_local.foldmethod = 'indent'
vim.opt_local.foldlevel = 99  -- Start with all folds open
