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

function utils.clamp(x, x1, x2)
    return math.min(math.max(x, x1), x2)
end

return utils
