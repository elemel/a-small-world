local utils = {}

function utils.newClass()
	local class = {}
	class.__index = class
	return class
end

function utils.newInstance(class, ...)
	local instance = setmetatable({}, class)
	instance:init(...)
	return instance
end

function utils.removeArrayValue(array, value)
    for i, v in ipairs(array) do
        if v == value then
            table.remove(array, i)
            return i
        end
    end

    return nil
end

function utils.normalize2(x, y)
    local length = math.sqrt(x * x + y * y)
    return x / length, y / length, length
end

return utils
