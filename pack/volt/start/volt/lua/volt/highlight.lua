local M = {}

--------------------------------- PUBLIC API ----------------------------------
function M.clear(group)
    vim.cmd(string.format('highlight clear %s', group))
end

function M.set(group, color)
    local command = { 'highlight', group }

    if color.attr then
        table.insert(
            command,
            string.format('gui=%s', table.concat(color.attr, ','))
        )
    end

    if color.fg then
        table.insert(command, string.format('guifg=%s', color.fg))
    end

    if color.bg then
        table.insert(command, string.format('guibg=%s', color.bg))
    end

    vim.cmd(table.concat(command, ' '))
end
-------------------------------------------------------------------------------

return M
