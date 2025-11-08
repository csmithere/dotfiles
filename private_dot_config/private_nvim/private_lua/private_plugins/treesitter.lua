return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup({
      ensure_installed = {
        "c",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "terraform",
        "hcl",           -- HashiCorp Configuration Language
        "markdown",
        "markdown_inline",
        "yaml",
        "json",          -- Often used with YAML
      },
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
    })
  end
}
