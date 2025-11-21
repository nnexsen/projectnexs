local Hook = {
    Players = {
        ["Killer"] = {Color = Color3.fromRGB(255, 93, 108), On = true},
        ["Survivor"] = {Color = Color3.fromRGB(64, 224, 255), On = true}
    },
    Objects = {
        ["Generator"] = {Color = Color3.fromRGB(210, 87, 255), On = true},
        ["Gate"] = {Color = Color3.fromRGB(255, 255, 255), On = true},
        ["Pallet"] = {Color = Color3.fromRGB(74, 255, 181), On = true},
        ["Window"] = {Color = Color3.fromRGB(74, 255, 181), On = true},
        ["Hook"] = {Color = Color3.fromRGB(132, 255, 169), On = true}
    }
}

local folder = {
    ["Generator"] = workspace.Map,
    ["Gate"] = workspace.Map,
    ["Pallet"] = workspace.Map,
    ["Window"] = workspace,
    ["Hook"] = workspace.Map
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

local function createBillboard(text, color)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BitchHook"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 120, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 0, 0)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "BitchHook"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 10
    textLabel.TextWrapped = true
    textLabel.Parent = billboard
    
    return billboard
end

local function getPlayerRole(player)
    if player.Team then
        local teamName = player.Team.Name:lower()
        if teamName:find("killer") then
            return "Killer"
        elseif teamName:find("survivor") then
            return "Survivor"
        end
    end
    return "Survivor"
end

local function updatePlayerNametag(player)
    if not player.Character then return end
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local cacheKey = player.Name .. "_nametag"
    local currentTime = tick()
    
    if cache[cacheKey] and currentTime - cache[cacheKey] < 0.1 then
        return
    end
    cache[cacheKey] = currentTime
    
    local existingTag = humanoidRootPart:FindFirstChild("BitchHook")
    if existingTag then existingTag:Destroy() end
    
    local role = getPlayerRole(player)
    local color = role == "Killer" and Hook.Players["Killer"].Color or Hook.Players["Survivor"].Color
    
    local distance = 0
    if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        distance = math.floor((humanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude)
    end
    
    local nametagText = player.Name .. "\n[" .. distance .. " studs]"
    local nametag = createBillboard(nametagText, color)
    nametag.Adornee = humanoidRootPart
    nametag.Parent = humanoidRootPart
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= localPlayer and p.Character and p.Team then
        if p.Team.Name == "Killer" then
            ESP(p.Character, Hook.Players["Killer"].Color)
        elseif p.Team.Name == "Survivors" then
            ESP(p.Character, Hook.Players["Survivor"].Color)
        end
    end
end

for t, f in pairs(folder) do
    for _, obj in ipairs(f:GetDescendants()) do
        if t == "Hook" and obj.Name == "Hook" then
            if obj:FindFirstChild("Model") then
                for _, part in ipairs(obj.Model:GetDescendants()) do
                    if part:IsA("MeshPart") then
                        ESP(part, Hook.Objects["Hook"].Color)
                    end
                end
            end
            if obj:FindFirstChild("Cartoony Blood Puddle") then
                ESP(obj["Cartoony Blood Puddle"], Hook.Objects["Hook"].Color)
            end
        elseif obj.Name == (t == "Pallet" and "Palletwrong" or t) then
            ESP(obj, Hook.Objects[t].Color)
        end
    end
end

local lastUpdate = 0
RunService.Heartbeat:Connect(function()
    local currentTime = tick()
    if currentTime - lastUpdate < 0.1 then return end
    lastUpdate = currentTime
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            updatePlayerNametag(player)
        end
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            updatePlayerNametag(player)
        end)
        if player.Character then
            updatePlayerNametag(player)
        end
    end
end
