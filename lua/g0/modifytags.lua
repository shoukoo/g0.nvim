local utils = require("g0.utils")

local M = {}
-- add json tag to all structs on that file
-- gomodifytags -file api/queries_pr.go -all -add-tags=json
-- add json tag based on the lines
-- gomodifytags -file api/queries_pr.go -line=16,19 -add-tags=jso
-- add json tag based on offset(bytes), this will transform the entire struct
-- gomodifytags -file api/queries_pr.go -offset=520 -add-tags=json
M.add_tags = function(...)
  P(...)
  local cmd = vim.fn.getcmdline()
  print("hello")
  print(cmd)
  -- local current_mode = vim.fn.mode()
  local current_mode = vim.fn.visualmode('v')
  print(current_mode)
  -- Get the start and end lines of the visual selection
  local start_line = vim.fn.line("'<") -- Start line
  local end_line = vim.fn.line("'>") -- End line
  local current_line = vim.fn.line('.')
  print(start_line)
  print(end_line)
  print(current_line)

  -- Iterate over the lines in the range and do something
  -- for line = start_line, end_line do
  --   -- Your logic here, using 'line' to access individual lines
  --   -- For example, you can use vim.fn.getline(line) to get the content of the line
  --   print("Line " .. line .. ": " .. vim.fn.getline(line))
  -- end
end

M.remove_tag = function()
end

return M
