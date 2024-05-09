-- TODO(volatus): REWRITE FUCKING EXPLORER FFS
-- TODO(volatus): Write a todo highlighting and searching plugin
-- TODO(volatus): Write a homescreen plugin

----------------------------------- Options -----------------------------------
vim.o.shiftwidth = 4
vim.o.wrap = false
vim.o.number = true
vim.o.relativenumber = true
vim.o.expandtab = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.scrolloff = 8
vim.o.termguicolors = true
vim.o.hlsearch = false
vim.o.timeout = false
vim.o.mouse = ''
vim.o.showmode = false
vim.o.cmdheight = 0
vim.o.laststatus = 0
vim.o.more = false

vim.o.shell = "nu"
vim.o.shellcmdflag = "-c"
vim.o.shellslash = true
vim.o.shellquote = ""
vim.o.shellxquote = ""
vim.o.shellpipe = ""

vim.opt.path:append('**')
vim.opt.fillchars:append({ fold = ' ' })

vim.g.mapleader = ' '
vim.g.maplocalleader = ','

vim.cmd('filetype plugin on')
vim.cmd('filetype indent on')
vim.cmd('syntax on')
-------------------------------------------------------------------------------

------------------------------ External Plugins -------------------------------
-- nvim-treesitter
require('nvim-treesitter.install').prefer_git = false
require('nvim-treesitter.configs').setup({
    ensure_installed = {
        'c',
        'lua',
        'vim',
        'vimdoc',
        'bash',
        'query',
        'odin',
        'gdscript',
    },
    highlight = { enable = true },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = 'gnn',
            node_incremental = 'grn',
            scope_incremental = 'grc',
            node_decremental = 'grm',
        },
    },
})
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'

-- leap.nvim
require('leap').add_default_mappings()
-------------------------------------------------------------------------------

----------------------------------- Imports -----------------------------------
local u = require('volt.u')
local window = require('volt.window')

local comment = require('comment')
local hunter = require('hunter')
local keymap = require('keymap')
local palette = require('palette')
local color = palette.color
local terminal = require('terminal')
local edit = require('edit')
-------------------------------------------------------------------------------

--------------------------- Volatus Palette v1.0.1 ----------------------------
color.purple = '#e2a6ff'
color.red =    '#f37a7a'
color.orange = '#ffbb80'
color.green =  '#a2f37a'
color.yellow = '#ffdd33'
color.blue =   '#8cd9ff'
color.cyan =   '#8cfffd'

color.purple_dark = '#8f70cc'
color.red_dark =    '#b35061'
color.orange_dark = '#cc7d5c'
color.green_dark =  '#50a642'
color.yellow_dark = '#c2b15b'
color.blue_dark =   '#5a87c7'
color.cyan_dark =   '#5dbaab'

color.dark1 = '#131515'
color.dark2 = '#171a1a'
color.dark3 = '#1b1e1f'
color.dark4 = '#212526'

color.grey1 = '#272b2e'
color.grey2 = '#2d3033'
color.grey3 = '#323638'
color.grey4 = '#383b3d'

color.light1 = '#f1f1f1'
color.light2 = '#d9d9d9'
color.light3 = '#c2c4c4'
color.light4 = '#a8adb3'
-------------------------------------------------------------------------------

palette.apply()

----------------------------------- Setups ------------------------------------
terminal.setup({
    key_term_escape = '<C-s>',
    key_term_leave = '<Esc>',
    key_term_close = '<C-q>',
    key_term_kill = '<C-d>',
    key_close = 'q',
    key_kill = '<C-q>',
})

hunter.setup({
    highlight_combos = { fg = color.yellow, attr = { 'bold' } },
    highlight_selected = { fg= color.light1 },
    highlight_option = { fg= color.light4 },
    key_next = '<C-n>',
    key_previous = '<C-p>',
})
-------------------------------------------------------------------------------

---------------------------------- Mappings ---------------------------------
keymap.insert() -- [INSERT]

-- Insert Mode Movement
:set({ key = '<C-f>', map = '<Right>' })
:set({ key = '<C-b>', map = '<Left>' })
:set({ key = '<A-n>', map = '<Down>' })
:set({ key = '<A-p>', map = '<Up>' })

keymap.normal() -- [NORMAL]

-- Neovim
:set({
    key = '<C-q>',
    map = function()
        local choice = vim.fn.confirm(
            'Are you sure you want to leave?',
            '&Yes\n&No', 1
        )

        if choice == 1 then
            vim.cmd('qall!')
        end
    end
})

-- Editing
:set({ key = 'dl', map = 'dd' })

-- terminal
:group({ key = '<Leader>t' })
    :set({ key = 'o', map = terminal.open_floating })
    :set({ key = 'h', map = terminal.open_left })
    :set({ key = 'j', map = terminal.open_below })
    :set({ key = 'k', map = terminal.open_above })
    :set({ key = 'l', map = terminal.open_right })
    :set({ key = '<Leader>', map = terminal.start_terminal })
:endgroup()

-- hunter
:group({ key = '<Leader>f' })
    :set({ key = 'd', map = function() hunter.hunt_files({ skip = { '.git' } }) end })
    :set({ key = 'a', map = hunter.hunt_buffers })
:endgroup()

