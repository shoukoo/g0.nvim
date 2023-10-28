local utils = require("g0.utils")

local M = {}
-- add json tag to all structs on that file
-- gomodifytags -file api/queries_pr.go -all -add-tags=json
-- add json tag based on the lines
-- gomodifytags -file api/queries_pr.go -line=16,19 -add-tags=jso
-- add json tag based on offset(bytes), this will transform the entire struct
-- gomodifytags -file api/queries_pr.go -offset=520 -add-tags=json
M.go_add_tags = function ()
end

M.go_remove_tag= function ()
end

return M
