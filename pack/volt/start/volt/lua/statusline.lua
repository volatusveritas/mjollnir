local statusline = {}

local settings = {
    padding = 0,
    space_char = ' ',
}

local modenames = {
    ['n'] = 'Normal',
    ['i'] = 'Insert',
    ['c'] = 'Command',
    ['v'] = 'Visual',
    ['x'] = 'Visual-x',
    ['s'] = 'Select',
    ['o'] = 'Operator',
    ['t'] = 'Terminal',
    ['l'] = 'Language',
}

function volt_statusline()
    local win_width = vim.api.nvim_win_get_width(vim.g.statusline_winid)
    local buf = vim.api.nvim_win_get_buf(vim.g.statusline_winid)

    local mode_name = modenames[vim.api.nvim_get_mode().mode] or 'Unknown'
    local file_name = vim.fn.bufname(buf) or 'Unnamed'
    local file_type = vim.bo[buf].filetype or 'No Type'

    local left = string.format('  %s  ', mode_name)
    local middle = string.format('  %s  ', file_name)
    local right = string.format('  %s  ', file_type)

    local left_size = #left
    local middle_size = #middle
    local right_size = #right

    local left_half = math.ceil(win_width / 2)
    local right_half = win_width - left_half

    local space_left_middle = string.rep(settings.space_char, left_half - left_size - math.floor(middle_size / 2) - settings.padding)
    local space_middle_right = string.rep(settings.space_char, right_half - math.ceil(middle_size / 2) - right_size - settings.padding)

    return string.format(
        '%s%%#StatusLineMode#%s%%*%s%%#StatusLineFileName#%s%%*%s%%#StatusLineFileType#%s%%*',
        string.rep(' ', settings.padding),
        left,
        space_left_middle,
        middle,
        space_middle_right,
        right
    )
end

function statusline.setup(user_settings)
    if user_settings ~= nil then
        settings.padding = user_settings.padding
        settings.space_char = user_settings.space_char
    end

    vim.o.statusline = '%!v:lua.volt_statusline()'
end

return statusline
