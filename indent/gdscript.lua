vim.bo.indentexpr = 'v:lua.volt_gdscript_indent()'

function volt_gdscript_indent()
    if vim.v.lnum == 1 then
        return -1
    end

    if vim.endswith(vim.fn.getline(vim.v.lnum - 1), ':') then
        return vim.fn.indent(vim.v.lnum - 1) + vim.o.shiftwidth
    end

    return -1
end
