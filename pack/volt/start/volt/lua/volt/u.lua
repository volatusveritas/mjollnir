local M = {}

-- TODO: document this
function M.normalize_range(a, b)
    if a < b then
        return a, b
    else
        return b, a
    end
end

return M
