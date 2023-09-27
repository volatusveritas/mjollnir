local M = {}

-- A mapping grid is a table mapping strings (rhs) to mapping cells.
--
-- A mappping cell contains:
-- * desc (string): a description of the mapping or title of the mapping group.
-- * opts [table]: the mapping options to be passed or propagated.
-- * map (string|function|table): if not a table, the rhs for the mapping, and
--   if a table, it is treated as a mapping grid of the subcommands.

function M.apply_mgrid(mode, mgrid, prefix)
    for key, mcell in pairs(mgrid) do
        local full_key = (prefix or "")..key

        if type(mcell.map) ~= "table" then
            vim.keymap.set(mode, full_key, mcell.map, mcell.opts)
        else
            for _, sub_mcell in pairs(mcell.map) do
                if mcell.opts then
                    if not sub_mcell.opts then
                        sub_mcell.opts = mcell.opts
                    end

                    for k, _ in pairs(mcell.opts or {}) do
                        if sub_mcell.opts[k] == nil then
                            sub_mcell.opts[k] = mcell.opts[k]
                        end
                    end
                end
            end

            M.apply_mgrid(mode, mcell.map, full_key)
        end
    end
end

function M.set(mode, mgrid)
    require("volt.desctable").apply_grid(mode, mgrid)

    M.apply_mgrid(mode, mgrid)
end

return M
