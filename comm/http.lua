local Http = {}

local base = require "comm.base"
local log = require "comm.log"
local gzip = require 'zlib'


--获取http参数 /post or get
local function getParam(param)

    local request_method = ngx.var.request_method
    local args = {}
    local getargs = ngx.req.get_uri_args()
    if getargs and next(getargs) then
        for k, v in pairs(getargs) do
            args[k] = v
        end
    end
    if "POST" == request_method then
        ngx.req.read_body()
        local postargs = ngx.req.get_post_args()
        if postargs and next(postargs) then
            for k, v in pairs(postargs) do
                args[k] = v
            end
        else
            local rpostArgs = {}
            local body = ngx.req.get_body_data()
            log:info("body data " .. body)
            local post = base.split(tostring(body), "&")
            if #post > 0 then
                for _, v in pairs(post) do
                    local temp = base.split(v, "=")
                    if #temp == 2 then
                        rpostArgs[tostring(base.trim(temp[1]))] = base.trim(temp[2])
                    end
                end
            end
            if next(rpostArgs) then
                for k, v in pairs(rpostArgs) do
                    args[k] = v
                end
            else
                log:info("rpostArgs is empty")
            end
        end
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
local function getCookie(param)
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
            local kvs = base.split(value, "=")
            if #kvs == 1 then
                table.insert(cookie_table, value)
            elseif #kvs == 2 then
                cookie_table[base.trim(kvs[1])] = base.trim(kvs[2])
            end
        end
    end

    if param then
        return cookie_table[param]
    end

    return cookie_table
end


--[[
    @comment 并发访问多个后端服务(最多15个),只支持json格式数据
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
    local container = { ht1, ht2, ht3, ht4, ht5, ht6, ht7, ht8, ht9, ht10, ht11, ht12, ht13, ht14, ht15 }

    local flag
    for key, value in pairs(container) do
        if value.status == ngx.HTTP_OK then
            if value.header["Content-Encoding"] == "gzip" then
                local zlib = gzip.inflate()
                local stream = zlib(value.body)
                flag, value = pcall(function() return json.decode(stream) end)
            else
                flag, value = pcall(function() return json.decode(value.body) end)
            end

            if flag then
                container[key] = value
            else
                container[key] = value.body
            end
        else
            container[key] = nil
        end
    end

    return container[1], container[2], container[3], container[4], container[5], container[6], container[7], container[8], container[9], container[10], container[11], container[12], container[13], container[14], container[15]
end

--[[
    @comment 访问单个后端服务
    @param string url
    @param table post 默认get请求,post不为空则为post请求
    @return table|nil
]]
local function getCapture(url, method)
    if not url then
        return nil, "param error"
    end
    local http_method = ngx.HTTP_GET
    if method and method == "post" then
        http_method = ngx.HTTP_POST
    end


    local http_result = ngx.location.capture(url, { method = http_method })
    if http_result.status ~= ngx.HTTP_OK then
        log:info("getCapture error:" .. url)
        return nil
    end

    local result, flag = {}
    if http_result.header["Content-Encoding"] == "gzip" then
        local zlib = gzip.inflate()
        local stream = zlib(http_result.body)
        flag, result = pcall(function() return json.decode(stream) end)
    else
        flag, result = pcall(function() return json.decode(http_result.body) end)
    end

    -- json decode error
    if not flag then
        result = http_result.body
    end

    return result
end



Http.getParam = getParam
Http.cookie = getCookie
Http.getCapture = getCapture
Http.getMultiCapture = getMultiCapture

return Http
