-- Safe HTTP Get with fallbacks
local function safeHttpGet(url)
    local success, result
    
    -- Try different HTTP methods based on executor
    if game.HttpGet then
        success, result = pcall(function()
            return game:HttpGet(url)
        end)
        if success then return result end
    end
    
    if syn and syn.request then
        success, result = pcall(function()
            return syn.request({Url = url, Method = "GET"}).Body
        end)
        if success then return result end
    end
    
    if http and http.request then
        success, result = pcall(function()
            return http.request({Url = url, Method = "GET"}).Body
        end)
        if success then return result end
    end
    
    if http_request then
        success, result = pcall(function()
            return http_request({Url = url, Method = "GET"}).Body
        end)
        if success then return result end
    end
    
    if request then
        success, result = pcall(function()
            return request({Url = url, Method = "GET"}).Body
        end)
        if success then return result end
    end
    
    error("Failed to load URL: " .. url)
end

-- Services (moved early so UI/fallback code that references LocalPlayer won't nil-index)
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Ensure LocalPlayer available (Solara and similar executors may need a short wait)
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    local start = tick()
    repeat
        task.wait(0.05)
        LocalPlayer = Players.LocalPlayer
    until LocalPlayer or tick() - start > 5
end
if not LocalPlayer then
    error("LocalPlayer not found — run as a client (LocalScript) or use a client executor.")
end

-- Load Rayfield with fallback (defensive)
local Rayfield
local loadSuccess, loadError = pcall(function()
    Rayfield = loadstring(safeHttpGet('https://sirius.menu/rayfield'))()
end)

if not loadSuccess or not Rayfield then
    warn("Failed to load Rayfield from sirius.menu, trying backup or using fallback UI...")

    -- Fallback: Try alternative Rayfield source
    local ok, alt = pcall(function()
        return loadstring(safeHttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
    end)

    if ok and alt then
        Rayfield = alt
    end
end

-- If Rayfield still nil, create a very small fallback UI library so script continues and a menu appears.
if not Rayfield then
    warn("Rayfield UI could not be loaded. Using lightweight fallback UI (basic functionality).")

    local function makeText(parent, text, size, bold)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -12, 0, size or 18)
        lbl.BackgroundTransparency = 1
        lbl.Text = text or ""
        lbl.TextColor3 = Color3.fromRGB(225,225,225)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = (bold and (size or 18)) or (size and size - 2 or 16)
        lbl.TextWrapped = true
        lbl.Parent = parent
        return lbl
    end

    local function makeButton(parent, name, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -12, 0, 28)
        btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
        btn.TextColor3 = Color3.fromRGB(240,240,240)
        btn.Text = name or "Button"
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        btn.Parent = parent
        btn.MouseButton1Click:Connect(function()
            pcall(callback)
        end)
        return btn
    end

    local function makeToggle(parent, name, initial, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -12, 0, 28)
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.75, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = name
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 16
        lbl.TextColor3 = Color3.fromRGB(220,220,220)
        lbl.Parent = frame

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.25, -4, 1, 0)
        btn.Position = UDim2.new(0.75, 4, 0, 0)
        btn.BackgroundColor3 = initial and Color3.fromRGB(80,180,80) or Color3.fromRGB(150,50,50)
        btn.Text = initial and "ON" or "OFF"
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Parent = frame

        btn.MouseButton1Click:Connect(function()
            local new = not (btn.Text == "ON")
            if new then
                btn.Text = "ON"
                btn.BackgroundColor3 = Color3.fromRGB(80,180,80)
            else
                btn.Text = "OFF"
                btn.BackgroundColor3 = Color3.fromRGB(150,50,50)
            end
            pcall(callback, new)
        end)

        return frame, btn
    end

    -- Minimal Rayfield-like API (very small subset used by script)
    Rayfield = {}
    function Rayfield:CreateWindow(opts)
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "VD_FallbackUI"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)

        local main = Instance.new("Frame")
        main.Size = UDim2.new(0, 420, 0, 520)
        main.Position = UDim2.new(0.5, -210, 0.5, -260)
        main.BackgroundColor3 = Color3.fromRGB(30,30,30)
        main.BorderSizePixel = 0
        main.Parent = screenGui

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 34)
        title.BackgroundTransparency = 1
        title.Text = opts.Name or "VD Fallback"
        title.Font = Enum.Font.GothamBold
        title.TextSize = 18
        title.TextColor3 = Color3.fromRGB(245,245,245)
        title.Parent = main

        local content = Instance.new("ScrollingFrame")
        content.Size = UDim2.new(1, -12, 1, -48)
        content.Position = UDim2.new(0, 6, 0, 40)
        content.BackgroundTransparency = 1
        content.CanvasSize = UDim2.new(0,0,0,0)
        content.Parent = main

        local layout = Instance.new("UIListLayout")
        layout.Parent = content
        layout.Padding = UDim.new(0,6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        local window = {}

        function window:CreateTab(name, icon)
            -- for fallback, tabs are just sections appended sequentially
            local tabFrame = Instance.new("Frame")
            tabFrame.Size = UDim2.new(1, 0, 0, 0)
            tabFrame.BackgroundTransparency = 1
            tabFrame.Parent = content

            local tabLayout = Instance.new("UIListLayout")
            tabLayout.Parent = tabFrame
            tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
            tabLayout.Padding = UDim.new(0,6)

            local function addSectionLabel(text)
                local sec = Instance.new("TextLabel")
                sec.Size = UDim2.new(1, -12, 0, 22)
                sec.BackgroundTransparency = 1
                sec.Font = Enum.Font.GothamBold
                sec.TextSize = 16
                sec.TextColor3 = Color3.fromRGB(220,220,220)
                sec.Text = text
                sec.Parent = tabFrame
                return sec
            end

            local tab = {}

            function tab:CreateSection(title)
                addSectionLabel(title)
            end

            function tab:CreateLabel(text)
                makeText(tabFrame, text, 16, false)
            end

            function tab:CreateParagraph(opts)
                makeText(tabFrame, (opts.Title and (opts.Title.."\n") or "") .. (opts.Content or ""), 18, false)
            end

            function tab:CreateButton(opts)
                makeButton(tabFrame, opts.Name or "Button", opts.Callback)
            end

            function tab:CreateToggle(opts)
                local _, btn = makeToggle(tabFrame, opts.Name or "Toggle", opts.CurrentValue or false, function(new)
                    if opts.Callback then opts.Callback(new) end
                end)
                return btn
            end

            function tab:CreateSlider(opts)
                -- fallback: create label and two buttons to +/-; call Callback with integer value within range
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, -12, 0, 28)
                frame.BackgroundTransparency = 1
                frame.Parent = tabFrame

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(0.6, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = opts.Name or "Slider"
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 14
                lbl.TextColor3 = Color3.fromRGB(220,220,220)
                lbl.Parent = frame

                local value = math.floor(opts.CurrentValue or ((opts.Range and opts.Range[1]) or 0))
                local valLbl = Instance.new("TextLabel")
                valLbl.Size = UDim2.new(0.2, 0, 1, 0)
                valLbl.Position = UDim2.new(0.6, 4, 0, 0)
                valLbl.BackgroundTransparency = 1
                valLbl.Text = tostring(value)
                valLbl.Font = Enum.Font.GothamBold
                valLbl.TextSize = 14
                valLbl.TextColor3 = Color3.fromRGB(200,200,200)
                valLbl.Parent = frame

                local plus = Instance.new("TextButton")
                plus.Size = UDim2.new(0.1, -4, 1, 0)
                plus.Position = UDim2.new(0.8, 4, 0, 0)
                plus.BackgroundColor3 = Color3.fromRGB(60,60,60)
                plus.Text = "+"
                plus.Font = Enum.Font.GothamBold
                plus.TextSize = 14
                plus.Parent = frame

                local minus = Instance.new("TextButton")
                minus.Size = UDim2.new(0.1, -4, 1, 0)
                minus.Position = UDim2.new(0.9, 4, 0, 0)
                minus.BackgroundColor3 = Color3.fromRGB(60,60,60)
                minus.Text = "-"
                minus.Font = Enum.Font.GothamBold
                minus.TextSize = 14
                minus.Parent = frame

                local function setValue(v)
                    value = math.clamp(math.floor(v), opts.Range[1] or 0, opts.Range[2] or v)
                    valLbl.Text = tostring(value)
                    if opts.Callback then pcall(opts.Callback, value) end
                end

                plus.MouseButton1Click:Connect(function()
                    setValue(value + (opts.Increment or 1))
                end)
                minus.MouseButton1Click:Connect(function()
                    setValue(value - (opts.Increment or 1))
                end)
            end

            function tab:CreateDropdown(opts)
                -- simple dropdown: show current and cycle options on click
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, -12, 0, 28)
                frame.BackgroundTransparency = 1
                frame.Parent = tabFrame

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(0.6, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = opts.Name or "Dropdown"
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 14
                lbl.TextColor3 = Color3.fromRGB(220,220,220)
                lbl.Parent = frame

                local cur = opts.CurrentOption or (opts.Options and opts.Options[1]) or ""
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(0.4, -4, 1, 0)
                btn.Position = UDim2.new(0.6, 4, 0, 0)
                btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
                btn.Text = tostring(cur)
                btn.Font = Enum.Font.GothamBold
                btn.TextSize = 14
                btn.Parent = frame

                local idx = 1
                for i,v in ipairs(opts.Options or {}) do
                    if v == cur then idx = i break end
                end

                btn.MouseButton1Click:Connect(function()
                    idx = idx + 1
                    if idx > # (opts.Options or {}) then idx = 1 end
                    btn.Text = opts.Options[idx]
                    if opts.Callback then pcall(opts.Callback, opts.Options[idx]) end
                end)
            end

            return tab
        end

        -- very small API compatibility
        local wrapper = {}
        wrapper.CreateTab = function(self, name, icon) return window:CreateTab(name, icon) end
        -- keep original ScreenGui for later cleanup if needed
        wrapper._Gui = screenGui
        wrapper._Main = main
        return wrapper
    end
end

-- Defensive notify function: check Rayfield.Notify exists and is callable before calling
local function notify(title, content, duration)
    if Rayfield and type(Rayfield.Notify) == "function" then
        pcall(function()
            Rayfield:Notify({
                Title = title,
                Content = content,
                Duration = duration or 3,
                Image = 4483362458
            })
        end)
    else
        -- fallback: print/warn to console so we don't attempt to call a nil function
        warn(string.format("[%s] %s", title or "Notify", content or ""))
    end
end

-- The rest of the script continues (defensive coding applied where appropriate)
-- Configuration (trimmed per request)
local Config = {
    ESP = {
        Killer = false,
        Survivor = false,
        Generator = false,
        ShowDistance = false, -- retained but disabled (no Billboard labels will be created)
        MaxDistance = 500
    },
    AutoFeatures = {
        SkillCheck = false
    }
}

-- Storage
local Highlights = {}            -- mapping Instance -> Highlight
local LastUpdate = 0
local UpdateConnection = nil

-- Movement (Walk CFrame) -- repurposed to Speed Attribute
local WalkConnection = nil
local WalkSpeed = 25 -- studs per second (10..50) - used as base speed when calculating attribute
local SavedWalkSpeed = nil
local SavedAutoRotate = nil
local CharacterAddedConn = nil

-- Speed Attribute feature variables
local SpeedAttrEnabled = false
local SpeedBoostPercent = 50 -- default percent boost (50% more)
-- Helper to track current applied humanoid (for restoring)
local AppliedHumanoid = nil

-- FOV & Camera
local OriginalCameraFOV = nil
local FOVTarget = nil
local FOVSmoothness = 0.25 -- (0.05..1.0) higher = faster interpolation
local FOVConnection = nil

-- Crosshair (round)
local CrosshairGui = nil
local CrosshairFrame = nil
local CrosshairEnabled = false
local CrosshairSize = 60 -- diameter in pixels (10..200)
local CrosshairThickness = 3 -- stroke thickness (1..10)
local CrosshairColor = Color3.fromRGB(255,255,255) -- white
local CrosshairDisplayOrder = 999 -- high to keep on top

-- Checkpoints
local Checkpoints = { nil, nil } -- CFrame or nil

-- Helper Functions
local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        return nil
    end
    return result
end

local function validateInstance(instance)
    return instance and typeof(instance) == "Instance" and instance.Parent ~= nil
end

local function isKiller()
    return LocalPlayer.Team and LocalPlayer.Team.Name == "Killer"
end

local function isSurvivor()
    return LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors"
end

-- Crosshair functions
local function createCrosshair()
    if CrosshairGui and validateInstance(CrosshairGui) then return end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return end

    local sg = Instance.new("ScreenGui")
    sg.Name = "NEXTHUB_Crosshair"
    sg.DisplayOrder = CrosshairDisplayOrder
    sg.IgnoreGuiInset = true
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
    sg.Parent = pg

    local frame = Instance.new("Frame")
    frame.Name = "CrosshairFrame"
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.Size = UDim2.new(0, CrosshairSize, 0, CrosshairSize)
    frame.BackgroundTransparency = 1 -- make inner transparent; stroke will draw ring
    frame.BorderSizePixel = 0
    frame.ZIndex = 1000
    frame.Parent = sg

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0) -- full circle
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Name = "CrosshairStroke"
    stroke.Thickness = CrosshairThickness
    stroke.Color = CrosshairColor
    stroke.Transparency = 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = frame
    stroke.ZIndex = 1001

    CrosshairGui = sg
    CrosshairFrame = frame
