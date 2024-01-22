local M = {}

----------------------------------- Imports -----------------------------------
local vmath = require('volt.math')
    local vector2 = vmath.vector2
local vnvim = require('volt.vnvim')
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

        return vector2(width, height)
    elseif border == nil or border == 'none' then
        return vector2(0, 0)
    else
        return vector2(2, 2)
    end
end

local function normalize_dimension(value, basis, default)
    value = value or default

    if value < 1 then
        value = value * basis
    end

    return math.floor(value)
end

--------------------------------- Public API ----------------------------------
M.border_right_only =  { '', '', '', '│', '', '', '', '' }
M.border_left_only =   { '', '', '', '', '', '', '', '│' }
M.border_top_only =    { '', '─', '', '', '', '', '', '' }
M.border_bottom_only = { '', '', '', '', '', '─', '', '' }

function M.open_rect(buf, enter, x, y, width, height, settings)
    -- * width [0.5] (number) If <= 1, multiply the screen width by that,
    --   otherwise use its value
    -- * height [0.5] (number) If <= 1, multiply the screen height by that,
    --   otherwise use its value

    -- Settings:
    -- * focusable [true] (boolean) Refer to nvim_open_win
    -- * zindex [50] (number) Refer to nvim_open_win
    -- * style (string) Refer to nvim_open_win
    -- * border ['single'] (string) Refer to nvim_open_win
    -- * title (string|list)? Refer to nvim_open_win
    -- * title_pos ['center'] (string)? Refer to nvim_open_win
    -- * footer (string|list)? Refer to nvim_open_win
    -- * footer_pos ['center'] (string)? Refer to nvim_open_win
    -- * noautocmd (boolean)? Refer to nvim_open_win
    -- * fixed (boolean)? Refer to nvim_open_win
    -- * hide (boolean)? Refer to nvim_open_win
    -- * ox [0] (number) An offset to apply to the window's x position
    -- * oy [0] (number) An offset to apply to the window's y position

    -- NOTE: This function expects width and height to have been obtained
    -- through normalize_dimension().

    if settings.title then
        settings.title_pos = settings.title_pos or 'center'
    end

    if settings.footer then
        settings.footer_pos = settings.footer_pos or 'center'
    end

    local screen_size = vnvim.screen_size()

    return vim.api.nvim_open_win(buf, enter, {
        relative = 'editor',
        col = x + normalize_dimension(settings.ox, screen_size.x, 0),
        row = y + normalize_dimension(settings.oy, screen_size.y, 0),
        width = width,
        height = height,
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

function M.open_centered(buf, enter, settings)
    local screen_size = vnvim.screen_size() - border_area(settings.border)

    local width = normalize_dimension(settings.width, screen_size.x, 0.5)
    local height = normalize_dimension(settings.height, screen_size.y, 0.5)
    local x = (screen_size.x - width) / 2.0
    local y = (screen_size.y - height) / 2.0

    return M.open_rect(buf, enter, x, y, width, height, settings)
end

function M.open_bottom_left(buf, enter, settings)
    local screen_size = vnvim.screen_size() - border_area(settings.border)

    local width = normalize_dimension(settings.width, screen_size.x, 0.5)
    local height = normalize_dimension(settings.height, screen_size.y, 0.5)
    local y = screen_size.y - height

    return M.open_rect(buf, enter, 0, y, width, height, settings)
end

function M.open_bottom_right(buf, enter, settings)
    local screen_size = vnvim.screen_size() - border_area(settings.border)

    local width = normalize_dimension(settings.width, screen_size.x, 0.5)
    local height = normalize_dimension(settings.height, screen_size.y, 0.5)
    local x = screen_size.x - width
    local y = screen_size.y - height

    return M.open_rect(buf, enter, x, y, width, height, settings)
end

function M.open_top_left(buf, enter, settings)
    local screen_size = vnvim.screen_size() - border_area(settings.border)

    local width = normalize_dimension(settings.width, screen_size.x, 0.5)
    local height = normalize_dimension(settings.height, screen_size.y, 0.5)

    return M.open_rect(buf, enter, 0, 0, width, height, settings)
end

function M.open_top_right(buf, enter, settings)
    local screen_size = vnvim.screen_size() - border_area(settings.border)

    local width = normalize_dimension(settings.width, screen_size.x, 0.5)
    local height = normalize_dimension(settings.height, screen_size.y, 0.5)
    local x = screen_size.x - width

    return M.open_rect(buf, enter, x, 0, width, height, settings)
end

function M.open_left(buf, enter, settings)
    settings.border = settings.border or M.border_right_only

    local screen_size = vnvim.screen_size - border_area(settings.border)

    local width = normalize_dimension(settings.width, screen_size.x, 0.375)

    return M.open_rect(buf, enter, 0, 0, width, screen_size.y, settings)
end

function M.open_right(buf, enter, settings)
    settings.border = settings.border or M.border_left_only

    local screen_size = vnvim.screen_size - border_area(settings.border)

    local width = normalize_dimension(settings.width, screen_size.x, 0.375)
    local x = screen_size.x - width

    return M.open_rect(buf, enter, x, 0, width, screen_size.y, settings)
end

function M.open_top(buf, enter, settings)
    settings.border = settings.border or M.border_bottom_only

    local screen_size = vnvim.screen_size - border_area(settings.border)

    local height = normalize_dimension(settings.height, screen_size.y, 0.375)

    return M.open_rect(buf, enter, 0, 0, screen_size.x, height, settings)
end

function M.open_bottom(buf, enter, settings)
    settings.border = settings.border or M.border_top_only

    local screen_size = vnvim.screen_size - border_area(settings.border)

    local height = normalize_dimension(settings.height, screen_size.y, 0.375)
    local y = screen_size.y - height

    return M.open_rect(buf, enter, 0, y, screen_size.x, height, settings)
end
-------------------------------------------------------------------------------

return M
