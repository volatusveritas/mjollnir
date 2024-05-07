local edit = {}

-- Swaps two lines in a buffer.
--[[
Parameters:
• buf (number): the buffer number of the buffer to be modified
• from_index (number): the index of the line to be swapped (1-based)
• to_index (number): the index of the line to swap with (1-based)
--]]
function edit.swap_lines(buf, from_index, to_index)
    edit.swap_ranges(buf, from_index, from_index, to_index, to_index)
end

-- Swaps two sequences of lines in a buffer.
--[[
Parameters:
• buf (number): the buffer number of the buffer to be modified
• from_start (number): the starting index of the line sequence to be swapped (1-based)
• from_end (number): the ending index of the line sequence to be swapped (1-based)
• to_start (number): the starting index of the line sequence to swap with (1-based)
• to_end (number): the ending index of the line sequence to swap with (1-based)
--]]
function edit.swap_ranges(buf, from_start, from_end, to_start, to_end)
    local lines_a = vim.api.nvim_buf_get_lines(buf, from_start - 1, from_end, true)
    local lines_b = vim.api.nvim_buf_get_lines(buf, to_start - 1, to_end, true)

    vim.api.nvim_buf_set_lines(buf, from_start - 1, from_end, true, lines_b)
    vim.api.nvim_buf_set_lines(buf, to_start - 1, to_end, true, lines_a)
end

return edit
