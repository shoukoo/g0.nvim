local M = {}

local create_cmd = function(cmd, func, opt)
  opt = vim.tbl_extend('force', { desc = 'go.nvim ' .. cmd }, opt or {})
  vim.api.nvim_create_user_command(cmd, func, opt)
end

M.add_cmds = function()
  create_cmd('G0Imports', function(_)
    require('g0.format').goimports()
  end)
end

return M
