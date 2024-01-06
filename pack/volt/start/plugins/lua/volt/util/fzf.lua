local M = {}

-- Import
local windowutils = require('volt.tui.window')
local msg = require('volt.util.msg')

local fzf_path = string.format(
    '%s/pack/plug/start/fzf/bin/fzf.exe',
    vim.fn.stdpath('config')
)

function M.prompt(opts)
    opts.options = opts.options or {}

    local cmd = { fzf_path, '--layout=reverse', '--info=inline' }

    for _, opt in ipairs(opts.options) do
        table.insert(cmd, opt)
    end

    local buf = vim.api.nvim_create_buf(false, true)

    if buf == 0 then
        msg.err('Failed to create buffer.')
        return
    end

    windowutils.open_window_centered(buf, true, { border = 'single' })

    vim.fn.termopen(cmd, {
        cwd = opts.dir,
        stdout_buffered = true,
        on_stdout = function(chan_id, lines, stream_name)
            opts.callback(lines)
        end,
    })

    vim.cmd('startinsert')
end

return M
