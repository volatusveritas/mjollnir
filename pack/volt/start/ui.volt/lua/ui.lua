local M = {}

--------------------------------- Public API ----------------------------------
-- Takes cmdline and statusline into account when fetching the screen height
function M.get_screen_height()
    return vim.o.lines - vim.o.cmdheight - 1
end

function M.input(opts)
    -- prompt (string) Prompt to give the user
    -- callback (function) The function to call for accepting the input
end
-------------------------------------------------------------------------------

return M
