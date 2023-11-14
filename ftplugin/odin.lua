vim.bo.commentstring = "// %s"

-- Imports
local keymap = require('volt.keymap')
local odin = require('volt.lang.odin')

local ns = vim.api.nvim_create_namespace('volt.ftplugin.odin')

local procedure_pat = [[/^\w*%s\w*\s*::\s*proc]]

local function populate_extmarks()
    local qflist = vim.fn.getqflist()

    vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

    for _, entry in ipairs(qflist) do
        vim.api.nvim_buf_set_extmark(
            entry.bufnr,
            ns,
            entry.lnum - 1,
            entry.col - 1,
            { virt_text = { { entry.text, 'Comment' } } }
        )
    end
end

keymap.set("n", {['<LocalLeader>'] = {
    desc = 'Odin special commands',
    opts = { buffer = 0 },
    map = {
        f = {
            desc = "Find procedure",
            map = function()
                local proc_name = vim.fn.input('Procedure name: ', '')

                if proc_name == '' then
                    return
                end

                vim.cmd(string.format(procedure_pat, proc_name))
            end,
        },
        e = {
            desc = 'Quickfix-check package',
            map = function()
                local package_name = vim.fn.input({
                    prompt = '(Odin check quickfix) package name: ',
                    completion = 'dir',
                    cancelreturn = nil,
                })

                if package_name == '' or package_name == nil then
                    return
                end

                -- TODO: fix the populate_extmarks function and use it here
                odin.check_package(package_name, function() end)
            end,
        },
    },
}})
