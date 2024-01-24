local M = {}

-- TODO: mark selected lines if in Visual mode

-- Concepts:
-- - delete a line to remove an item
-- - create a line to create an item
-- - use the format old->new to move an item in place
-- - mark for copying or moving

----------------------------------- Imports -----------------------------------
local vlua = require('volt.lua')
local highlight = require('volt.highlight')
local msg = require('volt.msg')

local keymap = require('keymap')
-------------------------------------------------------------------------------

-- :: map[bufnr(number)]{ path: string, files, folders, links: string[] }
local bufs = nil
-- :: map[string]string
local keys = nil
-- :: namespace_id(number)
local ns = nil

local function child_path(buf, child)
    return vim.fs.normalize(vim.fs.joinpath(bufs[buf].path, child))
end

local function item_to_directory(item)
    return string.format('%s/', item)
end

local function item_is_directory(item)
    return item:find('^[^%s]+/$') ~= nil
end

local function item_to_link(item)
    return string.format('%s >>', item)
end

local function item_is_link(item)
    return item:find('^[^%s]+ >>$') ~= nil
end

local function item_as_move_order(item)
    return item:match('([^%s]+)%s*->%s*([^%s]+)')
end

local function explore(buf, path)
    local file_lines = vlua.efficient_array()
    local link_lines = vlua.efficient_array()
    local folder_lines = vlua.efficient_array()

    for name, item_type in vim.fs.dir(path) do
        if item_type == 'directory' then
            folder_lines:insert(item_to_directory(name))
        elseif item_type == 'link' then
            link_lines:insert(item_to_link(name))
        else
            file_lines:insert(name)
        end
    end

    local buflines = vlua.efficient_array()

    for i = 1, file_lines.length do
        buflines:insert(file_lines[i])
    end

    for i = 1, link_lines.length do
        buflines:insert(link_lines[i])
    end

    for i = 1, folder_lines.length do
        buflines:insert(folder_lines[i])
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, true, buflines:make_natural())
    
    bufs[buf] = {
        path = path,
        files = file_lines,
        folders = folder_lines,
        links = link_lines,
    }
end

local function update_all_buffers()
    for bufnr, buf in pairs(bufs) do
        explore(bufnr, buf.path)
    end
end

