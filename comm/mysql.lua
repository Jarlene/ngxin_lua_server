local mysql = require "resty.mysql"
local db = require "conf.database"
local runtime = require "conf.runtime"

local MySQL = {}

--建立连接
function MySQL:getClient(database)

    if not database then
        database = runtime.DATABASE
    end

    if ngx.ctx[database] then
        return ngx.ctx[database]
    end

    local client, errmsg = mysql:new()

    if not client then
        return nil
    end

    local dbConf = db[database][runtime.RUNTIME]
    local hosts_num = #dbConf.hosts
    local options, result, errmsg = {}, {}, ""

    for i = 1, hosts_num do

        client:set_timeout(dbConf.timeout)

        options = {
            host = dbConf.hosts[i],
            port = dbConf.port,
            database = dbConf.database,
            user = dbConf.username,
            password = dbConf.password,
            max_packet_size = 1024 * 1024
        }

        result, errmsg = client:connect(options)

        if not result then
        else
            client:query("SET NAMES utf8")
            ngx.ctx[database] = client
            return ngx.ctx[database]
        end
    end

    return nil
end

--执行查询
function MySQL:query(query, database)

    local client = self:getClient(database)

    if not client then
        return nil
    end

    local ret = {}
    local result, errmsg, errno = client:query(query)
    if not result then
        return nil
    end

    if errmsg ~= "again" then
        ret = result
    else
        table.insert(ret, result)
        while errmsg == "again" do
            result, errmsg, errno = client:read_result()
            table.insert(ret, result)
        end
    end
    return ret
end

--关闭连接
function MySQL:close(database)
    if not database then
        database = runtime.DATABASE
    end
    if ngx.ctx[database] then
        local client = ngx.ctx[database]
        client:close()
        ngx.ctx[database] = nil
        client = nil
    end
end


return MySQL
