local M = {}
local api = vim.api
local fn = vim.fn

M.go_test_dir = function()
  local current_directory = vim.fn.expand('%:p:h')
  local test_command = 'go test -v ./...'

  vim.cmd('split')
  vim.cmd('resize ' .. 10)
  local winh = api.nvim_get_current_win()
  local bufh = api.nvim_create_buf(true, true)
  api.nvim_win_set_buf(winh, bufh)
  api.nvim_set_current_win(winh)

  fn.termopen(test_command, {
    cwd = current_directory,
    on_exit = function(term_id, exit_code)
      print('Go tests finished with exit code: ' .. exit_code)
      -- Close the terminal after the command has finished
      fn.termclose(term_id)
    end,
    open_terminal = true, -- Open a terminal window
  })
end

return M
