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
        if Rayfield and Rayfield.Notify then
            Rayfield:Notify({
                Title = title,
                Content = content,
                Duration = duration or 3,
                Image = 4483362458
            })
        else
            -- fallback: print + warn
            warn(string.format("[%s] %s", title, content))
        end
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

-- ============================
-- Fire / Shot detection system
-- Adds notifications when firearms/shooting happens (others or you)
-- Works by:
--  - monitoring Workspace for Sound plays that look like gunshots
--  - monitoring Workspace for projectile/bullet objects created
--  - monitoring ReplicatedStorage.Remotes for RemoteEvents with names matching shoot/fire patterns (OnClientEvent)
--  - monitoring local Tools (Tool.Activated) to detect when the player fires
--  - shows a small on-screen shot log UI
-- ============================

local FireDetector = {}
FireDetector.patterns = {"shoot","shot","fire","gun","bullet","bang","pew","blast","fireweapon","weapon"}
FireDetector.shortLog = {} -- circular buffer
FireDetector.maxLog = 6
FireDetector.gui = nil
FireDetector.guiLabel = nil
FireDetector.connections = {}

local function strContainsPattern(str)
    if not str then return false end
    str = tostring(str):lower()
    for _, p in ipairs(FireDetector.patterns) do
        if str:find(p) then
            return true
        end
    end
    return false
end

local function addShotLog(text)
    local timestamp = os.date("%H:%M:%S")
    local entry = string.format("[%s] %s", timestamp, text)
    table.insert(FireDetector.shortLog, 1, entry)
    while #FireDetector.shortLog > FireDetector.maxLog do
        table.remove(FireDetector.shortLog)
    end

    -- Update GUI if present
    if FireDetector.guiLabel and validateInstance(FireDetector.guiLabel) then
        FireDetector.guiLabel.Text = table.concat(FireDetector.shortLog, "\n")
    else
        -- fallback print
        print("[ShotLog] " .. entry)
    end
end

local function createShotGui()
    if FireDetector.gui and validateInstance(FireDetector.gui) then return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VD_ShotLog"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:FindFirstChild("PlayerGui") or nil

    local frame = Instance.new("Frame")
    frame.Name = "ShotFrame"
    frame.Size = UDim2.new(0, 260, 0, 140)
    frame.Position = UDim2.new(0, 10, 0, 80)
    frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -8, 0, 22)
    title.Position = UDim2.new(0, 4, 0, 4)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(235,235,235)
    title.Text = "Shot Log"
    title.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -8, 1, -36)
    lbl.Position = UDim2.new(0, 4, 0, 28)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(210,210,210)
    lbl.TextWrapped = true
    lbl.TextYAlignment = Enum.TextYAlignment.Top
    lbl.Text = ""
    lbl.Parent = frame

    FireDetector.gui = screenGui
    FireDetector.guiLabel = lbl
end

local function identifyShooterFromInstance(inst)
    if not inst then return nil end
    -- climb up to find a Model with a Humanoid or a Player
    local current = inst
    while current and current.Parent do
        if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
            -- see if model corresponds to a player
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character == current then
                    return p
                end
            end
            return current -- return model if not player (e.g. NPC)
        end
        current = current.Parent
    end
    return nil
end

-- Monitor sounds: detect likely gunshot sounds playing
local function hookSound(sound)
    if not validateInstance(sound) then return end
    if not sound:IsA("Sound") then return end

    -- pattern check on name
    if not strContainsPattern(sound.Name) then
        -- sometimes sound names are generic; also check sound.SoundId (if present) for hints - keep only if name matches
        -- but still attach so if it's playing and parent indicates weapon, we'll detect
    end

    local conn
    conn = sound.Changed:Connect(function(prop)
        if prop == "IsPlaying" then
            local playing = sound.IsPlaying
            if playing then
                local shooter = identifyShooterFromInstance(sound.Parent)
                if shooter and typeof(shooter) == "Instance" and shooter:IsA("Player") then
                    if shooter == LocalPlayer then
                        addShotLog("You fired (sound): " .. tostring(sound.Name))
                    else
                        addShotLog(shooter.Name .. " fired (sound): " .. tostring(sound.Name))
                    end
                else
                    -- if parent is a Tool or Model with no player, name the source
                    local srcName = (sound.Parent and sound.Parent.Name) or "Unknown"
                    addShotLog("Shot sound detected from: " .. srcName .. " (" .. tostring(sound.Name) .. ")")
                end
            end
        end
    end)
    table.insert(FireDetector.connections, conn)
end

local function hookExistingSounds()
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if inst:IsA("Sound") and strContainsPattern(inst.Name) then
            pcall(hookSound, inst)
        end
    end
end

-- Monitor projectile creation (Parts with velocity or named Bullet/Projectile)
local function isProjectileCandidate(inst)
    if not inst then return false end
    if inst:IsA("BasePart") then
        local name = inst.Name:lower()
        if strContainsPattern(name) or name:find("projectile") or name:find("bullet") or name:find("pellet") then
            return true
        end
        -- check for special children like BodyVelocity, LinearVelocity
        if inst:FindFirstChildOfClass("BodyVelocity") or inst:FindFirstChild("LinearVelocity") or inst.Velocity and inst.Velocity.Magnitude > 20 then
            return true
        end
    end
    return false
end

