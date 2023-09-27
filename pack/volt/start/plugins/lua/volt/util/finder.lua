local M = {}

function M.search(pattern, on_stdout)
    vim.fn.jobstart({ "rg", "--vimgrep", pattern }, {
        stdout_buffered = true,
        stdin = "null",
        on_stdout = function(_, data, _)
            -- Remove EOF string
            data[#data] = nil
            on_stdout(data)
        end,
    })
end

function M.search_files(pattern, on_stdout)
    M.search(pattern, function(lines)
        local file_locations = {}

        for _, line in ipairs(lines) do
            local lnum_marker = string.find(line, ":")
            local colnum_marker = string.find(line, ":", lnum_marker + 1)
            local ltext_marker = string.find(line, ":", colnum_marker + 1)

            table.insert(file_locations, {
                file = string.sub(line, 1, lnum_marker - 1),
                line = tonumber(
                    string.sub(line, lnum_marker + 1, colnum_marker - 1)
                ),
                col = tonumber(
                    string.sub(line, colnum_marker + 1, ltext_marker - 1)
                ),
                text = string.sub(line, ltext_marker + 1),
                full = line,
            })
        end

        on_stdout(file_locations)
    end)
end

return M
