local R = {}

local redis = require "resty.redis"
local redisconf = require "conf.redis"
local runtimeconf = require "conf.runtime"

function _connect(ip, port)
    local key = ip .. ":" .. port

    if ngx.ctx[key] then
        return ngx.ctx[key]
    end

    local red = redis:new()
    if not red then
        return nil
    end

    red:set_timeout(1000)
    local ok, err = red:connect(ip, port)
    if not ok then
        return nil
    end

    ngx.ctx[key] = red
    return ngx.ctx[key]
end

function R:getRedis()

    local server = redisconf[runtimeconf.RUNTIME][1]
    if not server then
        return nil
    end

    local client = ngx.ctx[server]
    if client then
        return client
    end

    local i, j = string.find(server, ":")
    local ip = string.sub(server, 1, i - 1)
    local port = string.sub(server, i + 1)
    client = _connect(ip, port)

    if not client then
        return nil
    end

    return client
end

function R:get(key)
    local object = self:getRedis()
    if not object then
        return nil
    end

    local result = object:get(key)
    if not result or result == ngx.null then
        return nil
    end

    return result
end

function R:set(key, value, exp)
    local object = self:getRedis()

    if not object then
        return nil
    end


    local ok, err
    if exp then
        ok, err = object:set(key, value, "EX", exp)
    else
        ok, err = object:set(key, value)
    end

    if not ok then
        return nil
    end

    return ok
end

function R:del(key)
    local object = self:getRedis()

    if not object then
        return nil
    end

    local ok, err = object:del(key)
    if not ok then
        return nil
    end

    return ok
end

function R:close()
    local server = redisconf[runtimeconf.RUNTIME][1]
    if server then
        local client = ngx.ctx[server]
        client:close()
        ngx.ctx[server] = nil
    end
end

return R



