vim.bo.commentstring = "// %s"

-- Imports
local keymap = require("volt.keymap")

keymap.set("n", {
    ["<LocalLeader>b"] = {
        desc = "Build Odin package and generate quickfix list",
        map = function()
            local result = vim.fn.jobstart({"odin", "check", "."}, {
                stderr_buffered = true,
                on_stderr = function(chan_id, data, name)
                    local qflist = {}

                    for _, line in ipairs(data) do
                        local qfll = vim.fn.matchlist(
                            line,
                            string.format([[^%s/\(.*\)(\(\d\+\):\(\d\+\))]], vim.fn.expand("%:p:h"))
                        )

                        if qfll[1] then
                            table.insert(qflist, {
                                filename = qfll[2],
                                lnum = tonumber(qfll[3]),
                                col = tonumber(qfll[4]),
                            })
                        end
                    end

                    vim.fn.setqflist(qflist)

                    print(string.format("%d errors added to quickfix list.", #qflist))
                end,
            })

            if result < 1 then
                vim.api.nvim_err_writeln("Could not generate Odin quickfix list.")
            end
        end,
    },
    ["<LocalLeader>e"] = {
        desc = "Move around the quickfix list",
        map = {
            n = {
                desc = "Go to next item",
                map = "<Cmd>cnext<CR>",
            },
            p = {
                desc = "Go to previous item",
                map = "<Cmd>cprevious<CR>",
            },
        },
    },
})
