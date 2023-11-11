vim.bo.commentstring = "// %s"

-- Imports
local keymap = require('volt.keymap')
local odin = require('volt.lang.odin')

local ns = vim.api.nvim_create_namespace('volt.ftplugin.odin')

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
                vim.ui.input({ prompt = "Procedure name: " }, function(input)
                    if input == nil then
                        return
                    end

                    vim.cmd(string.format([[/^\w*%s\w*\s*::\s*proc]], input))
                end)
            end,
        },
        e = {
            desc = 'Quickfix-check package',
            map = function()
                package_name = vim.fn.input({
                    prompt = '(Odin check quickfix) package name: ',
                    completion = 'dir',
                    cancelreturn = nil,
                })

                if package_name == '' or package_name == nil then
                    return
                end

                odin.check_package(package_name, populate_extmarks)
            end,
        },
    },
}})
