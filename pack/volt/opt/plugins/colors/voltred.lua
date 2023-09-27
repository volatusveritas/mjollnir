vim.schedule(function()
    vim.g.colors_name = "voltred"
end)

-- Constants
local CYAN        = "#7AF3F3"
local GREEN       = "#7AF39E"
local LIME        = "#A2F37A"
local YELLOW      = "#F1ED78"
local RED         = "#F37A7A"
local PURPLE      = "#E2A6FF"
local DARK_PURPLE = "#7054B0"
local VOID_PURPLE = "#3C3272"
local ORANGE      = "#F3B27A"

local BGD = "#13151F"  -- Darker2 than BG
local BG0 = "#1E2029"  -- Darker than BG
local BG1 = "#2A2D38"  -- Main BG
local BG2 = "#3F414D"  -- Brighter than BG
local BG3 = "#565661"  -- Brighter2 than BG
local FG1 = "#E8E8E8"  -- Brighter, main text
local FG2 = "#9CA0A6"  -- Darker, used for comments

local function set_highlight(ctable, group, fg, bg, gui)
    table.insert(ctable, ("hi! %s%s%s%s\n"):format(
        group,
        fg and (" guifg=%s"):format(fg) or "",
        bg and (" guibg=%s"):format(bg) or "",
        gui and (" gui=%s"):format(gui) or ""
    ))
end

local ctable = { "hi clear\n" }

set_highlight(ctable, "ColorColumn", nil, BG1)
set_highlight(ctable, "CursorColumn", nil, BG2)
set_highlight(ctable, "CursorLine", nil, BG2)
set_highlight(ctable, "Comment", FG2)
set_highlight(ctable, "EndOfBuffer", BG3)
set_highlight(ctable, "Folded", PURPLE, VOID_PURPLE, "underline")
set_highlight(ctable, "Identifier", PURPLE)
set_highlight(ctable, "IncSearch", RED, BG1, "reverse")
set_highlight(ctable, "LineNr", BG3)
set_highlight(ctable, "MatchParen", RED, BG3, "bold")
set_highlight(ctable, "Normal", FG1, "NONE")
set_highlight(ctable, "NormalFloat", FG1, BG1)
set_highlight(ctable, "Pmenu", RED, BG2)
set_highlight(ctable, "PmenuSbar", nil, BG3)
set_highlight(ctable, "PmenuSel", BGD, RED)
set_highlight(ctable, "PmenuThumb", nil, ORANGE)
set_highlight(ctable, "PreProc", GREEN)
set_highlight(ctable, "Search", YELLOW, BG1, "reverse")
set_highlight(ctable, "Special", ORANGE, "NONE")
set_highlight(ctable, "Statement", RED)
set_highlight(ctable, "StatusLine", BGD, RED, "NONE")
set_highlight(ctable, "StatusLineNC", BGD, BG3)
set_highlight(ctable, "String", LIME)
set_highlight(ctable, "Title", LIME, nil, "bold")
set_highlight(ctable, "Todo", BGD, ORANGE, "bold")
set_highlight(ctable, "Type", ORANGE)
set_highlight(ctable, "Visual", nil, BG2)
set_highlight(ctable, "WinSeparator", BG3)
set_highlight(ctable, "SpecialKey", CYAN)

vim.cmd(table.concat(ctable))
