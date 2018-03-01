local runtimeconf = require 'conf.runtime'
local p = runtimeconf.PACKAGE_PATH
local m_package_path = package.path
package.path = string.format("%s?.lua;%s", p, m_package_path)
local c = runtimeconf.PACKAGE_CPATH
local c_path = package.cpath
package.cpath = string.format("%s?.so;%s", c, c_path)

json = require 'cjson'
local returncode = require 'conf.returncode'
local catelog = require 'conf.catelog'

--路由分发
local dir = catelog[runtimeconf.RUNTIME][1]
local dir_len = string.len(dir) + 1
local prefix_uri = string.sub(ngx.var.uri, 1, dir_len)
if prefix_uri ~= dir.."/" then
    ngx.print(json.encode(returncode.BUSINESS.UriError))
    ngx.exit(0)
end

local suffix_uri = string.sub(ngx.var.uri, dir_len + 1)
local i = string.find(suffix_uri, "%/")
local tmp_module = string.sub(suffix_uri, 1, i - 1)
local tmp_method = string.sub(suffix_uri, i + 1)

local file = "ui." .. tmp_module

tmp_module = require(file)

if not tmp_module[tmp_method] then
    ngx.print(json.encode(returncode.BUSINESS.MethodError))
    ngx.exit(0)
end

if ngx.req.get_uri_args()["callback"] then
    ngx.print("/**/" .. ngx.req.get_uri_args()["callback"] .. "(" .. json.encode(tmp_module[tmp_method]()) .. ");")
else
    ngx.print(json.encode(tmp_module[tmp_method]()))
end


