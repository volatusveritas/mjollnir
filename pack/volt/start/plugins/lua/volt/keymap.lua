local M = {}

--[[
    The keymap module is based on mapping grids.

    A mapping grid is a table mapping strings (rhs) to mapping cells.

    A mappping cell contains:
    * desc [string]: a description of the mapping or title of the mapping
      group.
    * opts [table]: the mapping options to be passed or propagated.
    * map (string|function|table): if not a table, the rhs for the mapping, and
      if a table, it is treated as a mapping grid of the subcommands.

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
]]

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

local function apply_mcell(mode, key, mcell, prefix)
    local full_key = string.format('%s%s', prefix or '', key)

    if type(mcell.map) ~= 'table' then
        vim.keymap.set(mode, full_key, mcell.map, mcell.opts)
        return
    end

    if mcell.opts then
        for _, sub_mcell in pairs(mcell.map) do
            propagate_opts(mcell.opts, sub_mcell)
        end
    end

    M.set(mode, mcell.map, full_key)
end

function M.set(mode, mgrid, prefix)
    for key, mcell in pairs(mgrid) do
        apply_mcell(mode, key, mcell, prefix)
    end
end

return M
