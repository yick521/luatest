local ck = require "resty.cookie"

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

local cookie, err = ck:new()
if not cookie then
    log_err(ngx.ERR, err)
    return
end
local this={}
function this.set(k, v, path, host_name, secure, httponly, max_age)
	local ok, err = cookie:set({
        key = k, 
        value = v, 
        path = path,
        domain = host_name, 
        secure = secure, 
        httponly = httponly,
        max_age = max_age
        -- samesite = "Lax", 
        -- extension = "a4334aebaec"
    })
    if not ok then
    	log_err(ngx.ERR, err)
        return
    end
end

return this
