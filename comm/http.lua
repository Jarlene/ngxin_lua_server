local Http = {}

local base = require "comm.base"
local log = require "comm.log"
local gzip = require 'zlib'


--获取http参数 /post or get
local function getParam(param)
    local request_method = ngx.var.request_method
    local args = ngx.req.get_uri_args()
    if "POST" == request_method then
        ngx.req.read_body()
        table.insert(args, ngx.req.get_post_args())
    end

    if not param then
        return args
    end

    local p = args[param]

    --多个相同参数返回最后一个
    if type(p) == "table" then
        return p[#p]
    elseif type(p) == "string" and p == "" then
        return nil
    else
        return p
    end
end

--获取Cookie
local function getCookie()
    local cookie_table = {}
    local cookie = ngx.req.get_headers()['Cookie']

    if not cookie then
        return cookie_table
    end

    if type(cookie) == "table" then
        cookie = cookie[1]
    end

    cookie = base.split(cookie, ";")

    for key, value in pairs(cookie) do
        if value and value ~= "" then
            local kvs =  base.split(value, "=")
            if #kvs == 1 then
                table.insert(cookie_table, value)
            elseif #kvs == 2 then
                cookie_table[base.trim(kvs[1])] = base.trim(kvs[2])
            end
        end
    end

    return cookie_table
end

--[[
    @comment 并发访问多个后端服务(最多10个),只支持json格式数据
    @param string url
    @return table|nil
]]
local function getMultiCapture(...)
    local http_url = {}
    for i, v in pairs({ ... }) do
        if i <= 15 then
            local tmp_url = {}
            table.insert(tmp_url, v)
            table.insert(http_url, tmp_url)
        end
    end


    local ht1, ht2, ht3, ht4, ht5, ht6, ht7, ht8, ht9, ht10, ht11, ht12, ht13, ht14, ht15 = ngx.location.capture_multi(http_url)
    local ht = { ht1, ht2, ht3, ht4, ht5, ht6, ht7, ht8, ht9, ht10, ht11, ht12, ht13, ht14, ht15 }
    local container = {}

    for key, value in pairs(ht) do
        if value then
            table.insert(container, value)
        end
    end

    local flag

    for key, value in pairs(container) do
        if value.status == ngx.HTTP_OK then

            if value.header["Content-Encoding"] == "gzip" then
                local stream = gzip.inflate()
                local stream = stream(value.body)
                flag, value = pcall(function() return json.decode(stream) end)
            else
                flag, value = pcall(function() return json.decode(value.body) end)
            end

            if flag then
                ht[key] = value
            else
                ht[key] = nil
            end
        else

            ht[key] = nil
        end
    end

    return ht[1], ht[2], ht[3], ht[4], ht[5], ht[6], ht[7], ht[8], ht[9], ht[10], ht[11], ht[12], ht[13], ht[14], ht[15]
end

--[[
    @comment 访问单个后端服务
    @param string url
    @param string format 后端服务返回的数据格式,目前只支持json(默认),mcpack
    @param table post 默认get请求,post不为空则为post请求
    @return table|nil
]]
local function getCapture(url, format, post)
    if not url then
        return nil, "param error"
    end


    local http_result = ngx.location.capture(url)
    if http_result.status ~= ngx.HTTP_OK then
        log:info("getCapture error:"..url)
        return nil
    end

    local result, flag = {}
    if http_result.header["Content-Encoding"] == "gzip" then
        local stream = gzip.inflate()
        local stream = stream(http_result.body)
        flag, result = pcall(function() return json.decode(stream) end)
    else
        flag, result = pcall(function() return json.decode(http_result.body) end)
    end

    if not flag then
        http_result = ngx.location.capture(url)
        if http_result.status ~= ngx.HTTP_OK then
            log:info("getCapture error:"..url)
            return nil
        end
        flag, result = pcall(function() return json.decode(http_result.body) end)
        if not flag then
            log:info("getCapture error:"..url)
            result = nil
        end
    end

    return result
end



Http.getParam = getParam
Http.cookie = getCookie
Http.getCapture = getCapture
Http.getMultiCapture = getMultiCapture

return Http
