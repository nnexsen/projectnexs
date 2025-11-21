local Hook = {
    Players = {
        ["Killer"] = {Color = Color3.fromRGB(255, 93, 108), On = true},
        ["Survivor"] = {Color = Color3.fromRGB(64, 224, 255), On = true}
    },
    Objects = {
        ["Generator"] = {Color = Color3.fromRGB(255, 0, 0), On = true} -- changed to red
    }
}

local folder = {
    ["Generator"] = workspace.Map
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local cache = {}

local function ESP(obj, color)
    if obj:FindFirstChild("H") then return end
    local h = Instance.new("Highlight")
    h.Name = "H"
    h.Adornee = obj
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = 0.8
    h.OutlineTransparency = 0.3
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = obj
end

-- Apply player highlights (kept player ESP; nametags removed)
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= localPlayer and p.Character and p.Team then
        if p.Team.Name == "Killer" then
            ESP(p.Character, Hook.Players["Killer"].Color)
        elseif p.Team.Name == "Survivors" then
            ESP(p.Character, Hook.Players["Survivor"].Color)
        end
    end
end

-- Scan only generators and apply ESP (pallet/window/gate/hook ESP removed)
for t, f in pairs(folder) do
    for _, obj in ipairs(f:GetDescendants()) do
        if obj.Name == t then
            ESP(obj, Hook.Objects[t].Color)
        end
    end
end
