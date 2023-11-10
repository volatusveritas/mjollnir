-- Imports
local keymap = require('volt.keymap')

local header_pat = [[^\*\+\s\+\S.*$]]
local ref_pat = [=[\[\@<=\f*\%#\f*]\@=]=]

local function jump_to_next_header()
    vim.fn.search(header_pat, 'z')
end

local function jump_to_previous_header()
    vim.fn.search(header_pat, 'zb')
end

local function capture_ref()
    local ref_lnum = vim.fn.search(ref_pat, '')

    if ref_lnum == 0 then
        vim.api.nvim_err_writeln('No ref under the cursor.')
        return nil
    end

    local cursor_col = vim.fn.col('.')
    local line = vim.fn.getline(ref_lnum)
    local ref_end = string.find(line, ']', cursor_col + 1, true)

    return string.sub(line, cursor_col, ref_end - 1)
end

local function expand_ref(ref)
    return string.format('.vnotes/%s.vnotes', ref)
end

local function check_file(path)
    return vim.fn.filereadable(path) ~= 0
end

local function jump_to_file(path)
    vim.cmd(string.format('edit %s', path))
end

local function jump_to_file_protected(path)
    if not check_file(path) then
        vim.api.nvim_err_writeln('File not found.')
        return
    end

    jump_to_file(path)
end

keymap.set('n', {
    ["<LocalLeader>"] = {
        desc = 'VNotes commands',
        opts = { buffer = 0 },
        map = {
            g = {
                desc = 'Go/jump',
                map = {
                    j = {
                        desc = 'Jump to next header',
                        map = jump_to_next_header,
                    },
                    k = {
                        desc = 'Jump to previous header',
                        map = jump_to_previous_header,
                    },
                    o = {
                        desc = "Edit file ref",
                        opts = { buffer = 0 },
                        map = function()
                            local ref = capture_ref()

                            if ref then
                                jump_to_file(expand_ref(ref))
                            end
                        end,
                    },
                },
            },
        },
    },
    ["<CR>"] = {
        desc = "Jump to file ref",
        opts = { buffer = 0 },
        map = function()
            local ref = capture_ref()

            if ref then
                jump_to_file_protected(expand_ref(ref))
            end
        end,
    },
})
