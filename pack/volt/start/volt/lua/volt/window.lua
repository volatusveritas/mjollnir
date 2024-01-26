local M = {}

----------------------------------- Imports -----------------------------------
local vmath = require('volt.math')
local vnvim = require('volt.nvim')
-------------------------------------------------------------------------------

local function border_area(border)
    if type(border) == 'table' then
        local element_amount = math.min(#border, 8)

        local height = 0

        for i = 0, 2 do
            if border[i % element_amount] ~= '' then
                height = height + 1
                break
            end
        end

        for i = 4, 6 do
            if border[i % element_amount] ~= '' then
                height = height + 1
                break
            end
        end

        local width = 0

        for i = 2, 4 do
            if border[i % element_amount] ~= '' then
                width = width + 1
                break
            end
        end

        for i = 6, 8 do
            if border[i % element_amount] ~= '' then
                width = width + 1
                break
            end
        end

        return width, height
    elseif border == nil or border == 'none' then
        return 0, 0
    else
        return 2, 2
    end
end

--------------------------------- Public API ----------------------------------
M.border_left   = { '', '', '', '', '', '', '', '│' }
M.border_right  = { '', '', '', '│', '', '', '', '' }
M.border_top    = { '', '─', '', '', '', '', '', '' }
M.border_bottom = { '', '', '', '', '', '─', '', '' }

function M.open(buf, enter, settings)
    -- Settings:
    -- * x (number) Refer to nvim_open_win's "col"
    -- * y (number) Refer to nvim_open_win's "row"
    -- * width (number) Refer to nvim_open_win
    -- * height (number) Refer to nvim_open_win
    -- * relative = 'editor' [string] Refer to nvim_open_win
    -- * focusable = true [boolean] Refer to nvim_open_win
    -- * zindex = 50 [number] Refer to nvim_open_win
    -- * border = 'single' [string] Refer to nvim_open_win
    -- * title_pos = 'center' [string] Refer to nvim_open_win
    -- * footer_pos = 'center' [string] Refer to nvim_open_win
    -- * offset_x = 0 [number] A value to be added to x
    -- * offset_y = 0 [number] A value to be added to y
    -- * style [string] Refer to nvim_open_win
    -- * title [string|list] Refer to nvim_open_win
    -- * footer [string|list] Refer to nvim_open_win
    -- * noautocmd [boolean] Refer to nvim_open_win
    -- * fixed [boolean] Refer to nvim_open_win
    -- * hide [boolean] Refer to nvim_open_win

    if settings.title then
        settings.title_pos = settings.title_pos or 'center'
    end

    if settings.footer then
        settings.footer_pos = settings.footer_pos or 'center'
    end

    return vim.api.nvim_open_win(buf, enter, {
        relative = settings.relative or 'editor',
        col = settings.x + (settings.offset_x or 0),
        row = settings.y + (settings.offset_y or 0),
        width = settings.width,
        height = settings.height,
        focusable = settings.focusable,
        zindex = settings.zindex,
        style = settings.style,
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

function M.screen(settings)
    local border_width, border_height = border_area(settings.border)
    local screen_width = vnvim.screen_width() - border_width
    local screen_height = vnvim.screen_height() - border_height

    return vim.tbl_extend('force', settings, {
        x = vmath.to_axis(settings.x or 0, screen_width),
        y = vmath.to_axis(settings.y or 0, screen_height),
        offset_x = vmath.to_axis(settings.offset_x or 0, screen_width),
        offset_y = vmath.to_axis(settings.offset_y or 0, screen_height),
        width = vmath.to_axis(settings.width or 0, screen_width),
        height = vmath.to_axis(settings.height or 0, screen_height),
    })
end

function M.centered(settings)
    settings.width = settings.width or 0.5
    settings.height = settings.height or 0.5
    settings = M.screen(settings)

    local border_width, border_height = border_area(settings.border)
    local screen_width = vnvim.screen_width() - border_width
    local screen_height = vnvim.screen_height() - border_height

    return vim.tbl_extend('force', settings, {
        x = vmath.to_axis((screen_width - settings.width) / 2.0),
        y = vmath.to_axis((screen_height - settings.height) / 2.0),
    })
end

function M.bottom_left(settings)
    settings.width = settings.width or 0.5
    settings.height = settings.height or 0.5
    settings = M.screen(settings)

    local screen_width = vnvim.screen_width() - border_area(settings.border)

    return vim.tbl_extend('force', settings, {
        x = 0,
        y = vmath.to_axis(screen_width - settings.height),
    })
end

function M.bottom_right(settings)
    settings.width = settings.width or 0.5
    settings.height = settings.height or 0.5
    settings = M.screen(settings)

    local border_width, border_height = border_area(settings.border)
    local screen_width = vnvim.screen_width() - border_width
    local screen_height = vnvim.screen_height() - border_height

    return vim.tbl_extend('force', settings, {
        x = vmath.to_axis(screen_width - settings.width),
        y = vmath.to_axis(screen_height - settings.height),
    })
end

function M.top_left(settings)
    settings.width = settings.width or 0.5
    settings.height = settings.height or 0.5
    return vim.tbl_extend('force', settings, { x = 0, y = 0 })
end

function M.top_right(settings)
    settings.width = settings.width or 0.5
    settings.height = settings.height or 0.5
    settings = M.screen(settings)

    local screen_width = vnvim.screen_width() - border_area(settings.border)

    return vim.tbl_extend('force', settings, {
        x = vmath.to_axis(screen_width - settings.width),
        y = 0,
    })
end

function M.left(settings)
    settings.width = settings.width or 0.375
    settings = M.screen(settings)
    settings.border = settings.border or M.border_right_only

    local _, border_height = border_area(settings.border)
    local screen_height = vnvim.screen_height() - border_height

    return vim.tbl_extend('force', settings, {
        x = 0,
        y = 0,
        width = vmath.to_axis(settings.width),
        height = vmath.to_axis(screen_height),
    })
end

function M.right(settings)
    settings.width = settings.width or 0.375
    settings = M.screen(settings)
    settings.border = settings.border or M.border_left_only

    local border_width, border_height = border_area(settings.border)
    local screen_width = vnvim.screen_width() - border_width
    local screen_height = vnvim.screen_height() - border_height

    return vim.tbl_extend('force', settings, {
        x = vmath.to_axis(screen_width - settings.width),
        y = 0,
        height = vmath.to_axis(screen_height),
    })
end

function M.top(settings)
    settings.height = settings.height or 0.375
    settings = M.screen(settings)
    settings.border = settings.border or M.border_bottom_only

    local screen_width = vnvim.screen_width() - border_area(settings.border)

    return vim.tbl_extend('force', settings, {
        x = 0,
        y = 0,
        width = vmath.to_axis(screen_width),
    })
end

function M.bottom(settings)
    settings.height = settings.height or 0.375
    settings = M.screen(settings)
    settings.border = settings.border or M.border_top_only

    local border_width, border_height = border_area(settings.border)
    local screen_width = vnvim.screen_width() - border_width
    local screen_height = vnvim.screen_height() - border_height

    vim.tbl_extend('force', settings, {
        x = 0,
        y = vmath.to_axis(screen_height - settings.height),
        width = vmath.to_axis(screen_width),
    })
end
-------------------------------------------------------------------------------

return M
