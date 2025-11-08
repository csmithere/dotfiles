-- Terraform-specific plugins
return {
  -- Better Terraform syntax and filetype detection
  {
    'hashivim/vim-terraform',
    ft = { 'terraform', 'hcl' },
    config = function()
      -- Enable terraform fmt on save (via the plugin)
      vim.g.terraform_fmt_on_save = 1

      -- Enable terraform alignment
      vim.g.terraform_align = 1

      -- Fold resources and modules by default
      vim.g.terraform_fold_sections = 1
    end,
  },

  -- Terraform documentation lookup
  {
    'juliosueiras/vim-terraform-completion',
    ft = { 'terraform', 'hcl' },
    dependencies = {
      'hashivim/vim-terraform',
    },
  },
}
