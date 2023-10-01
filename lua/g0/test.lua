local M = {}
local api = vim.api
local o = vim.o
local fn = vim.fn

M.test_current_dir = function()

  local buf = api.nvim_create_buf(false, true) -- Create a new buffer

  local width = math.floor(o.columns * 0.5) -- 50% of the current window width
  local height = math.floor(o.lines * 0.5)
  local row = math.floor((o.lines - height) / 2)
  local col = math.floor((o.columns - width) / 2)

  -- Create the floating window
  local win_id = api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    zindex = 250,
    border = "single",
    title = "press q to quit",
  })

  -- Run the "go test ./..." command in the specified directory
  local current_directory = fn.expand('%:p:h')
  local command = "cd " .. current_directory .. " && go test ./..."

  vim.cmd("term " .. command)
  api.nvim_win_set_cursor(win_id, { fn.line('$'), 0 })

  -- Example: Close the floating window when pressing 'q'
  api.nvim_buf_set_keymap(buf, 'n', 'q', ':lua vim.api.nvim_win_close(' .. win_id .. ', true)<CR>', {
    noremap = true,
    silent = true,
  })

end

return M
