local database = {

    iread8 = {
        test = {
            hosts = {"127.0.0.1"},
            port = 3306,
            database = "iread8",
            username = "root",
            password = "root",
            timeout= 1000
        },
        dev = {

        },
        online = {
            hosts = {"127.0.0.1"},
            port = 3306,
            database = "iread8",
            username = "root",
            password = "root",
            timeout= 1000
        },

    },
}

return database
