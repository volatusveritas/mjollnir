local M = {}

-- Imports
local keymap = require("volt.keymap")

local function many(element, amount)
    local result = {}

    for _ = 1, amount do
        table.insert(result, element)
    end

    return result
end

function M.offset_line(offset)
    local line = vim.fn.line(".")
    local col = vim.fn.col(".")
    local line_text = vim.fn.getline(line)

    if offset < 0 and line == 1 then
        vim.api.nvim_echo({{ "Can't go above top of file." }}, false, {})
        return
    end

    if offset > 0 and line == vim.fn.line("$") then
        vim.api.nvim_echo({{ "Can't go below end of file." }}, false, {})
        return
    end

    vim.fn.deletebufline("", line)
    vim.fn.append(line + offset - 1, line_text)
    vim.fn.cursor(line + offset, col)
end

function M.offset_selection(offset)
    local cstart = vim.fn.col("v")
    local cend = vim.fn.col(".")

    local lstart = vim.fn.line("v")
    local lend = vim.fn.line(".")

    local first_line = math.min(lstart, lend)
    local last_line = math.max(lstart, lend)

    if offset < 0 and first_line == 1 then
        vim.api.nvim_echo({{ "Can't go above top of file." }}, false, {})
        return
    end

    if offset > 0 and last_line == vim.fn.line("$") then
        vim.api.nvim_echo({{ "Can't go below end of file." }}, false, {})
        return
    end

    local lines = vim.fn.getline(first_line, last_line)
    vim.fn.deletebufline("", first_line, last_line)
    vim.fn.append(first_line + offset - 1, lines)

    -- local offset_line
        -- = ("%d%s"):format(math.abs(offset), offset > 0 and "j" or "k")

    local voffset_col = cstart > 1 and ("0%dl"):format(cstart - 1) or "0"
    local coffset_col = cend > 1 and ("0%dl"):format(cend - 1) or "0"

    vim.fn.feedkeys(("%s%so"):rep(2):format(
        ("%dG"):format(lend + offset),
        coffset_col,
        ("%dG"):format(lstart + offset),
        voffset_col
    ))
end

function M.setup()
    keymap.set("n", {
        ["[<Space>"] = {
            desc = "Create line above",
            map = function()
                local curpos = vim.fn.getcurpos()
                vim.fn.append(curpos[2] - 1, many("", vim.v.count1))
                vim.fn.cursor(curpos[2] + vim.v.count1, curpos[3])
            end
        },
        ["]<Space>"] = {
            desc = "Create line below",
            map = function()
                vim.fn.append(".", many("", vim.v.count1))
            end
        },
        ["<M-j>"] = {
            desc = "Move line down",
            map = function() M.offset_line(vim.v.count1) end,
        },
        ["<M-k>"] = {
            desc = "Move line up",
            map = function() M.offset_line(-vim.v.count1) end,
        },
        ["<M-h>"] = {
            desc = "Shift line left",
            map = "<<",
        },
        ["<M-l>"] = {
            desc = "Shift line right",
            map = ">>",
        },
    })

    keymap.set("v", {
        ["[<Space>"] = {
            desc = "Create line above selection",
            map = function()
                local curpos = vim.fn.getcurpos()
                local lnum = math.min(vim.fn.getpos("v")[2], curpos[2])

                vim.fn.append(lnum - 1, many("", vim.v.count1))
                vim.fn.cursor(curpos[2] + vim.v.count1, curpos[3])
            end
        },
        ["]<Space>"] = {
            desc = "Create line below selection",
            map = function()
                vim.fn.append(".", many("", vim.v.count1))
            end
        },
        ["<M-j>"] = {
            desc = "Move selected lines down",
            map = function()
                M.offset_selection(vim.v.count1)
            end,
        },
        ["<M-k>"] = {
            desc = "Move selected lines up",
            map = function() M.offset_selection(-vim.v.count1) end,
        },
        ["<M-h>"] = {
            desc = "Shift selected lines left",
            map = "<",
        },
        ["<M-l>"] = {
            desc = "Shift selected lines right",
            map = ">",
        },
    })
end

return M
