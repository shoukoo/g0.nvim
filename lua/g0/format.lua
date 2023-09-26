local M = {}
local api = vim.api
local fn = vim.fn
local utils = require "g0.utils"

M.goimports = function()
  require('g0.install').install("goimports")

  local buf = api.nvim_get_current_buf()

  -- if the change is not saved or a new unsaved file then call write
  if fn.getbufinfo('%')[1].changed == 1 then
    vim.cmd('write')
  end

  local cmd = { 'goimports', vim.api.nvim_buf_get_name(buf) }
  local job_id = fn.jobstart(cmd, {
    on_stdout = function(_, data, _)
      data = utils.handle_job_data(data)
      if not data then
        return
      end
      api.nvim_buf_set_lines(0, 0, -1, false, data)
    end,
    on_stderr = function(_, data, _)
      data = utils.handle_job_data(data)
      if data then
        return vim.notify('goimports failed ' .. vim.inspect(data), vim.log.levels.ERROR)
      end
    end,
    on_exit = function(_, data, _)
      if data ~= 0 then
        return vim.notify('goimports failed ' .. tostring(data), vim.log.levels.ERROR)
      end
    end,
    stdout_buffered = true,
    stderr_buffered = true,
  })

  fn.jobwait({job_id})

  if job_id <= 0 then
    vim.notify("Error: unable to start goimports")
  end

end

return M