end

local function updateCrosshair()
    if not CrosshairGui or not validateInstance(CrosshairGui) then
        if CrosshairEnabled then
            createCrosshair()
        else
            return
        end
    end
    if CrosshairFrame and validateInstance(CrosshairFrame) then
        CrosshairFrame.Size = UDim2.new(0, CrosshairSize, 0, CrosshairSize)
        local stroke = CrosshairFrame:FindFirstChild("CrosshairStroke")
        if stroke and stroke:IsA("UIStroke") then
            stroke.Thickness = CrosshairThickness
            stroke.Color = CrosshairColor
        end
        -- Ensure top-most
        if CrosshairGui then
            CrosshairGui.DisplayOrder = CrosshairDisplayOrder
        end
    end
end

local function destroyCrosshair()
    if CrosshairGui and validateInstance(CrosshairGui) then
        pcall(function() CrosshairGui:Destroy() end)
    end
    CrosshairGui = nil
    CrosshairFrame = nil
end

-- The following helper will create/destroy Highlight instances directly (inline usage only).

local function ensureHighlightOnInstance(inst, color)
    if not validateInstance(inst) then return end
    -- if a highlight already exists for this instance, update color
    local existing = Highlights[inst]
    if existing and validateInstance(existing) then
        existing.FillColor = color
        existing.OutlineColor = color
        return existing
    end

    -- create a highlight on the instance (Adornee should be an Instance - model or part)
    local ok, h = pcall(function()
        local hl = Instance.new("Highlight")
        hl.Name = "VD_Highlight"
        hl.Adornee = inst
        hl.FillColor = color
        hl.OutlineColor = color
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.Parent = inst
        return hl
    end)

    if ok and h then
        Highlights[inst] = h
        return h
    end
    return nil
