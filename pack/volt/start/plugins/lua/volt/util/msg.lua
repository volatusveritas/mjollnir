local M = {}

function M.info(msg)
    vim.api.nvim_echo({{msg}}, false, {})
end

function M.errnf(msg)
    vim.api.nvim_err_write(msg)
end

function M.err(msg)
    vim.api.nvim_err_writeln(msg)
end

return M
