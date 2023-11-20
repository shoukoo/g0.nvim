local M = {}

local create_cmd = function(cmd, func, opt)
  opt = vim.tbl_extend('force', { desc = 'g0.nvim ' .. cmd }, opt or {})
  vim.api.nvim_create_user_command(cmd, func, opt)
end

M.add_cmds = function(config)
  create_cmd('G0TestCurrentDir', function(opts)
    require('g0.test').test_current_dir(opts.args, config)
  end, { nargs = "*" })

  create_cmd('G0TestCurrent', function(opts)
    require('g0.test').test_current(opts.args, config)
  end, { nargs = '*' })

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
    require('g0.format').goimports(config)
  end)

  create_cmd('G0AddTags', function(opts)
    require('g0.modifytags').add_tags(opts.args, config)
  end, { nargs = '*', range=true })

  create_cmd('G0RemoveTags', function(opts)
    require('g0.modifytags').remove_tags(opts.args, config)
  end, { nargs = '*', range=true })

  create_cmd('G0ClearTags', function(opts)
    require('g0.modifytags').clear_tags(opts.args, config)
  end, { nargs = '*', range=true })
end

return M
