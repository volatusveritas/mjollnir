local M = {}

function M.info(msg, populate_history)
    populate_history = populate_history or false

    vim.api.nvim_echo({{msg}}, populate_history, {})
end

function M.errnf(msg)
    vim.api.nvim_err_write(msg)
end

function M.err(msg)
    vim.api.nvim_err_writeln(msg)
end

return M
