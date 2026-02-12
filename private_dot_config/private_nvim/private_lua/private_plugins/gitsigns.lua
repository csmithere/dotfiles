-- ~/.config/nvim/lua/plugins/gitsigns.lua

return {
  'lewis6991/gitsigns.nvim',
  event = "BufReadPre",
  opts = {
    on_attach = function(bufnr)
      local gs = require('gitsigns')
      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      -- Hunk navigation
      map('n', ']c', function()
        if vim.wo.diff then return ']c' end
        vim.schedule(function() gs.next_hunk() end)
        return '<Ignore>'
      end, 'Next hunk')

      map('n', '[c', function()
        if vim.wo.diff then return '[c' end
        vim.schedule(function() gs.prev_hunk() end)
        return '<Ignore>'
      end, 'Previous hunk')

      -- Actions
      map('n', '<leader>hs', gs.stage_hunk, 'Stage hunk')
      map('n', '<leader>hr', gs.reset_hunk, 'Reset hunk')
      map('v', '<leader>hs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Stage hunk')
      map('v', '<leader>hr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, 'Reset hunk')
      map('n', '<leader>hu', gs.undo_stage_hunk, 'Undo stage hunk')
      map('n', '<leader>hp', gs.preview_hunk, 'Preview hunk')
      map('n', '<leader>hb', function() gs.blame_line({ full = true }) end, 'Blame line')
      map('n', '<leader>tb', gs.toggle_current_line_blame, 'Toggle line blame')
      map('n', '<leader>hd', gs.diffthis, 'Diff this')
    end,
  },
}
