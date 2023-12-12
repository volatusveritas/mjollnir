local M = {}

M.colors = {
    cyan        = '#7AF3F3',
    green       = '#7AF39E',
    lime        = '#A2F37A',
    yellow      = '#F1ED78',
    red         = '#F37A7A',
    purple      = '#E2A6FF',
    dark_purple = '#7054B0',
    void_purple = '#3C3272',
    orange      = '#F3B27A',

    bgd2 = '#131515',  -- Darker2 than BG
    bgd1 = '#1E2029',  -- Darker than BG
    bg = '#2A2D38',  -- Main BG
    bg1 = '#3F414D',  -- Brighter than BG
    bg2 = '#565661',  -- Brighter2 than BG

    fg1 = '#E8E8E8',  -- Brighter, main text
    fg2 = '#9CA0A6',  -- Darker, used for comments
}

local function set_highlight(ctable, group, fg, bg, gui)
    table.insert(ctable, ('hi! %s%s%s%s\n'):format(
        group,
        fg and (' guifg=%s'):format(fg) or '',
        bg and (' guibg=%s'):format(bg) or '',
        gui and (' gui=%s'):format(gui) or ''
    ))
end

function M.activate()
    local ctable = { 'hi clear\n' }

    set_highlight(ctable, 'ColorColumn', nil, M.colors.bgd1)
    set_highlight(ctable, 'Comment', M.colors.fg2, nil, 'italic')
    set_highlight(ctable, 'CursorColumn', nil, M.colors.bg1)
    set_highlight(ctable, 'CursorLine', nil, M.colors.bg1)
    set_highlight(ctable, 'EndOfBuffer', M.colors.bg2)
    set_highlight(ctable, 'Folded', M.colors.purple, 'NONE', 'italic')
    set_highlight(ctable, 'Identifier', M.colors.purple)
    set_highlight(ctable, 'IncSearch', M.colors.red, M.colors.bg, 'reverse')
    set_highlight(ctable, 'LineNr', M.colors.bg2)
    set_highlight(ctable, 'MatchParen', M.colors.red, M.colors.bg2, 'bold')
    set_highlight(ctable, 'Normal', M.colors.fg1, M.colors.bgd2)
    set_highlight(ctable, 'NormalFloat', M.colors.fg1, M.colors.bg)
    set_highlight(ctable, 'Pmenu', M.colors.red, M.colors.bg1)
    set_highlight(ctable, 'PmenuSbar', nil, M.colors.bg2)
    set_highlight(ctable, 'PmenuSel', M.colors.bgd2, M.colors.red)
    set_highlight(ctable, 'PmenuThumb', nil, M.colors.orange)
    set_highlight(ctable, 'PreProc', M.colors.green)
    set_highlight(ctable, 'Search', M.colors.yellow, M.colors.bg, 'reverse')
    set_highlight(ctable, 'Special', M.colors.orange, 'NONE')
    set_highlight(ctable, 'SpecialKey', M.colors.cyan)
    set_highlight(ctable, 'Statement', M.colors.red)
    set_highlight(ctable, 'StatusLine', M.colors.bgd2, M.colors.red, 'NONE')
    set_highlight(ctable, 'StatusLineNC', M.colors.bg2, M.colors.bg, 'NONE')
    set_highlight(ctable, 'String', M.colors.lime)
    set_highlight(ctable, 'Title', M.colors.lime, nil, 'bold')
    set_highlight(ctable, 'Todo', M.colors.bgd2, M.colors.orange, 'bold')
    set_highlight(ctable, 'Type', M.colors.orange)
    set_highlight(ctable, 'Visual', nil, M.colors.bg1)
    set_highlight(ctable, 'WinSeparator', M.colors.bg2)
    set_highlight(ctable, 'TabLine', 'NONE', M.colors.bg, 'NONE')
    set_highlight(ctable, 'TabLineFill', 'NONE', M.colors.bgd2, 'NONE')
    set_highlight(ctable, 'TabLineSel', M.colors.bgd2, M.colors.red, 'italic')

    vim.cmd(table.concat(ctable))
    vim.g.colors_name = 'voltred'
end

return M
