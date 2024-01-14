local M = {}

local Efficient_Array_Metatable = {}

local function efficient_array_make()
    local efficient_array = { length = 0 }
    setmetatable(efficient_array, Efficient_Array_Metatable)
    return efficient_array
end

function Efficient_Array_Metatable:insert(...)
    for _, element in ipairs({...}) do
        self[self.length + 1] = element
        self.length = self.length + 1
    end

    return self
end

function Efficient_Array_Metatable:clear()
    self.length = 0
    self[1] = nil

    return self
end

function Efficient_Array_Metatable:join(...)
    local joined = efficient_array_make()

    for _, element in ipairs(self) do
        joined:insert(element)
    end

    for _, tbl in ipairs({...}) do
        for _, element in ipairs(tbl) do
            joined:insert(element)
        end
    end

    return joined
end

function Efficient_Array_Metatable:make_natural()
    setmetatable(self, nil)
    self.length = nil

    return self
end

Efficient_Array_Metatable.__index = Efficient_Array_Metatable

M.efficient_array_make = efficient_array_make

-- local x = vlua.make_efficient_array()
-- x:insert(some_element)
-- y:insert(some_element)
-- print(y.length)

return M
