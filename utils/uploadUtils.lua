local cjson = require("cjson.safe");

local uploadUtils = {};
local tz = 28800000;

local log_err
if ngx then
    log_err = function(...)
        ngx.log(ngx.ERR, ...)
    end
else
    log_err = function(...)
        print(...)
    end
end
function uploadUtils.check(args_data)
    local return_data={};
    local check_data={};
    return_data['return_code']=0;
    return_data['return_message']='success';
    -- basic check
	if args_data['ak'] == nil or args_data['ak'] == "" then
        return_data['return_code']=-10001;
        return_data['return_message']='ak is null or does not exist';
        return return_data,check_data;
    elseif args_data['pl'] == nil or args_data['pl'] == "" then 
        return_data['return_code']=-10001;
        return_data['return_message']='pl is null or does not exist';
        return return_data,check_data;
    elseif args_data['debug']~=nil and type(args_data['debug']) ~= "number" then
        return_data['return_code']=-10001;
        return_data['return_message']='debug is null or does not exist, debug must be number type';
        return return_data,check_data;
    end
    -- usr,evt,pl,ss,se check
    local event_data = args_data['pr'];
    local usr = args_data['usr'];
    local return_data_pr = {}
    if args_data['dt']=='usr' then
        return_data_pr=uploadUtils.checkUsr(usr,event_data);
    elseif args_data['dt']=='evt' then
        return_data_pr=uploadUtils.checkEvt(usr,event_data);
    elseif args_data['dt']=='abp' then
        return_data_pr=uploadUtils.checkAbp(usr,event_data);
    elseif args_data['dt']=='pl' then
        return_data_pr=uploadUtils.checkPl(usr,event_data);
    else
        return_data['return_code']=-10001;
        return_data['return_message']='dt is null or does not exist'; 
        return return_data,check_data;
    end
    -- check info sum
    for key,value in pairs(return_data_pr)
    do
       return_data[key]=value;
    end
    -- 
    -- print("args_data ",cjson.encode(args_data))
    -- print("return_data ",cjson.encode(return_data))
    check_data=uploadUtils.init(args_data);
    -- print("check_data ",cjson.encode(check_data))
    return return_data,check_data;
end

function uploadUtils.checkUsr(usr,event_data)
    local return_data={};
    return_data['return_code']=0;
    return_data['return_message']='success';
    local cuid=event_data['$cuid'];
    local ct = event_data['$ct'];
    -- error
    if cuid==nil or cuid=="" then
        return_data['return_code']=-10001;
        return_data['return_message']='$cuid is null or does not exist';
        return return_data;
    elseif ct==nil or ct=="" or type(ct) ~="number" then
        return_data['return_code']=-10001;
        return_data['return_message']='$ct is null or does not exist, ct must be number type';
        return return_data;
    end
    -- warn
    if usr == nil or usr['did'] == nil or usr['did'] == "" then 
        return_data['return_code']=0;
        return_data['return_message']='did is null or does not exist';
        return_data['warn_did']='did is null, will have some impact on statistics';
    end
    return return_data;
end
function uploadUtils.checkAbp( usr,event_data )
    -- body
    local return_data=uploadUtils.checkEvt(usr,event_data);
    local return_code_evt=return_data['return_code'];
    local eid = event_data['$eid'];

    -- 收入分析
    if return_code_evt == 0 and eid == "revenue" then
        local price=event_data['$price'];
        local product_quantity=event_data['$productQuantity'];
        if price==nil or price=="" or type(price) ~="number" then
            return_data['return_code']=-10001;
            return_data['return_message']='$price is null or does not exist, $price must be number type';
            return return_data;
        elseif product_quantity==nil or product_quantity=="" or type(product_quantity) ~="number" then
            return_data['return_code']=-10001;
            return_data['return_message']='$productQuantity is null or does not exist, $productQuantity must be number type';
            return return_data;
        end
    end
    return return_data;
