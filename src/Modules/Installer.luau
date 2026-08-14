--!strict

local ChangeHistoryService = game:GetService("ChangeHistoryService")

local Installer = {}

local DEFAULTS_SOURCE = [=[--!strict
-- Safe local fallbacks. Experience Configs override these values at runtime.
return {
    kill_switch = false,
    feature_event_enabled = false,
    event_multiplier = 1,
    event_name = "",
    announcement = "",
}
]=]

local RUNTIME_SOURCE = [=[--!strict
local ConfigService = game:GetService("ConfigService")
local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Defaults = require(ReplicatedStorage:WaitForChild("LiveOpsDefaults"))
local event = ReplicatedStorage:FindFirstChild("LiveOpsEvent") or Instance.new("RemoteEvent")
event.Name = "LiveOpsEvent"
event.Parent = ReplicatedStorage

local state = table.clone(Defaults)
local TOPIC = "liveops-command-v1"

local function refresh(reason: string)
    local ok, snapshot = pcall(function()
        return ConfigService:GetConfigAsync()
    end)
    if not ok then
        warn("[LiveOps] Config refresh failed; keeping last safe state")
        return false
    end

    for key, fallback in Defaults do
        local valueOk, value = pcall(function()
            return snapshot:GetValue(key)
        end)
        if valueOk and value ~= nil and typeof(value) == typeof(fallback) then
            state[key] = value
        end
    end

    event:FireAllClients("state", table.clone(state), reason)
    return true
end

local function handleMessage(message)
    if type(message.Data) ~= "table" then
        return
    end
    local kind = message.Data.kind
    if kind == "refresh" then
        refresh("messaging")
    elseif kind == "announcement" and type(message.Data.text) == "string" then
        local text = string.sub(message.Data.text, 1, 240)
        event:FireAllClients("announcement", {text = text})
    end
end

refresh("server_start")

task.spawn(function()
    local ok, connection = pcall(function()
        return MessagingService:SubscribeAsync(TOPIC, handleMessage)
    end)
    if not ok then
        warn("[LiveOps] Messaging subscription unavailable; Experience Config polling remains active")
        return
    end
    script.Destroying:Connect(function()
        connection:Disconnect()
    end)
end)

task.spawn(function()
    while true do
        task.wait(60)
        refresh("poll")
    end
end)

event.OnServerEvent:Connect(function(player, kind)
    if kind == "request_state" then
        event:FireClient(player, "state", table.clone(state), "client_request")
    end
end)
]=]

local function ensure(parent: Instance, className: string, name: string): Instance
    local existing = parent:FindFirstChild(name)
    if existing then return existing end
    local created = Instance.new(className)
    created.Name = name
    created.Parent = parent
    return created
end

function Installer.install(): {string}
    ChangeHistoryService:SetWaypoint("LiveOps Autopilot before install")
    local changes = {}
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local serverScriptService = game:GetService("ServerScriptService")

    local defaults = ensure(replicatedStorage, "ModuleScript", "LiveOpsDefaults") :: ModuleScript
    if defaults.Source == "" then
        defaults.Source = DEFAULTS_SOURCE
        table.insert(changes, "Created LiveOpsDefaults")
    end

    local runtime = ensure(serverScriptService, "Script", "LiveOpsRuntime") :: Script
    if runtime.Source == "" then
        runtime.Source = RUNTIME_SOURCE
        table.insert(changes, "Created LiveOpsRuntime")
    end

    ChangeHistoryService:SetWaypoint("LiveOps Autopilot install")
    return changes
end

return Installer
