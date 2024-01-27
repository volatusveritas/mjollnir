----------------------------------- Options -----------------------------------
vim.o.shiftwidth = 4
vim.o.colorcolumn = '80'
vim.o.textwidth = 79
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
local explorer = require('explorer')
local hunter = require('hunter')
local keymap = require('keymap')
local lens = require('lens')
local palette = require('palette')
local color = palette.color
local terminal = require('terminal')
-------------------------------------------------------------------------------

---------------------------- Color Palette v1.0.1 -----------------------------
color.purple = '#e2a6ff'
color.red =    '#f37a7a'
color.orange = '#ffbb80'
color.green =  '#a2f37a'
color.yellow = '#f5f57a'
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

palette.apply()
-------------------------------------------------------------------------------

----------------------------------- Setups ------------------------------------
explorer.setup({
    highlight_file = { fg = color.orange },
    highlight_folder = { fg = color.purple, attr = { 'bold' } },
    highlight_link = { fg = color.red, attr = { 'italic' } },
    key_enter  = '<CR>',
    key_parent = '-',
    key_close  = 'q',
    key_update = 'r',
    key_apply  = 'z',
    key_mark   = 'm',
    key_copy   = '<LocalLeader>c',
    key_move   = '<LocalLeader>m',
})

terminal.setup({
    key_special = '<C-s>',
    key_leave = '<Esc>',
    key_close = 'q',
    key_kill = '<C-q>',
})

hunter.setup({
    highlight_combos = { fg = color.purple },
    highlight_selected = { fg= color.light1 },
    highlight_option = { fg= color.light4 },
    key_next = '<C-n>',
    key_previous = '<C-p>',
})
-------------------------------------------------------------------------------

---------------------------------- Mappings -----------------------------------
keymap.normal({ -- Neovim
    ['<C-q>'] = function()
        local choice = vim.fn.confirm(
            'Are you sure you want to leave?',
            '&Yes\n&No', 1
        )

        if choice == 1 then
            vim.cmd('qall!')
        end
    end
})

keymap.normal({ -- lens.volt
    [':'] = lens.cmdline
})

keymap.normal({ -- terminal.volt
    ['<Leader>t'] = terminal.open_floating
})

keymap.normal({ -- hunter.volt
    ['<Leader>f'] = {
        l = function()
            hunter.hunt(hunter.files(), { on_tracked = vim.cmd.edit })
        end,
    },
})

keymap.normal({ -- Window
    w = {
        h = '<C-w>h',
        j = '<C-w>j',
        k = '<C-w>k',
        l = '<C-w>l',
        q = '<C-w>q',
        s = '<C-w>s',
        v = '<C-w>v',
        n = '<C-w>n',
        t = '<C-w>t',
        x = '<C-w>x',
        ['<Leader>'] = {
            q = '<Cmd>quit!<CR>',
            h = '<C-w>H',
            j = '<C-w>J',
            k = '<C-w>K',
            l = '<C-w>L',
            t = '<C-w>T',
        },
        r = {
            j = '<C-w>r',
            k = '<C-w>R',
        },
    },
})

keymap.normal({ -- Clipboard
    ['<Leader>'] = {
        y = '"+y',
        p = '"+p',
        P = '"+P',
    },
})

keymap.normal({ -- Quickfix List
    [keymap.operator] = true,
    ['<Leader>e'] = {
         l = '<Cmd>cnext<CR>',
         h = '<Cmd>cprevious<CR>',
         j = '<Cmd>cbelow<CR>',
         k = '<Cmd>cabove<CR>',
         r = '<Cmd>cfirst<CR>',
         ['<Leader>'] = '<Cmd>clist<CR>',
     },
})

keymap.normal({ -- Comment
    ['<Leader>c'] = {
        [keymap.self] = {
            [keymap.operator] = true,
            function()
                 comment.toggle(0, vim.fn.line("'["), vim.fn.line("']"))
            end,
        },
        ['<Leader>'] = function()
            local line = vim.fn.line('.')
            comment.toggle(0, line, line)
        end,
        ['['] = {
            [keymap.self] = {
                [keymap.operator] = true,
                 function()
                     comment.uncomment(0, vim.fn.line("'["), vim.fn.line("']"))
                 end
            },
            ['<Leader>'] = function()
                local line = vim.fn.line('.')
                comment.uncomment(0, line, line)
            end,
        },
        [']'] = {
            [keymap.self] = {
                [keymap.operator] = true,
                 function()
                     comment.comment(0, vim.fn.line("'["), vim.fn.line("']"))
                 end
            },
            ['<Leader>'] = function()
                local line = vim.fn.line('.')
                comment.comment(0, line, line)
            end,
        },
    },
})

keymap.normal({ -- Explorer
    ['<Leader>l'] = {
        ['<Leader>'] = explorer.start,
        f = function()
            explorer.start(vim.fs.dirname(vim.fn.expand('%:p')))
        end,
    },
})

keymap.normal({ -- Movement
    g = {
        k = 'gg',
        j = 'G',
        l = '$',
        h = '0',
        o = ':find ',
        a = '^',
        z = 'j',
    },
})

keymap.normal({ -- Previous
    ['['] = {
        b = '<Cmd>bprevious<CR>',
        t = 'gT',
    },
})

keymap.normal({ -- Next
    [']'] = {
        b = '<Cmd>bnext<CR>',
        t = 'gt',
    },
})

keymap.visual({ -- Clipboard (Visual)
    ['<Leader>'] = {
        y = '"+y',
        p = '"+p',
        P = '"+P',
    },
})

keymap.visual({ -- Comment (Visual)
    ['<Leader>c'] = {
        ['<Leader>'] = function()
            comment.toggle(0, unpack({u.normalize_range(
                vim.fn.line('v'),
                vim.fn.line('.')
            )}))
        end,
        ['['] = function()
            comment.uncomment(0, unpack({u.normalize_range(
                vim.fn.line('v'),
                vim.fn.line('.')
            )}))
        end,
        [']'] = function()
            comment.comment(0, unpack({u.normalize_range(
                vim.fn.line('v'),
                vim.fn.line('.')
            )}))
        end,
    },
})

keymap.visual({ -- Movement (Visual)
    g = {
        k = 'gg',
        j = 'G',
        l = '$',
        h = '0',
    },
})

keymap.visual({ -- Search (Visual)
    s =  '/',
})

keymap.normal({ -- Editing
    dl = 'dd',
})

keymap.normal({ -- Debug
    ['<Leader><LocalLeader>w'] = function()
        local buf = vim.api.nvim_create_buf(false, true)
        window.open_right(buf, true, {
            title = ' Window Title ',
        })
    end
})
-------------------------------------------------------------------------------
