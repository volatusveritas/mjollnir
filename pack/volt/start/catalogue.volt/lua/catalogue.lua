local M = {}

-- TODO: document this
M.descriptions = {
    n = { global = {}, buffer = {} },
    v = { global = {}, buffer = {} },
}

-- TODO: document this
function M.register_mgrid(mode, buf, mgrid, target)
    if target == nil then
        if buf ~= nil then
            target = {}
            M.descriptions[mode].buffer[buf] = target
        else
            target = M.descriptions[mode].global
        end
    end

    for key, mcell in pairs(mgrid) do
        target[key] = { desc = mcell.desc or '' }

        if type(mcell.map) == 'table' then
            target[key].subkeys = {}

            M.register_mgrid(mode, buf, mcell.map, target[key].subkeys)
        end
    end
end

return M

