local M = {}
local api = vim.api
local o = vim.o
local fn = vim.fn

M.test_current_dir = function()

  local buf = api.nvim_create_buf(false, true) -- Create a new buffer

  local buffer_name = fn.bufname('%') -- Get the full path of the current buffer
  local current_directory = fn.fnamemodify(buffer_name, ':h') -- Get the directory part

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

  local command = "cd " .. current_directory .. " && go test ./..."
  print(command)

  vim.cmd("term " .. command)
  api.nvim_win_set_cursor(win_id, { fn.line('$'), 0 })

  -- Example: Close the floating window when pressing 'q'
  api.nvim_buf_set_keymap(buf, 'n', 'q', ':lua vim.api.nvim_win_close(' .. win_id .. ', true)<CR>', {
    noremap = true,
    silent = true,
  })

end

M.test_current = function()

    -- Query Tree-sitter for the current function node
    local node = vim.treesitter.get_node()

    -- Traverse up the tree until we find the function node
    while node and node:type() ~= 'function_declaration' do
        node = node:parent()
    end

    if node then
        local function_name = vim.treesitter.get_node_text(node:child(1), 0)
        print("Function Name:", function_name)
    else
        print("Not inside a function")
    end
end

function extract_golang_function_at_cursor()
  local ts = vim.treesitter.get_parser()
  ts:parse()
  local root = ts:parse()[1]:root()

  -- Get the current cursor position (row and column)
  local cursor_row, cursor_col= unpack(vim.api.nvim_win_get_cursor(0))
  -- local cursor_row = vim.fn.line('.')
  -- local cursor_col = vim.fn.col('.')

  -- Define the Tree-sitter query for Golang function names at the cursor position
  local query = string.format([[
        (function_declaration
            (identifier) @function_name
            (function_parameters)
            (function_body)
        ) @function_parent
    ]], cursor_row, cursor_col)

  -- Execute the query and extract function names
  local function_names = {}
  for capture in root:iter_captures(query) do
    local start_row, _, end_row, _ = capture.function_parent:range()
    if start_row <= cursor_row and cursor_row <= end_row then
      table.insert(function_names, capture.function_name)
    end
  end

  return function_names
end

return M
