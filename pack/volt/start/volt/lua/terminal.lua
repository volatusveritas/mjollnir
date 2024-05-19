local terminal = {}

----------------------------------- Imports -----------------------------------
local window = require('volt.window')
local keymap = require('keymap')
-------------------------------------------------------------------------------

--:: map[string]string
local keys = nil
--:: number
local augroup = nil

--------------------------------- Public API ----------------------------------
--:: map[term_index(number)]bufnr(number)
terminal.terminal_bufs = {}

function terminal.buffer_index(bufnr)
    for index, term_bufnr in pairs(terminal.terminal_bufs) do
        if term_bufnr == bufnr then
            return index
        end
    end

    return -1
end

-- Starts a terminal buffer in the current window
function terminal.start_terminal()
    local terminal_index = vim.v.count1
    local terminal_buf = terminal.terminal_bufs[terminal_index]

    if terminal_buf == nil then
        vim.cmd.terminal()

        local new_terminal_buf = vim.api.nvim_get_current_buf()

        terminal.terminal_bufs[terminal_index] = new_terminal_buf
        terminal_buf = new_terminal_buf
    else
        vim.api.nvim_set_current_buf(terminal_buf)
    end

    local fn_terminal_kill = function()
        vim.api.nvim_buf_delete(terminal_buf, { force = true })
        print('terminal kill called')
    end

    keymap.normal()
    :group({ opts = { buffer = terminal_buf } })
        :set({ key = keys.close, map = '<C-w>q' })
        :set({ key = keys.kill, map = fn_terminal_kill })
    :endgroup()

    keymap.terminal()
    :group({ opts = { buffer = terminal_buf } })
        :set({ key = keys.term_escape, map = [[<C-\><Esc>]] })
        :set({ key = keys.term_leave, map = [[<C-\><C-n>]] })
        :set({ key = keys.term_close, map = [[<C-\><C-n><C-w>q]] })
        :set({ key = keys.term_kill, map = fn_terminal_kill })
    :endgroup()

    vim.bo.filetype = 'terminal'

    vim.api.nvim_create_autocmd('BufDelete', {
        group = augroup,
        buffer = terminal_buf,
        callback = function(context)
            for idx, buf in pairs(terminal.terminal_bufs) do
                if buf == context.buf then
                    terminal.terminal_bufs[idx] = nil
                    break
                end
            end
        end,
    })

    vim.cmd.startinsert()
end

function terminal.open_floating()
    window.open(0, true, window.centered(window.screen({
        title = ' Terminal ',
        border = 'rounded',
        style = 'minimal',
        width = 0.6,
        height = 0.65,
    })))

    terminal.start_terminal()

    local terminal_win = vim.api.nvim_get_current_win()
    local terminal_buf = vim.api.nvim_get_current_buf()

    vim.api.nvim_create_autocmd('BufLeave', {
        group = augroup,
        buffer = terminal_buf,
        callback = function()
            if vim.api.nvim_win_is_valid(terminal_win) then
                vim.api.nvim_win_close(terminal_win, true)
            end
        end,
    })
end

function terminal.open_split(direction)
    vim.api.nvim_open_win(0, true, {win = 0, split = direction})

    terminal.start_terminal()
end

function terminal.open_left()
    terminal.open_split('left')
end

function terminal.open_right()
    terminal.open_split('right')
end

function terminal.open_below()
    terminal.open_split('below')
end

function terminal.open_above()
    terminal.open_split('above')
end

function terminal.setup(opts)
    augroup = vim.api.nvim_create_augroup('terminal', { clear = true })

    keys = {
        term_escape = opts.key_term_escape,
        term_leave = opts.key_term_leave,
        term_close = opts.key_term_close,
        term_kill = opts.key_term_kill,

        close = opts.key_close,
        kill = opts.key_kill,
    }

    vim.api.nvim_create_autocmd('ExitPre', {
        group = augroup,
        callback = function()
            for idx, buf in pairs(terminal.terminal_bufs) do
                vim.api.nvim_buf_delete(buf, { force = true })
            end
        end,
    })
end
-------------------------------------------------------------------------------

return terminal
