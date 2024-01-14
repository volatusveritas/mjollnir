local M = {}

-- Special key used to set self-mapping group keys.
M.self = '____self____'

-- Imports
local catalogue = require('catalogue')
local msg = require('volt.msg')
local native = require('volt.native')

--[[
    The keymap module is based on mapping grids.

    A mapping grid is a table mapping strings (lhs) to mapping cells.

    A mappping cell contains:
    * desc [string]: a description of the mapping or title of the mapping
      group.
    * opts [table]: the mapping options to be passed or propagated.
    * map (string|function|table): if not a table, the rhs for the mapping, and
      if a table, it is treated as a mapping grid of the subcommands.
    * operator (boolean): If true, map must be a function and this is called as
      an operator mapping.

    With that, you can build entire keymap trees. The options set for a given
    mapping propagate to the children unless the children manually override
    them.

    Every mapping requires a description of what they do. The recommended way
    of setting the desc option follows.

    * If the mapping cell indicates a single command with no subcommands,
      indicate its action in the imperative form with lowercase letters.
    * If the mapping cell has subcommands, name it the same way but expect its
      children to follow its name.

    As an example, you can expect the following tree:

    1. forge
       1. a hammer
       2. a shield
       3. an armour piece
    2. create
       1. a word
       2. a line
       3. a paragraph
    3. debugging:
       1. start
       2. stop
    4. destroy a text object
    5. clear trailing spaces

    To become the following exhaustive list of commands:

    2. Forge a hammer
    3. Forge a shield
    4. Forge an armour piece
    5. Create a word
    6. Create a line
    7. Create a paragraph
    8. Debugging: start
    9. Debugging: stop
    10. Destroy a text object
    11. Clear trailing spaces

    You can use [keymap.self] as a key to map an item in a subgroup to its
    parent key while also mapping other children maps.
]]

--- Transform a component list into a formatted keymap path string
-- @param components (table) Array of keymap path components as strings
-- @param length (number) The amount of the components to use
-- @return (string) A string formatted as x -> y -> z where x, y, and z are
-- elements of the components table
local function get_keymap_path_str(components, length)
    local path = {}

    for i = 1, length do
        path[i] = components[i]
    end

    return table.concat(path, ' -> ')
end

--- Transform a multi-key string into an array of components
-- @param raw_key (string) A string with one or more keys in non-special form
-- @return (table) An array of special form strings with each key
local function dismember_key(raw_key)
    local components = {}

    for i = 1, #raw_key do
        components[i] = vim.fn.keytrans(string.sub(raw_key, i, i))
    end

    return components
end

--- Linearizea a mapping grid to be made of individual keys
-- @param mgrid (table) The mapping grid to source
-- @return (table) The linearized mapping grid
local function expand_mgrid(mode, buf, mgrid)
    local linear_tree = {}

    for key, mcell in pairs(mgrid) do
        if key == M.self then
            linear_tree[key] = mcell
        else
            local components = dismember_key(vim.keycode(key))
            local components_len = #components

            local next_cell = linear_tree
            local chain_length = 1

            for i = 1, components_len - 1 do
                if next_cell[components[i]] == nil then
                    next_cell[components[i]] = { map = {} }
                elseif type(next_cell[components[i]].map) ~= 'table' then
                    msg.err(
                        'Conflicting keymaps: ( %s ) is already defined in this mapping grid and would override a group.',
                        get_keymap_path_str(components, chain_length)
                    )

                    return
                end

                next_cell = next_cell[components[i]].map
                chain_length = chain_length + 1
            end

            if next_cell[components[components_len]] ~= nil then
                msg.err(
                    'Conflicting keymaps: ( %s ) is already defined in this mapping grid and would override a map.',
                    get_keymap_path_str(components, chain_length)
                )

                return
            end

            chain_length = 1
            local next_desc

            if buf then
                next_desc = catalogue.descriptions[mode].buffer[buf]
            else
                next_desc = catalogue.descriptions[mode].global
            end

            for i = 1, components_len - 1 do
                if next_desc[components[i]] == nil then
                    break
                end

                next_desc = next_desc[components[i]].subkeys

                if next_desc == nil then
                    msg.err(
                        'Conflicting keymaps: ( %s ) is already defined and would override a group.',
                        get_keymap_path_str(components, chain_length)
                    )

                    return
                end

                chain_length = chain_length + 1
            end

            if (
                next_desc ~= nil
                and next_desc[components[components_len]] ~= nil
                and type(mcell.map) ~= 'table'
            ) then
                msg.err(
                    'Conflicting keymaps: ( %s ) is already defined and would override a map.',
                    get_keymap_path_str(components, chain_length)
                )

                return
            end

            next_cell[components[components_len]] = {}
            next_cell = next_cell[components[components_len]]

            for property_name, property_value in pairs(mcell) do
                next_cell[property_name] = property_value
            end

            if type(next_cell.map) == 'table' then
                next_cell.map = expand_mgrid(mode, buf, next_cell.map)
            end
        end
    end

    return linear_tree
