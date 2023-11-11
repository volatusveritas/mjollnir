local M = {}

M.error_format = '%f(%l:%c) %m'

local function info(msg)
    vim.api.nvim_echo({{msg}}, false, {})
end

function M.check_package(package_name, fix_callback)
    info(string.format('Checking package "%s".', package_name))

    local cmd = vim.system({'odin', 'check', package_name, '-terse-errors'})
    local event = cmd:wait()

    if event.stdout ~= '' or event.stderr == '' then
        info('No errors or warnings caught.')
        return
    end

    if vim.startswith(event.stderr, 'ERROR') then
        vim.api.nvim_err_write(event.stderr)
        return
    end

    local lines = vim.split(event.stderr, '\n')

    line_amount = #lines

    -- Last line is empty because of the last newline
    lines[line_amount] = nil
    line_amount = line_amount - 1

    vim.fn.setqflist({}, 'r', {
        lines = lines,
        efm = M.error_format,
        title = string.format('Odin check (%s)', package_name),
    })

    info(string.format('%d errors added to the quickfix list.', line_amount))

    fix_callback()
end

return M
