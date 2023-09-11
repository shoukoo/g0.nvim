local M = {}

M.goimports = function()
  require('minigo.install').install("goimports")

  local buf = vim.api.nvim_get_current_buf()
  -- if the change is not saved or a new unsaved file then call write
  if vim.fn.getbufinfo('%')[1].changed == 1 then
    vim.cmd('write')
  end

  local cmd = { 'goimports', '-w', '-l', vim.api.nvim_buf_get_name(buf) }
  local job_id = vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        -- reload the buffer if goimports ran successfully
        vim.cmd('edit')
      end
    end,
  })

  if job_id <= 0 then
    vim.notify("Error: unable to start goimports")
  end

end

return M

