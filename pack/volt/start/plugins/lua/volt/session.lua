local M = {}

-- Imports
local msg = require('volt.util.msg')

M.sessionlist = {}
M.sessionlist_path = string.format(
    "%s/volt_sessionlist.txt",
    vim.api.nvim_list_runtime_paths()[1]
)

local function save_sessionlist_to(file)
    file:write(table.concat(M.sessionlist, '\n'))
end

function M.save_sessionlist()
    local file, err = io.open(M.sessionlist_path, 'w')

    if file == nil then
        msg.err(string.format('Failed to save sessionlist: %s', err))
        return true
    end

    save_sessionlist_to(file)

    file:close()

    return false
end

function M.generate_sessionlist_file()
    local err = M.save_sessionlist()

    if not err then
        msg.info('Sessionlist file generated.')
    end
end

function M.read_sessionlist()
    local file, err = io.open(M.sessionlist_path, 'r')

    if file == nil then
        msg.err(string.format('Failed to read sessionlist: %s', err))
        return
    end

    local next_index = 1
    for line in file:lines() do
        M.sessionlist[next_index] = line
        next_index = next_index + 1
    end

    file:close()
end

local function save_current_session()
    if vim.v.this_session == '' then
        return
    end

    vim.cmd(string.format('mksession! %s', vim.v.this_session))
end

function M.setup()
    local augroup = vim.api.nvim_create_augroup('volt.session', {})

    M.read_sessionlist()

    -- Autosave session when leaving if opened with a session
    vim.api.nvim_create_autocmd('VimLeavePre', {
        group = augroup,
        callback = save_current_session,
    })

    vim.api.nvim_create_autocmd('SessionLoadPost', {
        group = augroup,
        callback = function()
            if vim.list_contains(M.sessionlist, vim.v.this_session) then
                return
            end

            print('Saved session: ', vim.v.this_session)
            table.insert(M.sessionlist, vim.v.this_session)
        end,
    })

    vim.api.nvim_create_autocmd('VimLeavePre', {
        group = augroup,
        callback = M.save_sessionlist,
    })

    vim.api.nvim_create_user_command(
        'VoltSessionlistGenerate',
        M.generate_sessionlist_file,
        {}
    )
end

return M
