-- vdespv2.lua
-- Reworked: Minimal Rayfield UI + ESP functionality (based on violencedistrictnexs.lua)
-- This script loads Rayfield (with fallback) and provides a Script tab with:
--  - Killer ESP toggle (uses the original ESP function behavior)
--  - Refresh ESP List button (re-applies highlights / cleans stale ones)

-- Configuration (from original vdespv2.lua)
local Hook = {
    Players = {
        ["Killer"] = {Color = Color3.fromRGB(0, 0, 0), On = true}
    }
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Minimal safeHttpGet & Rayfield loader (referenced from violencedistrictnexs.lua)
local function safeHttpGet(url)
    local success, result

    if game.HttpGet then
        success, result = pcall(function() return game:HttpGet(url) end)
        if success then return result end
    end

    if syn and syn.request then
        success, result = pcall(function() return syn.request({Url = url, Method = "GET"}).Body end)
        if success then return result end
    end

    if http and http.request then
        success, result = pcall(function() return http.request({Url = url, Method = "GET"}).Body end)
        if success then return result end
    end

    if http_request then
        success, result = pcall(function() return http_request({Url = url, Method = "GET"}).Body end)
        if success then return result end
    end

    if request then
        success, result = pcall(function() return request({Url = url, Method = "GET"}).Body end)
        if success then return result end
    end

    error("Failed to load URL: " .. url)
end

local Rayfield
do
    local ok, err = pcall(function()
        Rayfield = loadstring(safeHttpGet('https://sirius.menu/rayfield'))()
    end)

    if not ok or not Rayfield then
        -- fallback
        pcall(function()
            Rayfield = loadstring(safeHttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
        end)
    end

    if not Rayfield then
        error("CRITICAL: Could not load Rayfield UI Library. Please check your internet connection or executor compatibility.")
    end
end

-- Simple notify wrapper using Rayfield (matches violencedistrictnexs.lua style)
local function notify(title, content, duration)
    pcall(function()
        Rayfield:Notify({
            Title = title,
            Content = content,
            Duration = duration or 3
        })
    end)
end

-- Utility
local function validateInstance(instance)
    return instance and typeof(instance) == "Instance" and instance.Parent ~= nil
end

local function safeCall(fn, ...)
    local ok, res = pcall(fn, ...)
    if not ok then return nil end
    return res
end

-- Highlight / ESP state
local Highlights = {}        -- map from adornee Instance -> Highlight
local espEnabled = false

local function createHighlight(obj, color)
    if not validateInstance(obj) then return end
    -- Don't attach multiple highlights
    if obj:FindFirstChild("H") then return end

    safeCall(function()
        local h = Instance.new("Highlight")
        h.Name = "H"
        h.Adornee = obj
        h.FillColor = color
        h.OutlineColor = color
        h.FillTransparency = 0.5
        h.OutlineTransparency = 0.8
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = obj
        Highlights[obj] = h
    end)
end

local function removeHighlight(obj)
    if not obj then return end

    if Highlights[obj] and validateInstance(Highlights[obj]) then
        safeCall(function() Highlights[obj]:Destroy() end)
        Highlights[obj] = nil
    end

    local existing = obj:FindFirstChild("H")
    if existing then
        safeCall(function() existing:Destroy() end)
    end
end

local function clearAllHighlights()
    for obj, _ in pairs(Highlights) do
        if validateInstance(obj) then
            removeHighlight(obj)
        else
            Highlights[obj] = nil
        end
    end
end

-- The original vdespv2.lua only highlighted players on Killer team.
-- We'll mirror that and allow toggling via Rayfield.
local function applyESPToPlayers()
    clearAllHighlights()

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Team then
            if p.Team.Name == "Killer" and Hook.Players["Killer"].On then
                createHighlight(p.Character, Hook.Players["Killer"].Color)
            end
        end
    end
end

-- Keep highlights in sync when players/characters change
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if espEnabled and player.Team and player.Team.Name == "Killer" and Hook.Players["Killer"].On then
            createHighlight(char, Hook.Players["Killer"].Color)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if player and player.Character then
        removeHighlight(player.Character)
    end
end)

-- Expose a refresh that mirrors the "Refresh ESP" behavior from violencedistrictnexs.lua
local function refreshESPList()
    -- Remove any invalid / stale highlights and reapply
    for obj, h in pairs(Highlights) do
        if not validateInstance(obj) or not validateInstance(h) then
            Highlights[obj] = nil
        end
    end
    if espEnabled then
        applyESPToPlayers()
    end
    notify("ESP Refreshed", "ESP list refreshed", 2)
end

-- Create a minimal Rayfield window and Script tab (no other UI from violencedistrictnexs.lua)
local Window = Rayfield:CreateWindow({
    Name = "vdespv2 - Simple Rayfield ESP",
    LoadingTitle = "vdespv2",
    LoadingSubtitle = "Simple ESP integrated with Rayfield",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local ScriptTab = Window:CreateTab("Script", 4483362458)
ScriptTab:CreateSection("ESP Controls (vdespv2)")

ScriptTab:CreateToggle({
    Name = "Killer ESP (toggle)",
    CurrentValue = false,
    Flag = "KillerESP",
    Callback = function(value)
        espEnabled = value
        Hook.Players["Killer"].On = value

        if value then
            applyESPToPlayers()
            notify("Killer ESP", "Enabled", 2)
        else
            clearAllHighlights()
            notify("Killer ESP", "Disabled", 2)
        end
    end
})

ScriptTab:CreateButton({
    Name = "Refresh ESP List",
    Callback = function()
        refreshESPList()
    end
})

-- Provide option to change color quickly (optional helper)
ScriptTab:CreateColorPicker({
    Name = "Killer Color",
    Default = Hook.Players["Killer"].Color,
    Callback = function(color)
        Hook.Players["Killer"].Color = color
        if espEnabled then
            applyESPToPlayers()
        end
    end
})

-- Final notification
notify("vdespv2 Loaded", "Rayfield window ready - use Script tab to toggle ESP", 4)

-- Ensure initial state (no ESP on by default)
espEnabled = false
