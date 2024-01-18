vim.bo.indentexpr = 'v:lua.volt_odin_indent()'

function volt_odin_indent()
    if vim.v.lnum == 1 then
        return -1
    end

    if string.find(vim.fn.getline(vim.v.lnum), '%s*case') then
        for lnum = vim.v.lnum, 1, -1 do
            if string.find(vim.fn.getline(lnum), '%s*switch') then
                return vim.fn.indent(lnum)
            end
        end
    end

    if vim.endswith(vim.fn.getline(vim.v.lnum), '}') then
        return math.max(0, vim.fn.indent(vim.v.lnum - 1) - vim.o.shiftwidth)
    end

    local line_above = vim.fn.getline(vim.v.lnum - 1)

    if vim.endswith(line_above, '{') or vim.endswith(line_above, ':') then
        return vim.fn.indent(vim.v.lnum - 1) + vim.o.shiftwidth
    end

    return -1
end