local function apply_updates(buf)
    local new_files = vlua.efficient_array()
    local new_folders = vlua.efficient_array()
    local new_links = vlua.efficient_array()
    
    local new_targets = vim.api.nvim_buf_get_lines(buf, 0, -1, true)

    for _, line in ipairs(new_targets) do
        local from, to = item_as_move_order(line)

        if from ~= nil then
            if item_is_link(from) then
                -- TODO: move link
                new_links:insert(from)
                msg.msg('Moving links is not available yet.')
            elseif item_is_directory(from) then
                new_folders:insert(from)
                -- TODO: move folder
                msg.msg('Moving folders is not available yet.')
            else
                if vim.fn.filereadable(to) == 1 then
                    msg.err('Failed to move file %s to %s: target file already exists.', from, to)
                    return
                end

                local from_path = child_path(buf, from)
                local to_path = child_path(buf, to)

                if vim.fn.rename(from_path, to_path) ~= 0 then
                    msg.err('Failed to move file %s to %s', from_path, to_path)
                    return
                end

                msg.msg('File %s moved to %s', from_path, to_path)
                new_files:insert(from, to)
            end
        elseif item_is_link(line) then
            new_links:insert(line)
            local new_link = true
            for _, link in ipairs(bufs[buf].links) do
                if link == line then
                    new_link = false
                    break
                end
            end

            if new_link then
                msg.msg('Creating links is not available yet.')
                -- TODO: check if link exists, error if true
                -- TODO: msg.msg('Link created')
            end
        elseif item_is_directory(line) then
            new_folders:insert(line)
            local new_folder = true
            for _, folder in ipairs(bufs[buf].folders) do
                if folder == line then
                    new_folder = false
                    break
                end
            end

            if new_folder then
                local path = child_path(buf, line)
                if vim.fn.mkdir(path, 'p') == 0 then
                    msg.err('Failed to create folder %s', path)
                else
                    msg.msg('Folder %s created', path)
                end
            end
        else
            new_files:insert(line)
            local new_file = true 
            for _, file in ipairs(bufs[buf].files) do
                if file == line then
                    new_file = false
                    break
                end
            end

            if new_file then
                if vim.fn.filereadable(line) == 1 then
                    msg.err('Failed to create file %s: file already exists', line)
                    return
                end

                local path = child_path(buf, line)
                local file, err = io.open(path, 'w')

                if file == nil then
                    msg.err('Failed to create file %s: %s', path)
                    file:close()
                    return
                end

                file:write()
                file:close()

                msg.msg('File %s created', path)
            end
        end
    end

    for _, file in ipairs(bufs[buf].files) do
        local removed = true

        for _, new_file in ipairs(new_files) do
            if new_file == file then
                removed = false
                break
            end
        end

        if removed then
            local path = child_path(buf, file)

            if vim.fn.delete(path) == -1 then
                msg.err('Failed to remove file %s: %s', path, err)
                return
            end

            msg.msg('File %s removed', path)
        end
    end

    for _, folder in ipairs(bufs[buf].folders) do
        local removed = true

        for _, new_folder in ipairs(new_folders) do
            if new_folder == folder then
                removed = false
                break
            end
        end

        if removed then
            local path = child_path(buf, folder)

            if vim.fn.delete(path, 'rf') == -1 then
                msg.err('Failed to remove folder %s: %s', path)
                return
            end

            msg.msg('Folder %s removed', path)
        end
    end

    for _, link in ipairs(bufs[buf].links) do
        local removed = true

        for _, new_link in ipairs(new_links) do
            if new_link == link then
                removed = false
                break
            end
        end

        if removed then
            local path = child_path(buf, folder)

            if vim.fn.delete(path) == -1 then
                msg.err('Failed to remove link %s: %s', path)
                return
            end

            msg.msg('Link %s removed', path)
        end
    end

    update_all_buffers()
end

local function setup_buffer(path)
    local buf = vim.api.nvim_create_buf(false, true)

    if buf == 0 then
        msg.err('Unable to initialize the explorer buffer.')
        return nil
    end

    vim.api.nvim_buf_set_name(buf, string.format('Explorer %d', buf))

    vim.bo[buf].filetype = 'explorer'

    keymap.normal({
        [keymap.opts] = { buffer = buf },

        [keys.enter]  = function()
            local content = vim.fn.getline('.')
            local full_path = child_path(buf, content)

            if item_is_directory(content) then
                explore(buf, full_path)
            else
                if vim.fn.isdirectory(full_path) == 1 then
                    explore(buf, full_path)
                else
                    vim.cmd.edit(full_path)
                end
            end
        end,
        [keys.parent] = function()
            explore(buf, vim.fs.dirname(bufs[buf].path))
        end,
        [keys.close]  = function()
            vim.api.nvim_buf_delete(buf, {})
            bufs[buf] = nil
        end,
        [keys.update] = function() explore(buf, bufs[buf].path) end,
        [keys.apply] = function() apply_updates(buf) end,
    })

    bufs[buf] = { path = path, files = {}, folders = {}, links = {} }

    return buf
end

--------------------------------- Public API ----------------------------------
function M.start(path)
    path = path or vim.fn.getcwd()

    local buf = setup_buffer(path)

    if buf == nil then
        return
    end

    explore(buf, path)

    vim.api.nvim_win_set_buf(0, buf)
end

function M.setup(opts)
    highlight.set('ExplorerFile',   opts.highlight_file)
    highlight.set('ExplorerFolder', opts.highlight_folder)
    highlight.set('ExplorerLink',   opts.highlight_link)

    bufs = {}

    keys = {
        enter  = opts.key_enter,
        parent = opts.key_parent,
        close  = opts.key_close,
        update = opts.key_update,
        apply  = opts.key_apply,
        mark   = opts.key_mark,
        copy   = opts.key_copy,
        move   = opts.key_move,
    }

    ns = vim.api.nvim_create_namespace('explorer')
end
-------------------------------------------------------------------------------

return M
