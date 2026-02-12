-- Markdown-specific plugins
return {
  -- Markdown preview in browser
  {
    'iamcco/markdown-preview.nvim',
    ft = 'markdown',
    build = function()
      vim.fn['mkdp#util#install']()
    end,
    config = function()
      -- Set browser for preview
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_theme = 'dark'

      -- Keymaps are now managed centrally in lua/config/keymaps.lua
    end,
  },

  -- Better bullet and numbered list handling
  {
    'bullets-vim/bullets.vim',
    ft = { 'markdown', 'text' },
    config = function()
      vim.g.bullets_enabled_file_types = {
        'markdown',
        'text',
        'gitcommit',
      }

      -- Enable automatic bullet continuation
      vim.g.bullets_set_mappings = 1

      -- Enable checkbox toggling
      vim.g.bullets_checkbox_markers = ' .oOX'

      -- Keymaps are now managed centrally in lua/config/keymaps.lua
    end,
  },

  -- Table mode for easy table creation and formatting
  {
    'dhruvasagar/vim-table-mode',
    ft = 'markdown',
    config = function()
      -- Use markdown-compatible table corners
      vim.g.table_mode_corner = '|'

      -- Enable table mode for markdown
      vim.g.table_mode_markdown = 1

      -- Keymaps are now managed centrally in lua/config/keymaps.lua
    end,
  },

  -- Markdown TOC generator
  {
    'mzlogin/vim-markdown-toc',
    ft = 'markdown',
    config = function()
      -- Generate GitHub-flavored markdown TOC
      vim.g.vmt_fence_text = 'TOC'
      vim.g.vmt_fence_closing_text = '/TOC'

      -- Keymaps are now managed centrally in lua/config/keymaps.lua
    end,
  },
}
