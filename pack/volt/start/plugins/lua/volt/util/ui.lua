local M = {}

-- Imports
local windowutils = require("volt.util.window")
local keymap = require("volt.keymap")

local augroup = vim.api.nvim_create_augroup("volt.util.ui", {})

function M.selection(title, options, default, callback)
    -- TODO: add support for default selection (?)

    local option_amount = #options

    local buf = vim.api.nvim_create_buf(false, true)
    local win = windowutils.open_window_centered(buf, true, {
        title = ("%s (%d options)"):format(title, option_amount),
        title_pos = 'center',
        border = 'rounded',
        height = option_amount,
    })

    vim.bo.textwidth = vim.fn.winwidth(win)

    vim.api.nvim_set_option_value("foldmethod", "manual", {
        scope = "local",
        win = win
    })

    vim.api.nvim_set_option_value("cursorline", true, {
        scope = "local",
        win = win
    })

    local render_options = {}
    for _, option in ipairs(options) do
        table.insert(render_options, ("%s%s"):format(
            (" "):rep(math.floor((vim.fn.winwidth(0) - #option) / 2)),
            option
        ))
    end

    vim.api.nvim_buf_set_lines(
        buf,
        0, 1,
        false,
        render_options
    )

    -- Reset cursor after inserting the lines (it will be at the end)
    vim.fn.cursor(1, 1)

    -- Must be set after inserting lines
    vim.bo.modifiable = false

    vim.api.nvim_create_autocmd("BufLeave", {
        group = augroup,
        buffer = buf,
        callback = function(ctx)
            callback(nil)
            vim.api.nvim_buf_delete(buf, {})
        end,
    })

    keymap.set("n", {
        ["<CR>"] = {
            desc = "Confirm selection",
            opts = { buffer = 0 },
            map = function()
                local choice_index = vim.fn.line(".")
                vim.api.nvim_win_close(win, false)
                callback(choice_index, options[choice_index])
            end,
        },
        q = {
            desc = "Quit selection window",
            opts = { buffer = 0 },
            map = function() vim.api.nvim_win_close(win, false) end,
        }
    })
end

return M
