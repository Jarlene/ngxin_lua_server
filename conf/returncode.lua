--
-- Created by IntelliJ IDEA.
-- User: jarlene
-- Date: 2018/2/24
-- Time: 下午6:09
-- To change this template use File | Settings | File Templates.
--

local return_code = {
    SUCCESS = {
        code = 22000,
        msg = 'success'
    },

    --系统错误 10000-20000
    SYSTEM = {
        DBError = {code = 10000, msg = "can not connect database"},
        RedisError = {code = 10001, msg = "can not connect redis"},
        ReadTimeout = {code = 10002, msg = "read time out, please check network"},
        WriteTimeout = {code = 10003, msg = "write time out, please check network"},
        ReadFail = {code = 10004, msg = "read fail, please check network"},
        WriteFail = {code = 10005, msg = "write fail, please check network"},
    },

    --业务错误 30000-40000
    BUSINESS = {
        UriError = {code = 30001, msg = "Uri error"},
        MethodError = {code = 30002, msg = "no method for request"},
        ParamError = {code = 30002, msg = "param is error"},
        NoCookie = {code = 30003, msg = "can not get cookie"},
        TokenError = {code = 30004, msg="token is expired, Please login again"},
        NoUser = {code = 30005, msg = "no user exist, please login with correct account"},
        RegisterError = {code = 30006, msg = "email or user name or password is null, please try again"},
        HasRegisterError = {code = 30007, msg = "the email has register, please login"},
        LoginError = {code=30008, msg = "please input correct username and password"},
        ChangePassError = {code = 30009, msg="new password can not be null, please try again" },
        NoLoginError = {code = 30010, msg="user not login please login and try again"},
        NoBook = {code=30011, msg="the user has no book"},
        AlreadyHas = {code=30012, msg="already has this book"},
        RepeatFav ={code=30013, msg="repeat fav books"},
        CheckError = {code=30014, msg="check update error"},
        NONeedUpdate = {code=30015, msg="no need update"},
    },

}

return return_code
