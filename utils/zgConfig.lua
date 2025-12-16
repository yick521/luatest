local broker_list = {
    { host = "test01-cdh1", port = 9092 },
    { host = "test01-cdh2", port = 9092 },
    { host = "test01-cdh3", port = 9092 }
};

-- config
local zgConfig = {
    broker_list=broker_list
}
return zgConfig;