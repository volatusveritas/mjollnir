local M = {}

local function normalize_dimension(value, basis, default)
    value = value or default

    if value <= 1 then
        value = value * basis
    end

    return math.floor(value)
end

local function open_rect(buf, enter, x, y, width, height, settings)
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

    -- NOTE: This function expects width and height to have been obtained
    -- through normalize_dimension().

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

local function get_border_height(border)
    if type(border) == 'table' then
        local height = 0

        local element_amount = #border

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

        return height
    elseif border ~= 'none' then
        return 2
    else
        return 0
    end
end

-- Takes cmdline and statusline into account when fetching the screen height
local function screen_height()
    return vim.o.lines - vim.o.cmdheight - 1
end

--------------------------------- Public API ----------------------------------
M.border_right_only =  { '', '', '', '│', '', '', '', '' }
M.border_left_only =   { '', '', '', '', '', '', '', '│' }
M.border_top_only =    { '', '─', '', '', '', '', '', '' }
M.border_bottom_only = { '', '', '', '', '', '─', '', '' }

function M.open_centered(buf, enter, settings)
    local width = normalize_dimension(settings.width, vim.o.columns, 0.5)
    local height = normalize_dimension(settings.height, screen_height(), 0.5)
    local x = (vim.o.columns - width) / 2.0
    local y = (screen_height() - height) / 2.0

    open_rect(buf, enter, x, y, width, height, settings)
end

function M.open_bottom_left(buf, enter, settings)
    local width = normalize_dimension(settings.width, vim.o.columns, 0.5)
    local height = normalize_dimension(settings.height, screen_height(), 0.5)
    local y = screen_height() - height

    open_rect(buf, enter, 0, y, width, height, settings)
end

function M.open_bottom_right(buf, enter, settings)
    local width = normalize_dimension(settings.width, vim.o.columns, 0.5)
    local height = normalize_dimension(settings.height, screen_height(), 0.5)
    local x = vim.o.columns - width
    local y = screen_height() - height

    open_rect(buf, enter, x, y, width, height, settings)
end

function M.open_top_left(buf, enter, settings)
    local width = normalize_dimension(settings.width, vim.o.columns, 0.5)
    local height = normalize_dimension(settings.height, screen_height(), 0.5)

    open_rect(buf, enter, 0, 0, width, height, settings)
end

function M.open_top_right(buf, enter, settings)
    local width = normalize_dimension(settings.width, vim.o.columns, 0.5)
    local height = normalize_dimension(settings.height, screen_height(), 0.5)
    local x = vim.o.columns - width

    open_rect(buf, enter, x, 0, width, height, settings)
end

function M.open_left(buf, enter, settings)
    settings.border = settings.border or M.border_right_only

    local width = normalize_dimension(settings.width, vim.o.columns, 0.375)
    local height = screen_height() - get_border_height(settings.border)

    open_rect(buf, enter, 0, 0, width, height, settings)
end

function M.open_right(buf, enter, settings)
    settings.border = settings.border or M.border_left_only

    local width = normalize_dimension(settings.width, vim.o.columns, 0.375)
    local height = screen_height() - get_border_height(settings.border)
    local x = vim.o.columns - width

    open_rect(buf, enter, x, 0, width, height, settings)
end

function M.open_top(buf, enter, settings)
    settings.border = settings.border or M.border_bottom_only

    local width = vim.o.columns
    local height = normalize_dimension(settings.height, screen_height(), 0.375)

    open_rect(buf, enter, 0, 0, width, height, settings)
end

function M.open_bottom(buf, enter, settings)
    settings.border = settings.border or M.border_top_only

    local width = vim.o.columns
    local height = normalize_dimension(settings.height, screen_height(), 0.375)
    local y = screen_height() - height - get_border_height(settings.border)

    open_rect(buf, enter, 0, y, width, height, settings)
end
-------------------------------------------------------------------------------

return M
