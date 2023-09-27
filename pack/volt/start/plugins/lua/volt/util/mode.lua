local M = {}

-- Mode constants
M.NORMAL       = 0
M.VISUAL_CHAR  = 1
M.VISUAL_LINE  = 2
M.VISUAL_BLOCK = 3
M.SELECT       = 4
M.INSERT       = 5
M.REPLACE      = 6
M.COMMAND      = 7
M.PROMPT       = 8
M.SHELL        = 9
M.TERMINAL     = 10

M.conversion_table = {
    n =      M.NORMAL,
    v =      M.VISUAL_CHAR,
    V =      M.VISUAL_LINE,
    [""] = M.VISUAL_BLOCK,
    s =      M.SELECT,
    S =      M.SELECT,
    [""] = M.SELECT,
    i =      M.INSERT,
    R =      M.REPLACE,
    c =      M.COMMAND,
    r =      M.PROMPT,
    ["!"] =  M.SHELL,
    t =      M.TERMINAL,
}

M.from_normal_table = {
    [M.VISUAL_CHAR]  = "v",
    [M.VISUAL_LINE]  = "V",
    [M.VISUAL_BLOCK] = "",
    [M.SELECT]       = "v",
    [M.INSERT]       = "i",
    [M.REPLACE]      = "R",
    [M.COMMAND]      = ":",
    [M.SHELL]        = "i",
}

function M.start(mode)
    if mode == M.PROMPT or mode == M.SHELL then
        return
    end

    local current = M.get_current()

    if current == mode then
        return
    end

    if current ~= M.NORMAL then
        -- Press nomap <Esc>
        vim.api.nvim_feedkeys("", "n", false)
    end

    if mode ~= M.NORMAL then
        vim.api.nvim_feedkeys(M.from_normal_table[mode], "n", false)
    end
end

function M.get_current()
    return M.conversion_table[vim.fn.mode()]
end

return M
