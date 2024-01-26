local M = {}

----------------------------------- Imports -----------------------------------
local msg = require('volt.msg')
local window = require('volt.window')
local keymap = require('keymap')
------------------------------------------------------------------------------

local augroup = nil

--------------------------------- Public API ----------------------------------
function M.input(prompt, window_settings, opts)
    local original_window = vim.api.nvim_get_current_win()

    local border_buf = vim.api.nvim_create_buf(false, true)
    
    if border_buf == 0 then
        msg.err('Could not create temporary buffer for lens cmdline')
        return
    end

    local buf = vim.api.nvim_create_buf(false, true)
    
    if buf == 0 then
        msg.err('Could not create temporary buffer for lens cmdline')
        vim.api.nvim_buf_delete(border_buf, { force = true })
        return
    end

    local border_window_opts = window.centered(vim.tbl_extend('keep', window_settings, {
        title = prompt,
        style = 'minimal',
        border = 'rounded',
        height = 1,
        width = 0.3,
    }))

    local border_win = window.open(border_buf, true, border_window_opts)

    if border_win == 0 then
        msg.err('Could not create input window')
        vim.api.nvim_buf_delete(border_buf, { force = true })
        vim.api.nvim_buf_delete(buf, { force = true })
        return
    end

    local window_opts = vim.tbl_extend('force', border_window_opts, {
        style = 'minimal',
        border = 'none',
        x = border_window_opts.x + 2,
        y = border_window_opts.y + 1,
        width = vim.api.nvim_win_get_width(border_win) - 2,
    })

    local win = window.open(buf, true, window_opts)

    if win == 0 then
        msg.err('Could not create input window')
        if vim.api.nvim_win_is_valid(original_window) then
            vim.api.nvim_set_current_win(original_window)
        end
        vim.api.nvim_buf_delete(buf, { force = true })
        vim.api.nvim_win_close(border_win, true)
        vim.api.nvim_buf_delete(border_buf, { force = true })
        return
    end

    local fn_close = function()
        if vim.api.nvim_win_is_valid(original_window) then
            vim.api.nvim_set_current_win(original_window)
        end

        vim.api.nvim_win_close(win, true)
        vim.api.nvim_buf_delete(buf, { force = true })
        vim.api.nvim_win_close(border_win, true)
        vim.api.nvim_buf_delete(border_buf, { force = true })
    end

    vim.api.nvim_create_autocmd('InsertLeave', {
        group = augroup,
        buffer = buf,
        callback = function()
            local text = vim.api.nvim_buf_get_lines(buf, 0, -1, true)[1]
            fn_close()

            if opts.on_cancel ~= nil then
                opts.on_cancel(text)
            end
        end,
    })

    if opts.on_change ~= nil then
        vim.api.nvim_create_autocmd('TextChangedI', {
            group = augroup,
            buffer = buf,
            callback = function()
                local text = vim.api.nvim_buf_get_lines(buf, 0, -1, true)[1]
                opts.on_change(text)
            end,
        })
    end

    keymap.insert({
        [keymap.opts] = { buffer = buf },

        ['<CR>'] = function()
            local answer = vim.api.nvim_buf_get_lines(buf, 0, -1, true)[1]
            vim.cmd.stopinsert()
            fn_close()

            if opts.on_confirm ~= nil then
                opts.on_confirm(answer)
            end
        end,
    })

    vim.cmd.startinsert()

    return {
        border_buf = border_buf,
        border_win = border_win,
        buf = buf,
        win = win,
    }
end

function M.setup()
    augroup = vim.api.nvim_create_augroup('ui', { clear = true })
end
-------------------------------------------------------------------------------

return M