-- edit
:set({
    key = '<A-j>',
    map = function()
        local current_line = vim.fn.line('.')

        if current_line == vim.fn.line('$') then
            return
        end

        local position = vim.fn.getpos('.')
        edit.swap_lines(vim.fn.bufnr(), current_line, current_line + 1)
        vim.fn.cursor(position[2] + 1, position[3])
    end
})
:set({
    key = '<A-k>',
    map = function()
        local current_line = vim.fn.line('.')

        if current_line == 1 then
            return
        end

        local position = vim.fn.getpos('.')
        edit.swap_lines(vim.fn.bufnr(), current_line, current_line - 1)
        vim.fn.cursor(position[2] - 1, position[3])
    end
})

-- Window
:group({ key = 'w' })
    :set({ key = 'h', map = '<C-w>h' })
    :set({ key = 'j', map = '<C-w>j' })
    :set({ key = 'k', map = '<C-w>k' })
    :set({ key = 'l', map = '<C-w>l' })
    :set({ key = 'q', map = '<C-w>q' })
    :set({ key = 's', map = '<C-w>s' })
    :set({ key = 'v', map = '<C-w>v' })
    :set({ key = 'n', map = '<C-w>n' })
    :set({ key = 't', map = '<C-w>t' })
    :set({ key = 'x', map = '<C-w>x' })

    :group({ key = 'r' })
        :set({ key = 'j', map = '<C-w>r' })
        :set({ key = 'k', map = '<C-w>R' })
    :endgroup()

    :group({ key = '<Leader>' })
        :set({ key = 'q', map = '<Cmd>quit!<CR>' })
        :set({ key = 'h', map = '<C-w>H' })
        :set({ key = 'j', map = '<C-w>J' })
        :set({ key = 'k', map = '<C-w>K' })
        :set({ key = 'l', map = '<C-w>L' })
        :set({ key = 't', map = '<C-w>T' })
    :endgroup()
:endgroup()

-- Clipboard
:group({ key = '<Leader>' })
    :set({ key = 'y', map = '"+y' })
    :set({ key = 'p', map = '"+p' })
    :set({ key = 'P', map = '"+P' })
:endgroup()

-- Quickfix List
:group({ key = '<Leader>e', opts = { operator = true } })
     :set({ key = 'l', map = '<Cmd>cnext<CR>' })
     :set({ key = 'h', map = '<Cmd>cprevious<CR>' })
     :set({ key = 'j', map = '<Cmd>cbelow<CR>' })
     :set({ key = 'k', map = '<Cmd>cabove<CR>' })
     :set({ key = 'r', map = '<Cmd>cfirst<CR>' })
     :set({ key = '<Leader>', map = '<Cmd>clist<CR>' })
:endgroup()

-- Comment
:group({ key = '<Leader>c' })
    :self({
        opts = { operator = true },
        map = function()
            comment.toggle(0, vim.fn.line("'["), vim.fn.line("']"))
        end
    })

    :set({
        key = '<Leader>',
        map = function()
            local line = vim.fn.line('.')
            comment.toggle(0, line, line)
        end
    })

    :group({ key = '[' })
        :self({
            opts = { operator = true },
            map = function()
                comment.uncomment(0, vim.fn.line("'["), vim.fn.line("']"))
            end
        })

        :set({
            key = '<Leader>',
            map = function()
                local line = vim.fn.line('.')
                comment.uncomment(0, line, line)
            end
        })
    :endgroup()

    :group({ key = ']' })
        :self({
            opts = { operator = true },
            map = function()
                comment.comment(0, vim.fn.line("'["), vim.fn.line("']"))
            end
        })

        :set({
            key = '<Leader>',
            map = function()
                local line = vim.fn.line('.')
                comment.comment(0, line, line)
            end
        })
    :endgroup()
:endgroup()

-- Movement
:group({ key = 'g' })
    :set({ key = 'k', map = 'gg' })
    :set({ key = 'j', map = 'G' })
    :set({ key = 'l', map = '$' })
    :set({ key = 'h', map = '0' })
    :set({ key = 'o', map = ':find ' })
    :set({ key = 'a', map = '^' })
    :set({ key = 'z', map = 'j' })
:endgroup()

-- Previous & Next (brackets)
:group({ key = '[' })
    :set({ key = 'b', map = '<Cmd>bprevious<CR>' })
    :set({ key = 't', map = 'gT' })
:endgroup()

-- Next
:group({ key = ']' })
    :set({ key = 'b', map = '<Cmd>bnext<CR>' })
    :set({ key = 't', map = 'gt' })
:endgroup()

keymap.visual() -- [VISUAL]

-- Clipboard (Visual)
:group({ key = '<Leader>' })
    :set({ key = 'y', map = '"+y' })
    :set({ key = 'p', map = '"+p' })
    :set({ key = 'P', map = '"+P' })
:endgroup()

-- Comment (Visual)
:group({ key = '<Leader>c' })
    :set({
        key = '<Leader>',
        map = function()
            comment.toggle(0, unpack({u.normalize_range(
                vim.fn.line('v'),
                vim.fn.line('.')
            )}))
        end
    })
    :set({
        key = '[',
        map = function()
            comment.uncomment(0, unpack({u.normalize_range(
                vim.fn.line('v'),
                vim.fn.line('.')
            )}))
        end
    })
    :set({
        key = ']',
        map = function()
            comment.comment(0, unpack({u.normalize_range(
                vim.fn.line('v'),
                vim.fn.line('.')
            )}))
        end
    })
:endgroup()

-- Movement (Visual)
:group({ key = 'g' })
    :set({ key = 'k', map = 'gg' })
    :set({ key = 'j', map = 'G' })
    :set({ key = 'l', map = '$' })
    :set({ key = 'h', map = '0' })
:endgroup()

-- Search (Visual)
:set({ key = 's', map = '/' })
-------------------------------------------------------------------------------
