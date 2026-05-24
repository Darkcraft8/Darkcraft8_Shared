segmentString = function(string)
    local full = string
    local result = {}
    while full ~= "" do
        local s, e = string.find(full, "%^.-%;")
        local str
        if s ~= 1 then
            str = string.sub(full, 1, 1)
            full = string.sub(full, 2, string.len(full))
        else
            str = string.sub(full, s, e)
            full = string.sub(full, e, string.len(full))
        end
        table.insert(result, str)
    end
    return result
end