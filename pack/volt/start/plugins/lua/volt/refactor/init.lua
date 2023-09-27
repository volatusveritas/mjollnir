local M = {}

-- Imports
local keymap = require("volt.keymap")

local function get_matches(buf, lstart, lend, pat)
    local matches = {}

    for lnum = lstart, lend do
        local line = vim.fn.getline(lnum)

        local line_matches = {}

        local last_end = 0

        while last_end do
            local bstart, bend = string.find(line, pat, last_end + 1)

            last_end = bend

            if not bstart then
                break
            end

            table.insert(line_matches, { bstart, bend })
        end

        if line_matches[1] ~= nil then
            table.insert(matches, { lnum, line_matches })
        end
    end

    return matches
end

function M.get_substitution_parameters()
    local target

    vim.ui.input(
        { prompt = "(Substitution) target: " },
        function(input) target = input end
    )

    if not target then
        return nil
    end

    local new_value

    vim.ui.input(
        { prompt = string.format( "(Substitution) Change '%s' to: ", target) },
        function(input) new_value = input end
    )

    if not new_value then
        return nil
    end

    return target, new_value
end

function M.substitute(range_start, range_end, reverse)
    local target, new_value = M.get_substitution_parameters()

    if new_value == target then
        vim.api.nvim_echo(
            {{ "Substitution values are not different." }},
            false,
            {}
        )

        return
    end
end

function M.visual_substitute()
    local visual_line = vim.fn.line("v")
    local cursor_line = vim.fn.line(".")

    local range_start = math.min(visual_line, cursor_line)
    local range_end = math.max(visual_line, cursor_line)

    -- Leave Visual mode
    vim.fn.feedkeys("", "n")

    vim.schedule(function()
        M.substitute(range_start, range_end)
    end)
end

function M.setup()
    keymap.set("n", {
        ["<Leader>s"] = {
            desc = "Refactor: Substitute",
            map = {
                j = {
                    desc = "Refactor: Substitute Down",
                    map = function() M.substitute(".", "$") end,
                },
                k = {
                    desc = "Refactor: Substitute Up",
                    map = function() M.substitute("1", ".") end,
                },
                ["<Leader>"] = {
                    desc = "Refactor: Substitute In File",
                    map = function() M.substitute("1", "$") end,
                },
            },
        },
    })

    keymap.set("v", {
        s = {
            desc = "Substitute term in selection",
            map = M.visual_substitute,
        },
    })
end

return M
