local M = {}

----------------------------------- Imports -----------------------------------
local ui = require('volt.ui')
local vlua = require('volt.lua')
local window = require('volt.window')
-------------------------------------------------------------------------------

--------------------------------- Public API ----------------------------------
function M.cmdline()
    ui.input('cmdline', { on_confirm = vim.schedule_wrap(vim.cmd) })
end
-------------------------------------------------------------------------------

return M
