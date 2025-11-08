-- ~/.config/nvim/lua/plugins/gruvbox.lua

return {
  "ellisonleao/gruvbox.nvim",
  priority = 1000, -- Make sure to load this before all the other start plugins
  config = function()
    -- Setup the theme
    require("gruvbox").setup({
      contrast = "hard",
      -- You can add other options here
    })
    
    -- Load the colorscheme
    vim.cmd([[colorscheme gruvbox]])
  end,
}
