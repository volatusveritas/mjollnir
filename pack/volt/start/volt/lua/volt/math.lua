local M = {}

local Vector_2_Metatable = {}

local function vector2(x, y)
    local vector2 = { x or 0, y or 0 }
    setmetatable(vector2, Vector_2_Metatable)
    return vector2
end

function Vector_2_Metatable.__index(tbl, key)
    if key == 'x' then
        return tbl[1]
    elseif key == 'y' then
        return tbl[2]
    else
        return Vector_2_Metatable[key]
    end
end

function Vector_2_Metatable.__newindex(tbl, key, value)
    if key == 'x' then
        tbl[1] = value
    elseif key == 'y' then
        tbl[2] = value
    end
end

function Vector_2_Metatable.__add(v1, v2)
    return vector2(v1.x + v2.x, v1.y + v2.y)
end

function Vector_2_Metatable.__sub(v1, v2)
    return vector2(v1.x - v2.x, v1.y - v2.y)
end

function Vector_2_Metatable.__mul(v1, v2)
    if type(v1) == 'number' then
        return vector2(v1 * v2.x, v1 * v2.y)
    elseif type(v2) == 'number' then
        return vector2(v1.x * v2, v1.y * v2)
    end
end

function Vector_2_Metatable.__div(v1, v2)
    if type(v2) == 'number' then
        return vector2(v1.x / v2, v1.y / v2)
    end
end

function Vector_2_Metatable.__unm(vec)
    return vector2(-vec.x, -vec.y)
end

function Vector_2_Metatable.__eq(v1, v2)
    return v1.x == v2.x and v1.y == v2.y
end

M.vector2 = vector2

return M
