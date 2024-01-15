local M = {}

-- ColorTable is
-- - fg (string) The foreground color
-- - bg (string) The background color
-- - attr (string[]) Attributes for the highlight

----------------------------------- Imports -----------------------------------
local highlight = require('volt.highlight')
-------------------------------------------------------------------------------

M.color = {}

--------------------------------- PUBLIC API ----------------------------------
function M.apply()
    highlight.set('Normal', { fg = M.color.light1, bg = M.color.dark1 })
    highlight.set('Comment', { fg = M.color.light4 })
    highlight.set('Identifier', { fg = M.color.light1 })
    highlight.set('Constant', { fg = M.color.red, attr = { 'bold' } })
    highlight.set('Boolean', { fg = M.color.red })
    highlight.set('String', { fg = M.color.green })
    highlight.set('Statement', { fg = M.color.purple, attr = { 'bold' } })
    highlight.set('PreProc', { fg = M.color.purple })
    highlight.set('Function', { fg = M.color.orange })
    highlight.set('Special', { fg = M.color.orange })
    highlight.set('Added', { fg = M.color.green })
    highlight.set('Changed', { fg = M.color.cyan })
    highlight.set('Removed', { fg = M.color.red })
    highlight.set('Folded', { fg = M.color.purple, bg = 'NONE', attr = { 'bold' } })
    highlight.set('StatusLine', { fg = M.color.dark1, bg = M.color.purple_dark })
    highlight.set('StatusLineNC', { fg = M.color.light4, bg = M.color.dark4 })
    highlight.set('ColorColumn', { bg = M.color.dark4, attr = {'NONE'} })
    highlight.set('WinSeparator', { fg = M.color.purple, attr = {'NONE'} })
    highlight.set('Type', { fg = M.color.orange })
end
-------------------------------------------------------------------------------

return M
