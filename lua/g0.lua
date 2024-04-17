local M = {}

M.setup = function(opts)
  local config = require('g0.config').merge(opts)
  require("g0.config").override_default(config)
  require("g0.commands").add_cmds(config)
end

return M
