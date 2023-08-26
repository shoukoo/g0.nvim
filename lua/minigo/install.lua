local uv = vim.loop
local utils = require("minigo.utils")

local M = {}

M.get_path_env = function ()
  local sep = utils.sep()
  local env_path = os.getenv('PATH')
  local base_paths = vim.split(env_path, sep, true)
  return base_paths
end


M.is_installed = function(bin)
  local extension = utils.extension()
  local join_path = utils.join_path()


  if vim.fn.executable(bin) == 1 then
    return true
  end

  local base_paths = M.get_path_env()

  for _, value in pairs(base_paths) do
    if uv.fs_stat(value .. join_path .. bin .. extension) then
      return true
    end
  end

  return false
end


return M