end

--- Propagate opts recursively over a mapping cell
-- @param opts (table) The set of options to propagate
-- @param mcell (table) The mapping cell to propagate over
local function propagate_opts(opts, mcell)
    if not mcell.opts then
        mcell.opts = opts
        return
    end

    for key, _ in pairs(opts) do
        if mcell.opts[key] == nil then
            mcell.opts[key] = opts[key]
        end
    end
end

-- Defined later in the file
local apply_mgrid

--- Apply a mapping cell's mappings
-- @param mode (string) The mode for the mappings
-- @param key (string) The mapping cell's key
-- @param mcell (table) The mapping cell's values
-- @param prefix (string) A prefix for the key tree
local function apply_mcell(mode, key, mcell, prefix)
    local full_key

    if key == M.self then
        full_key = prefix
    else
        full_key = string.format('%s%s', prefix or '', key)
    end

    if type(mcell.map) ~= 'table' then
        if mcell.operator then
            if mcell.opts == nil then
                mcell.opts = {}
            end

            mcell.opts.expr = true

            vim.keymap.set(mode, full_key, function()
                vim.o.operatorfunc = 'v:lua.volt_operatorfunc'
                native.operatorfunc = mcell.map
                return 'g@'
            end, mcell.opts)
        else
            vim.keymap.set(mode, full_key, mcell.map, mcell.opts)
        end

        return
    end

    if mcell.opts then
        for _, sub_mcell in pairs(mcell.map) do
            propagate_opts(mcell.opts, sub_mcell)
        end
    end

    apply_mgrid(mode, mcell.map, full_key)
end

--- Apply a mapping grid's mappings
-- @param mode (string) The mode for the mappings
-- @param mgrid (table) The mapping grid to apply
-- @param prefix (string) A prefix for the key tree
apply_mgrid = function(mode, mgrid, prefix)
    for key, mcell in pairs(mgrid) do
        apply_mcell(mode, key, mcell, prefix)
    end
end

--- Set mappings through a mapping grid
-- @param mode (string) The mode for the mappings
-- @param mgrid (table) The mapping grid to use
-- @param prefix (string) A prefix for the key tree
function M.set(mode, mgrid, prefix)
    M.bset(mode, nil, mgrid, prefix)
end

-- TODO: document this
function M.bset(mode, buf, mgrid, prefix)
    local expanded_mgrid = expand_mgrid(mode, buf, mgrid)
    
    if expanded_mgrid == nil then
        return
    end

    for _, mcell in pairs(expanded_mgrid) do
        propagate_opts({ buffer = buf }, mcell)
    end

    apply_mgrid(mode, expanded_mgrid, prefix)
    catalogue.register_mgrid(mode, buf, expanded_mgrid)
end

return M