end

local function removeHighlightDirect(inst)
    if not inst then return end
    local h = Highlights[inst]
    if h and validateInstance(h) then
        pcall(function() h:Destroy() end)
    end
    Highlights[inst] = nil

    -- Also try to remove any highlight child on the instance (legacy)
    local child = inst:FindFirstChild("VD_Highlight") or inst:FindFirstChild("H")
    if child and child:IsA("Highlight") then
        pcall(function() child:Destroy() end)
    end
end

local function clearAllHighlights()
    for inst, h in pairs(Highlights) do
        if validateInstance(h) then
            pcall(function() h:Destroy() end)
        end
        Highlights[inst] = nil
    end
end

-- ESP Update Functions (streamlined)
-- Note: Billboard labels and distance display have been removed. ESP uses only Highlight instances.

local function updatePlayerESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Team then
            local teamName = player.Team.Name
            if teamName == "Killer" and Config.ESP.Killer then
                ensureHighlightOnInstance(player.Character, Color3.fromRGB(255, 0, 0))
            elseif teamName == "Survivors" and Config.ESP.Survivor then
                ensureHighlightOnInstance(player.Character, Color3.fromRGB(0, 255, 0))
            else
                removeHighlightDirect(player.Character)
            end
        end
    end
end

local function updateGeneratorESP()
    if not Config.ESP.Generator then
        -- remove any generator highlights if previously created
        for inst, _ in pairs(Highlights) do
            if validateInstance(inst) and inst:IsA("Model") and inst.Name == "Generator" then
                removeHighlightDirect(inst)
            end
        end
        return
    end

    safeCall(function()
        local map = Workspace:FindFirstChild("Map")
        if not map then return end
        
        for _, obj in ipairs(map:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Generator" then
                -- highlight the generator model directly
                ensureHighlightOnInstance(obj, Color3.fromRGB(203, 132, 66))
            end
        end
    end)
end

-- Consolidated updateAllESP (runs periodically via Heartbeat)
local ESP_UPDATE_RATE = 0.5 -- seconds
local function updateAllESP()
    local currentTime = tick()
    if currentTime - LastUpdate < ESP_UPDATE_RATE then return end
    LastUpdate = currentTime

    -- Clean up invalid highlights
    for inst, h in pairs(Highlights) do
        if not validateInstance(inst) or not validateInstance(h) then
            Highlights[inst] = nil
        end
    end

    -- Update only player and generator ESP (other object ESPs removed)
    updatePlayerESP()
    updateGeneratorESP()
end

-- Start automatic ESP updater (always running; start/stop functions removed per request)
if not UpdateConnection then
    UpdateConnection = RunService.Heartbeat:Connect(updateAllESP)
end

-- Create Rayfield Window (title changed to NEXTHUB BY NNEXT; subtitle by Nnext)
local Window
local okWindow, wndOrErr = pcall(function()
    if Rayfield and type(Rayfield.CreateWindow) == "function" then
        return Rayfield:CreateWindow({
            Name = "NEXTHUB BY NNEXT",
            LoadingTitle = "Loading Script",
            LoadingSubtitle = "by Nnext",
            ConfigurationSaving = {
                Enabled = true,
                FolderName = nil,
                FileName = "ViolenceDistrictConfig"
            },
            Discord = {
                Enabled = false,
                Invite = "CnNqEVFxh6",
                RememberJoins = false
            },
            KeySystem = false
        })
    else
        error("Rayfield.CreateWindow unavailable")
    end
end)

if okWindow and wndOrErr then
    Window = wndOrErr
else
    warn("Rayfield window creation failed:", tostring(wndOrErr))
    -- If our fallback Rayfield is present it should have CreateWindow; attempt again defensively
    if Rayfield and type(Rayfield.CreateWindow) == "function" then
        local ok2, w2 = pcall(function()
            return Rayfield:CreateWindow({
                Name = "NEXTHUB BY NNEXT",
                LoadingTitle = "Loading Script",
                LoadingSubtitle = "by Nnext",
                ConfigurationSaving = {
                    Enabled = true,
                    FolderName = nil,
                    FileName = "ViolenceDistrictConfig"
                },
                Discord = {
                    Enabled = false,
                    Invite = "CnNqEVFxh6",
                    RememberJoins = false
                },
                KeySystem = false
            })
        end)
        if ok2 and w2 then
            Window = w2
        else
            error("Could not create UI window; aborting: "..tostring(w2))
        end
    else
        error("No UI library available to create window")
    end
end

-- ESP Tab (streamlined: only Player ESP and Generator ESP remain; labels removed)
local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)
ESPTab:CreateSection("Player ESP")

