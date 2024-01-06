local M = {}

--- Swaps the position of two TSNodes.
-- @param node_a The base node.
-- @param node_b The node to positions with.
function M.swap(node_a, node_b)
    local node_a_pos = node_a:range()
    local node_b_pos = node_b:range()

    local node_a_lines = vim.api.nvim_buf_get_text(
        0,
        node_a_pos[1],
        node_a_pos[2],
        node_a_pos[3],
        node_a_pos[4] + 1,
        {}
    )

    local node_b_lines = vim.api.nvim_buf_get_text(
        0,
        node_b_pos[1],
        node_b_pos[2],
        node_b_pos[3],
        node_b_pos[4] + 1,
        {}
    )

    vim.api.nvim_buf_set_text(
        0,
        node_a_pos[1],
        node_a_pos[2],
        node_a_pos[3],
        node_a_pos[4] + 1,
        node_b_lines
    )

    vim.api.nvim_buf_set_text(
        0,
        node_b_pos[1],
        node_b_pos[2],
        node_b_pos[3],
        node_b_pos[4] + 1,
        node_a_lines
    )
end

return M
