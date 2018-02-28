local md5 = require "resty.md5"

local M = {}

--字符串进行urlencode
local function urlencode(str)
    if (str) then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w ])", function(c) return string.format("%%%02X", string.byte(c)) end)
        str = string.gsub(str, " ", "+")
    end

    return str
end

--字符串分隔
function split(str, split_char)
    local sub_str_tab = {};
    while (true) do
        local pos = string.find(str, split_char, 1, true);
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str;
            break;
        end
        local sub_str = string.sub(str, 1, pos - 1);
        sub_str_tab[#sub_str_tab + 1] = sub_str;
        str = string.sub(str, pos + string.len(split_char), #str);
    end

    return sub_str_tab;
end



--[[
    @comment 将时间字符串转换成Unix时间戳
    @param string time,如2015-09-12 18:43:49.只有日期将返回当前0:0:0的时间戳
    @return number
]]
local function strtotime(time_str)
    if not time_str then
        return 0
    end

    local i = string.find(time_str, " ")

    --只有日期从当天0:0:0开始计算
    if not i then
        time_str = time_str .. " 0:0:0"
    end

    local time = split(time_str, " ")
    local ymd = split(time[1], "-")
    local hms = split(time[2], ":")
    local timestamp = os.time({ year = ymd[1], month = ymd[2], day = ymd[3], hour = hms[1], min = hms[2], sec = hms[3] })

    return timestamp
end

--[[
    @comment 判断一个字符是否存在于一个数组内
    @param element:待判断字符, arr:待判断数组
    @return bool
]]
local function inarray(element, arr)
    if not arr or type(arr) ~= 'table' or #arr == 0 then
        return false
    end
    for _, val in pairs(arr) do
        if val == element then
            return true
        end
    end
    return false
end

--[[
    @comment 对手机号进行模糊化处理.中间5位用*代替
    @param string phone
    @return string
]]
local function formatPhone(phone)
    if not phone then
        return nil
    end

    return string.sub(phone, 1, 3) .. "*****" .. string.sub(phone, 9)
end



--[[
    @comment 对邮箱进行格式化处理.邮箱名字符数大于3,前两个和最后一个字符除外，其它字符统一用*代替;邮箱名字符数小于等于3,第一位明文展示,其它统一用*代替
    @param string email
    @return string
]]
local function formatEmail(email)
    if not email then
        return nil
    end

    local i = string.find(email, "@")
    if not i then
        return nil
    end

    local name = string.sub(email, 1, i - 1)
    local name_len = string.len(name)
    if name_len > 3 then
        return string.sub(email, 1, 2) .. string.rep("*", name_len - 3) .. string.sub(email, i - 1)
    else
        return string.sub(email, 1, 1) .. string.rep("*", name_len - 1) .. string.sub(email, i)
    end
end



local function tostring(arr)
    if not arr or type(arr) ~= table or #arr == 0 then
        return nil
    end
    local str = ""
    for _, val in pairs(arr) do
        str = str..val..","
    end
    return string.sub(str, 0, -2)
end


local function range(arr, pos, size)
    if not arr or type(arr) ~= 'table' or #arr == 0 then
        return nil
    end

    if #arr < pos then
        return nil
    end
    local res = {}
    if #arr == pos then
        res[1] = arr[#arr]
    end
    local index = 1
    if #arr >= pos + size then
        for j = pos, pos + size - 1, 1 do
            res[index] = arr[j]
            index = index + 1
        end
    else
        for j = pos, #arr, 1 do
            res[index] = arr[j]
            index = index + 1
        end
    end
    return res

end


local function trim (s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

M.urlencode = urlencode
M.split = split
M.strtotime = strtotime
M.inarray = inarray
M.formatPhone = formatPhone
M.formatEmail = formatEmail
M.tostring = tostring
M.range = range
M.trim = trim
return M
