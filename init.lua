-- Setup General Neovim options
vim.o.shiftwidth = 4
vim.o.colorcolumn = "80"
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
vim.o.mouse = ""
vim.opt.path:append("**")
vim.o.showmode = false

vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Activate filetype plugins
vim.cmd("filetype plugin on")

-- Activate indent plugins
vim.cmd("filetype indent on")

-- Load colorscheme utilities
require("volt.colorscheme").setup()

-- Load custom statusline
require("volt.statusline").setup()

-- Setup terminal functionalities
require("volt.terminal").setup()

-- Setup Netrw file explorer
require("volt.explorer").setup()

-- Setup text movement features
require("volt.move").setup()

-- Setup commenting commands
require("volt.comment").setup()

-- Setup autosession features
require("volt.session").setup()

-- Setup custom folds
require("volt.fold").setup()

-- Setup the description table
-- TODO: this module is WIP.
--require("volt.desctable").setup()

-- Load and set the custom colorscheme
require("volt.theme").activate()

-- Imports
local keymap = require("volt.keymap")

local surround = require("volt.surround")

-- Keymaps
keymap.set("n", {
    w = {
        desc = "Window",
        map = {
            h = {
                map = "<C-w>h",
                desc = "Jump to the window on the left.",
            },
            j = {
                map = "<C-w>j",
                desc = "Jump to the window below.",
            },
            k = {
                map = "<C-w>k",
                desc = "Jump to the window above.",
            },
            l = {
                map = "<C-w>l",
                desc = "Jump to the window on the right",
            },
            ["<Leader>"] = {
                desc = "Move window",
                map = {
                    h = {
                        map = "<C-w>H",
                        desc = "to the left.",
                    },
                    j = {
                        map = "<C-w>J",
                        desc = "to the top.",
                    },
                    k = {
                        desc = "to the bottom.",
                        map = "<C-w>K",
                    },
                    l = {
                        map = "<C-w>L",
                        desc = "to the right.",
                    },
                },
            },
            q = {
                map = "<C-w>q",
                desc = "Close the current window.",
            },
            s = {
                map = "<C-w>s",
                desc = "Split the window horizontally.",
            },
            v = {
                map = "<C-w>v",
                desc = "Split the window vertically.",
            },
            n = {
                map = "<C-w>n",
                desc = "Create a new window.",
            },
            g = {
                desc = "Go to tag",
                map = {
                    s = {
                        map = "<C-w>s<C-]>",
                        desc = "Go to tag on horizontal split.",
                    },
                    v = {
                        map = "<C-w>v<C-]>",
                        desc = "Go to tag on vertical split.",
                    },
                },
            },
        },
    },
    ["<Leader>f"] = {
        desc = "File",
        map = {
            s = {
                map = "<Cmd>update<CR>",
                desc = "Save the current file."
            },
            S = {
                map = "<Cmd>wall<CR>",
                desc = "Save all files."
            },
        },
    },
    g = {
        desc = "Go",
        map = {
            k = {
                map = "gg",
                desc = "Go to start of file."
            },
            j = {
                map = "G",
                desc = "Go to end of file."
            },
            l = {
                map = "$",
                desc = "Go to end of line."
            },
            h = {
                map = "0",
                desc = "Go to start of line."
            },
            o = {
                desc = "Go to a file using the :find command",
                map = ":find "
            },
            s = {
                desc = "Go to the first character in the line.",
                map = "^",
            },
        },
    },
    ["<Leader>p"] = {
        desc = "Paste from clipboard after cursor",
        map = "\"+p"
    },
    ["<Leader>P"] = {
        desc = "Paste from clipboard before cursor",
        map = "\"+P"
    },
    ["<Leader>y"] = {
        desc = "Copy to clipboard",
        map = "\"+y"
    },
    ["[b"] = {
        desc = "Go to previous buffer",
        map = "<Cmd>bprevious<CR>",
    },
    ["]b"] = {
        desc = "Go to next buffer",
        map = "<Cmd>bnext<CR>",
    },
    ["<Leader>h"] = {
        desc = "Stop the search highlighting",
        map = function()
            vim.cmd("nohlsearch")
        end,
    },
    dl = {
        desc = "Delete line",
        map = "dd",
    },
    s = {
        desc = "Start a search forward",
        map = "/",
    },
    S = {
        desc = "Start a search backwards",
        map = "?",
    },
    ["<Leader>s"] = {
        desc = "Surround",
        map = {
            a = {
                desc = "Add",
                map = {
                    iw = {
                        desc = "Inner word",
                        map = {
                            ["("] = {
                                desc = "Parentheses",
                                map = function()
                                    surround.surround_region(
                                        surround.patterns.word,
                                        surround.charpairs.parentheses
                                    )
                                end,
                            },
                            ["["] = {
                                desc = "Square brackets",
                                map = function()
                                    surround.surround_region(
                                        surround.patterns.word,
                                        surround.charpairs.square_brackets
                                    )
                                end,
                            },
                            ["{"] = {
                                desc = "Curly braces",
                                map = function()
                                    surround.surround_region(
                                        surround.patterns.word,
                                        surround.charpairs.curly_braces
                                    )
                                end,
                            },
                            ["<"] = {
                                desc = "Angle brackets",
                                map = function()
                                    surround.surround_region(
                                        surround.patterns.word,
                                        surround.charpairs.angle_brackets
                                    )
                                end,
                            }
                        },
                    },
                    iW = {
                        desc = "Inner WORD",
                        map = {
                            ["("] = {
                                desc = "Parentheses",
                                map = function()
                                    surround.surround_region(
                                        surround.patterns.WORD,
                                        surround.charpairs.parentheses
                                    )
                                end,
                            },
                            ["["] = {
                                desc = "Square brackets",
                                map = function()
                                    surround.surround_region(
                                        surround.patterns.WORD,
                                        surround.charpairs.square_brackets
                                    )
                                end,
                            },
                            ["{"] = {
                                desc = "Curly braces",
                                map = function()
                                    surround.surround_region(
                                        surround.patterns.WORD,
                                        surround.charpairs.curly_braces
                                    )
                                end,
                            },
                            ["<"] = {
                                desc = "Angle brackets",
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
            -- sourround
            d = {
                desc = "Delete",
                map = {
                    ["("] = {
                        desc = "Parentheses",
                        map = function()
                            surround.delete_surround(
                                surround.charpairs.parentheses
                            )
                        end,
                    },
                    ["["] = {
                        desc = "Square brackets",
                        map = function()
                            surround.delete_surround(
                                surround.charpairs.square_brackets
                            )
                        end,
                    },
                    ["{"] = {
                        desc = "Curly braces",
                        map = function()
                            surround.delete_surround(
                                surround.charpairs.curly_braces
                            )
                        end,
                    },
                    ["<"] = {
                        desc = "Angle brackets",
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
    ["<Leader>e"] = {
        desc = "Quickfix list",
        map = {
            l = {
                desc = "Jump to next error",
                map = "<Cmd>cnext<CR>",
            },
            h = {
                desc = "Jump to previous error",
                map = "<Cmd>cprevious<CR>",
            },
            j = {
                desc = "Jump to the first error above",
                map = "<Cmd>cbelow<CR>",
            },
            k = {
                desc = "Jump to the first error below",
                map = "<Cmd>cabove<CR>",
            },
            r = {
                desc = "Rewind the error list",
                map = "<Cmd>cfirst<CR>",
            },
            ["<Leader>"] = {
                desc = "Show error list",
                map = "<Cmd>clist<CR>",
            },
        },
    },
})

keymap.set("v", {
    ["<Leader>y"] = {
        desc = "Copy selection to clipboard",
        map = "\"+y",
    },
    ["<Leader>p"] = {
        desc = "Put from clipboard",
        map = "\"+p",
    },
    ["<Leader>P"] = {
        desc = "Put from clipboard without storing",
        map = "\"+P",
    },
    g = {
        desc = "Go",
        map = {
            k = {
                map = "gg",
                desc = "Go to start of file."
            },
            j = {
                map = "G",
                desc = "Go to end of file."
            },
            l = {
                map = "$",
                desc = "Go to end of line."
            },
            h = {
                map = "0",
                desc = "Go to start of line."
            },
        },
    },
    s = {
        desc = "Start search mode",
        map = "/",
    },
})

vim.filetype.add({
    extension = {
        vnotes = 'vnotes'
    }
})
