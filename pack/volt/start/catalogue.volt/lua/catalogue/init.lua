local M = {}

-- TODO: document this
M.descriptions = {
    n = {},
    v = {},
}

function M.register_mgrid(mode, mgrid, root)
    local target = root or M.descriptions[mode]

    for key, mcell in pairs(mgrid) do
        target[key] = { desc = mcell.desc or '' }

        if type(mcell.map) == 'table' then
            target[key].subkeys = {}

            M.register_mgrid(mcell.map, target[key].subkeys)
        end
    end
end

-- TODO: document this
function M.is_registered(mode, full_key)
    local normalized_key = vim.keycode(full_key)
    local target = M.descriptions[mode]

    for i = 1, #normalized_key do
        local next_key = vim.fn.keytrans(string.sub(normalized_key, i, i))

        if target == nil or target[next_key] == nil then
            return false
        end

        target = target[next_key].subkeys
    end

    return true
end

return M
