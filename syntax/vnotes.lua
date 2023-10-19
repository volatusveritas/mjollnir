if not vim.fn.exists("current_syntax") then
    return
end

vim.cmd('let b:current_syntax = "notes"')

vim.cmd([[hi VNoteItalic gui=italic]])
vim.cmd([[hi VNoteBold gui=bold]])

vim.cmd([[syntax match Identifier /^\*\+\s\+.*$/]])
vim.cmd([[syntax match Comment /^#.*$/]])
vim.cmd([[syntax match VNoteItalic /_\S\@=.\+\S\@<=_/]])
vim.cmd([[syntax match VNoteBold /\*\S\@=.\+\S\@<=\*/]])
vim.cmd([[syntax match Number /\d\+\(\.\d\+\)\?/]])

vim.cmd([[syntax region String start=/"/ end=/"/]])

vim.cmd([[syntax keyword Special INFO]])
vim.cmd([[syntax keyword Special NOTE]])
vim.cmd([[syntax keyword Special WARNING]])