ESPTab:CreateToggle({
    Name = "Killer ESP (Red)",
    CurrentValue = false,
    Flag = "KillerESP",
    Callback = function(Value)
        Config.ESP.Killer = Value
        -- immediate update (updateAllESP runs periodically)
        updatePlayerESP()
    end
})

ESPTab:CreateToggle({
    Name = "Survivor ESP (Green)",
    CurrentValue = false,
    Flag = "SurvivorESP",
    Callback = function(Value)
        Config.ESP.Survivor = Value
        updatePlayerESP()
    end
})

ESPTab:CreateSection("Object ESP")

ESPTab:CreateToggle({
    Name = "Generator ESP (Orange)",
    CurrentValue = false,
    Flag = "GeneratorESP",
    Callback = function(Value)
        Config.ESP.Generator = Value
        updateGeneratorESP()
    end
})

ESPTab:CreateSection("Settings")

ESPTab:CreateSlider({
    Name = "Max Distance (used for culling highlights)",
    Range = {100, 1000},
    Increment = 50,
    CurrentValue = 500,
    Flag = "MaxDistance",
    Callback = function(Value)
        Config.ESP.MaxDistance = Value
    end
})

-- Move Clear/Refresh ESP controls into ESP tab
ESPTab:CreateButton({
    Name = "Clear All ESP",
    Callback = function()
        clearAllHighlights()
        notify("Cleared", "All ESP cleared", 2)
    end
})

