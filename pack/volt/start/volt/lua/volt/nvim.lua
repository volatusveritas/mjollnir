local M = {}

----------------------------------- Imports -----------------------------------
local vmath = require('volt.math')
    local vector2 = vmath.vector2
-------------------------------------------------------------------------------

--------------------------------- Public API ----------------------------------
function M.screen_height()
    return vim.o.lines - vim.o.cmdheight - 1
end

function M.screen_width()
    return vim.o.columns
end

function M.screen_size()
    return vector2(M.screen_width(), M.screen_height())
end
-------------------------------------------------------------------------------

return M
