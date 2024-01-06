local M = {}

-- TODO: document this
function M.err(msg, ...)
    vim.api.nvim_err_writeln(string.format(msg, ...))
end

return M
