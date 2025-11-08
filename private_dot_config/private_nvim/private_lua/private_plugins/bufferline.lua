
-- ~/.config/nvim/lua/plugins/bufferline.lua

return {
  'akinsho/bufferline.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('bufferline').setup({
      options = {
        mode = 'buffers',
        separator_style = 'thin',
        show_buffer_close_icons = true,
        show_close_icon = true,
      }
    })
  end
}
