if not tll then return end
tll.utf8 = tll.utf8 or {}

local utf8pattern = "[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]*"

local rawget = rawget
local string_gsub = string.gsub
local string_lower = string.lower
local string_upper = string.upper
local string_byte = string.byte
local string_sub = string.sub

local lower2upper = {}
local upper2lower = {
    ["А"] = "а", ["Б"] = "б", ["В"] = "в", ["Г"] = "г", ["Д"] = "д", ["Е"] = "е", ["Ё"] = "ё", ["Ж"] = "ж", ["З"] = "з",
    ["И"] = "и", ["Й"] = "й", ["К"] = "к", ["Л"] = "л", ["М"] = "м", ["Н"] = "н", ["О"] = "о", ["П"] = "п", ["Р"] = "р",
    ["С"] = "с", ["Т"] = "т", ["У"] = "у", ["Ф"] = "ф", ["Х"] = "х", ["Ц"] = "ц", ["Ч"] = "ч", ["Ш"] = "ш", ["Щ"] = "щ",
    ["Ъ"] = "ъ", ["Ы"] = "ы", ["Ь"] = "ь", ["Э"] = "э", ["Ю"] = "ю", ["Я"] = "я"
}

for upper, lower in next, upper2lower do
    lower2upper[lower] = upper
end

setmetatable(upper2lower, {
    __index = function(self, char)
        return rawget(self, char) or string_lower(char)
    end
})

setmetatable(lower2upper, {
    __index = function(self, char)
        return rawget(self, char) or string_upper(char)
    end
})

local function utf8_byte(char, offset)
    if char == "" then return -1 end
    offset = offset or 1

    local byte = string_byte(char, offset)
    local length = 1
    if byte >= 128 then
        if byte >= 240 then
            length = 4
            if #char < 4 then return -1, length end
            byte = (byte % 8) * 262144
            byte = byte + (string_byte(char, offset + 1) % 64) * 4096
            byte = byte + (string_byte(char, offset + 2) % 64) * 64
            byte = byte + (string_byte(char, offset + 3) % 64)
        elseif byte >= 224 then
            length = 3
            if #char < 3 then return -1, length end
            byte = (byte % 16) * 4096
            byte = byte + (string_byte(char, offset + 1) % 64) * 64
            byte = byte + (string_byte(char, offset + 2) % 64)
        elseif byte >= 192 then
            length = 2
            if #char < 2 then return -1, length end
            byte = (byte % 32) * 64
            byte = byte + (string_byte(char, offset + 1) % 64)
        else
            byte = -1
        end
    end
    return byte, length
end

local function utf8_len(str)
    local _, length = string_gsub(str, "[^\128-\191]", "")
    return length
end

local function utf8_sub(str, i, j)
    j = j or -1

    local pos = 1
    local bytes = #str
    local length = 0

    local l = (i >= 0 and j >= 0) or utf8_len(str)
    local start_char = (i >= 0) and i or l + i + 1
    local end_char   = (j >= 0) and j or l + j + 1

    if start_char > end_char then return "" end

    local start_byte, end_byte = 1, bytes

    while pos <= bytes do
        length = length + 1

        if length == start_char then
            start_byte = pos
        end

        pos = pos + select(2, utf8_byte(str, pos))

        if length == end_char then
            end_byte = pos - 1
            break
        end
    end

    return string_sub(str, start_byte, end_byte)
end

function tll.utf8.lower(str)
    return string_gsub(str, utf8pattern, upper2lower)
end

function tll.utf8.upper(str)
    return string_gsub(str, utf8pattern, lower2upper)
end

tll.utf8.len = utf8_len
tll.utf8.sub = utf8_sub
