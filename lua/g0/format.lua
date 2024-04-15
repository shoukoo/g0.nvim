local M = {}
local utils = require "g0.utils"

M.goimports = function(config)
  require('g0.install').install("goimports")
  config = config or require("g0.config").defaults

  local buf = vim.api.nvim_get_current_buf()

  -- if the change is not saved or a new unsaved file then call write
  if vim.fn.getbufinfo('%')[1].changed == 1 then
    vim.cmd('write')
  end

  local cmd = { 'goimports', vim.api.nvim_buf_get_name(buf) }
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
        vim.notify('goimports failed ' .. vim.inspect(data), vim.log.levels.ERROR)
        return
      end
    end,
    stdout_buffered = true,
    stderr_buffered = true,
  })

  local result = vim.fn.jobwait({ job_id }, config.timeout)

  if result[1] == -1 then
    vim.notify("Error: goimports timeout", vim.log.levels.ERROR)
  end

end

M.lsp_format = function()
  vim.lsp.buf.format({
    bufnr = vim.api.nvim_get_current_buf(),
    name = 'gopls',
  })
  if vim.fn.getbufinfo('%')[1].changed == 1 then
    vim.cmd('noautocmd write')
  end
end

M.lsp_imports = function(config)
  config = config or require("g0.config").defaults

  local params = vim.lsp.util.make_range_params()
  params.context = { only = { "source.organizeImports" } }

  local gopls = M.client()
  print(gopls)
  if gopls == nil then
    vim.notify('gopls not found', vim.log.levels.ERROR)
    return
  end
  --
  -- buf_request_sync defaults to a 1000ms timeout. Depending on your
  -- machine and codebase, you may want longer. Add an additional
  -- argument after params if you find that you have to write the file
  -- twice for changes to be saved.
  -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, config.timeout)
  vim.notify("Error: goimports timeout", vim.inspect(result), vim.log.levels.ERROR)

  for cid, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do
      if r.edit then
        local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
        vim.lsp.util.apply_workspace_edit(r.edit, enc)
      end
    end
  end
  vim.lsp.buf.format({ async = false })

  if vim.fn.getbufinfo('%')[1].changed == 1 then
    vim.cmd('noautocmd write')
  end
end


M.client = function()
  local clients = vim.lsp.get_active_clients({
    bufnr = vim.api.nvim_get_current_buf(),
    name = 'gopls',
  }) or {}
  return clients[1]
end

return M
