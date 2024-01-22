local M = {}

----------------------------------- Imports -----------------------------------
local ui = require('volt.ui')
local vlua = require('volt.vlua')
-------------------------------------------------------------------------------

--------------------------------- Public API ----------------------------------
function M.cmdline()
    ui.input('cmdline', { oy = 0.375 }, function(command)
        vim.schedule(function() vim.cmd(command) end)
    end)
end
-------------------------------------------------------------------------------

return M
