local utils = require("g0.utils")

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
  print(last_command)
  local buf = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(buf)
  local cmd

  -- read last user cmd to determine the vim mode
  -- if the last cmd contains '<,'>, it was in visual mode
  if string.match(last_command, '\'<,\'>') then
    local start_line = vim.fn.line("'<") -- Start line
    local end_line = vim.fn.line("'>") -- End line
    cmd = string.format("gomodifytags -file %s -line=%s", filename, start_line..","..end_line)

    if not string.match(args, '-add-tags') then
      cmd = cmd .. " -add-tags=json"
    end

    cmd = cmd .. " " .. args
  else
    local current_line = vim.fn.line('.')
    print(current_line)
  end

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
    vim.notify("Error: gomodifytags failed ".. result[1], vim.log.levels.ERROR)
  end
end

M.remove_tag = function()
end

return M
