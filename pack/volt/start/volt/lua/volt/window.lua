local M = {}

----------------------------------- Imports -----------------------------------
local vmath = require('volt.math')
local vnvim = require('volt.nvim')
-------------------------------------------------------------------------------

--------------------------------- Public API ----------------------------------
M.border_left   = { '', '', '', '', '', '', '', '│' }
M.border_right  = { '', '', '', '│', '', '', '', '' }
M.border_top    = { '', '─', '', '', '', '', '', '' }
M.border_bottom = { '', '', '', '', '', '─', '', '' }

function M.open(buf, enter, opts)
    -- opts:
    -- • x (number) Refer to nvim_open_win's "col"
    -- • y (number) Refer to nvim_open_win's "row"
    -- • width (number) Refer to nvim_open_win
    -- • height (number) Refer to nvim_open_win
    -- • relative = 'editor' [string] Refer to nvim_open_win
    -- • focusable = true [boolean] Refer to nvim_open_win
    -- • zindex = 50 [number] Refer to nvim_open_win
    -- • border = [string] Refer to nvim_open_win
    -- • title_pos = 'center' [string] Refer to nvim_open_win
    -- • footer_pos = 'center' [string] Refer to nvim_open_win
    -- • style [string] Refer to nvim_open_win
    -- • title [string|list] Refer to nvim_open_win
    -- • footer [string|list] Refer to nvim_open_win
    -- • noautocmd [boolean] Refer to nvim_open_win
    -- • fixed [boolean] Refer to nvim_open_win
    -- • hide [boolean] Refer to nvim_open_win

    if opts.title then
        opts.title_pos = opts.title_pos or 'center'
    end

    if opts.footer then
        opts.footer_pos = opts.footer_pos or 'center'
    end

    return vim.api.nvim_open_win(buf, enter, {
        relative = opts.relative or 'editor',
        col = opts.x,
        row = opts.y,
        width = opts.width,
        height = opts.height,
        focusable = opts.focusable,
        zindex = opts.zindex,
        style = opts.style,
        border = opts.border,
        title = opts.title,
        title_pos = opts.title_pos,
        footer = opts.footer,
        footer_pos = opts.footer_pos,
        noautocmd = opts.noautocmd,
        fixed = opts.fixed,
        hide = opts.hide,
    })
end

function M.offset(opts, offset)
    return vim.tbl_extend('force', opts, {
        x = opts.x + (offset.x or 0),
        y = opts.y + (offset.y or 0),
        width = opts.width + (offset.width or 0),
        height = opts.height + (offset.height or 0),
    })
end

function M.border_area(border)
    if type(border) == 'table' then
        local element_amount = math.min(#border, 8)

        local top = 0
        local bottom = 0

        for i = 0, 2 do
            if border[i % element_amount] ~= '' then
                top = 1
                break
            end
        end

        for i = 4, 6 do
            if border[i % element_amount] ~= '' then
                bottom = 1
                break
            end
        end

        local left = 0
        local right = 0

        for i = 2, 4 do
            if border[i % element_amount] ~= '' then
                right = 1
                break
            end
        end

        for i = 6, 8 do
            if border[i % element_amount] ~= '' then
                left = 1
                break
            end
        end

        return { left = left, right = right, top = top, bottom = bottom }
    elseif border == nil or border == 'none' then
        return { left = 0, right = 0, top = 0, bottom = 0 }
    else
        return { left = 1, right = 1, top = 1, bottom = 1 }
    end
end

function M.screen(opts)
    local border_area = M.border_area(opts.border)
    local border_width = border_area.left + border_area.right
    local border_height = border_area.top + border_area.bottom
    local screen_width = vnvim.screen_width() - border_width
    local screen_height = vnvim.screen_height() - border_height

    return vim.tbl_extend('force', opts, {
        x = vmath.to_axis(opts.x or 0, screen_width),
        y = vmath.to_axis(opts.y or 0, screen_height),
        width = vmath.to_axis(opts.width or 0, screen_width),
        height = vmath.to_axis(opts.height or 0, screen_height),
    })
end

function M.contained(opts, padding)
    local border_area = M.border_area(opts.border)

    return vim.tbl_extend('force', opts, {
        x = opts.x + border_area.left + (padding.left or 0),
        y = opts.y + border_area.top + (padding.top or 0),
        width = opts.width - (padding.left or 0) - (padding.right or 0),
        height = opts.height - (padding.top or 0) - (padding.bottom or 0),
    })

    -- Expect result with padding = 1 for all sides
    -- ##############################
    -- #                            #
    -- # ########################## #
    -- # #                        # #
    -- # ########################## #
    -- #                            #
    -- ##############################

    -- Expect result with padding = 1 for all sides and left = 2
    -- ##############################
    -- #                            #
    -- #  ######################### #
    -- #  #                       # #
    -- #  ######################### #
    -- #                            #
    -- ##############################
end

function M.centered(opts)
    return vim.tbl_extend('force', opts, {
        x = (vim.o.columns - opts.width) / 2.0 - 1,
        y = (vim.o.lines - opts.height) / 2.0 - 1,
    })
end

function M.bottom_left(opts)
    return vim.tbl_extend('force', opts, {
        x = 0,
        y = vim.o.lines - opts.height,
    })
end

function M.bottom_right(opts)
    return vim.tbl_extend('force', opts, {
        x = vim.o.columns - opts.width,
        y = vim.o.lines - opts.height,
    })
end

function M.top_left(opts)
    return vim.tbl_extend('force', opts, { x = 0, y = 0 })
end

function M.top_right(opts)
    return vim.tbl_extend('force', opts, {
        x = vim.o.columns - opts.width,
        y = 0,
    })
end
-------------------------------------------------------------------------------

return M