end
function uploadUtils.checkEvt(usr,event_data)
    local return_data={};
    return_data['return_code']=0;
    return_data['return_message']='success';
    local cuid=event_data['$cuid'];
    local ct = event_data['$ct'];
    local eid = event_data['$eid'];
    local sid = event_data['$sid'];
    -- custom
    local cr = event_data['$cr'];
    local ov = event_data['$ov'];
    local net = event_data['$net'];
    local browser_version = event_data['$browser_version'];
    -- error
    if (cuid==nil or cuid=="") and (usr == nil or usr['did'] == nil or usr['did'] == "") then
        return_data['return_code']=-10001;
        return_data['return_message']='$cuid,did cannot be empty at the same time';
        return return_data;
    elseif ct==nil or ct=="" or type(ct) ~="number" then
        return_data['return_code']=-10001;
        return_data['return_message']='$ct is null or does not exist, ct must be number type';
        return return_data;
    elseif eid==nil or eid=="" then
        return_data['return_code']=-10001;
        return_data['return_message']='$eid is null or does not exist';
        return return_data;
    elseif sid~=nil and type(sid) ~= "number" then
        return_data['return_code']=-10001;
        return_data['return_message']='$sid is null or does not exist, sid must be number type';
        return return_data;
    elseif cr ~=nil and type(cr) ~= "number" then
        return_data['return_code']=-10001;
        return_data['return_message']='$cr must be number type';
        return return_data;
    elseif ov ~=nil and type(ov) ~= "number" then
        return_data['return_code']=-10001;
        return_data['return_message']='$ov must be number type';
        return return_data;
    elseif net ~=nil and type(net) ~= "number" then
        return_data['return_code']=-10001;
        return_data['return_message']='$net must be number type';
        return return_data;
    elseif browser_version ~=nil and type(browser_version) ~= "number" then
        return_data['return_code']=-10001;
        return_data['return_message']='$browser_version must be number type';
        return return_data;
   end

    -- warn
    if usr == nil or usr['did'] == nil or usr['did'] == "" then 
        return_data['return_code']=0;
        return_data['return_message']='did is null or does not exist';
        return_data['warn_did']='did is null, will have some impact on statistics';
    elseif sid == nil or sid == "" then 
        return_data['return_code']=0;
        return_data['return_message']='sid is null or does not exist';
        return_data['warn_sid']='sid is null, will have some impact on statistics';
    end
    return return_data;
end

function uploadUtils.checkPl( usr,event_data )
    -- body
    local return_data={};
    return_data['return_code']=0;
    return_data['return_message']='success';
    local ct = event_data['$ct'];
    -- error
    if ct==nil or ct=="" then
        return_data['return_code']=-10001;
        return_data['return_message']='$ct is null or does not exist';
        return return_data;
    elseif usr == nil or usr['did'] == nil or usr['did'] == "" then 
        return_data['return_code']=-10001;
        return_data['return_message']='did is null or does not exist';
        return return_data;
    end
    return return_data;
end

function uploadUtils.init(args_data)
    -- ak
    -- debug
    -- pl
    -- usr.did
    -- ut

    -- init basic
    local init_data = args_data;
    local cuid = args_data['pr']['$cuid'];
    init_data['owner']='zg';
    init_data['sdk']='zg_server';
    init_data['sdkv']='0.0.2';
    init_data['sln']='itn';
    init_data['tz']=tz;
    init_data['ut']=os.date('%Y-%m-%d %H:%M:%S');
    if init_data['debug']==nil then
        init_data['debug']=0;
    end
    if init_data['usr']==nil or init_data['usr']['did'] == nil or init_data['usr']['did'] == "" then
        init_data['usr']={
            did=cuid
        }
    end
    -- init event pr
    local ct = args_data['pr']['$ct'];
    local sid = init_data['pr']['$sid'];
    if (sid==nil or sid =="") and (ct~=nil and ct~="" and type(ct) =="number")  then
        local _year = os.date("%Y",ct/1000)
        local _month = os.date("%m",ct/1000)
        local _day = os.date("%d",ct/1000)
        local _hour = os.date("%H",ct/1000)
        local temp_date_time={year=_year, month=_month, day=_day, hour=_hour};
        local temp_sid=os.time(temp_date_time)*1000;
        init_data['pr']['$sid']=temp_sid;
    end
    
    init_data['pr']['$tz']=tz;
    local sid = init_data['pr']['$sid'];
    if sid==nil or sid =="" then
        local temp_date=os.date("*t");
        local temp_date_time={year=temp_date.year, month=temp_date.month, day=temp_date.day, hour=temp_date.hour};
        local temp_sid=os.time(temp_date_time)*1000;
        init_data['pr']['$sid']=temp_sid;
    end
    -- init收入分析
    local eid=init_data['pr']['$eid'];
    if eid == "revenue" then
        local price = init_data['pr']['$price'];
        local product_quantity = init_data['pr']['$productQuantity'];
        local total = price*product_quantity;
        init_data['pr']['$total']=total;
    end
    -- 
    local pr = init_data['pr'];
    init_data['pr']=nil;
    local temp_pr = {}
    for key,value in pairs(pr)
    do
        if key:match("^($)") then
            temp_pr[key]=value; 
        else
            temp_pr['_'..key]=value;
        end
    end
    -- Standard structure
    local data_array={{
        pr=temp_pr,
        dt=init_data['dt']
    }}
    init_data['dt']=nil;
    init_data['data']=data_array;
    return init_data;
