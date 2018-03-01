local database = {
    test = {
        hosts = { "127.0.0.1" },
        port = 3306,
        username = "root",  --用户名
        password = "root",  --密码
        timeout = 1000
    },
    dev = {
        hosts = { "127.0.0.1" },
        port = 3306,
        username = "root",
        password = "root",
        timeout = 1000
    },
    online = {
        hosts = { "127.0.0.1" },
        port = 3306,
        username = "root",
        password = "root",
        timeout = 1000
    },
}

return database
