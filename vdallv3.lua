-- Executor Info (mobile support removed)
local executorName = identifyexecutor and identifyexecutor() or "Unknown"

print("=== Violence District v2.2 ===")
print("Executor: " .. executorName)
print("============================================")

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

-- Load Rayfield with fallback
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
        screenGui.Parent = LocalPlayer:FindFirstChild("PlayerGui") or nil

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

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Configuration (unchanged)
local Config = {
    ESP = {
        Killer = false,
        Survivor = false,
        Generator = false,
        Gate = false,
        Hook = false,
        Pallet = false,
        Window = false,
        Pumpkin = false,
        ClosestHook = false,
        ShowOnlyClosestHook = false,
        ShowDistance = true,
        MaxDistance = 500
    },
    AutoFeatures = {
        AutoGenerator = false,
        GeneratorMode = "great",
        AutoLeaveGenerator = false,
        LeaveDistance = 15,
        LeaveKeybind = Enum.KeyCode.Q,
        AutoAttack = false,
        AttackRange = 10
    },
    Teleportation = {
        TeleportOffset = 3,
        SafeTeleport = true,
        TeleportDelay = 0.1
    },
    Performance = {
        UpdateRate = 0.5,
        UseDistanceCulling = true,
        MaxESPObjects = 100,
        DisableParticles = false,
        LowerGraphics = false,
        DisableShadows = false,
        ReduceRenderDistance = false
    },
    RootLock = {
        Enabled = false,
        LockedCFrame = nil
    }
}

-- Storage
local Highlights = {}
local BillboardGuis = {}
local LastUpdate = 0
local UpdateConnection = nil
local LeaveGeneratorConnection = nil
local AutoAttackConnection = nil
local ClosestHookHighlight = nil
local FPSCounterEnabled = false
local FPSCounterUI = nil
local RootLockConnection = nil

-- Helper Functions
local function notify(title, content, duration)
    local success = pcall(function()
        Rayfield:Notify({
            Title = title,
            Content = content,
            Duration = duration or 3,
            Image = 4483362458
        })
    end)
    
    if not success then
        warn(string.format("[%s] %s", title, content))
    end
end

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

-- Performance functions unchanged (no mobile-specific code)

local function applyPerformanceSettings()
    local lighting = game:GetService("Lighting")
    local workspace = Workspace
    
    if Config.Performance.DisableParticles then
        safeCall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                    obj.Enabled = false
                end
            end
        end)
    end
    
    if Config.Performance.LowerGraphics then
        safeCall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
    end
    
    if Config.Performance.DisableShadows then
        safeCall(function()
            lighting.GlobalShadows = false
            lighting.FogEnd = 100
        end)
    end
    
    if Config.Performance.ReduceRenderDistance then
        safeCall(function()
            workspace.StreamingEnabled = true
            workspace.StreamingMinRadius = 32
            workspace.StreamingTargetRadius = 64
        end)
    end
end

local function resetPerformanceSettings()
    local lighting = game:GetService("Lighting")
    local workspace = Workspace
    
    safeCall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                obj.Enabled = true
            end
        end
        
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        lighting.GlobalShadows = true
        lighting.FogEnd = 100000
        
        -- Re-enable post effects
        for _, effect in ipairs(lighting:GetChildren()) do
            if effect:IsA("PostEffect") then
                effect.Enabled = true
            end
        end
        
        -- Re-enable textures
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Texture") or obj:IsA("Decal") then
                obj.Transparency = 0
            end
        end
    end)
end

-- FPS Counter functions unchanged
local function createFPSCounter()
    if FPSCounterUI then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FPSCounter"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Name = "FPSFrame"
    frame.Size = UDim2.new(0, 120, 0, 50)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Name = "FPSLabel"
    fpsLabel.Size = UDim2.new(1, 0, 1, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: 999"
    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    fpsLabel.TextStrokeTransparency = 0
    fpsLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.TextSize = 20
    fpsLabel.Parent = frame
    
    -- Make it draggable
    local dragging = false
    local dragInput, mousePos, framePos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- FPS Calculation (updates every 1.5 seconds)
    local lastTime = tick()
    local frameCount = 0
    local fps = 0
    
    RunService.Heartbeat:Connect(function()
        if not FPSCounterEnabled then return end
        
        frameCount = frameCount + 1
        local currentTime = tick()
        local deltaTime = currentTime - lastTime
        
        -- Update every 1.5 seconds instead of 1 second
        if deltaTime >= 1.5 then
            fps = math.floor(frameCount / deltaTime)
            frameCount = 0
            lastTime = currentTime
            
            -- Color based on FPS
            if fps >= 60 then
                fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Green
            elseif fps >= 30 then
                fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 0) -- Yellow
            else
                fpsLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Red
            end
            
            fpsLabel.Text = string.format("FPS: %d", fps)
        end
    end)
    
    local success = pcall(function()
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end)
    
    if success then
        FPSCounterUI = screenGui
        FPSCounterEnabled = true
        notify("FPS Counter", "Enabled - Drag to move!", 3)
    end
end

local function removeFPSCounter()
    if FPSCounterUI then
        FPSCounterUI:Destroy()
        FPSCounterUI = nil
        FPSCounterEnabled = false
    end
end

