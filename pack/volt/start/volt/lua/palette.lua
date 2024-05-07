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
    local line = vim.fn.getline(vim.v.foldstart)
    local leading_whitespace = line:match('(%s*)')
    local line_content = line:match('%s*(.*)')
    return string.format('%s%s...', leading_whitespace, line_content)
end

--------------------------------- PUBLIC API ----------------------------------
function M.apply()
    highlight.set('Normal', { fg = M.color.light1, bg = 'NONE' })
    highlight.set('Comment', { fg = '#698a95' })
    highlight.set('Identifier', { fg = M.color.light1 })
    highlight.set('Function', { fg = M.color.light4 })
    highlight.set('Type', { fg = M.color.blue })
    highlight.set('Constant', { fg = M.color.purple })
    highlight.set('Number', { fg = M.color.red })
    highlight.set('Boolean', { fg = M.color.red })
    highlight.set('String', { fg = M.color.green })
    highlight.set('Statement', { fg = M.color.yellow, attr = {'bold'} })
    highlight.set('PreProc', { fg = M.color.blue, attr = {'bold'} })
    highlight.set('Special', { fg = M.color.orange })
    highlight.set('Added', { fg = M.color.green })
    highlight.set('Changed', { fg = M.color.cyan })
    highlight.set('Removed', { fg = M.color.red })
    highlight.set('Folded', { fg = M.color.blue, bg = M.color.dark4 })
    highlight.set('StatusLine', { fg = M.color.dark1, bg = M.color.blue_dark })
    highlight.set('StatusLineNC', { fg = M.color.light4, bg = M.color.dark4 })
    highlight.set('ColorColumn', { bg = M.color.dark4, attr = {'NONE'} })
    highlight.set('WinSeparator', { fg = M.color.grey4, attr = {'NONE'} })
    highlight.set('Title', { fg = M.color.light1, attr = { 'bold' } })
    highlight.set('LineNrAbove', { fg = M.color.grey4 })
    highlight.set('LineNrBelow', { fg = M.color.grey4 })
    highlight.set('LineNr', { fg = M.color.light4 })
    highlight.set('CurSearch', { fg = M.color.dark1, bg = M.color.yellow })
    highlight.set('NormalFloat', { fg = M.color.light1, bg = 'NONE' })
    highlight.set('FloatBorder', { fg = M.color.purple, bg = 'NONE' })
    highlight.set('FloatTitle', { fg = M.color.purple, attr = { 'bold' } })
    highlight.set('FloatFooter', { fg = M.color.purple })
    highlight.set('Pmenu', { fg = M.color.light1, bg = M.color.dark4 })
    highlight.set('PmenuSel', { fg = M.color.dark1, bg = M.color.purple_dark })
    highlight.set('PmenuSBar', { fg = M.color.light1, bg = M.color.dark4 })
    highlight.set('PmenuThumb', { fg = M.color.light1, bg = M.color.purple })

    vim.o.foldtext = 'v:lua.volt_foldtext()'
end
-------------------------------------------------------------------------------

return M
