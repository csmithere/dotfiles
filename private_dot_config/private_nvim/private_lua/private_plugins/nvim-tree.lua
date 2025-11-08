
-- ~/.config/nvim/lua/plugins/nvim-tree.lua

return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local nvimtree = require("nvim-tree")
    nvimtree.setup({
      view = {
        width = 30,
      },
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = true,
      },
    })

    -- Keymaps
    vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", {
      desc = "Toggle file explorer",
    })
  end,
}
