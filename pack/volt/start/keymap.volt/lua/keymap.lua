local M = {}

-- TODO: warn on keymap overrides

M.opts = '____opts____'
M.operator = '____operator____'
M.self = '____self____'
M.operatorfunc = nil

function volt_operatorfunc()
    M.operatorfunc()
end

local function propagate(from, to)
    for key, _ in pairs(from) do
        if to[key] == nil then
            to[key] = from[key]
        end
    end

    vim.print(to)
end

local function set(mode, grid, root)
    for key, map in pairs(grid) do
        local full_key

        if key == M.self then
            full_key = root
        else
            full_key = string.format('%s%s', root or '', key)
        end

        if key == M.opts or key == M.operator then
            -- Do nothing
        elseif type(map) == 'string' or type(map) == 'function' then
            if grid[M.operator] then
                -- Operator function
                if grid[M.opts] == nil then
                    grid[M.opts] = {}
                end

                grid[M.opts].expr = true

                vim.keymap.set(mode, full_key, function()
                    vim.o.operatorfunc = 'v:lua.volt_operatorfunc'
                    M.operatorfunc = map
                    return 'g@'
                end, grid[M.opts])
            else
                vim.keymap.set(mode, full_key, map, grid[M.opts])
            end
        elseif map[1] ~= nil then
            -- Unique opts
            if grid[M.opts] then
                propagate(grid[M.opts], map[2])
            end

            if map[M.operator] or (grid[M.operator] and map[M.operator] ~= false) then
                -- Operator function
                if map[2] == nil then
                    map[2] = {}
                end

                map[2].expr = true

                vim.keymap.set(mode, full_key, function()
                    vim.o.operatorfunc = 'v:lua.volt_operatorfunc'
                    M.operatorfunc = map[1]
                    return 'g@'
                end, map[2])
            else
                vim.keymap.set(mode, full_key, map[1], map[2])
            end
        else
            -- Submappings
            if map[M.opts] == nil then
                map[M.opts] = grid[M.opts]
            elseif grid[M.opts] then
                propagate(grid[M.opts], map[M.opts])
            end

            set(mode, map, full_key)
        end
    end
end

M.normal   = function(grid) set('n', grid) end
M.visual   = function(grid) set('v', grid) end
M.terminal = function(grid) set('t', grid) end
M.insert   = function(grid) set('i', grid) end

return M