ESPTab:CreateButton({
    Name = "Refresh ESP",
    Callback = function()
        clearAllHighlights()
        updateAllESP()
        notify("Refreshed", "ESP refreshed", 2)
    end
})

-- Gameplay Tab (contains Walk (CFrame) and Checkpoint Teleport features)
local GameplayTab = Window:CreateTab("🎮 Gameplay", 4483362458)
GameplayTab:CreateSection("Auto Features")

-- Improved Auto Skill Check module (replaces previous implementation)
local SkillCheck = {}
do
    local LP = LocalPlayer
    local PG = nil
    local CheckGui = nil
    local Check = nil
    local Line = nil
    local Goal = nil

    local HeartbeatConn = nil
    local VisibleConn = nil
    local PlayerGuiChildConn = nil

    local function PressSpace()
        -- Prefer VirtualInputManager; if not available, notify user
        if VirtualInputManager and VirtualInputManager.SendKeyEvent then
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait(0.01)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)
        else
            notify("Skill Check", "VirtualInputManager unavailable — cannot send key event", 4)
        end
    end

    local function LineInGoal()
        if not Line or not Goal then return false end
        -- Defensive: ensure Rotation property exists
        local lr = (Line.Rotation or 0) % 360
        local gr = (Goal.Rotation or 0) % 360
        local gs = (gr + 104) % 360
        local ge = (gr + 114) % 360

        if gs > ge then
            return lr >= gs or lr <= ge
        else
            return lr >= gs and lr <= ge
        end
    end

    local function stopHeartbeat()
        if HeartbeatConn then
            HeartbeatConn:Disconnect()
            HeartbeatConn = nil
        end
    end

    local function HeartbeatCheck()
        -- Only attempt if player is survivor (same logic as before)
        if LP.Team and LP.Team.Name == "Survivors" then
            if LineInGoal() then
                PressSpace()
                stopHeartbeat()
            end
        else
            stopHeartbeat()
        end
    end

    local function OnCheckVisible()
        -- Called when Check.Visible changes
        if not Check then return end
        if LP.Team and LP.Team.Name == "Survivors" then
            if Check.Visible then
                stopHeartbeat()
                HeartbeatConn = RunService.Heartbeat:Connect(HeartbeatCheck)
            else
                stopHeartbeat()
            end
        else
            stopHeartbeat()
        end
    end

    local function attachToCheckGui(gui)
        -- try attach to Check inside provided gui
        pcall(function()
            CheckGui = gui or (LP:FindFirstChild("PlayerGui") and LP.PlayerGui:FindFirstChild("SkillCheckPromptGui"))
            if not CheckGui then return end
            Check = CheckGui:FindFirstChild("Check")
            if not Check then return end
            Line = Check:FindFirstChild("Line")
            Goal = Check:FindFirstChild("Goal")

            -- connect visible watcher
            if VisibleConn then VisibleConn:Disconnect() VisibleConn = nil end
            VisibleConn = Check:GetPropertyChangedSignal("Visible"):Connect(OnCheckVisible)

            -- if it's already visible start heartbeat
            if Check.Visible then
                stopHeartbeat()
                HeartbeatConn = RunService.Heartbeat:Connect(HeartbeatCheck)
            end
        end)
    end

    local function onPlayerGuiChildAdded(child)
        -- when SkillCheckPromptGui is added, attach
        if not child then return end
        if child.Name == "SkillCheckPromptGui" then
            -- small delay to allow contents to be created
            task.wait(0.05)
            attachToCheckGui(child)
        end
    end

    function SkillCheck:Enable()
        if Config.AutoFeatures.SkillCheck then return end
        Config.AutoFeatures.SkillCheck = true

        -- ensure PlayerGui exists and attach child listener for new GUIs
        pcall(function()
            PG = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 5)
            if PG then
                -- If already connected, disconnect first
                if PlayerGuiChildConn then PlayerGuiChildConn:Disconnect() PlayerGuiChildConn = nil end
                PlayerGuiChildConn = PG.ChildAdded:Connect(onPlayerGuiChildAdded)
                -- If SkillCheckPromptGui already present, attach immediately
                local existing = PG:FindFirstChild("SkillCheckPromptGui")
                if existing then
                    attachToCheckGui(existing)
                end
            else
                notify("Skill Check", "PlayerGui not found; cannot attach skillcheck detector", 4)
            end
        end)

        notify("Skill Check", "Auto Skill Check Enabled", 2)
    end

    function SkillCheck:Disable()
        Config.AutoFeatures.SkillCheck = false

        -- disconnect all connections
        if VisibleConn then VisibleConn:Disconnect() VisibleConn = nil end
        if PlayerGuiChildConn then PlayerGuiChildConn:Disconnect() PlayerGuiChildConn = nil end
        stopHeartbeat()

        -- clear references (so next enable re-scans)
        CheckGui = nil
        Check = nil
        Line = nil
        Goal = nil

        notify("Skill Check", "Auto Skill Check Disabled", 2)
    end
