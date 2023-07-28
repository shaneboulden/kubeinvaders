loadfile("/usr/local/openresty/nginx/conf/kubeinvaders/cheat-code.lua")

local https = require "ssl.https"
local ltn12 = require "ltn12"
local json = require "lunajson"

local arg = ngx.req.get_uri_args()
local config = require "config_kubeinv"

local http = require("socket.http")
math.randomseed(os.clock()*100000000000)
local rand = math.random(999, 9999)
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
local url = k8s_url.. "/apis/apps/v1/namespaces/" .. namespace  .. "/deployments/"
ngx.log(ngx.INFO, "Creating a new deployment in namespace " .. namespace)

local resp = {}

local body = [[
    {
        "apiVersion": "apps/v1",
        "kind": "Deployment",
        "metadata": {
          "labels": {
            "app": "log4shell-app",
            "app.kubernetes.io/component": "log4shell-app",
            "app.kubernetes.io/instance": "log4shell-app",
            "app.kubernetes.io/name": "log4shell-app",
            "app.kubernetes.io/part-of": "log4shell-app"
          },
          "name": "log4shell-app"
        },
        "spec": {
          "progressDeadlineSeconds": 600,
          "replicas": 0,
          "revisionHistoryLimit": 10,
          "selector": {
            "matchLabels": {
              "app": "log4shell-app"
            }
          },
          "strategy": {
            "rollingUpdate": {
              "maxSurge": "25%",
              "maxUnavailable": "25%"
            },
            "type": "RollingUpdate"
          },
          "template": {
            "metadata": {
              "annotations": null,
              "labels": {
                "app": "log4shell-app",
                "deployment": "log4shell-app"
              }
            },
            "spec": {
              "containers": [
                {
                  "image": "quay.io/smileyfritz/log4shell-app:v0.5",
                  "imagePullPolicy": "IfNotPresent",
                  "name": "log4shell-app",
                  "ports": [
                    {
                      "containerPort": 8080,
                      "protocol": "TCP"
                    }
                  ],
                  "resources": {},
                  "terminationMessagePath": "/dev/termination-log",
                  "terminationMessagePolicy": "File"
                }
              ],
              "dnsPolicy": "ClusterFirst",
              "restartPolicy": "Always",
              "schedulerName": "default-scheduler",
              "securityContext": {},
              "terminationGracePeriodSeconds": 30
            }
          }
        }
      }
]]

local headers = {
    ["Accept"] = "*/*",
    ["Content-Type"] = "application/json",
    ["Authorization"] = "Bearer " .. token,
    ["Content-Length"] = string.len(body)
}

local ok, statusCode, headers, statusText = https.request{
  url = url,
  headers = headers,
  method = "POST",
  sink = ltn12.sink.table(resp),
  source = ltn12.source.string(body)
}

ngx.log(ngx.INFO, ok)
ngx.log(ngx.INFO, statusCode)
ngx.log(ngx.INFO, statusText)
ngx.say("cheat code")
