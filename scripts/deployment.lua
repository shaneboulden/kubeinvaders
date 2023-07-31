loadfile("/usr/local/openresty/nginx/conf/kubeinvaders/cheat-code.lua")

local https = require "ssl.https"
local ltn12 = require "ltn12"
local json = require "lunajson"

local arg = ngx.req.get_uri_args()
local config = require "config_kubeinv"

local arg = ngx.req.get_uri_args()
local k8s_url = ""

if os.getenv("KUBERNETES_SERVICE_HOST") then
  k8s_url = "https://" .. os.getenv("KUBERNETES_SERVICE_HOST") .. ":" .. os.getenv("KUBERNETES_SERVICE_PORT_HTTPS")
else
  k8s_url = os.getenv("ENDPOINT")
end

local token = os.getenv("TOKEN")
local namespace = arg['namespace']

ngx.header['Access-Control-Allow-Origin'] = '*'
ngx.header['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
ngx.header['Access-Control-Allow-Headers'] = 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range'
ngx.header['Access-Control-Expose-Headers'] = 'Content-Length,Content-Range';

-- Now make a request to create a new deployment
local url = k8s_url.. "/apis/apps/v1/namespaces/" .. namespace  .. "/deployments/log4shell-app"
ngx.log(ngx.INFO, "Deleting infected deployment in namespace " .. namespace)

local resp = {}

local headers = {
    ["Accept"] = "*/*",
    ["Content-Type"] = "application/json",
    ["Authorization"] = "Bearer " .. token
}

local ok, statusCode, headers, statusText = https.request{
  url = url,
  headers = headers,
  method = "DELETE",
  sink = ltn12.sink.table(resp)
}

ngx.log(ngx.INFO, ok)
ngx.log(ngx.INFO, statusCode)
ngx.log(ngx.INFO, statusText)
ngx.say("cheat code")
