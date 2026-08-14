--!strict

assert(plugin, "LiveOps Autopilot must run as a Studio plugin")

local Audit = require(script.Parent.Modules.Audit)
local Installer = require(script.Parent.Modules.Installer)

local toolbar = plugin:CreateToolbar("LiveOps Autopilot")
local open = toolbar:CreateButton("LiveOps", "Install and audit safe Roblox LiveOps controls", "rbxassetid://0")
open.ClickableWhenViewportHidden = true

local info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right, false, false, 480, 560, 340, 380)
local widget = plugin:CreateDockWidgetPluginGuiAsync("LiveOpsAutopilotWidget_v1", info)
widget.Title = "LiveOps Autopilot"

local root = Instance.new("Frame")
root.Size = UDim2.fromScale(1, 1)
root.BackgroundColor3 = Color3.fromRGB(20, 23, 29)
root.Parent = widget

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 12)
padding.PaddingBottom = UDim.new(0, 12)
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.Parent = root

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = root

local function label(text: string, height: number, bold: boolean?): TextLabel
    local item = Instance.new("TextLabel")
    item.Size = UDim2.new(1, 0, 0, height)
    item.BackgroundTransparency = 1
    item.TextColor3 = Color3.fromRGB(235, 238, 245)
    item.TextXAlignment = Enum.TextXAlignment.Left
    item.TextYAlignment = Enum.TextYAlignment.Top
    item.TextWrapped = true
    item.Font = if bold then Enum.Font.GothamBold else Enum.Font.Gotham
    item.TextSize = if bold then 18 else 14
    item.Text = text
    item.Parent = root
    return item
end

local function button(text: string): TextButton
    local item = Instance.new("TextButton")
    item.Size = UDim2.new(1, 0, 0, 40)
    item.BackgroundColor3 = Color3.fromRGB(70, 104, 238)
    item.TextColor3 = Color3.new(1, 1, 1)
    item.Font = Enum.Font.GothamBold
    item.TextSize = 14
    item.Text = text
    item.Parent = root
    Instance.new("UICorner", item).CornerRadius = UDim.new(0, 8)
    return item
end

label("Ship events and kill switches without republishing the whole experience.", 48, true)
local status = label("Audit the current place or install the safe scaffold.", 38)
local auditButton = button("Audit LiveOps readiness")
local installButton = button("Install LiveOps foundation")
local report = label("", 330)

local function runAudit()
    local findings = Audit.scan()
    local passes, warnings, failures = Audit.summary(findings)
    status.Text = string.format("%d pass · %d warning · %d fail", passes, warnings, failures)
    local lines = {}
    for _, finding in findings do
        table.insert(lines, string.format("[%s] %s\n%s", finding.severity, finding.code, finding.message))
    end
    report.Text = table.concat(lines, "\n\n")
end

auditButton.MouseButton1Click:Connect(runAudit)
installButton.MouseButton1Click:Connect(function()
    local changes = Installer.install()
    status.Text = if #changes > 0 then table.concat(changes, " · ") else "LiveOps foundation already installed."
    runAudit()
end)
open.Click:Connect(function()
    widget.Enabled = not widget.Enabled
    if widget.Enabled then runAudit() end
end)