end

-- Add Toggle to Gameplay UI
GameplayTab:CreateToggle({
    Name = "Auto Skill Check",
    CurrentValue = false,
    Flag = "AutoSkillCheck",
    Callback = function(Value)
        if Value then
            SkillCheck:Enable()
        else
            SkillCheck:Disable()
        end
    end
})

-- Gameplay Tab continued: Killer Powers

GameplayTab:CreateSection("Killer Powers")

GameplayTab:CreateButton({
    Name = "Activate Killer Power",
    Callback = function()
        safeCall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if remotes then
                local killerRemotes = remotes:FindFirstChild("Killers")
                if killerRemotes then
                    local killerFolder = killerRemotes:FindFirstChild("Killer")
                    if killerFolder then
                        local activatePower = killerFolder:FindFirstChild("ActivatePower")
                        if activatePower then
                            activatePower:FireServer()
                            notify("Power Activated", "Killer power triggered", 2)
                        end
                    end
                end
            end
        end)
    end
})

GameplayTab:CreateButton({
    Name = "Basic Attack (Killer)",
    Callback = function()
        safeCall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if remotes then
                local attacks = remotes:FindFirstChild("Attacks")
                if attacks then
                    local basicAttack = attacks:FindFirstChild("BasicAttack")
                    if basicAttack then
                        basicAttack:FireServer(false)
                        notify("Attack", "Basic attack executed", 2)
                    end
                end
            end
        end)
    end
})

-- Movement Section (repurposed): Speed Attribute
GameplayTab:CreateSection("Movement")

-- Helper to apply speed attribute to humanoid
local function applySpeedToHumanoid(humanoid)
    if not validateInstance(humanoid) then return end
    pcall(function()
        if SavedWalkSpeed == nil then
            SavedWalkSpeed = humanoid.WalkSpeed
        end
        -- base speed: prefer configured WalkSpeed else humanoid current/wrapped saved
        local base = WalkSpeed or SavedWalkSpeed or humanoid.WalkSpeed
        local multiplier = 1 + ( (SpeedBoostPercent or 0) / 100 )
        local newSpeed = math.clamp(base * multiplier, 0, 1000)
        -- set attribute "Speed" on humanoid (some games read attributes)
        pcall(function()
            if humanoid.SetAttribute then
                humanoid:SetAttribute("Speed", newSpeed)
            end
        end)
        -- also apply locally so movement reacts immediately
        humanoid.WalkSpeed = newSpeed
        AppliedHumanoid = humanoid
    end)
end

local function removeSpeedAttributeFromHumanoid(humanoid)
    if not validateInstance(humanoid) then return end
    pcall(function()
        -- try remove attribute; set to nil if possible
        if humanoid.GetAttribute and humanoid:GetAttribute("Speed") ~= nil then
            pcall(function()
                humanoid:SetAttribute("Speed", nil)
            end)
        end
        -- restore WalkSpeed if saved
        if SavedWalkSpeed ~= nil then
            humanoid.WalkSpeed = SavedWalkSpeed
        end
    end)
