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

      -- Keymap to toggle preview
      vim.keymap.set('n', '<leader>mp', '<cmd>MarkdownPreviewToggle<cr>',
        { desc = 'Toggle markdown preview' })
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

      -- Enable checkbox toggling with <leader>x
      vim.g.bullets_checkbox_markers = ' .oOX'
      vim.keymap.set('n', '<leader>mx', '<cmd>ToggleCheckbox<cr>',
        { desc = 'Toggle markdown checkbox' })
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

      -- Keybinding to toggle table mode
      vim.keymap.set('n', '<leader>mt', '<cmd>TableModeToggle<cr>',
        { desc = 'Toggle table mode' })
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

      -- Keymap to generate TOC
      vim.keymap.set('n', '<leader>mtoc', '<cmd>GenTocGFM<cr>',
        { desc = 'Generate markdown TOC' })
    end,
  },
}
