local M = {}

local function clear_highlights(str)
    return string.gsub(str, '%%#%w+#', '')
end

local function format_tab_name(tabnr)
    local buflist = vim.fn.tabpagebuflist(tabnr)
    local winnr = vim.fn.tabpagewinnr(tabnr)
    local bufnr = buflist[winnr]
    local name = vim.fn.bufname(bufnr)

    if name == '' then
        return 'Unnamed'
    end

    local parent = vim.fs.basename(vim.fs.dirname(name))
    local base = vim.fs.basename(name)

    local fullname

    if parent == '.' then
        fullname = base
    else
        fullname = string.format('• %s/%s', parent, base)
    end

    local highlight

    if tabnr == vim.fn.tabpagenr() then
        highlight = '%#TabLineSel#'
    else
        highlight = '%#TabLine#'
    end

    return string.format('%s %s %%#TabLineFill#', highlight, fullname)
end

function volt_tabline()
    local names = {}

    for tabnr = 1, vim.fn.tabpagenr('$') do
        table.insert(names, format_tab_name(tabnr))
    end

    local tabnames = table.concat(names, ' ')
    local midsize = #clear_highlights(tabnames)

    local before = string.rep(' ', (vim.o.columns - midsize) / 2)

    return string.format('%s%s', before, tabnames)
end

function M.setup()
    vim.o.tabline = '%!v:lua.volt_tabline()'
end

return M
