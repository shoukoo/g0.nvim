local utils = require("g0.utils")

local M = {}
-- add json tag to all structs on that file
-- gomodifytags -file api/queries_pr.go -all -add-tags=json
M.go_add_tags = function ()
end

M.go_remove_tag= function ()
end

return M
