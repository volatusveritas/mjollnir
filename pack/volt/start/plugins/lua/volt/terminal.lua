local M = {}

-- Imports
local set_keymap = require("volt.keymap").set

-- Mapping of terminal indexes to terminal buffer handles
M.terminals = {}

function M.close_terminal(index)
    if not M.terminals[index] then
        vim.api.nvim_err_writeln("Not a terminal buffer.")
        return
    end

    vim.api.nvim_buf_delete(M.terminals[index], { force = true })
    M.terminals[index] = nil
end

function M.close_current_terminal()
    local terminal_index = vim.v.count

    if vim.v.count == 0 then
        terminal_index = M.get_terminal_index(vim.api.nvim_get_current_buf())
    end

    M.close_terminal(terminal_index)
end

-- FIXME: Opportunity for performance improvement here
function M.get_terminal_index(buf_handle)
    for i, handle in ipairs(M.terminals) do
        if handle == buf_handle then
            return i
        end
    end
end

-- mode = 0 :: use current window
-- mode = 1 :: use new hsplit window
-- mode = 2 :: use new vsplit window
function M.open_terminal(mode)
    if mode == 1 then
        vim.cmd("split")
    elseif mode == 2 then
        vim.cmd("vsplit")
    end

    if M.terminals[vim.v.count1] == nil then
        vim.cmd("terminal")
        M.terminals[vim.v.count1] = vim.api.nvim_get_current_buf()
    else
        vim.api.nvim_win_set_buf(0, M.terminals[vim.v.count1])
    end

    vim.cmd("startinsert")
end

function M.setup()
    -- Options
    vim.o.shell = "nu"
    vim.o.shellcmdflag = "-c"
    vim.o.shellslash = true
    vim.o.shellquote = ""
    vim.o.shellxquote = ""
    vim.o.shellpipe = ""

    -- Keymaps
    set_keymap("n", {
        ["<Leader>t"] = {
            desc = "Terminal",
            map = {
                ["<Leader>"] = {
                    desc = "Open terminal here.",
                    map = function() M.open_terminal(0) end,
                },
                s = {
                    desc = "H-split open terminal.",
                    map = function() M.open_terminal(1) end,
                },
                v = {
                    desc = "V-split-open terminal.",
                    map = function() M.open_terminal(2) end,
                },
                q = {
                    desc = "Close terminal.",
                    map = M.close_current_terminal,
                },
            }
        }
    })

    set_keymap("t", {
        ["<C-s>"] = {
            desc = "Special terminal keys",
            map = "<C-\\><Esc>",
        },
        ["<Esc>"] = {
            desc = "Leave terminal mode.",
            map = "<C-\\><C-N>",
        }
    })

    local augroup = vim.api.nvim_create_augroup("volt.terminal", {})

    -- Filetype detection
    vim.api.nvim_create_autocmd("TermOpen", {
        group = augroup,
        callback = function()
            vim.cmd("setfiletype terminal")
        end,
    })

    -- Buffer cleanup
    vim.api.nvim_create_autocmd("BufDelete", {
        group = augroup,
        callback = function(context)
            local terminal_index = M.get_terminal_index(context.buf)

            if not terminal_index then
                return
            end

            M.terminals[terminal_index] = nil
        end
    })
end

return M
