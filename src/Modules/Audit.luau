--!strict

export type Finding = {
    severity: "PASS" | "WARN" | "FAIL",
    code: string,
    message: string,
}

local Audit = {}

local function finding(severity: "PASS" | "WARN" | "FAIL", code: string, message: string): Finding
    return {severity = severity, code = code, message = message}
end

function Audit.scan(): {Finding}
    local out: {Finding} = {}
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local serverScriptService = game:GetService("ServerScriptService")

    local defaults = replicatedStorage:FindFirstChild("LiveOpsDefaults")
    if not defaults or not defaults:IsA("ModuleScript") then
        table.insert(out, finding("FAIL", "DEFAULTS_MISSING", "ReplicatedStorage.LiveOpsDefaults is missing."))
    else
        table.insert(out, finding("PASS", "DEFAULTS_OK", "Fallback config module exists."))
    end

    local runtime = serverScriptService:FindFirstChild("LiveOpsRuntime")
    if not runtime or not runtime:IsA("Script") then
        table.insert(out, finding("FAIL", "RUNTIME_MISSING", "ServerScriptService.LiveOpsRuntime is missing."))
    else
        table.insert(out, finding("PASS", "RUNTIME_OK", "LiveOps runtime exists."))
        local source = runtime.Source
        if string.find(source, "kill_switch", 1, true) and string.find(source, "ConfigService", 1, true) then
            table.insert(out, finding("PASS", "KILL_SWITCH_OK", "ConfigService kill switch path found."))
        else
            table.insert(out, finding("FAIL", "KILL_SWITCH_MISSING", "Runtime must consume a kill_switch Experience Config."))
        end
        if string.find(source, "SubscribeAsync", 1, true) then
            table.insert(out, finding("PASS", "MESSAGING_OK", "Cross-server LiveOps message listener found."))
        else
            table.insert(out, finding("WARN", "MESSAGING_MISSING", "No MessagingService listener found for external announcements/refresh."))
        end
    end

    local remote = replicatedStorage:FindFirstChild("LiveOpsEvent")
    if remote and remote:IsA("RemoteEvent") then
        table.insert(out, finding("PASS", "CLIENT_CHANNEL_OK", "Client LiveOps channel exists."))
    else
        table.insert(out, finding("WARN", "CLIENT_CHANNEL_RUNTIME", "LiveOpsEvent will be created safely by the server at runtime."))
    end

    return out
end

function Audit.summary(findings: {Finding}): (number, number, number)
    local passes, warnings, failures = 0, 0, 0
    for _, item in findings do
        if item.severity == "PASS" then passes += 1 elseif item.severity == "WARN" then warnings += 1 else failures += 1 end
    end
    return passes, warnings, failures
end

return Audit