end

GameplayTab:CreateToggle({
    Name = "Use Speed Attribute",
    CurrentValue = false,
    Flag = "SpeedAttribute",
    Callback = function(Value)
        if Value then
            if SpeedAttrEnabled then return end
            SpeedAttrEnabled = true

            -- connect to character added to reapply attribute on respawn
            if CharacterAddedConn then CharacterAddedConn:Disconnect() CharacterAddedConn = nil end
            CharacterAddedConn = LocalPlayer.CharacterAdded:Connect(function(char)
                task.wait(0.05)
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    applySpeedToHumanoid(humanoid)
                end
            end)

            -- apply to current character immediately if present
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                applySpeedToHumanoid(humanoid)
            else
                notify("Speed Attribute", "No humanoid found to apply speed attribute", 3)
            end

            notify("Speed Attribute", "Enabled — attribute 'Speed' set on humanoid (if supported)", 3)
        else
            -- disable
            SpeedAttrEnabled = false
            if CharacterAddedConn then
                CharacterAddedConn:Disconnect()
                CharacterAddedConn = nil
            end
            -- restore current humanoid if tracked
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                removeSpeedAttributeFromHumanoid(humanoid)
            elseif AppliedHumanoid and validateInstance(AppliedHumanoid) then
                removeSpeedAttributeFromHumanoid(AppliedHumanoid)
            end
            AppliedHumanoid = nil
            SavedWalkSpeed = nil
            notify("Speed Attribute", "Disabled — restored WalkSpeed where possible", 2)
        end
    end
})

GameplayTab:CreateSlider({
    Name = "Walk Speed (studs/sec)",
    Range = {10, 50},
    Increment = 1,
    CurrentValue = WalkSpeed,
    Flag = "WalkSpeed",
    Callback = function(Value)
        WalkSpeed = math.clamp(Value or 25, 10, 50)
        -- if speed attribute enabled, update current humanoid live
        if SpeedAttrEnabled then
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                applySpeedToHumanoid(humanoid)
            end
        end
    end
})

-- New: Speed Boost percent slider (applies as multiplier)
GameplayTab:CreateSlider({
    Name = "Speed Boost (%)",
    Range = {0, 200},
    Increment = 1,
    CurrentValue = SpeedBoostPercent,
    Flag = "SpeedBoostPercent",
    Callback = function(Value)
        SpeedBoostPercent = math.clamp(Value or 50, 0, 200)
        -- if enabled, update immediately
        if SpeedAttrEnabled then
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                applySpeedToHumanoid(humanoid)
            elseif AppliedHumanoid and validateInstance(AppliedHumanoid) then
                applySpeedToHumanoid(AppliedHumanoid)
            end
        end
    end
})

-- Teleport Checkpoints
GameplayTab:CreateSection("Teleport - Checkpoints")

-- Checkpoint 1
GameplayTab:CreateParagraph({Title = "Checkpoint 1", Content = ""})
GameplayTab:CreateButton({
    Name = "SAVE Checkpoint 1",
    Callback = function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            notify("Checkpoint 1", "No HumanoidRootPart found to save", 2)
            return
        end
        Checkpoints[1] = hrp.CFrame
        notify("Checkpoint 1", "Saved current position", 2)
    end
})
GameplayTab:CreateButton({
    Name = "LOAD Checkpoint 1",
    Callback = function()
        local cf = Checkpoints[1]
        if not cf then
            notify("Checkpoint 1", "No saved position. Use SAVE first.", 2)
            return
        end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            notify("Checkpoint 1", "No HumanoidRootPart found to teleport", 2)
            return
        end
        pcall(function()
            hrp.CFrame = cf
        end)
        notify("Checkpoint 1", "Loaded saved position", 2)
    end
})

-- Checkpoint 2
GameplayTab:CreateParagraph({Title = "Checkpoint 2", Content = ""})
GameplayTab:CreateButton({
    Name = "SAVE Checkpoint 2",
    Callback = function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            notify("Checkpoint 2", "No HumanoidRootPart found to save", 2)
            return
        end
        Checkpoints[2] = hrp.CFrame
        notify("Checkpoint 2", "Saved current position", 2)
    end
})
GameplayTab:CreateButton({
    Name = "LOAD Checkpoint 2",
    Callback = function()
        local cf = Checkpoints[2]
        if not cf then
            notify("Checkpoint 2", "No saved position. Use SAVE first.", 2)
            return
        end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            notify("Checkpoint 2", "No HumanoidRootPart found to teleport", 2)
            return
        end
        pcall(function()
            hrp.CFrame = cf
        end)
        notify("Checkpoint 2", "Loaded saved position", 2)
    end
})

-- Settings Tab (trimmed) - keep Unload Script and Camera settings
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

-- Camera / FOV Section
SettingsTab:CreateSection("Camera")

-- Save original camera FOV
OriginalCameraFOV = (Workspace.CurrentCamera and Workspace.CurrentCamera.FieldOfView) or 70
FOVTarget = OriginalCameraFOV or 70
FOVSmoothness = 0.25

