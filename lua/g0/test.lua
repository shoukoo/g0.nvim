local utils = require("g0.utils")
local c = require("g0.config")
local M = {}

local float_win = function(buf, title)
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
    title = title .. " | press q to quit",
  })

  vim.cmd([[
      hi GoTestResultFail guifg=#FF4000
      match GoTestResultFail /--- FAIL/
  ]])
  return win_id
end

local parse_args = function(args, config)
  local is_verbose = config.gotest.verbose
  if not string.match(args, utils.escape_pattern("-v")) and is_verbose then
    local flag = "-v"
    if string.sub(args, -1) ~= " " then
      flag = " " .. flag
    end
    args = args .. flag
  end
  return args
end


M.history = function()
  local buf = vim.api.nvim_create_buf(false, true) -- Create a new buffer
  for _, line in ipairs(c._state.test_history) do
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, line)
  end
  local win_id = float_win(buf, "G0TestHistory")
  vim.api.nvim_win_set_cursor(win_id, { vim.fn.line('$'), 0 })
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':lua vim.api.nvim_win_close(' .. win_id .. ', true)<CR>', {
    noremap = true,
    silent = true,
  })
end

M.run = function(args, config, command, title)
  -- getting config
  config = config or c.defaults
  args = parse_args(args or "", config)

  -- creating a commnd
  local buf = vim.api.nvim_create_buf(false, true) -- Create a new buffer

  local win_id = float_win(buf, title)
  vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "> " .. command })
  c.save_history({ "> " .. command })

  local job_id = vim.fn.jobstart(command, {
    on_stdout = function(_, data, _)
      data = utils.handle_job_data(data)
      if not data then
        return
      end
      vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
      c.save_history(data)
      vim.api.nvim_win_set_cursor(win_id, { vim.fn.line('$'), 0 })
    end,
    on_stderr = function(_, data, _)
      data = utils.handle_job_data(data)
      if data then
        vim.notify('gotest failed ' .. vim.inspect(data), vim.log.levels.ERROR)
        return
      end
    end,
    on_exit = function(_, status)
      if status == 0 then
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "completed" })
        vim.api.nvim_win_set_cursor(win_id, { vim.fn.line('$'), 0 })
      else
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "failed" })
        vim.api.nvim_win_set_cursor(win_id, { vim.fn.line('$'), 0 })
      end

    end,
  })

  -- Set the key mapping using luaeval
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q',
    [[:lua vim.api.nvim_win_close(]] .. win_id .. [[, true) vim.fn.jobstop(]] .. job_id .. [[)<CR>]], {
    noremap = true,
    silent = true,
    expr = false,
  })

  -- Asynchronous timer to check for updates every 500 milliseconds
  local timer = vim.loop.new_timer()
  vim.loop.timer_start(timer, 500, 0, vim.schedule_wrap(function()
    if not vim.fn.jobwait({ job_id }, 0)[1] == -1 then
      -- The job has finished
      vim.fn.timer_stop(timer)
      vim.fn.jobstop(job_id)
    end
  end))

end

M.test_current_dir = function(args, config)
  config = config or require("g0.config").defaults
  args = parse_args(args or "", config)

  local buffer_name = vim.fn.bufname('%') -- Get the full path of the current buffer
  local current_directory = vim.fn.fnamemodify(buffer_name, ':h') -- Get the directory part

  local command = "cd " .. current_directory .. " && go test ./..."
  if args and args ~= "" then
    -- if no space pre append to args then add one
    if string.sub(args, 1, 1) ~= " " then
      args = " " .. args
    end
    command = command .. args
  end

  M.run(args, config, command, "G0TestCurrentDir")
end

-- test_current only read the "-v" argument
M.test_current = function(args, config)
  config = config or require("g0.config").defaults
  args = parse_args(args or "", config)

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
    local command = "cd " .. current_directory .. " && go test -run=" .. function_name
    if args and args ~= "" then
      -- if no space pre append to args then add one
      if string.sub(args, 1, 1) ~= " " then
        args = " " .. args
      end
      command = command .. args
    end

    M.run(args, config, command, "G0TestCurrent")
  else
    vim.notify("Not inside a function", vim.log.levels.ERROR)
  end
end

return M
