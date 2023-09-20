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

M.sep = function()
  if M.is_windows() then
    return ';'
  end
  return ':'
end

M.extension= function()
  if M.is_windows() then
    return '.exe'
  end
  return ''
end

M.handle_job_data = function(data)
  if not data then
    return nil
  end
  -- Because the nvim.stdout's data will have an extra empty line at end on some OS (e.g. maxOS), we should remove it.
  for _ = 1, 3, 1 do
    if data[#data] == '' then
      table.remove(data, #data)
    end
  end
  if #data < 1 then
    return nil
  end
  -- remove ansi escape code
  for i, v in ipairs(data) do
    data[i] = M.remove_ansi_escape(data[i])
  end

  return data
end

M.remove_ansi_escape = function(str)
  local ansi_escape_pattern = '\27%[%d+;%d*;%d*m'
  -- Replace all occurrences of the pattern with an empty string
  str = str:gsub(ansi_escape_pattern, '')
  str = str:gsub('\27%[[%d;]*%a', '')
  return str
end

return M
