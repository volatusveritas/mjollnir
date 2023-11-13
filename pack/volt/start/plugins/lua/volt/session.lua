local M = {}

-- Imports
local msg = require('volt.util.msg')
local ui = require('volt.util.ui')

local sessions_path = '.nvim/sessions'
local augroup = vim.api.nvim_create_augroup('volt.session', {})

M.sessionlist = {}

local function name_to_path(name)
    return string.format('%s/%s', sessions_path, name)
end

local function save_current_session()
    if vim.v.this_session == '' then
        return
    end

    vim.cmd(string.format('mksession! %s', vim.v.this_session))
end

local function source_session(name)
    save_current_session()
    vim.cmd(string.format('source %s', name_to_path(name)))
end

function M.update_sessionlist()
    if vim.fn.isdirectory(sessions_path) == 0 then
        msg.info(
            'Sessions folder not found. Skipping sessionlist loading.',
            true
        )
        return
    end

    local next_index = 1
    local outlier_items = 0

    for item, class in vim.fs.dir(sessions_path) do
        if class == 'file' then
            M.sessionlist[next_index] = item
            next_index = next_index + 1
        else
            outlier_items = outlier_items + 1
        end
    end

    msg.info('Sessionlist loaded.', true)

    if outlier_items > 0 then
        msg.info(
            string.format(
                '%d outliers found while loading the sessionlist.',
                outlier_items
            ),
            true
        )
    end
end

function M.prompt_source_session()
    if #M.sessionlist == 0 then
        msg.info('Sessionlist is empty. Skipping session selection prompt.')
        return
    end

    ui.selection(
        'Source session',
        M.sessionlist,
        nil,
        function(idx, item)
            if idx == nil then
                return
            end

            source_session(item)
        end
    )
end

function M.setup()
    M.update_sessionlist()

    vim.api.nvim_create_autocmd('VimLeavePre', {
        group = augroup,
        callback = save_current_session,
    })
end

return M
