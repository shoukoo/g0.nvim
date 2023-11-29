local M = {}

M.defaults = {
  gotest = {
    -- run go test in verbose mode
    verbose = false
  },
  gomodifytags = {
    -- https://github.com/fatih/gomodifytags#transformations
    -- Transform adds a transform rule when adding tags.
    -- Current options: [snakecase, camelcase, lispcase, pascalcase, titlecase, keep]
    transform = "snakecase",
    -- Add/Remove tags for the comma separated list of keys. i.e.: json,xml
    tags = "json",
    -- Add the options per given key. i.e: json=omitempty,hcl=squash
    options = ""
  },
  debug = false,
  -- timeout in seconds, mainly used by goimports
  timeout = 1000
}

M._state = {
  -- store both history from both g0testcurrent and g0testcurrentdir
  -- limit is 1000
  test_history = {}
}

--@param history table
M.save_history = function(history)
  table.insert(M._state.test_history, history)

  local max_history_length = 1000
  local current_length = #M._state.test_history

  -- If the length exceeds 1000, remove the earlier elements
  if current_length > max_history_length then
    local excess = current_length - max_history_length
    for i = 1, excess do
      table.remove(M._state.test_history, 1)
    end
  end
end


M.merge = function(opts)
  return vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

return M
