local M = {}

function M.err(msg, ...)
    vim.api.nvim_err_writeln(string.format(msg, ...))
end

function M.msg(msg, ...)
    print(string.format(msg, ...))
end

return M
