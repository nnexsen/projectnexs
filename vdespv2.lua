local Hook = {
    Players = {
        ["Killer"] = {Color = Color3.fromRGB(255, 93, 108), On = true}    
    }
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
    h.FillTransparency = 0
    h.OutlineTransparency = 0.1
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = obj
end


for _, p in ipairs(Players:GetPlayers()) do
    if p ~= localPlayer and p.Character and p.Team then
        if p.Team.Name == "Killer" then
            ESP(p.Character, Hook.Players["Killer"].Color)
        end
    end
end
