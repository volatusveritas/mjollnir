local M = {}

--------------------------------- Public API ----------------------------------
function M.to_axis(value, basis)
    if value > -1 and value < 1 then
        value = value * basis
    end

    return math.floor(value)
end
-------------------------------------------------------------------------------

return M
