local M = {}

function M.get_indent_size(lnum)
    return math.floor(vim.fn.indent(lnum) / vim.o.shiftwidth)
end

function volt_fold_expr(lnum)
    local line = vim.fn.getline(lnum)

    if line:match("^%s*$") then
        -- TODO: Optimize this please
        if M.get_indent_size(lnum - 1) ~= 0 and M.get_indent_size(lnum + 1) ~= 0 then
            return "="
        else
            return 0
        end
    end

    local indentsize = M.get_indent_size(lnum)

    if lnum < vim.fn.line("$") then
        local nextsize = M.get_indent_size(lnum + 1)

        if nextsize > indentsize then
            return string.format(">%d", indentsize + 1)
        end
    end

    if lnum > 1 then
        local prevsize = M.get_indent_size(lnum - 1)

        if prevsize > indentsize then
            return string.format("<%d", indentsize + 1)
        end
    end

    return indentsize
end

function volt_fold_text()
    -- TODO: shorten lines if they exceed textwidth (80cols)

    local lines = vim.v.foldend - vim.v.foldstart + 1

    local fstart = vim.fn.getline(vim.v.foldstart)
    local fend = vim.fn.getline(vim.v.foldend)
    local lcount = string.format("(%d) ", lines)

    local content = fstart

    if
        vim.fn.indent(vim.v.foldstart) == vim.fn.indent(vim.v.foldend)
    then
        content = string.format("%s...%s", fstart, vim.trim(fend))
    end

    return string.format(
        "%s%s%s",
        content,
        string.rep(" ", vim.o.textwidth - #content - #lcount),
        lcount
    )
end

function M.setup()
    vim.o.fillchars = "fold: "
    vim.o.foldmethod = "expr"
    vim.o.foldtext = "v:lua.volt_fold_text()"
    vim.o.foldexpr = "v:lua.volt_fold_expr(v:lnum)"
end

return M
