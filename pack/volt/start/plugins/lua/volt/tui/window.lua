local M = {}

local DEFAULT_WIDTH = 68
local DEFAULT_HEIGHT = 20
local DEFAULT_BORDER = "none"
local DEFAULT_STYLE = "minimal"
local DEFAULT_RELATIVE = "editor"

function M.apply_default_options(opts)
    opts.relative = opts.relative or DEFAULT_RELATIVE
    opts.border = opts.border or DEFAULT_BORDER
    opts.width = opts.width or DEFAULT_WIDTH
    opts.height = opts.height or DEFAULT_HEIGHT
    opts.style = opts.style or DEFAULT_STYLE
end

function M.open_window(buffer, enter, opts)
    M.apply_default_options(opts)

    return vim.api.nvim_open_win(buffer, enter, opts)
end

function M.open_window_centered(buffer, enter, opts)
    opts.row = (opts.row or 0) + (vim.o.lines - (opts.height or DEFAULT_HEIGHT)) / 2
    opts.col = (opts.col or 0) + (vim.o.columns - (opts.width or DEFAULT_WIDTH)) / 2

    return M.open_window(buffer, enter, opts)
end

function M.open_window_br(buffer, enter, opts)
    opts.row = (opts.row or 0) + vim.o.lines - (opts.height or DEFAULT_HEIGHT)
    opts.col = (opts.col or 0) + vim.o.columns - (opts.width or DEFAULT_WIDTH)

    return M.open_window(buffer, enter, opts)
end

-- TODO: open_window_bl
-- TODO: open_window_tr
-- TODO: open_window_tl

return M
