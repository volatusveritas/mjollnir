local M = {}

  ------------------------------- PUBLIC API --------------------------------

-- TODO: document this
function M.clear(group)
    vim.cmd(string.format('highlight clear %s', group))
end

-- TODO: write this
-- TODO: document this
function M.set(group, values)
    local command = { 'highlight', group }

    if values.attr then
        table.insert(
            command,
            string.format('gui=%s', table.concat(values.attr, ','))
        )
    end

    if values.fg then
        table.insert(command, string.format('guifg=%s', values.fg))
    end

    if values.bg then
        table.insert(command, string.format('guibg=%s', values.bg))
    end

    vim.cmd(table.concat(command, ' '))
end

return M
