local M = {}

-- Imports
local vlua = require('volt.vlua')
local highlight = require('volt.highlight')
local msg = require('volt.msg')

local color = require('palette').color
local keymap = require('keymap')

-- TODO: document this
local bufs = {}
local keys = {}
local ns = vim.api.nvim_create_namespace('explorer')

-- Defined later
local update_buffer

---------------------------------- COMMANDS -----------------------------------
local function command_enter(buf)
    local line = vim.fn.line('.')
    local content = vim.fn.getline('.')

    if bufs[buf].types[line] == 'directory' then
        update_buffer(buf,
            vim.fs.joinpath(bufs[buf].path, vim.fs.normalize(content))
        )
    else
        vim.cmd.edit(vim.fs.joinpath(bufs[buf].path, content))
    end
end

local function command_up(buf)
    update_buffer(buf, vim.fs.dirname(bufs[buf].path))
end

local function command_back(buf)
    local path = bufs[buf].origin

    if vim.fn.filereadable(path) == 1 then
        vim.cmd.edit(path)
    else
        update_buffer(buf, path)
    end
end

local function command_update(buf)
end
-------------------------------------------------------------------------------

-- TODO: document this
local function update_highlights(buf)
    for i, item_type in ipairs(bufs[buf].types) do
        local highlight_group

        if item_type == 'directory' then
            highlight_group = 'ExplorerFolder'
        elseif item_type == 'link' then
            highlight_group = 'ExplorerLink'
        else
            highlight_group = 'ExplorerFile'
        end

        vim.api.nvim_buf_add_highlight(buf, ns, highlight_group, i - 1, 0, -1)
    end
end

-- TODO: document this
update_buffer = function(buf, path)
    local file_lines = vlua.efficient_array_make()
    local link_lines = vlua.efficient_array_make()
    local folder_lines = vlua.efficient_array_make()

    for name, item_type in vim.fs.dir(path) do
        if item_type == 'directory' then
            folder_lines:insert(string.format('%s/', name))
        elseif item_type == 'link' then
            link_lines:insert(string.format('%s >>', name))
        else
            file_lines:insert(name)
        end
    end

    local buflines = vlua.efficient_array_make()
    local typelist = vlua.efficient_array_make()

    for i = 1, file_lines.length do
        buflines:insert(file_lines[i])
        typelist:insert('file')
    end

    for i = 1, link_lines.length do
        buflines:insert(link_lines[i])
        typelist:insert('link')
    end

    for i = 1, folder_lines.length do
        buflines:insert(folder_lines[i])
        typelist:insert('directory')
    end

    local bmn = buflines:make_natural()
    print(string.format('Settings buf[%d] to %s', buf, bmn))
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, bmn)
    
    bufs[buf].path = path
    bufs[buf].types = typelist

    update_highlights(buf)
end

-- TODO: document this
local function setup_keybindings(buf)
    keymap.bset('n', buf, {
        [keys.enter] = {
            desc = 'enter directory/file',
            map = function() command_enter(buf) end,
        },
        [keys.parent] = {
            desc = 'go up directory',
            map = function() command_up(buf) end,
        },
        [keys.back] = {
            desc = 'go back to exploration origin',
            map = function() command_back(buf) end,
        },
        [keys.update] = {
            desc = 'update explorer',
            map = function() command_update(buf) end,
        },
    })
end

-- TODO: document this
local function setup_buffer(path)
    local buf = vim.api.nvim_create_buf(false, true)

    if buf == 0 then
        msg.err('Unable to initialize the explorer buffer.')
        return nil
    end

    setup_keybindings(buf)

    return buf
end

--------------------------------- PUBLIC API ----------------------------------
-- TODO: document this
function M.start(path)
    path = path or vim.fn.getcwd()

    local buf = setup_buffer(path)

    bufs[buf] = { path = path, origin = vim.fn.expand('%:p') }

    update_buffer(buf, path)

    if buf == nil then
        return
    end

    vim.api.nvim_win_set_buf(0, buf)
end

-- TODO: document this
function M.setup(opts)
    highlight.set('ExplorerFile',   opts.highlight_file)
    highlight.set('ExplorerFolder', opts.highlight_folder)
    highlight.set('ExplorerLink',   opts.highlight_link)

    keys.enter  = opts.key_enter
    keys.parent = opts.key_parent
    keys.back   = opts.key_back
    keys.update = opts.key_update
end
-------------------------------------------------------------------------------

return M
