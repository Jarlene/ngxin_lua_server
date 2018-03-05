--
-- Created by IntelliJ IDEA.
-- User: jarlene
-- Date: 2018/3/5
-- Time: 下午12:56
-- To change this template use File | Settings | File Templates.
--

local log = ngx.log
local ERR = ngx.ERR
local INFO = ngx.INFO
local WARN = ngx.WARN
local DEBUG = ngx.DEBUG



local Log = {}

function Log:info(...)
    log(INFO, "[info]: ", ...)
end

function Log:debug(...)
    log(DEBUG, '[debug]: ', ...)
end

function Log:warn(...)
    log(WARN, '[warn]: ', ...)
end

function Log:error(...)
    log(ERR, '[error]: ', ...)
end

return Log