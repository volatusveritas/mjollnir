vim.bo.commentstring = "// %s"

-- Imports
local keymap = require("volt.keymap")

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
})
