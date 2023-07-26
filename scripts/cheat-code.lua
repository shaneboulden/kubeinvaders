loadfile("/usr/local/openresty/nginx/conf/kubeinvaders/cheat-code.lua")
ngx.log(ngx.INFO, "Cheat code activated, executing a command!")

local handle = os.execute("whoami")

ngx.say("cheat code")