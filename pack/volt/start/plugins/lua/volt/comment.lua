local M = {}

-- Imports
local keymap = require("volt.keymap")

local function pattern_escape_char(str, char)
    return str:gsub(("%%%s"):format(char), ("%%%%%s"):format(char))
end

local function normalize_bufnr(source)
    return vim.fn.bufnr((source == 0) and "" or source)
end

local function normalize_commentstring(str)
    -- FIXME: make this more robust, that's a piece of shit for now
    return pattern_escape_char(str, "-")
        :gsub("%%s", "(.*)")
        :gsub("%s+", "%%s*")
end

function M.comment_line(buffer, lnum)
    buffer = normalize_bufnr(buffer)

    local line = vim.fn.getbufline(buffer, lnum)[1]
    local padding, content = line:match("^(%s*)(.*)")

    vim.fn.setbufline(
        buffer,
        lnum,
        ("%s%s"):format(
            padding,
            vim.bo[buffer].commentstring:format(content)
        )
    )
end

function M.uncomment_line(buffer, lnum)
    buffer = normalize_bufnr(buffer)

    local pattern = ("(%%s*)%s"):format(
        vim.bo[buffer].commentstring:gsub("%%s", "(.*)")
    )

    local line = vim.fn.getbufline(buffer, lnum)[1]
    local padding, content = line:match(pattern)

    vim.fn.setbufline(buffer, lnum, ("%s%s"):format(padding, content))
end

function M.is_line_commented(buffer, lnum)
    buffer = normalize_bufnr(buffer)

    return vim.fn.getbufline(buffer, lnum)[1]:match(("^%%s*%s"):format(
        normalize_commentstring(vim.bo[buffer].commentstring)
    )) ~= nil
end

function M.toggle_comment_line(buffer, lnum)
    buffer = normalize_bufnr(buffer)

    if vim.fn.getline(lnum) == "" then
        return
    end

    if M.is_line_commented(buffer, lnum) then
        M.uncomment_line(buffer, lnum)
    else
        M.comment_line(buffer, lnum)
    end
end

function M.setup()
    keymap.set("n", {
        gcc = {
            desc = "Comment a line",
            map = function()
                local lnum = vim.fn.getcurpos()[2]

                for l = lnum, lnum + vim.v.count1 - 1 do
                    M.toggle_comment_line(0, l)
                end
            end,
        },
    })

    keymap.set("v", {
        gc = {
            desc = "Comment selected lines",
            map = function()
                local lstart = vim.fn.line("v")
                local lend = vim.fn.line(".")

                local first_line = math.min(lstart, lend)
                local last_line = math.max(lstart, lend)

                for l = first_line, last_line do
                    M.toggle_comment_line(0, l)
                end
            end,
        }
    })
end

return M
