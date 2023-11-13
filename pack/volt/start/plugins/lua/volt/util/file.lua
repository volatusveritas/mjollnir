local M = {}

function M.create_dir_path(path)
    local normalized = vim.fs.normalize(path, {})

    local components = {}
    local next_index = 1
    for part in vim.gsplit(normalized, '/', {plain = true}) do
        components[next_index] = part
        next_index = next_index + 1
    end
end

return M
