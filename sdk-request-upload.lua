-- ngx.header.content_type = "text/plain";
local cjson = require("cjson.safe");
local client = require("resty.kafka.client");
local producer = require("resty.kafka.producer");
local upload = require("utils.uploadUtils");
local auth = require("utils.auth");
local osnow = ngx.now() * 1000;
-- ngx.eof();
-- local broker_list = {
--     { host = "172.31.13.30", port = 9092 },
--     { host = "172.31.13.31", port = 9092 },
--     { host = "172.31.13.32", port = 9092 }
-- }
local zgConfig = require "utils.zgConfig"
local broker_list = zgConfig.broker_list;
-- local topic = "sdklua_test";
local topic = "sdklua_online";
local key = nil;
local headers = cjson.encode(ngx.req.get_headers());
local bodys = cjson.encode(ngx.req.get_body_data());
local args = "";
local method = ngx.req.get_method();
if "GET" == method then
    args = ngx.req.get_uri_args()
else
    ngx.req.read_body()
    args = ngx.req.get_post_args()
end
local data = args['data'];
if data == nil then
    ngx.req.read_body()
    data = ngx.req.get_body_data()
end
if data == nil then
    local return_data = {};
    return_data['return_code'] = -10002;
    return_data['return_message'] = 'data is null';
    ngx.say(cjson.encode(return_data));
    return ;
end
-- 
local data = cjson.decode(data);
if not data then
    local return_data = {};
    return_data['return_code'] = -10002;
    return_data['return_message'] = 'data structure error';
    ngx.say(cjson.encode(return_data));
    return ;
end

-- 
local username, password = auth.get(ngx.req.get_headers().authorization);
if not (username and password and username == data['ak']) then
    local return_data = {};
    return_data['return_code'] = -10002;
    return_data['return_message'] = 'authorization is error';
    ngx.say(cjson.encode(return_data));
    return ;
end

-- 
local return_data, check_data = upload.check(data);
if return_data['return_code'] < 0 then
    ngx.say(cjson.encode(return_data));
    return ;
end

-- 
local request_data = {
    method = "event_statis_srv.upload",
    event = cjson.encode(check_data),
    compress = "0"
}
local request_str = cjson.encode(request_data);

local myIP = ngx.req.get_headers()["X-Real-IP"]
if myIP == nil then
    myIP = ngx.req.get_headers()["x_forwarded_for"]
end
if myIP == nil then
    myIP = ngx.req.get_headers()["Proxy-Client-IP"]
end
if myIP == nil then
    myIP = ngx.req.get_headers()["WL-Proxy-Client-IP"]
end
if myIP == nil then
    myIP = ngx.req.get_headers()["http_x_forwarded_for"]
end
if myIP == nil or myIP == "-" then
    myIP = ngx.var.remote_addr
end
if check_data['ip'] ~= nil and check_data['ip'] ~= "" then
    myIP = check_data['ip'];
end
if type(myIP) == "table" then
    myIP = tostring(myIP[1])
end
local has_split = ngx.re.match(myIP, [[\,]], "o");
if has_split then
    myIP = string.match(myIP, "%d+[\\.]?%d+[\\.]?%d+[\\.]?%d+[\\.]?");
end
local res = {
    Now = osnow,
    Ip = myIP,
    Method = method,
    Header = headers,
    Args = request_str
}
local message = cjson.encode(res);

-- this is async producer_type and bp will be reused in the whole nginx worker
local error_handle = function(topic, partition_id, message_queue, index, err, retryable)
    ngx.log(ngx.ERR, "send err: topic=", topic, "   partition_id:,", partition_id, "    message_queue: ", #message_queue, " index:", index, "   err:", err, "   message: ", message)
end

local bp = producer:new(broker_list, { producer_type = "async", error_handle = error_handle, refresh_interval = 5000  })
local ok, err = bp:send(topic, key, message)
if not ok then
    ngx.say("send err:", err)
    return_code = -10001;
    return
end
-- ngx.say("send success, ok:", ok) 
ngx.say(cjson.encode(return_data));











