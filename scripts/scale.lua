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
local replicas = arg['replicas']

ngx.header['Access-Control-Allow-Origin'] = '*'
ngx.header['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
ngx.header['Access-Control-Allow-Headers'] = 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range'
ngx.header['Access-Control-Expose-Headers'] = 'Content-Length,Content-Range';

-- Now make a request to create a new deployment
local url = k8s_url.. "/apis/apps/v1/namespaces/" .. namespace  .. "/deployments/log4shell-app"
ngx.log(ngx.INFO, "Scaling replicas for log4shell-app to " .. replicas .. " in namespace " .. namespace)

local resp = {}

local body = [[
    {
        "spec": {
          "replicas": ]] .. replicas .. [[
        }
    }
]]

local headers = {
    ["Accept"] = "application/json",
    ["Content-Type"] = "application/strategic-merge-patch+json",
    ["Authorization"] = "Bearer " .. token,
    ["Content-Length"] = string.len(body)
}

local ok, statusCode, headers, statusText = https.request{
  url = url,
  headers = headers,
  method = "PATCH",
  sink = ltn12.sink.table(resp),
  source = ltn12.source.string(body)
}

ngx.log(ngx.INFO, ok)
ngx.log(ngx.INFO, statusCode)
ngx.log(ngx.INFO, statusText)
ngx.say("cheat code")
