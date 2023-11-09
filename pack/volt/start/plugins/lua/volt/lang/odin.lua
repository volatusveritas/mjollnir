local M = {}

M.error_format = '%f(%l:%c) %m'

local function info(msg)
    vim.api.nvim_echo({{msg}}, false, {})
end

function M.check_package(package_name)
    info(string.format('Checking package "%s".', package_name))

    vim.fn.jobstart({'odin', 'check', package_name, '-terse-errors'}, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, lines)
            info('No errors or warnings caught.')
        end,
        on_stderr = function(_, lines)
            line_amount = #lines

            if vim.startswith(lines[1], 'ERROR') then
                vim.api.nvim_err_write(table.concat(lines, '\n'))
                return
            end

            -- Last line is empty because of the last newline
            lines[line_amount] = nil
            line_amount = line_amount - 1

            vim.fn.setqflist({}, 'r', {
                lines = lines,
                efm = M.error_format,
                title = string.format('Odin check (%s)', package_name),
            })

            info(string.format(
                '%d errors added to the quickfix list.',
                line_amount
            ))
        end,
    })
end

return M
