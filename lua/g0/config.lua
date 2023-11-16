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
    tags = "json"
  },
  debug = false,
  -- timeout in seconds, mainly used by goimports
  timeout = 1000
}

M.merge = function(opts)
  return vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

return M
