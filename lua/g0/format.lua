local M = {}
local utils = require"g0.utils"

M.goimports = function()
  require('g0.install').install("goimports")

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
      vim.notify('updating..' , vim.log.levels.INFO)
      vim.api.nvim_buf_set_lines(0, 0, -1, false, data)
      vim.cmd("edit")
    end,
    on_stderr = function(_, data, _)
      data = utils.handle_job_data(data)
      if data then
        return vim.notify('goimports failed ' .. vim.inspect(data), vim.log.levels.ERROR)
      end
    end,
    on_exit = function(_, exit_code)
    end,
    stdout_buffered = true,
    stderr_buffered = true,
  })

  if job_id <= 0 then
    vim.notify("Error: unable to start goimports")
  end

end

return M