-- Teleportation Helper Functions
local function getCharacterRootPart()
    if not LocalPlayer.Character then return nil end
    return LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function isNearGenerator()
    local hrp = getCharacterRootPart()
    if not hrp then return false, nil end
    
    local map = Workspace:FindFirstChild("Map")
    if not map then return false, nil end
    
    local nearestGen = nil
    local nearestDist = math.huge
    
    for _, obj in ipairs(map:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Generator" then
            local genPart = obj:FindFirstChildWhichIsA("BasePart")
            if genPart then
                local distance = (genPart.Position - hrp.Position).Magnitude
                if distance < nearestDist then
                    nearestDist = distance
                    nearestGen = obj
                end
            end
        end
    end
    
    if nearestGen and nearestDist <= Config.AutoFeatures.LeaveDistance then
        return true, nearestGen, nearestDist
    end
    
    return false, nil, nil
end

-- Updated safeTeleport with camera reset and collision restore
function safeTeleport(target, offset)
    local hrp = getCharacterRootPart()
    if not hrp then 
        -- If character/humanoidrootpart doesn't exist, ensure camera is in a safe state and abort.
        pcall(function()
            local cam = Workspace.CurrentCamera
            if cam then
                cam.CameraType = Enum.CameraType.Custom
            end
        end)
        notify("Error", "Character not found - cannot teleport", 3)
        return false
    end

    -- Resolve target position
    local targetPosition
    if typeof(target) == "CFrame" then
        targetPosition = target.Position
    elseif typeof(target) == "Vector3" then
        targetPosition = target
    elseif typeof(target) == "Instance" and target:IsA("BasePart") then
        targetPosition = target.Position
    elseif typeof(target) == "Instance" and target:IsA("Model") then
        local part = target:FindFirstChildWhichIsA("BasePart")
        if part then
            targetPosition = part.Position
        else
            targetPosition = hrp.Position
        end
    else
        notify("Error", "Invalid teleport target", 3)
        return false
    end
    
    offset = offset or Vector3.new(0, Config.Teleportation.TeleportOffset, 0)
    
    -- Raycast to find ground
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true
    
    local rayOrigin = targetPosition + Vector3.new(0, 60, 0)
    local rayDirection = Vector3.new(0, -160, 0)
    local rayResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    local finalY
    if rayResult and rayResult.Position then
        finalY = rayResult.Position.Y + offset.Y
    else
        finalY = math.max(targetPosition.Y + offset.Y, hrp.Position.Y + 2, 5)
    end
    
    local finalPos = Vector3.new(targetPosition.X, finalY, targetPosition.Z)
    
    -- save original CanCollide states
    local originalStates = {}
    if Config.Teleportation.SafeTeleport then
        safeCall(function()
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    originalStates[part] = part.CanCollide
                    part.CanCollide = false
                end
            end
        end)
    end
    
    -- Teleport
    local success, err = pcall(function()
        local lookVector = hrp.CFrame.LookVector
        hrp.CFrame = CFrame.new(finalPos, finalPos + lookVector)
    end)
    
    if Config.Teleportation.SafeTeleport then
        task.delay(0.5, function()
            safeCall(function()
                for part, state in pairs(originalStates) do
                    if validateInstance(part) and part:IsA("BasePart") then
                        part.CanCollide = state
                    end
                end
            end)
        end)
    end
    
    -- Reset camera to player humanoid to avoid stuck camera
    safeCall(function()
        local cam = Workspace.CurrentCamera
        if cam then
            cam.CameraType = Enum.CameraType.Custom
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    cam.CameraSubject = humanoid
                end
            end
        end
    end)
    
    if not success then
        notify("Teleport Failed", tostring(err), 3)
        return false
    end
    
    return true
end

-- leaveGenerator: robust zero-vector handling
function leaveGenerator()
    local hrp = getCharacterRootPart()
    if not hrp then return false end
    
    local isNear, nearestGen, distance = isNearGenerator()
    if not isNear then
        notify("Not Near", "You're not near any generator", 2)
        return false
    end
    
    local genPart = nearestGen:FindFirstChildWhichIsA("BasePart")
    if genPart then
        local vec = hrp.Position - genPart.Position
        -- horizontal only
        vec = Vector3.new(vec.X, 0, vec.Z)
        if vec.Magnitude < 0.5 then
            -- fallback direction: away from map center or random
            local map = Workspace:FindFirstChild("Map")
            local mapCenter = Vector3.new(0, hrp.Position.Y, 0)
            if map and map:IsA("Model") then
                local acc = Vector3.new(0,0,0)
                local c = 0
                for _, v in ipairs(map:GetDescendants()) do
                    if v:IsA("BasePart") then
                        acc = acc + v.Position
                        c = c + 1
                    end
                end
                if c > 0 then
                    mapCenter = Vector3.new((acc / c).X, hrp.Position.Y, (acc / c).Z)
                end
            end
            vec = hrp.Position - mapCenter
            vec = Vector3.new(vec.X, 0, vec.Z)
            if vec.Magnitude < 0.5 then
                vec = Vector3.new(math.random()-0.5, 0, math.random()-0.5)
            end
        end
        
        local direction = vec.Unit
        local escapeDistance = Config.AutoFeatures.LeaveDistance + 15
        local escapeTarget = hrp.Position + (direction * escapeDistance)
        
        if safeTeleport(escapeTarget, Vector3.new(0, Config.Teleportation.TeleportOffset + 1, 0)) then
            notify("Escaped!", string.format("Moved %.0f studs away", escapeDistance), 2)
            return true
        else
            -- fallback: teleport further from generator
            local fallback = genPart.Position + (direction * (escapeDistance + 5))
            if safeTeleport(fallback, Vector3.new(0, Config.Teleportation.TeleportOffset + 1, 0)) then
                notify("Escaped (Fallback)!", string.format("Moved %.0f studs away", escapeDistance + 5), 2)
                return true
            end
        end
    end
    
    return false
end

-- Root Lock: keeps HumanoidRootPart at captured CFrame while enabled
local function enableRootLock()
    if RootLockConnection then return end
    local hrp = getCharacterRootPart()
    if not hrp then
        notify("Root Lock", "No character found to lock", 2)
        return
    end
    Config.RootLock.LockedCFrame = hrp.CFrame
    Config.RootLock.Enabled = true

    RootLockConnection = RunService.Heartbeat:Connect(function()
        local curHRP = getCharacterRootPart()
        if not curHRP then return end
        -- set only position and keep same orientation as locked CFrame
        local locked = Config.RootLock.LockedCFrame
        if locked then
            -- preserve locked position, but allow slight Y adjustments to avoid embedding
            local target = Vector3.new(locked.Position.X, locked.Position.Y, locked.Position.Z)
            local look = locked.LookVector
            curHRP.CFrame = CFrame.new(target, target + look)
            -- ensure camera subject remains on humanoid
            safeCall(function()
                local cam = Workspace.CurrentCamera
                if cam and LocalPlayer.Character then
                    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        cam.CameraType = Enum.CameraType.Custom
                        cam.CameraSubject = humanoid
                    end
                end
            end)
        end
    end)

    notify("Root Lock", "Locked HRP to current position", 3)
end

local function disableRootLock()
    if RootLockConnection then
        RootLockConnection:Disconnect()
        RootLockConnection = nil
    end
    Config.RootLock.Enabled = false
    Config.RootLock.LockedCFrame = nil
    notify("Root Lock", "Released HRP lock", 2)
end

-- Auto Leave generator input listener
local function startAutoLeaveGenerator()
    if LeaveGeneratorConnection then return end
    
    LeaveGeneratorConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Config.AutoFeatures.LeaveKeybind then
            leaveGenerator()
        end
    end)
    
    notify("Auto Leave Enabled", string.format("Press %s to leave generator", Config.AutoFeatures.LeaveKeybind.Name), 3)
