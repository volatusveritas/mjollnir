local M = {}

M.patterns = {
    word = "%w+",
    WORD = "[^%s]+",
}

M.charpairs = {
    parentheses = { "(", ")" },
    square_brackets = { "[", "]" },
    curly_braces = { "{", "}" },
    angle_brackets = { "<", ">" },
}

local function get_region(pattern)
    local cursor_col = vim.fn.col(".")
    local line = vim.fn.getline(".")
    local line_length = #line

    local match_right, anchor_end = string.find(line, pattern, cursor_col)

    local match_left, anchor_start = string.find(
        string.reverse(line),
        pattern,
        line_length - cursor_col
    )

    if match_right == nil and match_left == nil then
        return nil
    end

    local region_start = (
        (match_left == nil) and match_right - 1 or line_length - anchor_start
    )

    local region_end = (
        (match_right == nil) and line_length - match_left or anchor_end - 1
    )

    return region_start, region_end
end

local function get_surround(pattern, pair)
    return get_region(string.format("%s%s%s", pair[1], pattern, pair[2]))
end

function M.surround_region(pattern, pair)
    local start_idx, end_idx = get_region(pattern)

    if start_idx == nil then
        return false
    end

    local lnum = vim.fn.line(".")

    print(lnum - 1, start_idx, lnum - 1, end_idx + 1)

    local original_text = vim.api.nvim_buf_get_text(
        0,
        lnum - 1,
        start_idx,
        lnum - 1,
        end_idx + 1,
        {}
    )

    vim.api.nvim_buf_set_text(
        0,
        lnum - 1,
        start_idx,
        lnum - 1,
        end_idx + 1,
        { string.format("%s%s%s", pair[1], original_text[1], pair[2]) }
    )
end

return M
