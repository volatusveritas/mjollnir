local M = {}

-- Imports
local mode = require("volt.util.mode")

local PADDING_SIZE = 2

M.mode_to_string = {
    [mode.NORMAL]       = "Normal",
    [mode.VISUAL_CHAR]  = "Visual (Char)",
    [mode.VISUAL_LINE]  = "Visual (Line)",
    [mode.VISUAL_BLOCK] = "Visual (Block)",
    [mode.SELECT]       = "Select",
    [mode.INSERT]       = "Insert",
    [mode.REPLACE]      = "Replace",
    [mode.COMMAND]      = "Command",
    [mode.PROMPT]       = "Prompt",
    [mode.SHELL]        = "Shell",
    [mode.TERMINAL]     = "Terminal",
}

M.blocks = {}

M.terminal_filename_regex = vim.regex([[^term:.*]])

function M.blocks.mode()
    return M.mode_to_string[mode.get_current()]
end

function M.blocks.file(bufnr, tail_only)
    local filename = vim.fn.expand(("#%d%s"):format(
        bufnr,
        tail_only and ":t" or ""
    ))

    if M.terminal_filename_regex:match_str(filename) then
        filename = string.format(
            "term::%d",
            require("volt.terminal").get_terminal_index(
                vim.api.nvim_get_current_buf()
            )
        )
    end

    if filename == "" then
        return ""
    end

    if not vim.bo.modifiable then
        filename = string.format("[%s]", filename)
    end

    local filetype = ""

    if vim.bo.filetype ~= "" then
        filetype = string.format(
            "(%s%s) ",
            string.upper(string.sub(vim.bo[bufnr].filetype, 1, 1)),
            string.sub(vim.bo[bufnr].filetype, 2)
        )
    end

    return string.format(
        "%s%s%s",
        filetype,
        filename,
        vim.bo[bufnr].modified and " +" or ""
    )
end

function M.blocks.position()
    local win_cursor_pos = vim.api.nvim_win_get_cursor(vim.g.statusline_winid)

    return string.format("%d, %d", win_cursor_pos[1], win_cursor_pos[2])
end

function M.build_statusline_from_blocks(left, middle, right)
    local statusline_elements = {}

    local line_width = vim.fn.winwidth(vim.g.statusline_winid)
    local base_padding_size = math.floor(
        line_width / 2 - PADDING_SIZE - #middle / 2
    )

    table.insert(statusline_elements, string.rep(" ", PADDING_SIZE))

    table.insert(statusline_elements, left)

    table.insert(
        statusline_elements,
        string.rep(" ", base_padding_size - #left)
    )

    table.insert(statusline_elements, middle)

    table.insert(
        statusline_elements,
        string.rep(" ", base_padding_size - #right)
    )

    table.insert(statusline_elements, right)

    table.insert(statusline_elements, string.rep(" ", PADDING_SIZE))

    return table.concat(statusline_elements)
end

function volt_statusline()
    local bufnr = vim.fn.winbufnr(vim.g.statusline_winid)

    if vim.g.statusline_winid == vim.fn.win_getid() then
        return M.build_statusline_from_blocks(
            M.blocks.mode(),
            M.blocks.file(bufnr, false),
            M.blocks.position()
        )
    else
        return M.build_statusline_from_blocks(
            "",
            M.blocks.file(bufnr, true),
            M.blocks.position()
        )
    end
end

function M.setup()
    vim.o.statusline = "%!v:lua.volt_statusline()"
end

return M
