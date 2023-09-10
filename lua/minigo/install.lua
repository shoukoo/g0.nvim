local uv = vim.loop
local utils = require("minigo.utils")

local M = {}

local pkgs = {
  goimports = 'golang.org/x/tools/cmd/goimports',
  gomodifytags = 'github.com/fatih/gomodifytags',
  -- gopls = 'golang.org/x/tools/gopls',
  -- govulncheck = 'golang.org/x/vuln/cmd/govulncheck',

}

M.get_path_env = function()
  local sep = utils.sep()
  local env_path = os.getenv('PATH')
  local base_paths = vim.split(env_path, sep, true)
  return base_paths
end


M.is_installed = function(pkg)
  local extension = utils.extension()
  local join_path = utils.join_path()


  if vim.fn.executable(pkg) == 1 then
    return true
  end

  local base_paths = M.get_path_env()

  for _, value in pairs(base_paths) do
    if uv.fs_stat(value .. join_path .. pkg .. extension) then
      return true
    end
  end

  return false
end

M.install = function(pkg)
  local u = pkgs[pkg]
  if u == nil then
    vim.notify(
      'command ' .. pkg .. ' not supported, please update install.lua, or manually install it',
      vim.log.levels.WARN
    )
    return
  end

  if M.is_installed(pkg)then
    return
  end

  u = u .. '@latest'
  local setup = { 'go', 'install', u }

  vim.fn.jobstart(setup, {
    on_stdout = function(_, data, _)
      -- log(setup)
      if type(data) == 'table' and #data > 0 then
        data = table.concat(data, ' ')
      end
      local msg = 'install ' .. u .. ' finished'
      if #data > 1 then
        msg = msg .. data
      end
      vim.notify(msg, vim.log.levels.INFO)
    end,
  })
end

M.install_all = function()
  for name, _ in pairs(pkgs) do
    if not M.is_installed(name) then
      vim.notify('installing ' .. name, vim.log.levels.INFO)
      M.install(name)
    else
      vim.notify('skip, ' .. name .. " has been installed", vim.log.levels.INFO)
    end
  end
end

M.update_all = function()
  for name, _ in pairs(pkgs) do
    vim.notify('updating ' .. name, vim.log.levels.INFO)
    M.install(name)
  end
end


return M
