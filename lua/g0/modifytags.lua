local utils = require("g0.utils")
local tsutil = require('nvim-treesitter.ts_utils')

-- types
ADD_TAG = 0
REMOVE_TAG = 1
CLEAR_TAG = 2

local M = {}

M.modifytags = function(args, type)
  require('g0.install').install("gomodifytags")

  local maincmd = "'"
  if type == REMOVE_TAG then
    maincmd = "-remove-tags"
  elseif type == ADD_TAG then
    maincmd = "-add-tags"
  elseif type == CLEAR_TAG then
    maincmd = "-clear-tags"
  end

  local last_command = utils.get_last_usr_cmd()
  local buf = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(buf)
  local cmd

  -- read last user cmd to determine the vim mode
  -- if the last cmd contains '<,'>, the cmd was running in visual mode
  if string.match(last_command, '\'<,\'>') then
    local start_line = vim.fn.line("'<") -- Start line
    local end_line = vim.fn.line("'>") -- End line
    cmd = string.format("gomodifytags -file %s -line=%s", filename, start_line .. "," .. end_line)
  else

    -- NOTE: treesitter doesn't return the right node when providing a position in the get_node func
    -- the column calculation is different between treesitter and vim
    -- vim include the indentation when counting the column where treesitter doesn't
    local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
    row = row - 1

    -- get the first node from the row
    local node = vim.treesitter.get_node({ pos = { row, 1 } })

    if node then
      if node:type() == 'type_declaration' and node:child_count() >= 2 then
        -- 0 based index
        -- inspect child node - type_spec
        local ts_node = node:child(1)
        if ts_node and ts_node:child_count() >= 2 and ts_node:child(1):type() == "struct_type" then
          local struct_name = vim.treesitter.get_node_text(ts_node:child(0), 0)
          -- NOTE: possbiliy a gomodifytags bug where sometimes it doesn't asdd/remove tags
          -- when using -struct flag
          cmd = string.format("gomodifytags -file=%s -struct=%s", filename, struct_name)
        end
      end

      if node:type() == 'field_identifier' then
        -- revert row back to normal line number
        cmd = string.format("gomodifytags -file=%s -line=%s", filename, row + 1)
      end
    end
  end

  if vim.fn.getbufinfo('%')[1].changed == 1 then
    vim.cmd('write')
  end

  if not string.match(args, maincmd) then
    if not type == CLEAR_TAG then
      cmd = cmd .. " " .. maincmd .. "=json"
    else
      cmd = cmd .. " " .. maincmd
    end
  end

  cmd = cmd .. " " .. args

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
        return vim.notify('gomodifytags failed ' .. vim.inspect(data), vim.log.levels.ERROR)
      end
    end,
    stdout_buffered = true,
    stderr_buffered = true,
  })

  local result = vim.fn.jobwait({ job_id }, 1000)

  if result[1] == -1 then
    vim.notify("Error: gomodifytags timeout", vim.log.levels.ERROR)
  elseif result[1] < 0 then
    vim.notify("Error: gomodifytags failed " .. result[1], vim.log.levels.ERROR)
  end
end

M.remove_tags = function(...)
  local args = ... or ""
  M.modifytags(args, REMOVE_TAG)
end

M.add_tags = function(...)
  local args = ... or ""
  M.modifytags(args, ADD_TAG)
end

M.clear_tags = function(...)
  local args = ... or ""
  M.modifytags(args, CLEAR_TAG)
end

return M
