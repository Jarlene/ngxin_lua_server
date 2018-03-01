--
-- Created by IntelliJ IDEA.
-- User: jarlene
-- Date: 2018/2/24
-- Time: 下午6:22
-- To change this template use File | Settings | File Templates.
--

local User = {}
local returncode = require "conf.returncode"
local http = require "comm.http"

local function test()
    local res = { code = returncode.SUCCESS.code, msg = returncode.SUCCESS.msg }
    return res
end

local function ipsearch()
    local ip = http.getParam("ip")
    if not ip then
        return returncode.BUSINESS.ParamError
    end

    local url = "/ipsearch?format=json&ip=" .. ip
    local r = http.getCapture(url)
    if not r or type(r) ~= 'table' or not r.ret  or r.ret ~= 1 then
        return returncode.BUSINESS.UriError
    end
    local result = {}
    result.country = r.country
    result.province = r.province
    result.city = r.city
    result.district = r.district
    result.isp = r.isp
    local res = { code = returncode.SUCCESS.code, msg = returncode.SUCCESS.msg, data = result }
    return res
end



User.test = test
User.ipsearch = ipsearch
return User
