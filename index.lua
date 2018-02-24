json = require 'cjson'
local returncode = require 'conf.returncode'
local catelog = require 'conf.catelog'
local runtimeconf = require 'conf.runtime'

--路由分发
local dir = catelog[runtimeconf.RUNTIME][1]
local prefix_uri = string.sub(ngx.var.uri, 1, length(dir))

if prefix_uri ~= dir then
    ngx.print(json.encode(returncode.BUSINESS.UriError))
    ngx.exit(0)
end

local suffix_uri = string.sub(ngx.var.uri, length(dir) + 1)
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


