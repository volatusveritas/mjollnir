local statusline = {}

----------------------------------- Imports -----------------------------------
local terminal = require('terminal')
local vlua = require('volt/lua')
-------------------------------------------------------------------------------

local status_blocks = nil

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

-- returns content(string), length(number)
local function render_block(block)
    local text

    if type(block.content) == 'function' then
        text = block.content()
    else
        text = block.content
    end

    local text_length = #text + block.padding * 2

    local padding = string.rep(' ', block.padding)
    local content = string.format('%%#StatusLineBlock%s#%s%s%s%%*', block.color, padding, text, padding)

    return content, text_length
end

-- returns {
--     content: string,
--     length: number,
-- }
local function render_block_group(blocks)
    local block_contents = vlua.efficient_array()
    local block_length = 0

    for _, block in ipairs(blocks) do
        local content, length = render_block(block)
        block_contents:insert(content)
        block_length = block_length + length
    end

    return { content = table.concat(block_contents), length = block_length }
end

function volt_statusline()
    local win_width = vim.api.nvim_win_get_width(vim.g.statusline_winid)

    local left = render_block_group(status_blocks.left)
    local middle = render_block_group(status_blocks.middle)
    local right = render_block_group(status_blocks.right)

    local left_half = math.ceil(win_width / 2)
    local right_half = win_width - left_half

    local space_left_middle = string.rep(settings.space_char, left_half - left.length - math.floor(middle.length / 2) - settings.padding)
    local space_middle_right = string.rep(settings.space_char, right_half - math.ceil(middle.length / 2) - right.length - settings.padding)

    return table.concat({
        string.rep(' ', settings.padding),
        left.content,
        space_left_middle,
        middle.content,
        space_middle_right,
        right.content,
    })
end

function statusline.block_file_name()
    local buf = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
    local file_name = vim.fn.bufname(buf)
    
    if file_name == '' then
        file_name = 'Unnamed'
    elseif vim.startswith(file_name, 'term://') then
        local term_index = terminal.buffer_index(buf)

        if term_index == -1 then
            file_name = 'Terminal::?'
        else
            file_name = string.format('Terminal::%d', term_index)
        end
    end

    return file_name
end

function statusline.block_mode()
    return modenames[vim.api.nvim_get_mode().mode] or 'Unknown'
end

function statusline.block_file_type()
    local buf = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
    local file_type = vim.bo[buf].filetype

    if file_type == '' then
        file_type = 'No Type'
    end

    return file_type
end

-- Block :: {
--     color: Color,
--     content: string|function,
--     padding: number,
-- }
--
-- blocks :: {
--     left: Block[],
--     middle: Block[],
--     right: Block[]
-- }
function statusline.setup(user_settings, blocks)
    status_blocks = blocks

    if user_settings ~= nil then
        settings.padding = user_settings.padding
        settings.space_char = user_settings.space_char
    end

    vim.o.statusline = '%!v:lua.volt_statusline()'
end

return statusline