end

local function stopAutoLeaveGenerator()
    if LeaveGeneratorConnection then
        LeaveGeneratorConnection:Disconnect()
        LeaveGeneratorConnection = nil
    end
    notify("Auto Leave Disabled", "Keybind disabled", 2)
end

-- Auto Attack Functions
local function findClosestSurvivor()
    if not isKiller() then return nil, nil end
    
    local hrp = getCharacterRootPart()
    if not hrp then return nil, nil end
    
    local closestPlayer = nil
    local closestDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team and player.Team.Name == "Survivors" and player.Character then
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local dist = (targetHRP.Position - hrp.Position).Magnitude
                if dist < closestDist and dist <= Config.AutoFeatures.AttackRange then
                    closestDist = dist
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer, closestDist
end

local function performAutoAttack()
    if not isKiller() then return end
    
    local target, distance = findClosestSurvivor()
    if not target then return end
    
    safeCall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local attacks = remotes:FindFirstChild("Attacks")
            if attacks then
                local basicAttack = attacks:FindFirstChild("BasicAttack")
                if basicAttack then
                    basicAttack:FireServer(false)
                end
            end
        end
    end)
end

local function startAutoAttack()
    if AutoAttackConnection then return end
    
    if not isKiller() then
        notify("Error", "You must be the Killer to use Auto Attack!", 3)
        return
    end
    
    AutoAttackConnection = RunService.Heartbeat:Connect(function()
        if Config.AutoFeatures.AutoAttack then
            performAutoAttack()
        end
    end)
    
    notify("Auto Attack Enabled", string.format("Range: %d studs", Config.AutoFeatures.AttackRange), 3)
end

local function stopAutoAttack()
    if AutoAttackConnection then
        AutoAttackConnection:Disconnect()
        AutoAttackConnection = nil
    end
    notify("Auto Attack Disabled", "Auto attack stopped", 2)
end

