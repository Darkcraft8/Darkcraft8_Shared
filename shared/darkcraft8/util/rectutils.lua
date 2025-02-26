require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/rect.lua"

--- Utility function for rect variable ---
if not rect then rect = {} end

rect.shiftByVec2 = function(_rect, _vec2) -- shift the rect by the value of vec2, does the same as rect.translate except that it check before hand that both argument are valid
    if not rect.isRect(_rect) then return rect.isRect(_rect) end
    if not rect.isVec2(_vec2) then return rect.isVec2(_vec2) end
    local newRect = {
        _rect[1] + _vec2[1],
        _rect[2] + _vec2[2],
        _rect[3] + _vec2[1],
        _rect[4] + _vec2[2]
    }
    return newRect
end


rect.vec2InRect = function(_rect, _vec2) -- return if the vec2 is inside the rect
    if not rect.isRect(_rect) then return rect.isRect(_rect) end
    if not rect.isVec2(_vec2) then return rect.isVec2(_vec2) end
    
    if (_vec2[1] > _rect[1] and _vec2[1] < _rect[3]) and (_vec2[2] > _rect[2] and _vec2[2] < _rect[4]) then
        return true
    else
        return false
    end
end

rect.centerRect = function(_rect) -- return the given rect centered and it size ... rect.center() give back just the given rect centered
    if not rect.isRect(_rect) then return rect.isRect(_rect) end
    local centerForce = {
        _rect[3] - _rect[1],
        _rect[4] - _rect[2]
    }

    centerForce = vec2.mul(vec2.div(centerForce, 2), -1)
    return rect.shiftByVec2(_rect, centerForce), vec2.mul(centerForce, -1)
end
--- Validity Check ---
rect.isRect = function(_rect)
    if not _rect then return false, "no rect argument given" end
    if type(_rect) ~= "table" then return false, "rect ins't a table" end
    if #_rect ~= 4 then return false, "rect isn't valid" end
    if type(_rect[1]) ~= "number" then return false, "first value ins't a number" end
    if type(_rect[2]) ~= "number" then return false, "second value ins't a number" end
    if type(_rect[3]) ~= "number" then return false, "third value ins't a number" end
    if type(_rect[4]) ~= "number" then return false, "fourth value ins't a number" end

    return true
end

rect.isVec2 = function(_vec2)
    if not _vec2 then return false, "no vec2 argument given" end
    if type(_vec2) ~= "table" then return false, "vec2 ins't a table" end
    if #_vec2 ~= 2 then return false, "vec2 isn't valid" end
    if type(_vec2[1]) ~= "number" then return false, "first value ins't a number" end
    if type(_vec2[2]) ~= "number" then return false, "second value ins't a number" end

    return true
end