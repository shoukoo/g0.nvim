local M = {}

local float_win = function(buf, cmd)
  local width = math.floor(vim.o.columns * 0.8) -- 50% of the current window width
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  -- Create the floating window
  local win_id = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    zindex = 250,
    border = "single",
    title = "press q to quit | cmd: " .. cmd,
  })
  return win_id
end

M.test_current_dir = function(args, config)
  config = config or require("g0.config").defaults

  local buf = vim.api.nvim_create_buf(false, true) -- Create a new buffer

  local buffer_name = vim.fn.bufname('%') -- Get the full path of the current buffer
  local current_directory = vim.fn.fnamemodify(buffer_name, ':h') -- Get the directory part

  local command = "cd " .. current_directory .. " && go test ./..."
  if args and args ~= "" then
    command = command .. " " .. args
  end

  local win_id = float_win(buf, command)

  vim.cmd("term " .. command)
  vim.api.nvim_win_set_cursor(win_id, { vim.fn.line('$'), 0 })

  -- Close the floating window when pressing 'q'
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':lua vim.api.nvim_win_close(' .. win_id .. ', true)<CR>', {
    noremap = true,
    silent = true,
  })

end

-- test_current only read the "-v" argument
M.test_current = function(args, config)
  config = config or require("g0.config").defaults

  -- Query Tree-sitter for the current function node
  local node = vim.treesitter.get_node()

  -- Traverse up the tree until we find the function node
  while node and node:type() ~= 'function_declaration' do
    node = node:parent()
  end


  if node then
    local buffer_name = vim.fn.bufname('%') -- Get the full path of the current buffer

    -- Chech if the file name has "_test.go"
    if not string.find(buffer_name, "_test.go$") then
      vim.notify("This is not a Go test file", vim.log.levels.ERROR)
      return
    end

    local current_directory = vim.fn.fnamemodify(buffer_name, ':h') -- Get the directory part
    local function_name = vim.treesitter.get_node_text(node:child(1), 0)
    local command = "cd " .. current_directory .. " && go test -run " .. function_name
    if args and args ~= "" then
      command = command .. " " .. args
    end

    local buf = vim.api.nvim_create_buf(false, true) -- Create a new buffer
    local win_id = float_win(buf, command)

    vim.cmd("term " .. command)
    vim.api.nvim_win_set_cursor(win_id, { vim.fn.line('$'), 0 })

    -- Close the floating window when pressing 'q'
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':lua vim.api.nvim_win_close(' .. win_id .. ', true)<CR>', {
      noremap = true,
      silent = true,
    })

  else
    vim.notify("Not inside a function", vim.log.levels.ERROR)
  end
end

return M
