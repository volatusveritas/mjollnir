local M = {}

-- Imports
local log = require("volt.util.log")
local keymap = require("volt.keymap")

-- Consts
local HI_MATCH = "VoltSubstituteMatch"
local HI_SELECTED = "VoltSubstituteSelected"
local HI_NEW = "VoltSubstituteNew"
local HI_TITLE = "VoltSubstituteTitle"
local HI_MESSAGE = "VoltSubstituteMessage"

-- NOTES
-- Currently presuming direction is always 'down'
-- USES NEOVIM LINE INDEXING (1-line, 0-col)
--
-- Mode keybindings:
-- j, <C-n>: go to next match
-- k, <C-p>: go to previous match
-- s, <CR>, <C-y>: substitute one, jump to next
-- a: substitute all
-- <Esc>, q: leave substitute mode

-- Creates a new match tuple.
-- Parameters:
    -- line (number): the match's line
    -- start_col (number): the line column where the match starts
    -- end_col (number): the line column past where the match ends
-- Returns:
-- Returns:
    -- a tuple with keys {line}, {start_col} and {end_col}, where each key
    -- stores its corresponding passed parameter with the same name.
local function new_match(line, start_col, end_col)
    return {
        line = line,
        start_col = start_col,
        end_col = end_col
    }
end

-- Creates a new sized string.
-- Parameters:
    -- str (string): the string to be stored
-- Returns:
    -- a table with keys {value} and {size}, where {value} stores <str> and
    --     {size} stores the length of <str>.
local function new_sized_string(str)
    return {
        value = str,
        length = #str,
    }
end

-- Returns the index of the next non-empty value in the match list.
-- Parameters:
    -- match_list (table): array of match tuples
    -- size (number): the length of the array
    -- start (number): the array index to start at
    -- step (number): how to modify the starting index in each iteration
-- Returns:
    -- if a value is found, the index of it (number)
    -- if no value is found, nil
local function get_next(match_list, size, start, step)
    local index = start

    while index > 0 and index <= size do
        if match_list[index] then
            return index
        end
        
        index = index + step
    end

    return nil
end

-- Prettily outputs a message in a standard format without polluting the
-- message history.
-- Parameters:
    -- message (string): the message to be echoed.
    -- arg (...): <message> is used as a format string, with <arg> specifying
    --     the additional values required by it.
local function out(message, ...)
    vim.api.nvim_echo(
        {
            { " SUBSTITUTE ", "VoltSubstituteTitle" },
            {
                string.format(string.format(" %s ", message), ...),
                "VoltSubstituteMessage"
            }
        },
        false, {}
    )
end

-- Collects matches in a line.
-- Parameters:
    -- lnum (number): the 1-based index of the line to be searched.
    -- pat (string): the vim regex pattern to be used in the search.
    -- length (number): the string size of the pattern.
    -- tbl (table): the table to store the matches found.
-- Returns:
    -- the amount of matches found in the line (number).
local function collect_matches_in_line(lnum, pat, length, tbl)
    local line = vim.fn.getline(lnum)

    local anchor = 0
    local amount = 0

    while true do
        local start = vim.fn.match(line, pat, anchor)

        if start == -1 then
            break
        end

        anchor = start + length
        amount = amount + 1

        table.insert(tbl, new_match(lnum, start, anchor))
    end

    return amount
end

-- Collects matches in the current line in a line range.
-- Parameters:
    -- target (sized string): a sized string to search for.
    -- line_start (number): the 1-based line range start.
    -- line_end (number): the 1-based line range end.
-- Returns:
    -- the array and amount of matches found (table, number)
local function get_matches_in_range(target, line_start, line_end)
    local matches = {}
    local amount = 0

    local pat = string.format([[\<%s\>]], target.value)

    for lnum = line_start, line_end do
        amount = amount + collect_matches_in_line(
            lnum, pat, target.length, matches
        )
    end

    return matches, amount
end

-- Highlights a match tuple in the current file.
-- Parameters:
    -- match (match tuple): the match tuple to be highlighted.
    -- ns (number): the ID of the namespace to use.
    -- group (string): the name of the highlight group to use.
local function highlight_match(match, ns, group)
    vim.highlight.range(
        0, ns, group,
        { match.line - 1, match.start_col },
        { match.line - 1, match.end_col },
        {}
    )
end

-- Clears the highlights in the current file in a line range.
-- Parameters:
    -- ns (number): the namespace ID of the highlights.
    -- line_start (number): the 1-based line range start.
    -- line_end (number?): the 1-based line range end. If not provided,
    --   <line_start> is used instead.
local function clear_highlights(ns, line_start, line_end)
    line_end = line_end or line_start

    vim.api.nvim_buf_clear_namespace(0, ns, line_start - 1, line_end)
end

-- Substitutes a match in the current file with a sized string.
-- Parameters:
    -- match (match tuple): the match tuple to substituted.
    -- new (sized string): the text to take the place of the match.
local function substitute_match(match, new)
    vim.bo.modifiable = true

    vim.api.nvim_buf_set_text(
        0,
        match.line - 1, match.start_col,
        match.line - 1, match.end_col,
        { new.value }
    )

    vim.bo.modifiable = false
end

-- Moves the cursor to the start of a match.
-- Parameters:
    -- match (match tuple): the match tuple to jump to.
local function jump_to_match(match)
    vim.fn.cursor(match.line, match.start_col + 1)
end

