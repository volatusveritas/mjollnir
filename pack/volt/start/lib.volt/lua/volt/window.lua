local M = {}

local function normalize_dimensions(width, height)
    width = width or 0.5
    height = height or 0.5

    if width <= 1 then
        width = width * vim.o.columns
    end

    if height <= 1  then
        height = height * vim.o.lines
    end

    return math.floor(width), math.floor(height)
end

local function open_at(buf, enter, settings, x, y)
    -- Settings:
    -- * width [0.5] (number) If <= 1, multiply the screen width by that,
    --   otherwise use its value
    -- * height [0.5] (number) If <= 1, multiply the screen height by that,
    --   otherwise use its value
    -- * focusable [true] (boolean) Refer to nvim_open_win
    -- * zindex [50] (number) Refer to nvim_open_win
    -- * style ['minimal'] (string) Refer to nvim_open_win
    -- * border ['single'] (string) Refer to nvim_open_win
    -- * title (string|list)? Refer to nvim_open_win
    -- * title_pos ['center'] (string)? Refer to nvim_open_win
    -- * footer (string|list)? Refer to nvim_open_win
    -- * footer_pos ['center'] (string)? Refer to nvim_open_win
    -- * noautocmd (boolean)? Refer to nvim_open_win
    -- * fixed (boolean)? Refer to nvim_open_win
    -- * hide (boolean)? Refer to nvim_open_win

    -- NOTE: This function expects width and height to have been obtained
    -- through normalize_dimensions().

    if settings.title then
        settings.title_pos = settings.title_pos or 'center'
    end

    if settings.footer then
        settings.footer_pos = settings.footer_pos or 'center'
    end

    return vim.api.nvim_open_win(buf, enter, {
        relative = 'editor',
        col = x,
        row = y,
        width = settings.width,
        height = settings.height,
        focusable = settings.focusable,
        zindex = settings.zindex,
        style = settings.style or 'minimal',
        border = settings.border or 'single',
        title = settings.title,
        title_pos = settings.title_pos,
        footer = settings.footer,
        footer_pos = settings.footer_pos,
        noautocmd = settings.noautocmd,
        fixed = settings.fixed,
        hide = settings.hide,
    })
end

--------------------------------- Public API ----------------------------------
function M.open_centered(buf, enter, settings)
    settings.width, settings.height = normalize_dimensions(settings.width, settings.height)
    open_at(buf, enter, settings, (vim.o.columns - settings.width) / 2.0, (vim.o.lines - settings.height) / 2.0)
end

function M.open_bottom_left(buf, enter, settings)
    settings.width, settings.height = normalize_dimensions(settings.width, settings.height)
    open_at(buf, enter, settings, 0, vim.o.lines - settings.height)
end

function M.open_bottom_right(buf, enter, settings)
    settings.width, settings.height = normalize_dimensions(settings.width, settings.height)
    open_at(buf, enter, settings, vim.o.columns - settings.width, vim.o.lines - settings.height)
end

function M.open_top_left(buf, enter, settings)
    settings.width, settings.height = normalize_dimensions(settings.width, settings.height)
    open_at(buf, enter, settings, 0, 0)
end

function M.open_top_right(buf, enter, settings)
    settings.width, settings.height = normalize_dimensions(settings.width, settings.height)
    open_at(buf, enter, settings, vim.o.columns - settings.width, 0)
end
-------------------------------------------------------------------------------

return M
