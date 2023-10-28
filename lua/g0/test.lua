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

local set_args = function(...)
  local args = ... or {}
  local options = {}
  for _, value in ipairs(args) do
    if value == "-v" then
      options["verbose"] = true
    end
  end
  return options
end

M.test_current_dir = function(...)

  local args = ...
  local buf = vim.api.nvim_create_buf(false, true) -- Create a new buffer

  local buffer_name = vim.fn.bufname('%') -- Get the full path of the current buffer
  local current_directory = vim.fn.fnamemodify(buffer_name, ':h') -- Get the directory part

  local command = "cd " .. current_directory .. " && go test ./..."
  if args then
    command = command .. " " .. table.concat(args, " ")
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
M.test_current = function(...)

  local args = ...

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
    if args then
      command = command .. " " .. table.concat(args, " ")
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

M.popup = function(helpfulText, width, height)
    -- Create a new buffer for the popup window
    local buf = vim.api.nvim_create_buf(false, true)

    -- Calculate dimensions if not provided
    if not width then
        width = 40
    end
    if not height then
        height = 1
    end

    -- Set buffer options to allow text input
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')

    -- Set the content in the buffer with centered helpful text
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {"go test ./..."})


    -- Calculate the position to center the window
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    -- Create the popup window
    local win_id = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'single',
        title = helpfulText
    })

    -- Enter insert mode in the popup window
    vim.api.nvim_set_current_win(win_id)
    vim.api.nvim_feedkeys('i', 'n', true)

    -- Handle keypress events in the popup
    vim.api.nvim_buf_set_keymap(buf, 'i', '<CR>', '<Esc>:lua handle_popup_input()<CR>',{})
    vim.api.nvim_buf_set_keymap(buf, 'i', '<Esc>', '<Esc>:q!<CR>', { noremap = true, silent = true })


    -- Function to handle Enter keypress in the popup
    function handle_popup_input()
        local text = vim.fn.getline(1, '$')
        print(text)
        -- You can process the entered text here
        -- For example, close the popup window or perform actions with the input
        vim.api.nvim_win_close(win_id, true)
    end
end

return M
