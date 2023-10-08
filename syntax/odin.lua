if not vim.fn.exists("current_syntax") then
    return
end

vim.cmd('let b:current_syntax = "odin"')

vim.cmd("syntax keyword Boolean false")
vim.cmd("syntax keyword Boolean true")
vim.cmd("syntax keyword Keyword auto_cast")
vim.cmd("syntax keyword Keyword bit_set")
vim.cmd("syntax keyword Keyword break")
vim.cmd("syntax keyword Keyword case")
vim.cmd("syntax keyword Keyword cast")
vim.cmd("syntax keyword Keyword context")
vim.cmd("syntax keyword Keyword continue")
vim.cmd("syntax keyword Keyword defer")
vim.cmd("syntax keyword Keyword distinct")
vim.cmd("syntax keyword Keyword do")
vim.cmd("syntax keyword Keyword dynamic")
vim.cmd("syntax keyword Keyword else")
vim.cmd("syntax keyword Keyword enum")
vim.cmd("syntax keyword Keyword fallthrough")
vim.cmd("syntax keyword Keyword for")
vim.cmd("syntax keyword Keyword foreign")
vim.cmd("syntax keyword Keyword if")
vim.cmd("syntax keyword Keyword import")
vim.cmd("syntax keyword Keyword in")
vim.cmd("syntax keyword Keyword nil")
vim.cmd("syntax keyword Keyword not_in")
vim.cmd("syntax keyword Keyword package")
vim.cmd("syntax keyword Keyword proc")
vim.cmd("syntax keyword Keyword return")
vim.cmd("syntax keyword Keyword struct")
vim.cmd("syntax keyword Keyword switch")
vim.cmd("syntax keyword Keyword transmute")
vim.cmd("syntax keyword Keyword typeid")
vim.cmd("syntax keyword Keyword using")
vim.cmd("syntax keyword Keyword when")

vim.cmd([[syntax match Number /\<\d\+\>/]])
vim.cmd([[syntax match Float /\d\+\.\d\+/]])
vim.cmd([[syntax match Function /\<\w\+\>\((\)\@=/]])
vim.cmd([[syntax match Constant /\<\(\u\|_\)\+\>/]])

vim.cmd([[syntax region String start=/"/ skip=/\\"/ end=/"/]])
vim.cmd([[syntax region Character start=/'/ end=/'/]])
vim.cmd([[syntax region Comment start='//' end=/$/]])
vim.cmd([[syntax region Comment start='/\*' end='\*/']])
