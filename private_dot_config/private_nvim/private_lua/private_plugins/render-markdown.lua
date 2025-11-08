-- Markdown rendering configuration
return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons'
  },
  config = function()
    require('render-markdown').setup({
      -- Enable rendering by default
      enabled = true,

      -- Maximum file size to render (in MB)
      max_file_size = 10.0,

      -- Headings configuration
      headings = {
        -- Characters to use for heading icons
        icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
        -- Whether to show heading signs
        sign = true,
        -- Heading background colors
        backgrounds = {
          'RenderMarkdownH1Bg',
          'RenderMarkdownH2Bg',
          'RenderMarkdownH3Bg',
          'RenderMarkdownH4Bg',
          'RenderMarkdownH5Bg',
          'RenderMarkdownH6Bg',
        },
      },

      -- Code block configuration
      code = {
        -- Show code block language
        sign = true,
        -- Width of code blocks
        width = 'block',
        -- Border style
        border = 'thin',
      },

      -- Bullet list configuration
      bullet = {
        icons = { '●', '○', '◆', '◇' },
      },

      -- Checkbox configuration
      checkbox = {
        unchecked = { icon = '󰄱 ' },
        checked = { icon = '󰱒 ' },
      },

      -- Quote configuration
      quote = {
        icon = '▋',
      },

      -- Table configuration
      pipe_table = {
        enabled = true,
        style = 'full',
      },

      -- Link configuration
      link = {
        enabled = true,
        custom = {
          web = { pattern = '^http[s]?://', icon = '󰖟 ' },
        },
      },

      -- Toggle rendering keybinding
      vim.keymap.set('n', '<leader>mr', '<cmd>RenderMarkdown toggle<cr>',
        { desc = 'Toggle markdown rendering' }),
    })
  end,
}
