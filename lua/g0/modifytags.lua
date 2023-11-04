local utils = require("g0.utils")
local tsutil = require('nvim-treesitter.ts_utils')

local M = {}
-- add json tag to all structs on that file
-- gomodifytags -file api/queries_pr.go -all -add-tags=json
-- add json tag based on the lines
-- gomodifytags -file api/queries_pr.go -line=16,19 -add-tags=jso
-- add json tag based on offset(bytes), this will transform the entire struct
-- gomodifytags -file api/queries_pr.go -offset=520 -add-tags=json
M.add_tags = function(...)
  require('g0.install').install("gomodifytags")

  local args = ... or ""

  local last_command = utils.get_last_usr_cmd()
  local buf = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(buf)
  local cmd

  -- read last user cmd to determine the vim mode
  -- if the last cmd contains '<,'>, it was in visual mode
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
    print(node)

    if node and node:type() == 'type_declaration' and node:child_count() >= 2 then
      -- 0 based index
      -- inspect child node - type_spec
      local ts_node = node:child(1)
      if ts_node and ts_node:child_count() >= 2 and ts_node:child(1):type() == "struct_type" then
        local struct_name = vim.treesitter.get_node_text(ts_node:child(0), 0)
        cmd = string.format("gomodifytags -file=%s -struct=%s", filename, struct_name)
      end
    end
    -- -- local cnode = vim.treesitter.get_node()
    -- local cnode = tsutil.get_node_at_cursor()
    -- -- node = tsutil.goto_node(node, true, true)
    -- while node do
    --   -- local crow, _, _, _ = node:range()
    --   print("-------------- row " .. row .. " col " .. col )
    --   -- print(crow .. " " .. row)
    --   print("current node: " .. cnode:type())
    --   print(node:type())
    --   print(node:range())
    --   -- node = node:next_named_sibling()
    --   node = tsutil.get_next_node(node, false, false)
    -- end
  end

  if not string.match(args, '-add-tags') then
    cmd = cmd .. " -add-tags=json"
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
  })

  local result = vim.fn.jobwait({ job_id }, 1000)

  if result[1] == -1 then
    vim.notify("Error: gomodifytags timeout", vim.log.levels.ERROR)
  elseif result[1] < 0 then
    vim.notify("Error: gomodifytags failed " .. result[1], vim.log.levels.ERROR)
  end
end

M.remove_tag = function()
end

return M
