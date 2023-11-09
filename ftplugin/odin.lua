vim.bo.commentstring = "// %s"

-- Imports
local keymap = require('volt.keymap')
local odin = require('volt.lang.odin')

keymap.set("n", {
    ["<LocalLeader>f"] = {
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
    ['<LocalLeader>e'] = {
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

            odin.check_package(package_name)
        end,
    },
})
