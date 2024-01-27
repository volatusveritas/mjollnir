local M = {}

----------------------------------- Imports -----------------------------------
local fuzzy = require('volt.fuzzy')
local ui = require('volt.ui')
local window = require('volt.window')
local msg = require('volt.msg')
local vlua = require('volt.lua')
local highlight = require('volt.highlight')
local keymap = require('keymap')
local vnvim = require('volt.nvim')
-------------------------------------------------------------------------------

local ns = nil
local keys = nil

--------------------------------- Public API ----------------------------------
function M.hunt(entries, opts)
    -- Opts:
    -- • on_tracked [function] A callback to be called when an item is
    -- selected; the selected item's text is passed as an argument

    local entries_buf = vim.api.nvim_create_buf(false, true)

    if entries_buf == 0 then
        msg.err('Could not create buffer to display entries')
        return
    end

    local entries_win_opts = window.centered(window.screen({
        border = 'single',
        style = 'minimal',
        width = 0.5,
        height = 0.5,
    }))

    local entries_win = window.open(entries_buf, false, entries_win_opts)

    if entries_win == 0 then
        msg.err('Could not create window to display entries')
        vim.api.nvim_buf_delete(entries_buf, { force = true })
        return
    end

    local selected = 1

    local matches = nil
    local entry_lines = nil
    local n_entry_lines = 0

    local update_selection_extmark = function()
        if n_entry_lines == 0 then
            return
        end

        extmark_id = vim.api.nvim_buf_set_extmark(
            entries_buf,
            ns,
            selected - 1,
            0,
            {
                virt_text = { { '> ', 'Special' } },
                virt_text_pos = 'inline',
            }
        )

        vim.api.nvim_win_set_cursor(entries_win, {selected, 0})
    end

    local update_highlights = function()
        vim.api.nvim_buf_clear_namespace(entries_buf, ns, 0, -1)

        for match_idx, match in ipairs(matches) do
            if match_idx == selected then
                vim.api.nvim_buf_add_highlight(
                    entries_buf,
                    ns,
                    'HunterSelected',
                    match_idx - 1,
                    0,
                    -1
                )
            else
                vim.api.nvim_buf_add_highlight(
                    entries_buf,
                    ns,
                    'HunterOption',
                    match_idx - 1,
                    0,
                    -1
                )
            end

            for _, idx in ipairs(match.indexes) do
                vim.api.nvim_buf_add_highlight(
                    entries_buf,
                    ns,
                    'HunterCombos',
                    match_idx - 1,
                    idx - 1,
                    idx
                )
            end
        end

        update_selection_extmark()
    end

    local update_matches = function(new_text)
        matches = fuzzy.match(new_text, entries)

        selected = 1

        entry_lines = {}
        n_entry_lines = 0

        for match_idx, match in ipairs(matches) do
            entry_lines[match_idx] = match.value
            n_entry_lines = match_idx
        end

        vim.api.nvim_buf_set_lines(entries_buf, 0, -1, true, entry_lines)

        update_highlights()
    end

    local input_win_opts = window.offset(entries_win_opts, { y = -3 })
    input_win_opts.title = ' Search '
    input_win_opts.height = 1

    local input_view = ui.input('Search', {
        win_opts = input_win_opts,
        on_change = update_matches,

        on_confirm = function()
            local target = vim.api.nvim_buf_get_lines(entries_buf, selected-1, selected, true)[1]
            vim.api.nvim_win_close(entries_win, true)
            vim.api.nvim_buf_delete(entries_buf, { force = true })

            if opts.on_tracked then
                opts.on_tracked(target)
            end
        end,

        on_cancel = function()
            vim.api.nvim_win_close(entries_win, true)
            vim.api.nvim_buf_delete(entries_buf, { force = true })
        end,
    })

    if input_view == nil then
        return
    end

    keymap.insert({
        [keymap.opts] = { buffer = input_view.buf },

        [keys.next] = function()
            selected = math.min(selected + 1, n_entry_lines)
            update_highlights()
        end,
        [keys.previous] = function()
            selected = math.max(selected - 1, 1)
            update_highlights()
        end,
    })

    update_matches('')
end

function M.files()
    local entries = vlua.efficient_array()

    for name, type in vim.fs.dir('.', { depth = math.huge }) do
        if type == 'file' then
            entries:insert(name)
        end
    end

    return entries
end

function M.setup(opts)
    ns = vim.api.nvim_create_namespace('hunter')

    highlight.set('HunterCombos', opts.highlight_combos)
    highlight.set('HunterSelected', opts.highlight_selected)
    highlight.set('HunterOption', opts.highlight_option)

    keys = {
        next     = opts.key_next,
        previous = opts.key_previous,
    }
end
-------------------------------------------------------------------------------

return M
