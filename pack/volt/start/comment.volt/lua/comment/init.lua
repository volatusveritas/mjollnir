local M = {}

-- TODO: document this
local langs = {}

-- TODO: document this
local function get_lang_values()
    local lang = vim.bo.filetype

    if langs[lang] ~= nil then
        return langs[lang]
    end

    local starter = '//'

    for format in string.gmatch(vim.bo.comments, '[^,]*') do
        if format:sub(1, 1) == ':' then
            starter = format:sub(2)
            -- break :: We're searching for the last
        elseif format:sub(1, 2) == 'b:' then
            starter = format:sub(3)
            -- break :: We're searching for the last
        end
    end

    langs[lang] = {
        starter = starter,
        pattern = string.format('^%s (.*)', starter),
    }

    return langs[lang]
end

-- TODO: document this
local function split_content(line)
    local _, _, whitespace, content = line:find('^(%s*)(.*)')
    return whitespace, content
end

-- TODO: document this
local function lines_as_comments(lines, lang)
    local commented = {}
    local next_idx = 1

    for _, line in ipairs(lines) do
        local whitespace, content = split_content(line)
        commented[next_idx] = string.format(
            '%s%s %s',
            whitespace,
            lang.starter,
            content
        )
        next_idx = next_idx + 1
    end
    
    return commented
end

-- TODO: document this
local function comments_as_lines(lines, lang)
    local uncommented = {}
    local next_idx = 1
    
    for _, line in ipairs(lines) do
        local whitespace, content = split_content(line)
        local _, _, uncommented_line = content:find(lang.pattern)

        if uncommented_line ~= nil then
            uncommented[next_idx] = string.format(
                '%s%s',
                whitespace,
                uncommented_line
            )
        else
            uncommented[next_idx] = line
        end

        next_idx = next_idx + 1
    end

    return uncommented
end

-- TODO: document this
local function toggle_lines(lines, lang)
    local toggled = {}
    local next_idx = 1

    for _, line in ipairs(lines) do
        local whitespace, content = split_content(line)
        local _, _, uncommented = content:find(lang.pattern)

        if uncommented ~= nil then
            toggled[next_idx] = string.format('%s%s', whitespace, uncommented)
        else
            toggled[next_idx] = string.format(
                '%s%s %s',
                whitespace,
                lang.starter,
                content
            )
        end

        next_idx = next_idx + 1
    end

    return toggled
end

-- TODO: document this
local function apply_lines(buf, r_start, r_end, modifier)
    vim.api.nvim_buf_set_lines(buf, r_start - 1, r_end, false, modifier(
        vim.api.nvim_buf_get_lines(buf, r_start - 1, r_end, false),
        get_lang_values()
    ))
end

    ----------------------------- PUBLIC API ------------------------------

-- TODO: document this
function M.comment(buf, r_start, r_end)
    apply_lines(buf, r_start, r_end, lines_as_comments)
end

-- TODO: document this
function M.uncomment(buf, r_start, r_end)
    apply_lines(buf, r_start, r_end, comments_as_lines)
end

-- TODO: document this
function M.toggle(buf, r_start, r_end)
    apply_lines(buf, r_start, r_end, toggle_lines)
end

return M
