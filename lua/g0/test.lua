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


return M
