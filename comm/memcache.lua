local memcache = require "resty.memcached"
local memcache_conf = require "conf.memcache"
local runtime = require "conf.runtime"
local host_conf = memcache_conf["host"][runtime.RUNTIME]
local weight = memcache_conf["node_num"][runtime.RUNTIME]

local Memcached = {
    _node = {},
    _key = ""
}

--建立连接
function _connect(ip, port)
    local client, err = memcache:new()

    if not client then
        return nil
    end

    client:set_timeout(1000)


    local result, err = client:connect(ip, port)
    if not result then
        return nil
    end

    return client
end

--一致性hash
function _lookup(key)
    local selected_server, selected_weight, current_weight;

    for server, weight in pairs(Memcached._node) do
        current_weight = ngx.md5(server .. "_" .. key)
        current_weight = ngx.crc32_short(current_weight)
        current_weight = current_weight / weight

        if not selected_weight or selected_weight > current_weight then
            selected_server = server
            selected_weight = current_weight
        end
    end

    local i, j = string.find(selected_server, ":")
    local ip = string.sub(selected_server, 1, i - 1)
    local port = string.sub(selected_server, i + 1)

    return ip, port
end

--获取memcache实例
function Memcached:getMemcache(key)
    if not host_conf or #host_conf == 0 then
        return nil
    end

    for key, host in pairs(host_conf) do
        Memcached._node[host] = weight
    end

    local ip, port, mem_key, client

    for i = 1, 2 do
        ip, port = _lookup(key)
        mem_key = ip .. "_" .. port
        Memcached._key = mem_key

        if ngx.ctx[mem_key] then
            return ngx.ctx[mem_key]
        end

        client = _connect(ip, port)

        if not client then
            Memcached._node[ip .. ":" .. port] = 1
        else
            break
        end
    end

    if client then
        --local ok,err = client:set_keepalive(60000, 2)
        --if not ok then
        --    ngx.print(err)
        --    ngx.exit(0)
        --end
        ngx.ctx[mem_key] = client

        return client
    else
        return nil
    end
end

--获取缓存
function Memcached:get(key)
    local object = self:getMemcache(key)
    if not object then
        return nil
    end


    local result = object:get(key)
    if not result then
        return nil
    end

    ngx.ctx[Memcached._key] = nil

    return result
end

--[[
    @comment 获取多key的缓存
    @return bool|table
]]
function Memcached:getMulti(keys)
    if type(keys) ~= 'table' then
        return false
    end

    local valueArray = {}
    local servers = {}
    local server = nil
    local ip, port, mem_key, client

    for index, key in pairs(keys) do
        valueArray[key] = false
        ip, port = _lookup(key)
        server = ip .. ':' .. port
        servers[server] = servers[server] or {}
        table.insert(servers[server], key)
    end

    for server, keys in pairs(servers) do
        local i, _ = string.find(server, ":")
        ip = string.sub(server, 1, i - 1)
        port = string.sub(server, i + 1)
        for i = 1, 2 do
            mem_key = ip .. "_" .. port
            Memcached._key = mem_key

            if ngx.ctx[mem_key] then
                client = ngx.ctx[mem_key]
            else
                client = _connect(ip, port)
            end

            if not client then
                Memcached._node[server] = 1
            else
                if not ngx.ctx[mem_key] then
                    ngx.ctx[mem_key] = client
                    break
                else
                    break
                end
            end
        end

        if client then
            local results = client:get(keys)
            for key, value in pairs(results) do
                valueArray[key] = value
            end
        end
    end

    return servers[server]
end

--设置缓存
function Memcached:set(key, value, exptime)
    local object = self:getMemcache(key)
    if not object then
        return nil
    end


    local result = object:set(key, value, exptime)

    if not result then
        return nil
    end

    ngx.ctx[Memcached._key] = nil

    return result
end

--关闭连接
--function Memcached:close()
--    if ngx.ctx[MySQL] then
--        ngx.ctx[MySQL]:set_keepalive(0,100)
--        ngx.ctx[MySQL] = nil
--    end
--end

return Memcached