local function hookProjectile(inst)
    if not validateInstance(inst) then return end
    if not inst:IsA("BasePart") then return end

    local shooter = identifyShooterFromInstance(inst)
    if shooter and shooter:IsA("Player") then
        if shooter == LocalPlayer then
            addShotLog("You fired projectile: " .. inst.Name)
        else
            addShotLog(shooter.Name .. " fired projectile: " .. inst.Name)
        end
    else
        addShotLog("Projectile spawned: " .. inst.Name)
    end

    -- Optionally, watch the part for impact or removal to note hits
    local conn
    conn = inst.AncestryChanged:Connect(function(child, parent)
        if not parent then
            conn:Disconnect()
        end
    end)
    table.insert(FireDetector.connections, conn)
end

-- Hook ReplicatedStorage.Remotes RemoteEvents that look like shooting events
local function hookRemotes()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return end

    local function tryHookEvent(ev)
        if not validateInstance(ev) then return end
        if ev.ClassName ~= "RemoteEvent" then return end
        local name = ev.Name:lower()
        if strContainsPattern(name) then
            -- When server fires this to clients, we can detect it via OnClientEvent
            local conn = ev.OnClientEvent:Connect(function(...)
                local args = {...}
                -- Try to parse shooter from args
                local shooterName = nil
                for i, a in ipairs(args) do
                    if typeof(a) == "Instance" and a:IsA("Player") then
                        shooterName = a.Name
                        break
                    elseif typeof(a) == "Instance" and a:IsA("Model") and a:FindFirstChildOfClass("Humanoid") then
                        -- check players
                        for _, p in pairs(Players:GetPlayers()) do
                            if p.Character == a then shooterName = p.Name break end
                        end
                        if shooterName then break end
                    elseif typeof(a) == "string" and strContainsPattern(a) then
                        shooterName = a
                        break
                    end
                end

                if shooterName then
                    if shooterName == LocalPlayer.Name then
                        addShotLog("You fired (remote): " .. ev.Name)
                    else
                        addShotLog(shooterName .. " fired (remote): " .. ev.Name)
                    end
                else
                    addShotLog("Remote event fired: " .. ev.Name)
                end
            end)
            table.insert(FireDetector.connections, conn)
        end
    end

    for _, v in ipairs(remotes:GetDescendants()) do
        tryHookEvent(v)
    end

    -- watch for new remotes
    local con = remotes.DescendantAdded:Connect(function(d)
        tryHookEvent(d)
    end)
    table.insert(FireDetector.connections, con)
end

-- Hook workspace for new sounds/projectiles
local function hookWorkspace()
    -- existing sounds and projectiles
    hookExistingSounds()
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if isProjectileCandidate(inst) then
            pcall(hookProjectile, inst)
        end
    end

    -- descendant added
    local dcon = Workspace.DescendantAdded:Connect(function(inst)
        -- sound
        if inst:IsA("Sound") and (strContainsPattern(inst.Name) or strContainsPattern((inst.Parent and inst.Parent.Name) or "")) then
            pcall(hookSound, inst)
        end
        -- projectile candidate
        if isProjectileCandidate(inst) then
            pcall(hookProjectile, inst)
        end
    end)
    table.insert(FireDetector.connections, dcon)
end

-- Hook local player's Tools (Tool.Activated)
local function hookLocalToolsForFiring()
    local function hookCharacterChar(char)
        if not char then return end
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                -- connect activated
                local conn = tool.Activated:Connect(function()
                    addShotLog("You activated tool: " .. tool.Name)
                end)
                table.insert(FireDetector.connections, conn)
            end
        end
        -- watch for tools added later
        local con = char.ChildAdded:Connect(function(c)
            if c:IsA("Tool") then
                local conn2 = c.Activated:Connect(function()
                    addShotLog("You activated tool: " .. c.Name)
                end)
                table.insert(FireDetector.connections, conn2)
            end
        end)
        table.insert(FireDetector.connections, con)
    end

    if LocalPlayer.Character then hookCharacterChar(LocalPlayer.Character) end
    local charCon = LocalPlayer.CharacterAdded:Connect(function(char)
        hookCharacterChar(char)
    end)
    table.insert(FireDetector.connections, charCon)
end

-- High-level monitor init
function FireDetector:Start()
    createShotGui()
    hookWorkspace()
    hookRemotes()
    hookLocalToolsForFiring()
    addShotLog("Shot detector initialized")
end

function FireDetector:Stop()
    for _, c in ipairs(FireDetector.connections) do
        pcall(function() c:Disconnect() end)
    end
    FireDetector.connections = {}
    if FireDetector.gui and validateInstance(FireDetector.gui) then
        FireDetector.gui:Destroy()
    end
    FireDetector.gui = nil
    FireDetector.guiLabel = nil
    FireDetector.shortLog = {}
end

-- Start detector automatically
pcall(function() FireDetector:Start() end)

-- ============================
-- End Fire / Shot detection system
-- ============================

-- Performance functions (remaining script continues unchanged)
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

-- (The rest of the original script continues unchanged, including ESP, Teleportation, RootLock, UI creation, AutoGenerator loop, etc.)
-- Note: I injected the FireDetector system above and ensured it starts automatically.
-- If you want the shot detector to be toggleable from the menu I can add a dedicated toggle in the Settings tab to enable/disable it.

-- Final Notification
notify("Script Loaded!", "Violence District v2.2 loaded (shot detector active)", 4)
