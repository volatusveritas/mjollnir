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
function M.hunt(entries)
    local entries_buf = vim.api.nvim_create_buf(false, true)

    if entries_buf == 0 then
        msg.err('Could not create buffer to display entries')
        return
    end

    local entries_settings = window.centered({
        border = 'single',
        style = 'minimal',
        height = 0.5,
    })

    local entries_win = window.open(entries_buf, false, entries_settings)

    if entries_win == 0 then
        msg.err('Could not create window to display entries')
        vim.api.nvim_buf_delete(entries_buf, { force = true })
        return
    end

    local selected = 1

    local matches = nil
    local entry_lines = nil
    local n_entry_lines = 0

    local extmark_id = nil

    local update_selection_extmark = function()
        if n_entry_lines == 0 then
            return
        end

        local target_line = math.max(0, selected - 1)

        extmark_id = vim.api.nvim_buf_set_extmark(
            entries_buf,
            ns,
            selected - 1,
            0,
            {
                id = extmark_id,
                virt_text = { { '-> ', 'Special' } },
                virt_text_pos = 'inline',
            }
        )

        vim.api.nvim_win_set_cursor(entries_win, {target_line + 1, 0})
    end

    local update_highlights = function()
        vim.api.nvim_buf_clear_namespace(entries_buf, ns, 0, -1)

        update_selection_extmark()

        for match_idx, match in ipairs(matches) do
            if match_idx == selected then
                vim.api.nvim_buf_add_highlight(
                    entries_buf,
                    ns,
                    'HunterSelected',
                    match_idx - 1,
                    0,
                    #match.value
                )
            else
                vim.api.nvim_buf_add_highlight(
                    entries_buf,
                    ns,
                    'HunterOption',
                    match_idx - 1,
                    0,
                    #match.value
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

    local input_y_offset = -entries_settings.height / 2 - 2

    local input_view = ui.input('Search', { offset_y = input_y_offset }, {
        on_change = update_matches,

        on_confirm = function()
            local target = vim.api.nvim_buf_get_lines(entries_buf, selected-1, selected, true)[1]
            vim.api.nvim_win_close(entries_win, true)
            vim.api.nvim_buf_delete(entries_buf, { force = true })
            vim.cmd.edit(target)
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
