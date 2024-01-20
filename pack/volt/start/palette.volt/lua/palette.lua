local M = {}

-- ColorTable is
-- - fg (string) The foreground color
-- - bg (string) The background color
-- - attr (string[]) Attributes for the highlight

----------------------------------- Imports -----------------------------------
local highlight = require('volt.highlight')
-------------------------------------------------------------------------------

M.color = {}

function volt_foldtext()
    return string.format('%s...', vim.fn.getline(vim.v.foldstart))
end

--------------------------------- PUBLIC API ----------------------------------
function M.apply()
    highlight.set('Normal', { fg = M.color.light1, bg = M.color.dark1 })
    highlight.set('Comment', { fg = M.color.light4 })
    highlight.set('Identifier', { fg = M.color.light1 })
    highlight.set('Constant', { fg = M.color.red })
    highlight.set('Boolean', { fg = M.color.red })
    highlight.set('String', { fg = M.color.green })
    highlight.set('Statement', { fg = M.color.purple, attr = { 'bold' } })
    highlight.set('PreProc', { fg = M.color.purple })
    highlight.set('Function', { fg = M.color.orange })
    highlight.set('Special', { fg = M.color.orange })
    highlight.set('Added', { fg = M.color.green })
    highlight.set('Changed', { fg = M.color.cyan })
    highlight.set('Removed', { fg = M.color.red })
    highlight.set('Folded', { fg = M.color.purple, bg = M.color.grey2 })
    highlight.set('StatusLine', { fg = M.color.dark1, bg = M.color.purple_dark })
    highlight.set('StatusLineNC', { fg = M.color.light4, bg = M.color.dark4 })
    highlight.set('ColorColumn', { bg = M.color.dark4, attr = {'NONE'} })
    highlight.set('WinSeparator', { fg = M.color.purple, attr = {'NONE'} })
    highlight.set('Type', { fg = M.color.orange })
    highlight.set('Title', { fg = M.color.light1, attr = { 'bold' } })
    highlight.set('LineNrAbove', { fg = M.color.grey4 })
    highlight.set('LineNrBelow', { fg = M.color.grey4 })
    highlight.set('LineNr', { fg = M.color.light4 })
    highlight.set('CurSearch', { fg = M.color.dark1, bg = M.color.yellow })
    highlight.set('NormalFloat', { fg = M.color.light1, bg = M.color.dark1 })
    highlight.set('FloatBorder', { fg = M.color.purple, bg = M.color.dark1 })
    highlight.set('FloatTitle', { fg = M.color.purple, attr = { 'bold' } })
    highlight.set('FloatFooter', { fg = M.color.purple })

    vim.o.foldtext = 'v:lua.volt_foldtext()'
end
-------------------------------------------------------------------------------

return M
