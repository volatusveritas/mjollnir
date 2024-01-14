-- Setup General Neovim options
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
vim.o.scrolloff = 5
vim.o.termguicolors = true
vim.o.hlsearch = false
vim.o.timeout = false
vim.o.mouse = ''
vim.opt.path:append('**')
vim.o.showmode = false

vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- Activate filetype plugins
vim.cmd('filetype plugin on')

-- Activate indent plugins
vim.cmd('filetype indent on')

---- Override with treesitter folds
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'

-- Configure Treesitter
---- Use curl instead of git
require('nvim-treesitter.install').prefer_git = false
require('nvim-treesitter.configs').setup({
    ensure_installed = {
        'c',
        'lua',
        'vim',
        'vimdoc',
        'bash',
        'query',
        'odin'
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

-- Setup leap.nvim
require('leap').add_default_mappings()

-- Imports
local u = require('volt.u')
local palette = require('palette')
local color = palette.color

local keymap = require('keymap')
local comment = require('comment')
local explorer = require('explorer')

-- Color Palette
color.cyan   = '#7AF3F3'
color.green  = '#7AF39E'
color.lime   = '#A2F37A'
color.yellow = '#F1ED78'
color.red    = '#F37A7A'
color.purple = '#E2A6FF'
color.orange = '#F3B27A'

explorer.setup({
    highlight_file = { fg = color.orange },
    highlight_folder = { fg = color.purple, attr = { 'bold' } },
    highlight_link = { fg = color.red, attr = { 'italic' } },
    key_enter = '<CR>',
    key_parent = '-',
    key_back = 'q',
    key_update = 'r',
})

-- Keymaps
keymap.set('n', {
    w = {
        desc = 'window',
        map = {
            h = {
                desc = 'jump left',
                map = '<C-w>h',
            },
            j = {
                desc = 'jump below',
                map = '<C-w>j',
            },
            k = {
                desc = 'jump above',
                map = '<C-w>k',
            },
            l = {
                desc = 'jump right',
                map = '<C-w>l',
            },
            r = {
                desc = 'rotate',
                map = {
                    j = {
                        desc = 'downwards',
                        map = '<C-w>r',
                    },
                    k = {
                        desc = 'upwards',
                        map = '<C-w>R',
                    },
                },
            },
            ['<Leader>'] = {
                desc = 'move',
                map = {
                    h = {
                        desc = 'left',
                        map = '<C-w>H',
                    },
                    j = {
                        desc = 'top',
                        map = '<C-w>J',
                    },
                    k = {
                        desc = 'bottom',
                        map = '<C-w>K',
                    },
                    l = {
                        desc = 'right',
                        map = '<C-w>L',
                    },
                    t = {
                        desc = 'to tab',
                        map = '<C-w>T',
                    },
                },
            },
            q = {
                desc = 'close current',
                map = '<C-w>q',
            },
            s = {
                desc = 'split horizontally',
                map = '<C-w>s',
            },
            v = {
                desc = 'split vertically',
                map = '<C-w>v',
            },
            n = {
                desc = 'create',
                map = '<C-w>n',
            },
            g = {
                desc = 'open tag',
                map = {
                    s = {
                        desc = 'with horizontal split',
                        map = '<C-w>s<C-]>',
                    },
                    v = {
                        desc = 'with vertical split',
                        map = '<C-w>v<C-]>',
                    },
                },
            },
            t = {
                desc = 'go to top',
                map = '<C-w>t',
            },
            x = {
                desc = 'exchange',
                map = '<C-w>x',
            },
        },
    },
    ['<Leader>'] = {
        map = {
            f = {
                desc = 'file',
                map = {
                    s = {
                        desc = 'save current',
                        map = '<Cmd>update<CR>',
                    },
                    S = {
                        desc = 'save all',
                        map = '<Cmd>wall<CR>',
                    },
                },
            },
            p = {
                desc = 'paste from clipboard after cursor',
                map = '"+p'
            },
            P = {
                desc = 'paste from clipboard before cursor',
                map = '"+P'
            },
            y = {
                desc = 'copy to clipboard',
                map = '"+y'
            },
            h = {
                desc = 'stop search highlighting',
                map = function()
                    vim.cmd('nohlsearch')
                end,
            },
            s = {
                desc = 'surround',
                map = {
                    a = {
                        desc = 'add',
                        map = {
                            i = {
                                desc = 'to inner',
                                map = {
                                    w = {
                                        desc = 'to inner word',
                                        map = {
                                            ['('] = {
                                                desc = 'parentheses',
                                                map = function()
                                                    surround.surround_region(
                                                        surround.patterns.word,
                                                        surround.charpairs.parentheses
                                                    )
                                                end,
                                            },
                                            ['['] = {
                                                desc = 'square brackets',
                                                map = function()
                                                    surround.surround_region(
                                                        surround.patterns.word,
                                                        surround.charpairs.square_brackets
                                                    )
                                                end,
                                            },
                                            ['{'] = {
                                                desc = 'curly braces',
                                                map = function()
                                                    surround.surround_region(
                                                        surround.patterns.word,
                                                        surround.charpairs.curly_braces
                                                    )
                                                end,
                                            },
                                            ['<'] = {
                                                desc = 'angle brackets',
                                                map = function()
                                                    surround.surround_region(
                                                        surround.patterns.word,
                                                        surround.charpairs.angle_brackets
                                                    )
                                                end,
                                            }
                                        },
                                    },
                                    W = {
                                        desc = 'to inner WORD',
                                        map = {
                                            ['('] = {
                                                desc = 'parentheses',
                                                map = function()
                                                    surround.surround_region(
                                                        surround.patterns.WORD,
                                                        surround.charpairs.parentheses
                                                    )
                                                end,
                                            },
                                            ['['] = {
                                                desc = 'square brackets',
                                                map = function()
                                                    surround.surround_region(
                                                        surround.patterns.WORD,
                                                        surround.charpairs.square_brackets
                                                    )
                                                end,
                                            },
                                            ['{'] = {
                                                desc = 'curly braces',
                                                map = function()
                                                    surround.surround_region(
                                                        surround.patterns.WORD,
                                                        surround.charpairs.curly_braces
                                                    )
                                                end,
                                            },
                                            ['<'] = {
                                                desc = 'angle brackets',
                                                map = function()
                                                    surround.surround_region(
                                                        surround.patterns.WORD,
                                                        surround.charpairs.angle_brackets
                                                    )
                                                end,
                                            }
                                        },
                                    },
                                },
                            },
                        },
                    },
                    d = {
                        desc = 'delete',
                        map = {
                            ['('] = {
                                desc = 'parentheses',
                                map = function()
                                    surround.delete_surround(
                                        surround.charpairs.parentheses
                                    )
                                end,
                            },
                            ['['] = {
                                desc = 'square brackets',
                                map = function()
                                    surround.delete_surround(
                                        surround.charpairs.square_brackets
                                    )
                                end,
                            },
                            ['{'] = {
                                desc = 'curly braces',
                                map = function()
                                    surround.delete_surround(
                                        surround.charpairs.curly_braces
                                    )
                                end,
                            },
                            ['<'] = {
                                desc = 'angle brackets',
                                map = function()
                                    surround.delete_surround(
                                        surround.charpairs.angle_brackets
                                    )
                                end,
                            },
                        },
                    },
                }
            },
            e = {
                desc = 'quickfix list',
                map = {
                    l = {
                        desc = 'jump to next error',
                        map = '<Cmd>cnext<CR>',
                    },
                    h = {
                        desc = 'jump to previous error',
                        map = '<Cmd>cprevious<CR>',
                    },
                    j = {
                        desc = 'jump to error above',
                        map = '<Cmd>cbelow<CR>',
                    },
                    k = {
                        desc = 'jump to error below',
                        map = '<Cmd>cabove<CR>',
                    },
                    r = {
                        desc = 'rewind error list',
                        map = '<Cmd>cfirst<CR>',
                    },
                    ['<Leader>'] = {
                        desc = 'show error list',
                        map = '<Cmd>clist<CR>',
                    },
                },
            },
            c = {
                desc = 'comment',
                map = {
                    [keymap.self] = {
                        desc = 'toggle motion',
                        operator = true,
                        map = function()
                            comment.toggle(
                                0,
                                vim.fn.line("'["),
                                vim.fn.line("']")
                            )
                        end,
                    },
                    ['<Leader>'] = {
                        desc = 'toggle line',
                        map = function()
                            local line = vim.fn.line('.')
                            comment.toggle(0, line, line)
                        end,
                    },
                    ['['] = {
                        desc = 'uncomment',
                        map = {
                            [keymap.self] = {
                                desc = 'motion',
                                operator = true,
                                map = function()
                                    comment.uncomment(
                                        0,
                                        vim.fn.line("'["),
                                        vim.fn.line("']")
                                    )
                                end
                            },
                            ['<Leader>'] = {
                                desc = 'line',
                                map = function()
                                    local line = vim.fn.line('.')
                                    comment.uncomment(0, line, line)
                                end
                            }
                        },
                    },
                    [']'] = {
                        desc = 'comment',
                        map = {
                            [keymap.self] = {
                                desc = 'motion',
                                operator = true,
                                map = function()
                                    comment.comment(
                                        0,
                                        vim.fn.line("'["),
                                        vim.fn.line("']")
                                    )
                                end,
                            },
                            ['<Leader>'] = {
                                desc = 'line',
                                map = function()
                                    local line = vim.fn.line('.')
                                    comment.comment(0, line, line)
                                end
                            }
                        },
                    }
                },
            },
            l = {
                desc = 'explorer',
                map = {
                    ['<Leader>'] = {
                        desc = 'start from working directory',
                        map = explorer.start,
                    },
                    f = {
                        desc = 'start from file',
                        map = function()
                            explorer.start(
                                vim.fs.dirname(vim.fn.expand('%:p'))
                            )
                        end,
                    },
                },
            },
        }
    },
    g = {
        desc = 'go to',
        map = {
            k = {
                desc = 'start of file',
                map = 'gg',
            },
            j = {
                desc = 'end of file',
                map = 'G',
            },
            l = {
                desc = 'end of line',
                map = '$',
            },
            h = {
                desc = 'start of line',
                map = '0',
            },
            o = {
                desc = 'file using :find',
                map = ':find '
            },
            a = {
                desc = 'first character in line',
                map = '^',
            },
            z = {
                desc = 'line below',
                map = 'j',
            },
        },
    },
    ['['] = {
        desc = 'previous',
        map = {
            b = {
                desc = 'buffer',
                map = '<Cmd>bprevious<CR>',
            },
            t = {
                desc = 'tab',
                map = 'gT',
            },
        },
    },
    [']'] = {
        desc = 'next',
        map = {
            b = {
                desc = 'buffer',
                map = '<Cmd>bnext<CR>',
            },
            t = {
                desc = 'tab',
                map = 'gt',
            },
        },
    },
    dl = {
        desc = 'delete line',
        map = 'dd',
    },
})

keymap.set('v', {
    ['<Leader>'] = {
        map = {
            y = {
                desc = 'copy selection to clipboard',
                map = '"+y',
            },
            p = {
                desc = 'put from clipboard',
                map = '"+p',
            },
            P = {
                desc = 'put from clipboard without storing',
                map = '"+P',
            },
            c = {
                desc = 'comment',
                map = {
                    ['<Leader>'] = {
                        desc = 'toggle',
                        map = function()
                            comment.toggle(0, unpack({u.normalize_range(
                                vim.fn.line('v'),
                                vim.fn.line('.')
                            )}))
                        end,
                    },
                    ['['] = {
                        desc = 'uncomment',
                        map = function()
                            comment.uncomment(0, unpack({u.normalize_range(
                                vim.fn.line('v'),
                                vim.fn.line('.')
                            )}))
                        end,
                    },
                    [']'] = {
                        desc = 'comment',
                        map = function()
                            comment.comment(0, unpack({u.normalize_range(
                                vim.fn.line('v'),
                                vim.fn.line('.')
                            )}))
                        end,
                    },
                },
            },
        },
    },
    g = {
        desc = 'go to',
        map = {
            k = {
                desc = 'start of file',
                map = 'gg',
            },
            j = {
                desc = 'end of file',
                map = 'G',
            },
            l = {
                desc = 'end of line',
                map = '$',
            },
            h = {
                desc = 'start of line',
                map = '0',
            },
        },
    },
    s = {
        desc = 'start search mode',
        map = '/',
    },
})

vim.filetype.add({
    extension = {
        vnotes = 'vnotes'
    }
})
