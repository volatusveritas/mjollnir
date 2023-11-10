if not vim.fn.exists("current_syntax") then
    return
end

-- Imports
local theme = require('volt.theme')
local keymap = require('volt.keymap')

vim.cmd('let b:current_syntax = "notes"')

vim.cmd(string.format(
    [[highlight VNoteTodo gui=bold guifg=%s]], theme.colors.cyan
))

vim.cmd(string.format(
    [[highlight VNoteDone gui=bold guifg=%s]], theme.colors.red
))

vim.cmd(string.format(
    [[highlight VNoteRef gui=underline guifg=%s]], theme.colors.purple
))

vim.cmd([=[
    highlight VNoteItalic gui=italic
    highlight VNoteBold gui=bold

    syntax match Identifier /^\*\+\s\+\S.*$/
    syntax match Comment /^#.*$/
    syntax match VNoteItalic /_[^_]\+_/
    syntax match VNoteBold /\*[^*]\+\*/
    syntax match Number /\d\+\(\.\d\+\)\?/

    syntax region String start=/"/ end=/"/
    syntax region String start=/'/ end=/'/
    syntax region VNoteRef start=/\[/ end=/\]/

    syntax keyword Special INFO
    syntax keyword Special NOTE
    syntax keyword Special WARNING
    syntax keyword VNoteTodo TODO
    syntax keyword VNoteDone DONE
]=])
