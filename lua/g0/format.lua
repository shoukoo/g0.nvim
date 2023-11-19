local M = {}
local utils = require "g0.utils"

M.goimports = function(config)
  require('g0.install').install("goimports")
  config = config or require("g0.config").defaults

  local buf = vim.api.nvim_get_current_buf()

  -- if the change is not saved or a new unsaved file then call write
  if vim.fn.getbufinfo('%')[1].changed == 1 then
    vim.cmd('write')
  end

  local cmd = { 'goimports', vim.api.nvim_buf_get_name(buf) }
  local job_id = vim.fn.jobstart(cmd, {
    on_stdout = function(_, data, _)
      data = utils.handle_job_data(data)
      if not data then
        return
      end
      vim.api.nvim_buf_set_lines(0, 0, -1, false, data)
    end,
    on_stderr = function(_, data, _)
      data = utils.handle_job_data(data)
      if data then
        vim.notify('goimports failed ' .. vim.inspect(data), vim.log.levels.ERROR)
        return
      end
    end,
    stdout_buffered = true,
    stderr_buffered = true,
  })

  local result = vim.fn.jobwait({ job_id }, config.timeout)

  if result[1] == -1 then
    vim.notify("Error: goimports timeout", vim.log.levels.ERROR)
  end

end

return M
