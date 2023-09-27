local M = {}

function M.create_option_package()
    local package = {
        bo = {},
        wo = {},
    }

    return package
end

function M.push_buffer_option(package, option_name, new_value)
    package.bo[option_name] = new_value
end

function M.push_window_option(package, option_name, new_value)
    package.wo[option_name] = new_value
end

function M.apply(package)
    for name, value in pairs(package.bo) do
        vim.bo[name] = value
    end

    for name, value in pairs(package.wo) do
        vim.api.nvim_set_option_value(name, value, {
            scope = "local",
            win = vim.fn.win_getid()
        })
    end
end

function M.set_undo_ftplugin(package)
    local parts = { "setlocal" }

    for name, _ in pairs(package.bo) do
        table.insert(parts, string.format(" %s<", name))
    end

    for name, _ in pairs(package.wo) do
        table.insert(parts, string.format(" %s<", name))
    end

    vim.cmd(string.format('let b:undo_ftplugin = "%s"', table.concat(parts)))
end

return M
