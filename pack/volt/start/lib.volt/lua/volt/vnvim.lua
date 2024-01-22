local M = {}

--------------------------------- Public API ----------------------------------
function M.get_screen_height()
    return vim.o.lines - vim.o.cmdheight - 1
end
-------------------------------------------------------------------------------

return M