-- Start FOV smoothing connection
local function startFOVConnection()
    if FOVConnection then return end
    FOVConnection = RunService.RenderStepped:Connect(function(dt)
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local current = cam.FieldOfView
        local target = FOVTarget or current
        if math.abs(current - target) < 0.01 then
            cam.FieldOfView = target
            return
        end
        -- Interpolate: higher FOVSmoothness -> faster interpolation
        local alpha = math.clamp(FOVSmoothness * dt * 6, 0, 1)
        cam.FieldOfView = current + (target - current) * alpha
    end)
end

local function stopFOVConnection()
    if FOVConnection then
        FOVConnection:Disconnect()
        FOVConnection = nil
    end
end

SettingsTab:CreateSlider({
    Name = "Field of View (70-110)",
    Range = {70, 110},
    Increment = 1,
    CurrentValue = FOVTarget,
    Flag = "FOV",
    Callback = function(Value)
        FOVTarget = math.clamp(Value or 70, 70, 110)
        startFOVConnection()
    end
})

SettingsTab:CreateSlider({
    Name = "FOV Smoothness (higher = faster)",
    Range = {0.05, 1.0},
    Increment = 0.05,
    CurrentValue = FOVSmoothness,
    Flag = "FOVSmooth",
    Callback = function(Value)
        FOVSmoothness = math.clamp(Value or 0.25, 0.05, 1.0)
        startFOVConnection()
    end
})

-- Crosshair Section (round ring)
SettingsTab:CreateSection("Crosshair")

SettingsTab:CreateToggle({
    Name = "Enable Round Crosshair",
    CurrentValue = false,
    Flag = "CrosshairToggle",
    Callback = function(Value)
        CrosshairEnabled = Value
        if Value then
            createCrosshair()
            updateCrosshair()
            notify("Crosshair", "Round crosshair enabled", 2)
        else
            destroyCrosshair()
            notify("Crosshair", "Round crosshair disabled", 2)
        end
    end
})

SettingsTab:CreateSlider({
    Name = "Crosshair Diameter (px)",
    Range = {10, 200},
    Increment = 1,
    CurrentValue = CrosshairSize,
    Flag = "CrosshairSize",
    Callback = function(Value)
        CrosshairSize = math.clamp(Value or 60, 10, 200)
        updateCrosshair()
    end
})

SettingsTab:CreateSlider({
    Name = "Crosshair Thickness",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = CrosshairThickness,
    Flag = "CrosshairThickness",
    Callback = function(Value)
        CrosshairThickness = math.clamp(Value or 3, 1, 10)
        updateCrosshair()
    end
})

-- Script Controls: leave only Unload Script here
SettingsTab:CreateSection("Script Controls")

SettingsTab:CreateButton({
    Name = "Unload Script",
    Callback = function()
        -- cleanup
        if UpdateConnection then
            UpdateConnection:Disconnect()
            UpdateConnection = nil
        end
        clearAllHighlights()
        -- stop walk connection if running
        if WalkConnection then
            WalkConnection:Disconnect()
            WalkConnection = nil
        end
        if CharacterAddedConn then
            CharacterAddedConn:Disconnect()
            CharacterAddedConn = nil
        end
        -- try restore humanoid on unload
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function()
                if SavedWalkSpeed ~= nil then humanoid.WalkSpeed = SavedWalkSpeed end
                if SavedAutoRotate ~= nil then humanoid.AutoRotate = SavedAutoRotate end
                -- remove attribute if present
                if humanoid.GetAttribute and humanoid:GetAttribute("Speed") ~= nil then
                    pcall(function() humanoid:SetAttribute("Speed", nil) end)
                end
            end)
        end
        SavedWalkSpeed = nil
        SavedAutoRotate = nil

        -- restore camera FOV and stop smoothing
        pcall(function()
            local cam = Workspace.CurrentCamera
            if cam and OriginalCameraFOV then
                cam.FieldOfView = OriginalCameraFOV
            end
        end)
        stopFOVConnection()

        -- destroy crosshair if present
        destroyCrosshair()

        -- Rayfield fallback: destroy UI if possible
        pcall(function()
            if Rayfield and Rayfield.Destroy then
                pcall(Rayfield.Destroy, Rayfield)
            elseif Rayfield and Rayfield._Gui then
                if validateInstance(Rayfield._Gui) then
                    Rayfield._Gui:Destroy()
                end
            end
        end)

        -- ensure simulated Shift released on unload
        pcall(function()
            if not UserInputService.TouchEnabled and VirtualInputManager and VirtualInputManager.SendKeyEvent then
                pcall(function()
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
                end)
            end
        end)

        notify("Unloaded", "Script unloaded", 2)
    end
})

-- Final Notification
notify("Script Loaded!", "NEXTHUB BY NNEXT - Violence District v2.2 (modified) loaded", 4)
