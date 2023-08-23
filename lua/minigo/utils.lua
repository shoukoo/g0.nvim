local M = {}

M.is_windows = function ()
  local os_name = vim.loop.os_uname().sysname
  return os_name == 'Windows' or os_name == 'Windows_NT'
end

M.join_path = function()
  if M.is_windows() then
    return '\\'
  end
  return '/'
end

M.extension= function()
  if M.is_windows() then
    return '.exe'
  end
  return ''
end

return M