end
-- local testUsr = cjson.decode('{ "ak": "13aee7324a544935af772d5065f1c913", "dt": "usr", "pr": { "$an": "ZhugeDemo", "$cn": "zhuge", "$cr": "46002", "$ct": 1491812561821, "$cuid": "123", "$sid": "1491812561821", "$os": "Android", "$tz": 28800000, "$vn": "1.0", "信息网": "我没有", "小游戏": "我默默", "我妈妈": " 小游戏" }, "debug": 1, "owner": "zg", "pl": "and", "sdk": "zg_android", "sdkv": "3.0.0_b", "sln": "itn", "tz": 28800000, "ut": "2017-04-10 16:22:46" }');
-- local testEvt = cjson.decode('{ "ak": "13aee7324a544935af772d5065f1c913", "dt": "evt", "pr": { "$an": "ZhugeDemo", "$cn": "zhuge", "$cr": "46002", "$ct": 1491812561821, "$cuid": "123", "$eid":"abcd", "$os": "Android", "$tz": 28800000, "$vn": "1.0", "信息网": "我没有", "小游戏": "我默默", "我妈妈": " 小游戏" }, "debug": 0, "owner": "zg", "pl": "and", "sdk": "zg_android", "sdkv": "3.0.0_b", "sln": "itn", "tz": 28800000, "usr": { "did": "7df321978522f95327c2c413c0405c0e" }, "ut": "2017-04-10 16:22:46" }');
-- local r,c=uploadUtils.check(testUsr);
-- print(cjson.encode(r))
return uploadUtils;


-- https://docs.google.com/document/d/1rB5KwIyHB98RkAyHyBJKwU_FBmQWUbikAKvjHlUEzYE/edit
-- {
--   "ak": "13aee7324a544935af772d5065f1c913",
--   "data": [
--     {
--       "dt": "usr",
--       "pr": {
--         "$an": "ZhugeDemo",
--         "$cn": "zhuge",
--         "$cr": "46002",
--         "$ct": 1491812561821,
--         "$cuid": "",
--         "$sid": "1491812561821",
--         "$os": "Android",
--         "$tz": 28800000,
--         "$vn": "1.0",
--         "_信息网": "我没有",
--         "_小游戏": "我默默",
--         "_我妈妈": " 小游戏"
--       }
--     }
--   ],
--   "debug": 0,
--   "owner": "zg",
--   "pl": "and",
--   "sdk": "zg_android",
--   "sdkv": "3.0.0_b",
--   "sln": "itn",
--   "tz": 28800000,
--   "usr": {
--     "did": "7df321978522f95327c2c413c0405c0e"
--   },
--   "ut": "2017-04-10 16:22:46"
-- }
-- 
-- { "ak": "f4d77df8fe904833b0afdd4458dd2dd4", "dt": "evt", "pl": "and", "debug": 0, "ip": "10.0.0.16", "pr": { "$ct": 1491812561821, "$eid": "事件名称", "$cuid": "123@zhugeio.com", "$sid": 1491812519004, "$vn": "1.0", "$cn": "zhuge", "$cr": 46002, "$os": "Android", "$ov": 5, "$net": 1 ,"事件属性名1": "事件属性值1", "事件属性名2": "事件属性值2" }, "usr": { "did": "7df321978522f95327c2c413c0405c0e" } }





