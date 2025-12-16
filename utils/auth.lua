local basexx = require "utils.basexx"

local auth = {};

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

function auth.get(authorization)
	if not authorization then
		return nil,nil;
	end
	local userpass_b64 = authorization:match("Basic%s+(.*)")
	if not userpass_b64 then
		return nil,nil;
	end
	local userpass = basexx.from_base64(userpass_b64)
	if not userpass then
		return nil,nil;
	end

	local username, password = userpass:match("([^:]*):(.*)")
	if not (username and password) then
		return nil,nil;
	end
	return username,password;
end

-- print(auth.get("Basic QXBwS2V5OlNlY3JldEtleQ=="))
return auth;