local function getAllGenerators()
    local generators = {}
    local map = Workspace:FindFirstChild("Map")
    if not map then return generators end
    
    for _, obj in ipairs(map:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Generator" then
            local genPart = obj:FindFirstChildWhichIsA("BasePart")
            if genPart then
                table.insert(generators, {
                    model = obj,
                    part = genPart,
                    position = genPart.Position
                })
            end
        end
    end
    
    return generators
end

function getGeneratorsByDistance()
    local hrp = getCharacterRootPart()
    if not hrp then return {} end
    
    local generators = getAllGenerators()
    
    for _, gen in ipairs(generators) do
        gen.distance = (gen.position - hrp.Position).Magnitude
    end
    
    table.sort(generators, function(a, b)
        return a.distance < b.distance
    end)
    
    return generators
end

-- ESP Functions (unchanged)
local function createHighlight(obj, color)
    if not validateInstance(obj) then return end
    if obj:FindFirstChild("H") then return end
    
    safeCall(function()
        local h = Instance.new("Highlight")
        h.Name = "H"
        h.Adornee = obj
        h.FillColor = color
        h.OutlineColor = color
        h.FillTransparency = 0.5
        h.OutlineTransparency = 0
        h.Parent = obj
        Highlights[obj] = h
    end)
end

local function removeHighlight(obj)
    if Highlights[obj] then
        safeCall(function()
            if validateInstance(Highlights[obj]) then
                Highlights[obj]:Destroy()
            end
        end)
        Highlights[obj] = nil
    end
    
    local existingH = obj:FindFirstChild("H")
    if existingH then
        existingH:Destroy()
    end
end

local function createLabel(obj, text, color)
    if not validateInstance(obj) then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") or (obj:IsA("BasePart") and obj or nil)
    if not rootPart then return end
    
    local playerRoot = LocalPlayer.Character.HumanoidRootPart
    local distance = (playerRoot.Position - rootPart.Position).Magnitude
    
    if Config.Performance.UseDistanceCulling and distance > Config.ESP.MaxDistance then
        if BillboardGuis[obj] then
            safeCall(function()
                if validateInstance(BillboardGuis[obj]) then
                    BillboardGuis[obj]:Destroy()
                end
            end)
            BillboardGuis[obj] = nil
        end
        return
    end
    
    if BillboardGuis[obj] and validateInstance(BillboardGuis[obj]) then
        local textLabel = BillboardGuis[obj]:FindFirstChild("TextLabel")
        if textLabel and Config.ESP.ShowDistance then
            textLabel.Text = string.format("%s\n%.0fm", text, distance)
        elseif textLabel then
            textLabel.Text = text
        end
        return
    end
    
    safeCall(function()
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Adornee = rootPart
        billboard.Parent = obj
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = color
        textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        textLabel.TextStrokeTransparency = 0
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextScaled = true
        textLabel.Text = Config.ESP.ShowDistance and string.format("%s\n%.0fm", text, distance) or text
        textLabel.Parent = billboard
        
        BillboardGuis[obj] = billboard
    end)
end

local function removeLabel(obj)
    if BillboardGuis[obj] then
        safeCall(function()
            if validateInstance(BillboardGuis[obj]) then
                BillboardGuis[obj]:Destroy()
            end
        end)
        BillboardGuis[obj] = nil
    end
end

local function clearAllESP()
    for obj, h in pairs(Highlights) do
        removeHighlight(obj)
    end
    for obj, gui in pairs(BillboardGuis) do
        removeLabel(obj)
    end
    Highlights = {}
    BillboardGuis = {}
end

-- Update ESP Functions
local function updatePlayerESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Team then
            local teamName = player.Team.Name
            
            if teamName == "Killer" and Config.ESP.Killer then
                createHighlight(player.Character, Color3.fromRGB(255, 0, 0))
                createLabel(player.Character, player.Name .. "\n[KILLER]", Color3.fromRGB(255, 0, 0))
            elseif teamName == "Survivors" and Config.ESP.Survivor then
                createHighlight(player.Character, Color3.fromRGB(0, 255, 0))
                createLabel(player.Character, player.Name .. "\n[SURVIVOR]", Color3.fromRGB(0, 255, 0))
            else
                removeHighlight(player.Character)
                removeLabel(player.Character)
            end
        end
    end
end

local function updateGeneratorESP()
    if not Config.ESP.Generator then return end
    
    safeCall(function()
        local map = Workspace:FindFirstChild("Map")
        if not map then return end
        
        for _, obj in ipairs(map:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Generator" then
                createHighlight(obj, Color3.fromRGB(203, 132, 66))
                createLabel(obj, "Generator", Color3.fromRGB(203, 132, 66))
            end
        end
    end)
end

local function updateGateESP()
    if not Config.ESP.Gate then return end
    
    safeCall(function()
        local map = Workspace:FindFirstChild("Map")
        if not map then return end
        
        for _, obj in ipairs(map:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Gate" then
                createHighlight(obj, Color3.fromRGB(255, 255, 255))
                createLabel(obj, "Gate", Color3.fromRGB(255, 255, 255))
            end
        end
    end)
end

local function updateHookESP()
    if not Config.ESP.Hook then return end
    
    safeCall(function()
        local map = Workspace:FindFirstChild("Map")
        if not map then return end
        
        if Config.ESP.ShowOnlyClosestHook then
            local hrp = getCharacterRootPart()
            if not hrp then return end
            
            local closestHook = nil
            local closestDist = math.huge
            
            for _, obj in ipairs(map:GetDescendants()) do
                if obj:IsA("Model") and obj.Name == "Hook" then
                    local hookPart = obj:FindFirstChildWhichIsA("BasePart")
                    if hookPart then
                        local dist = (hookPart.Position - hrp.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestHook = obj
                        end
                    end
                end
            end
            
            for _, obj in ipairs(map:GetDescendants()) do
                if obj:IsA("Model") and obj.Name == "Hook" then
                    removeHighlight(obj)
                    removeLabel(obj)
                end
            end
            
            if closestHook then
                if closestHook:FindFirstChild("Model") then
                    for _, part in ipairs(closestHook.Model:GetDescendants()) do
                        if part:IsA("MeshPart") then
                            createHighlight(part, Color3.fromRGB(255, 255, 0))
                        end
                    end
                end
                createLabel(closestHook, "CLOSEST HOOK", Color3.fromRGB(255, 255, 0))
            end
        else
            for _, obj in ipairs(map:GetDescendants()) do
                if obj:IsA("Model") and obj.Name == "Hook" then
                    if obj:FindFirstChild("Model") then
                        for _, part in ipairs(obj.Model:GetDescendants()) do
                            if part:IsA("MeshPart") then
                                createHighlight(part, Color3.fromRGB(255, 0, 0))
                            end
                        end
                    end
                    createLabel(obj, "Hook", Color3.fromRGB(255, 0, 0))
                end
            end
        end
    end)
end

local function updatePalletESP()
    if not Config.ESP.Pallet then return end
    
    safeCall(function()
        local map = Workspace:FindFirstChild("Map")
        if not map then return end
        
        for _, obj in ipairs(map:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Palletwrong" then
                createHighlight(obj, Color3.fromRGB(255, 255, 0))
                createLabel(obj, "Pallet", Color3.fromRGB(255, 255, 0))
            end
        end
    end)
end

local function updateWindowESP()
    if not Config.ESP.Window then return end
    
    safeCall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Window" then
                createHighlight(obj, Color3.fromRGB(173, 216, 230))
                createLabel(obj, "Window", Color3.fromRGB(173, 216, 230))
            end
        end
    end)
end

local function updatePumpkinESP()
    if not Config.ESP.Pumpkin then return end
    
    safeCall(function()
        local map = Workspace:FindFirstChild("Map")
        if not map then return end
        
        local pumpkins = map:FindFirstChild("Pumpkins")
        if not pumpkins then return end
        
        for _, obj in ipairs(pumpkins:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:find("Pumpkin") then
                createHighlight(obj, Color3.fromRGB(255, 140, 0))
                createLabel(obj, "Pumpkin", Color3.fromRGB(255, 140, 0))
            end
        end
    end)
end

local function updateAllESP()
    local currentTime = tick()
    if currentTime - LastUpdate < Config.Performance.UpdateRate then return end
    LastUpdate = currentTime
    
    local espCount = 0
    local maxObjects = Config.Performance.MaxESPObjects
    
    for obj, h in pairs(Highlights) do
        if not validateInstance(obj) or not validateInstance(h) then
            Highlights[obj] = nil
        else
            espCount = espCount + 1
        end
    end
    
    for obj, gui in pairs(BillboardGuis) do
        if not validateInstance(obj) or not validateInstance(gui) then
            BillboardGuis[obj] = nil
        end
    end
    
    if espCount >= maxObjects then
        return
    end
    
    updatePlayerESP()
    updateGeneratorESP()
    updateGateESP()
    updateHookESP()
    updatePalletESP()
    updateWindowESP()
    updatePumpkinESP()
end

local function startESP()
    if UpdateConnection then return end
    UpdateConnection = RunService.Heartbeat:Connect(updateAllESP)
    notify("ESP Started", "All ESP features activated", 2)
end

local function stopESP()
    if UpdateConnection then
        UpdateConnection:Disconnect()
        UpdateConnection = nil
    end
    clearAllESP()
    notify("ESP Stopped", "All ESP disabled", 2)
end

-- Create Rayfield Window
local Window = Rayfield:CreateWindow({
    Name = "🎮 Golds Easy Hub - Violence District v2.2",
    LoadingTitle = "Loading Script",
    LoadingSubtitle = "by goldgoldgoldblazn",
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

-- Credits Tab (FIRST TAB - Default)
local CreditsTab = Window:CreateTab(" Credits & Info", 4483362458)

CreditsTab:CreateSection(" Main Developer")

CreditsTab:CreateLabel("Created by: goldgoldgoldblazn")
CreditsTab:CreateLabel("Version: 2.2")
CreditsTab:CreateLabel("")
CreditsTab:CreateLabel(" Thank you for using my script!")

CreditsTab:CreateSection(" Discord Community")

CreditsTab:CreateLabel("Join for updates, support & more!")
CreditsTab:CreateLabel("Discord: discord.gg/CnNqEVFxh6")

CreditsTab:CreateButton({
    Name = " Copy Discord Invite Link",
    Callback = function()
        local inviteLink = "https://discord.gg/CnNqEVFxh6"
        
        local success = pcall(function()
            setclipboard(inviteLink)
        end)
        
        if success then
            notify("Discord Link Copied!", "discord.gg/CnNqEVFxh6 copied to clipboard!", 4)
        else
            notify("Discord Server", "discord.gg/CnNqEVFxh6 - Copy this manually!", 5)
        end
    end
})

CreditsTab:CreateSection(" Script Information")

CreditsTab:CreateLabel("Game: Violence District")
CreditsTab:CreateLabel("Executor: " .. executorName)
CreditsTab:CreateLabel("UI Library: Rayfield by Sirius")

CreditsTab:CreateSection(" What's New in v2.2")

CreditsTab:CreateParagraph({
    Title = "Changes",
    Content = "Mobile components removed. Added Root Lock option (keeps your HumanoidRootPart at a fixed position)."
})

-- ESP Tab
local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)
ESPTab:CreateSection("Player ESP")

ESPTab:CreateToggle({
    Name = "Killer ESP (Red)",
    CurrentValue = false,
    Flag = "KillerESP",
    Callback = function(Value)
        Config.ESP.Killer = Value
        if Value then
            startESP()
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Team and player.Team.Name == "Killer" then
                    removeHighlight(player.Character)
                    removeLabel(player.Character)
                end
            end
        end
    end
})

ESPTab:CreateToggle({
    Name = "Survivor ESP (Green)",
    CurrentValue = false,
    Flag = "SurvivorESP",
    Callback = function(Value)
        Config.ESP.Survivor = Value
        if Value then
            startESP()
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Team and player.Team.Name == "Survivors" then
                    removeHighlight(player.Character)
                    removeLabel(player.Character)
                end
            end
        end
    end
})

ESPTab:CreateSection("Object ESP")

ESPTab:CreateToggle({
    Name = "Generator ESP (Orange)",
    CurrentValue = false,
    Flag = "GeneratorESP",
    Callback = function(Value)
        Config.ESP.Generator = Value
        if Value then
            startESP()
        else
            local map = Workspace:FindFirstChild("Map")
            if map then
                for _, obj in ipairs(map:GetDescendants()) do
                    if obj:IsA("Model") and obj.Name == "Generator" then
                        removeHighlight(obj)
                        removeLabel(obj)
                    end
                end
            end
        end
    end
})

ESPTab:CreateToggle({
    Name = "Gate ESP (White)",
    CurrentValue = false,
    Flag = "GateESP",
    Callback = function(Value)
        Config.ESP.Gate = Value
        if Value then
            startESP()
        end
    end
})

ESPTab:CreateToggle({
    Name = "Hook ESP (Red)",
    CurrentValue = false,
    Flag = "HookESP",
    Callback = function(Value)
        Config.ESP.Hook = Value
        if Value then
            startESP()
        else
            local map = Workspace:FindFirstChild("Map")
            if map then
                for _, obj in ipairs(map:GetDescendants()) do
                    if obj:IsA("Model") and obj.Name == "Hook" then
                        removeHighlight(obj)
                        removeLabel(obj)
                    end
                end
            end
        end
    end
})

ESPTab:CreateToggle({
    Name = "Show Only Closest Hook",
    CurrentValue = false,
    Flag = "ShowOnlyClosestHook",
    Callback = function(Value)
        Config.ESP.ShowOnlyClosestHook = Value
        
        local map = Workspace:FindFirstChild("Map")
        if map then
            for _, obj in ipairs(map:GetDescendants()) do
                if obj:IsA("Model") and obj.Name == "Hook" then
                    removeHighlight(obj)
                    removeLabel(obj)
                end
            end
        end
        
        if Config.ESP.Hook then
            updateHookESP()
        end
        
        notify("Hook ESP", Value and "Showing only closest hook" or "Showing all hooks", 2)
    end
})

ESPTab:CreateToggle({
    Name = "Pallet ESP (Yellow)",
    CurrentValue = false,
    Flag = "PalletESP",
    Callback = function(Value)
        Config.ESP.Pallet = Value
        if Value then
            startESP()
        end
    end
})

ESPTab:CreateToggle({
    Name = "Window ESP (Light Blue)",
    CurrentValue = false,
    Flag = "WindowESP",
    Callback = function(Value)
        Config.ESP.Window = Value
        if Value then
            startESP()
        end
    end
})

ESPTab:CreateToggle({
    Name = "Pumpkin ESP (Orange)",
    CurrentValue = false,
    Flag = "PumpkinESP",
    Callback = function(Value)
        Config.ESP.Pumpkin = Value
        if Value then
            startESP()
        end
    end
})

ESPTab:CreateSection("Settings")

ESPTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = true,
    Flag = "ShowDistance",
    Callback = function(Value)
        Config.ESP.ShowDistance = Value
    end
})

ESPTab:CreateSlider({
    Name = "Max Distance",
    Range = {100, 1000},
    Increment = 50,
    CurrentValue = 500,
    Flag = "MaxDistance",
    Callback = function(Value)
        Config.ESP.MaxDistance = Value
    end
})

ESPTab:CreateSlider({
    Name = "Update Rate (seconds)",
    Range = {0.1, 2},
    Increment = 0.1,
    CurrentValue = 0.5,
    Flag = "UpdateRate",
    Callback = function(Value)
        Config.Performance.UpdateRate = Value
    end
})

ESPTab:CreateSlider({
    Name = "Max ESP Objects",
    Range = {25, 500},
    Increment = 25,
    CurrentValue = 100,
    Flag = "MaxESPObjects",
    Callback = function(Value)
        Config.Performance.MaxESPObjects = Value
    end
})

-- Gameplay Tab
local GameplayTab = Window:CreateTab("🎮 Gameplay", 4483362458)
GameplayTab:CreateSection("Auto Features")

GameplayTab:CreateToggle({
    Name = "Auto Complete Generators",
    CurrentValue = false,
    Flag = "AutoGenerator",
    Callback = function(Value)
        Config.AutoFeatures.AutoGenerator = Value
        if Value then
            notify("Auto Generator", "Enabled - Generators will auto-complete", 3)
        else
            notify("Auto Generator", "Disabled", 2)
        end
    end
})

GameplayTab:CreateDropdown({
    Name = "Generator Mode",
    Options = {"Great (Fast)", "Normal (Slow)"},
    CurrentOption = "Great (Fast)",
    Flag = "GeneratorMode",
    Callback = function(Option)
        if Option == "Great (Fast)" then
            Config.AutoFeatures.GeneratorMode = "great"
        else
            Config.AutoFeatures.GeneratorMode = "normal"
        end
    end
})

GameplayTab:CreateSection("Quick Escape")

GameplayTab:CreateToggle({
    Name = "Enable Quick Leave Generator",
    CurrentValue = false,
    Flag = "AutoLeaveGenerator",
    Callback = function(Value)
        Config.AutoFeatures.AutoLeaveGenerator = Value
        if Value then
            startAutoLeaveGenerator()
        else
            stopAutoLeaveGenerator()
        end
    end
})

GameplayTab:CreateDropdown({
    Name = "Leave Generator Keybind",
    Options = {"Q", "E", "F", "G", "X", "Z", "V", "B"},
    CurrentOption = "Q",
    Flag = "LeaveKeybind",
    Callback = function(Option)
        local keyMap = {
            ["Q"] = Enum.KeyCode.Q,
            ["E"] = Enum.KeyCode.E,
            ["F"] = Enum.KeyCode.F,
            ["G"] = Enum.KeyCode.G,
            ["X"] = Enum.KeyCode.X,
            ["Z"] = Enum.KeyCode.Z,
            ["V"] = Enum.KeyCode.V,
            ["B"] = Enum.KeyCode.B
        }
        
        Config.AutoFeatures.LeaveKeybind = keyMap[Option]
        
        if Config.AutoFeatures.AutoLeaveGenerator then
            stopAutoLeaveGenerator()
            startAutoLeaveGenerator()
        end
        
        notify("Keybind Changed", "Leave generator key set to: " .. Option, 2)
    end
})

GameplayTab:CreateSlider({
    Name = "Detection Range (studs)",
    Range = {5, 30},
    Increment = 1,
    CurrentValue = 15,
    Flag = "LeaveDistance",
    Callback = function(Value)
        Config.AutoFeatures.LeaveDistance = Value
    end
})

GameplayTab:CreateButton({
    Name = "Leave Generator Now",
    Callback = function()
        leaveGenerator()
    end
})

GameplayTab:CreateSection("Manual Actions")

GameplayTab:CreateButton({
    Name = "Complete All Generators (Instant)",
    Callback = function()
        local map = Workspace:FindFirstChild("Map")
        if not map then
            notify("Error", "Map not found", 3)
            return
        end
        
        local completed = 0
        
        safeCall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if not remotes then return end
            
            local genRemotes = remotes:FindFirstChild("Generator")
            if not genRemotes then return end
            
            local repairEvent = genRemotes:FindFirstChild("RepairEvent")
            local skillCheckEvent = genRemotes:FindFirstChild("SkillCheckResultEvent")
            
            if not repairEvent or not skillCheckEvent then return end
            
            for _, obj in ipairs(map:GetDescendants()) do
                if obj:IsA("Model") and obj.Name == "Generator" then
                    for _, point in ipairs(obj:GetChildren()) do
                        if point.Name:find("GeneratorPoint") then
                            pcall(function()
                                for i = 1, 10 do
                                    repairEvent:FireServer(point, true)
                                    skillCheckEvent:FireServer("success", 1, obj, point)
                                end
                                completed = completed + 1
                            end)
                        end
                    end
                end
            end
        end)
        
        if completed > 0 then
            notify("Complete!", string.format("Completed %d generator(s)", completed), 4)
        else
            notify("Failed", "Could not find generators", 3)
        end
    end
})

GameplayTab:CreateSection("Killer Powers")

GameplayTab:CreateToggle({
    Name = "Auto Attack Nearby Survivors",
    CurrentValue = false,
    Flag = "AutoAttack",
    Callback = function(Value)
        Config.AutoFeatures.AutoAttack = Value
        if Value then
            startAutoAttack()
        else
            stopAutoAttack()
        end
    end
})

GameplayTab:CreateSlider({
    Name = "Auto Attack Range (studs)",
    Range = {5, 20},
    Increment = 1,
    CurrentValue = 10,
    Flag = "AttackRange",
    Callback = function(Value)
        Config.AutoFeatures.AttackRange = Value
    end
})

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

-- Teleportation Tab
local TeleportTab = Window:CreateTab(" Teleport", 4483362458)
TeleportTab:CreateSection("Generator Teleportation")

TeleportTab:CreateButton({
    Name = "Teleport to Closest Generator",
    Callback = function()
        local generators = getGeneratorsByDistance()
        
        if #generators == 0 then
            notify("Not Found", "No generators found on the map", 3)
            return
        end
        
        local closest = generators[1]
        if safeTeleport(closest.part.CFrame) then
            notify("Teleported!", string.format("Teleported to closest generator (%.0fm)", closest.distance), 3)
        end
    end
})

TeleportTab:CreateButton({
    Name = "Teleport to Farthest Generator",
    Callback = function()
        local generators = getGeneratorsByDistance()
        
        if #generators == 0 then
            notify("Not Found", "No generators found on the map", 3)
            return
        end
        
        local farthest = generators[#generators]
        if safeTeleport(farthest.part.CFrame) then
            notify("Teleported!", string.format("Teleported to farthest generator (%.0fm)", farthest.distance), 3)
        end
    end
})

TeleportTab:CreateButton({
    Name = "Teleport Through All Generators",
    Callback = function()
        local generators = getGeneratorsByDistance()
        
        if #generators == 0 then
            notify("Not Found", "No generators found", 3)
            return
        end
        
        notify("Starting", string.format("Teleporting through %d generators...", #generators), 3)
        
        task.spawn(function()
            for i, gen in ipairs(generators) do
                if not getCharacterRootPart() then break end
                
                safeTeleport(gen.part.CFrame)
                notify("Generator " .. i, string.format("At generator %d/%d (%.0fm)", i, #generators, gen.distance), 2)
                
                task.wait(Config.Teleportation.TeleportDelay)
            end
            
            notify("Complete!", "Visited all generators", 3)
        end)
    end
})

TeleportTab:CreateButton({
    Name = "Show Generator List (Console)",
    Callback = function()
        local generators = getGeneratorsByDistance()
        
        if #generators == 0 then
            notify("Not Found", "No generators found", 3)
            print("No generators found on the map")
            return
        end
        
        print("\n=== GENERATOR LIST ===")
        for i, gen in ipairs(generators) do
            print(string.format("%d. Generator at %.0fm - Position: %s", 
                i, gen.distance, tostring(gen.position)))
        end
        print("======================\n")
        
        notify("List Printed", string.format("Found %d generators - Check console (F9)", #generators), 3)
    end
})

TeleportTab:CreateSection("Other Teleports")

TeleportTab:CreateButton({
    Name = "Teleport to Nearest Gate",
    Callback = function()
        local hrp = getCharacterRootPart()
        if not hrp then
            notify("Error", "Character not found", 3)
            return
        end
        
        local map = Workspace:FindFirstChild("Map")
        if not map then
            notify("Error", "Map not found", 3)
            return
        end
        
        local nearestGate = nil
        local nearestDist = math.huge
        
        for _, obj in ipairs(map:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Gate" then
                local gatePart = obj:FindFirstChildWhichIsA("BasePart")
                if gatePart then
                    local dist = (gatePart.Position - hrp.Position).Magnitude
                    if dist < nearestDist then
                        nearestGate = gatePart
                        nearestDist = dist
                    end
                end
            end
        end
        
        if nearestGate then
            safeTeleport(nearestGate.CFrame)
            notify("Teleported", string.format("Teleported to gate (%.0fm)", nearestDist), 3)
        else
            notify("Not Found", "No gates found", 3)
        end
    end
})

TeleportTab:CreateSection("Survivor Win")

TeleportTab:CreateButton({
    Name = "Escape Game (Survivor Only)",
    Callback = function()
        if not isSurvivor() then
            notify("Error", "You must be a Survivor to use this!", 3)
            return
        end
        
        local hrp = getCharacterRootPart()
        if not hrp then
            notify("Error", "Character not found", 3)
            return
        end
        
        local map = Workspace:FindFirstChild("Map")
        if not map then
            notify("Error", "Map not found", 3)
            return
        end
        
        local gate = nil
        for _, obj in ipairs(map:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Gate" then
                gate = obj
                break
            end
        end
        
        if not gate then
            notify("Error", "No gates found on map", 3)
            return
        end
        
        local escapeZone = gate:FindFirstChild("Escape") or gate:FindFirstChildWhichIsA("BasePart")
        
        if escapeZone then
            safeTeleport(escapeZone.CFrame, Vector3.new(0, 5, 0))
            
            task.wait(0.5)
            
            safeCall(function()
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                if remotes then
                    local gateRemote = remotes:FindFirstChild("Gate")
                    if gateRemote then
                        local escapeEvent = gateRemote:FindFirstChild("Escape")
                        if escapeEvent then
                            escapeEvent:FireServer()
                        end
                    end
                end
            end)
            
            notify("Escape!", "Teleported to exit gate - Walk through to escape!", 4)
        else
            notify("Error", "Could not find escape zone", 3)
        end
    end
})

TeleportTab:CreateSection("Teleport Settings")

TeleportTab:CreateSlider({
    Name = "Teleport Height Offset",
    Range = {0, 10},
    Increment = 1,
    CurrentValue = 3,
    Flag = "TeleportOffset",
    Callback = function(Value)
        Config.Teleportation.TeleportOffset = Value
    end
})

TeleportTab:CreateSlider({
    Name = "Multi-Teleport Delay (seconds)",
    Range = {0.1, 5},
    Increment = 0.1,
    CurrentValue = 0.1,
    Flag = "TeleportDelay",
    Callback = function(Value)
        Config.Teleportation.TeleportDelay = Value
    end
})

TeleportTab:CreateToggle({
    Name = "Safe Teleport (Disable Collision)",
    CurrentValue = true,
    Flag = "SafeTeleport",
    Callback = function(Value)
        Config.Teleportation.SafeTeleport = Value
    end
})

-- Settings Tab
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

SettingsTab:CreateSection("Performance Options")

SettingsTab:CreateToggle({
    Name = "Disable Particles & Effects",
    CurrentValue = false,
    Flag = "DisableParticles",
    Callback = function(Value)
        Config.Performance.DisableParticles = Value
        applyPerformanceSettings()
        notify("Performance", Value and "Particles disabled" or "Particles enabled", 2)
    end
})

SettingsTab:CreateToggle({
    Name = "Lower Graphics Quality",
    CurrentValue = false,
    Flag = "LowerGraphics",
    Callback = function(Value)
        Config.Performance.LowerGraphics = Value
        applyPerformanceSettings()
        notify("Performance", Value and "Graphics lowered" or "Graphics reset", 2)
    end
})

SettingsTab:CreateToggle({
    Name = "Disable Shadows",
    CurrentValue = false,
    Flag = "DisableShadows",
    Callback = function(Value)
        Config.Performance.DisableShadows = Value
        applyPerformanceSettings()
        notify("Performance", Value and "Shadows disabled" or "Shadows enabled", 2)
    end
})

SettingsTab:CreateToggle({
    Name = "Reduce Render Distance",
    CurrentValue = false,
    Flag = "ReduceRenderDistance",
    Callback = function(Value)
        Config.Performance.ReduceRenderDistance = Value
        applyPerformanceSettings()
        notify("Performance", Value and "Render distance reduced" or "Render distance normal", 2)
    end
})

SettingsTab:CreateToggle({
    Name = "Use Distance Culling (ESP)",
    CurrentValue = true,
    Flag = "UseDistanceCulling",
    Callback = function(Value)
        Config.Performance.UseDistanceCulling = Value
        notify("Performance", Value and "Distance culling enabled" or "Distance culling disabled", 2)
    end
})

SettingsTab:CreateButton({
    Name = "Apply All Performance Boosts",
    Callback = function()
        Config.Performance.DisableParticles = true
        Config.Performance.LowerGraphics = true
        Config.Performance.DisableShadows = true
        Config.Performance.ReduceRenderDistance = true
        Config.Performance.UseDistanceCulling = true
        applyPerformanceSettings()
        notify("Performance", "All performance boosts applied!", 3)
    end
})

SettingsTab:CreateButton({
    Name = "Reset Performance Settings",
    Callback = function()
        Config.Performance.DisableParticles = false
        Config.Performance.LowerGraphics = false
        Config.Performance.DisableShadows = false
        Config.Performance.ReduceRenderDistance = false
        resetPerformanceSettings()
        notify("Performance", "Settings reset to default", 2)
    end
})

SettingsTab:CreateSection("Root Lock")

SettingsTab:CreateToggle({
    Name = "Lock Root to Current Position",
    CurrentValue = false,
    Flag = "RootLock",
    Callback = function(Value)
        if Value then
            enableRootLock()
        else
            disableRootLock()
        end
    end
})

SettingsTab:CreateSection("Display Options")

SettingsTab:CreateToggle({
    Name = "Show FPS Counter",
    CurrentValue = false,
    Flag = "FPSCounter",
    Callback = function(Value)
        if Value then
            createFPSCounter()
        else
            removeFPSCounter()
            notify("FPS Counter", "Disabled", 2)
        end
    end
})

SettingsTab:CreateSection("Script Controls")

SettingsTab:CreateButton({
    Name = "Clear All ESP",
    Callback = function()
        clearAllESP()
        notify("Cleared", "All ESP cleared", 2)
    end
})

SettingsTab:CreateButton({
    Name = "Refresh ESP",
    Callback = function()
        clearAllESP()
        updateAllESP()
        notify("Refreshed", "ESP refreshed", 2)
    end
})

SettingsTab:CreateButton({
    Name = "Unload Script",
    Callback = function()
        stopESP()
        clearAllESP()
        stopAutoLeaveGenerator()
        stopAutoAttack()
        resetPerformanceSettings()
        removeFPSCounter()
        disableRootLock()
        Rayfield:Destroy()
        notify("Unloaded", "Script unloaded", 2)
    end
})

-- Auto Generator Loop
task.spawn(function()
    while task.wait(0.2) do
        if Config.AutoFeatures.AutoGenerator then
            safeCall(function()
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                if not remotes then return end
                
                local genRemotes = remotes:FindFirstChild("Generator")
                if not genRemotes then return end
                
                local repairEvent = genRemotes:FindFirstChild("RepairEvent")
                local skillCheckEvent = genRemotes:FindFirstChild("SkillCheckResultEvent")
                
                if not repairEvent or not skillCheckEvent then return end
                
                local map = Workspace:FindFirstChild("Map")
                if not map then return end
                
                for _, obj in ipairs(map:GetDescendants()) do
                    if obj:IsA("Model") and obj.Name == "Generator" then
                        for _, point in ipairs(obj:GetChildren()) do
                            if point.Name:find("GeneratorPoint") then
                                pcall(function()
                                    repairEvent:FireServer(point, true)
                                    
                                    local result = Config.AutoFeatures.GeneratorMode == "great" and "success" or "neutral"
                                    local value = Config.AutoFeatures.GeneratorMode == "great" and 1 or 0
                                    skillCheckEvent:FireServer(result, value, obj, point)
                                end)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Final Notification
notify("Script Loaded!", "Violence District v2.2 loaded", 4)
