if vim.fn.exists("b:did_indent") ~= 0 then
    return
end

vim.cmd("let b:did_indent = 1")

function volt_gdscript_indentexpr()
    if vim.endswith(vim.fn.getline(vim.v.lnum - 1), ":") then
        return vim.fn.indent(vim.v.lnum - 1) + vim.o.shiftwidth
    end

    return -1
end

vim.bo.indentexpr = "v:lua.volt_gdscript_indentexpr()"
