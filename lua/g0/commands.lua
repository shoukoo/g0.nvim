local M = {}

local create_cmd = function(cmd, func, opt)
  opt = vim.tbl_extend('force', { desc = 'go.nvim ' .. cmd }, opt or {})
  vim.api.nvim_create_user_command(cmd, func, opt)
end

M.add_cmds = function()
  create_cmd('G0TestDir', function(_)
    require('g0.test').go_test_dir()
  end)

  create_cmd('G0Install', function(opts)
    require('g0.install').install(unpack(opts.fargs))
  end, { nargs = '*' })

  create_cmd('G0InstallAll', function(_)
    require('g0.install').install_all()
  end)

  create_cmd('G0UpdateAll', function(_)
    require('g0.install').update_all()
  end)

  create_cmd('G0Imports', function(_)
    require('g0.format').goimports()
  end)
end

return M