local function leave_mode(ns, ns_sel, ns_new, matches, amount, selected)
    clear_highlights(ns, matches[1].line, matches[amount].line)
    clear_highlights(ns_new, matches[1].line, matches[amount].line)
    clear_highlights(ns_sel, matches[selected].line, matches[selected].line)
    vim.api.nvim_echo({{ "" }}, false, {})
    vim.bo.modifiable = true

    -- local bufmaps = vim.api.nvim_buf_get_keymap(0, "n")
    vim.keymap.del("n", "j", { buffer = 0 })
    vim.keymap.del("n", "k", { buffer = 0 })
    vim.keymap.del("n", "s", { buffer = 0 })
    vim.keymap.del("n", "q", { buffer = 0 })
end

local function offset_selection(matches, selected, offset, amount, ns_sel)
    match_line = matches[selected][1]

    -- THIS IS GET_NEXT
    repeat
        selected = selected + offset

        if selected == 0 then
            return
        end

        if selected == amount + 1 then
            return
        end
    until matches[selected] ~= nil

    clear_match_highlight(ns_sel, match_line, match_line)
    select_match(matches[selected], ns_sel)
    
    out("Match %d of %d", selected, amount)

    return selected
end

-- Selects the next available match.
-- Parameters:
    -- matches (tuple): array of match tuples for matches in the file.
    -- amount (number): the amount of matches in the file.
    -- selected (number): the index of the currently selected match.
    -- ns (number): ID of the highlight group for selected matches.
    -- step (number): selection offset for each iteration.
-- Returns:
    -- the index of the next match available and whether or not one was
    --     successfully found (number, boolean).
function M.select_next(matches, amount, selected, ns, step)
    local next_match = get_next(matches, amount, selected + step, step)

    if not next_match then
        return selected, false
    end

    clear_highlights(ns, matches[selected].line)
    highlight_match(matches[next_match], ns, HI_SELECTED)
    jump_to_match(matches[next_match])

    return next_match, true
end

function M.enter_mode(line_start, line_end, target, new)
    local matches, amount = get_matches_in_range(target, line_start, line_end)

    if matches[1] == nil then
        vim.api.nvim_err_writeln(string.format(
            "No match found for '%s'.",
            target.value
        ))
        
        return
    end

    local ns = vim.api.nvim_create_namespace("volt.substitute")
    local ns_sel = vim.api.nvim_create_namespace("volt.substitute-sel")
    local ns_new = vim.api.nvim_create_namespace("volt.substitute-new")

    for _, match in ipairs(matches) do
        highlight_match(match, ns, HI_MATCH)
    end

    highlight_match(matches[1], ns_sel, HI_SELECTED)
    jump_to_match(matches[1])

    local selected = 1
    local substitutions = 0

    vim.bo.modifiable = false

    keymap.set("n", {
        j = {
            desc = "Select next match",
            opts = { buffer = 0 },
            map = function()
                local index, success = M.select_next(
                    matches, amount, selected, ns_sel, 1
                )

                selected = index

                if not success then
                    out("No further matches.")
                end
            end,
        },
        k = {
            desc = "Select previous match",
            opts = { buffer = 0 },
            map = function()
                local index, success = M.select_next(
                    matches, amount, selected, ns_sel, -1
                )

                selected = index

                if not success then
                    out("No previous matches.")
                end
            end,
        },
        s = {
            desc = "Substitute",
            opts = { buffer = 0 },
            map = function()
                substitute_match(matches[selected], new)
                substitutions = substitutions + 1

                if substitutions == amount then
                    leave_mode()
                    -- TODO: make this prettier
                    print("All matches were substituted.")
                    return
                end

                -- TODO: wrap around when on the last index
                local next_match, success = M.select_next(
                    matches, amount, selected, ns_sel, 1
                )

                if not success then
                    next_match, success = M.select_next(
                        matches, amount, selected, ns, -1
                    )
                end

                selected = next_match
                matches[selected] = nil

                out("Substituted match %d", selected)
            end
        },
        q = {
            desc = "Leave substitute mode",
            opts = { buffer = 0 },
            map = function()
                leave_mode(ns, ns_sel, ns_new, matches, amount, selected)
            end,
        }
    })
end

function M.setup()
    -- TODO: make this come from voltred or colorscheme instead
    vim.cmd(string.format("highlight %s guifg=#13151F guibg=#E2A6FF gui=bold", HI_MATCH))
    vim.cmd(string.format("highlight %s guifg=#13151F guibg=#F1ED78 gui=bold", HI_SELECTED))
    vim.cmd(string.format("highlight %s guifg=#13151F guibg=#7AF39E gui=bold", HI_NEW))
    vim.cmd(string.format("highlight %s guifg=#E8E8E8 guibg=#7054B0", HI_TITLE))
    vim.cmd(string.format("highlight %s guifg=#E2A6FF guibg=#3C3272", HI_MESSAGE))

    keymap.set("n", {
        ["<Leader>s"] = {
            desc = "Substitute",
            map = {
                ["*j"] = {
                    desc = "word under cursor downwards",
                    map = function()
                        local new = nil

                        vim.ui.input(
                            { prompt = "(Substitute) new: " },
                            function(i_new) new = i_new end
                        )

                        M.enter_mode(
                            vim.fn.line("."),
                            vim.fn.line("$"),
                            new_sized_string(vim.fn.expand("<cword>")),
                            new_sized_string(new)
                        )
                    end,
                },
                j = {
                    desc = "downwards",
                    map = function()
                        local target = nil
                        local new = nil

                        vim.ui.input(
                            { prompt = "(Substitute) target: " },
                            function(i_target) target = i_target end
                        )

                        if target == nil or target == "" then
                            return
                        end

                        vim.ui.input(
                            { prompt = "(Substitute) new: " },
                            function(i_new) new = i_new end
                        )

                        if new == nil or new == "" then
                            return
                        end

                        M.enter_mode(
                            vim.fn.line("."),
                            vim.fn.line("$"),
                            new_sized_string(target),
                            new_sized_string(new)
                        )
                    end,
                }
            },
        },
    })
end

return M
