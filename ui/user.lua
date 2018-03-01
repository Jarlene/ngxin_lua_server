--
-- Created by IntelliJ IDEA.
-- User: jarlene
-- Date: 2018/2/24
-- Time: 下午6:22
-- To change this template use File | Settings | File Templates.
--

local User = {}
local returncode = require "conf.returncode"
local function test()
    local res = { code = returncode.SUCCESS.code, msg = returncode.SUCCESS.msg }
    return res
end




User.test = test
return User
