-- Options
vim.bo.commentstring = '// %s'
vim.bo.comments = '://,s:/*,m: ,e:*/'

local keymap = require 'keymap'

local function add_import()
    local no_import = false
    local anchor = vim.fn.search([[^\<import\>]], 'n')

    if anchor == 0 then
        no_import = true
        anchor = vim.fn.search([[^\<package\>]], 'n')
    end

    if anchor == 0 then
        vim.api.nvim_err_writeln('No import or package statement found.')
        return
    end

    local package_name = vim.fn.input('Package name: ')

    if package_name == '' then
        vim.api.nvim_err_writeln('No package name provided.')
        return
    end

    local import_line = string.format('import "%s"', package_name)

    local import_replacement
    local line_index

    if no_import then
        import_replacement = {'', import_line}
        line_index = anchor
    else
        import_replacement = {import_line}
        line_index = anchor - 1
    end

    vim.api.nvim_buf_set_lines(0, line_index, line_index, true, import_replacement)

    vim.print('Line', line_index)

    if no_import then
        vim.fn.cursor(anchor + 2, 0)
    else
        vim.fn.cursor(anchor, 0)
    end
end

keymap.normal()
:group({ key = '<LocalLeader>' })
    :set({ key = 'i', map = add_import })
:endgroup()
