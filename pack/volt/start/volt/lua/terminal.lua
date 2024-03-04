local M = {}

----------------------------------- Imports -----------------------------------
local window = require('volt.window')
local keymap = require('keymap')
-------------------------------------------------------------------------------

-- :: map[string]string
local keys = nil
-- :: number
local augroup = nil

--------------------------------- Public API ----------------------------------
-- :: map[term_index(number)]bufnr(number)
M.terminal_bufs = {}

function M.open_floating()
    window.open(0, true, window.centered(window.screen({
        title = ' Terminal ',
        border = 'rounded',
        style = 'minimal',
        width = 0.6,
        height = 0.65,
    })))

    local terminal_index = vim.v.count1

    if M.terminal_bufs[terminal_index] == nil then
        vim.cmd.terminal()
        M.terminal_bufs[terminal_index] = vim.api.nvim_get_current_buf()
    else
        vim.api.nvim_win_set_buf(0, M.terminal_bufs[terminal_index])
    end

    local terminal_buf = M.terminal_bufs[vim.v.count1]
    local terminal_win = vim.api.nvim_get_current_win()

    keymap.terminal({
        [keymap.opts] = { buffer = terminal_buf },

        [keys.special] = [[<C-\><Esc>]],
        [keys.leave] = [[<C-\><C-n>]],
    })

    keymap.normal({
        [keymap.opts] = { buffer = terminal_buf },

        [keys.close] = '<C-w>q',
        [keys.kill] = function()
            vim.api.nvim_buf_delete(terminal_buf, { force = true })
            M.terminal_bufs[terminal_index] = nil
        end
    })

    vim.api.nvim_create_autocmd('BufDelete', {
        group = augroup,
        buffer = terminal_buf,
        callback = function(context)
            for idx, buf in pairs(M.terminal_bufs) do
                if buf == context.buf then
                    M.terminal_bufs[idx] = nil
                end
            end
        end,
    })

    vim.api.nvim_create_autocmd('BufLeave', {
        group = augroup,
        buffer = terminal_buf,
        callback = function()
            if vim.api.nvim_win_is_valid(terminal_win) then
                vim.api.nvim_win_close(terminal_win, true)
            end
        end,
    })

    vim.cmd.startinsert()
end

function M.setup(opts)
    augroup = vim.api.nvim_create_augroup('terminal', { clear = true })

    keys = {
        special = opts.key_special,
        leave = opts.key_leave,
        close = opts.key_close,
        kill = opts.key_kill,
    }

    vim.api.nvim_create_autocmd('ExitPre', {
        group = augroup,
        callback = function()
            for idx, buf in pairs(M.terminal_bufs) do
                vim.api.nvim_buf_delete(buf, { force = true })
            end
        end,
    })
end
-------------------------------------------------------------------------------

return M
