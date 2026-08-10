-- =============================================
-- CIVIC HUB - VIOLENCE DISTRICT
-- MODULE: FEATURES
-- BUILT BY VINZEE
-- VERSION 2.0.0
-- =============================================

-- Dependencies will be injected via setConfig/setUI
local Utils = nil

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local Camera = workspace.CurrentCamera

local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")

-- =======================================
-- CONSTANTS
local TeamColors = {
    Killer = Color3.fromRGB(255, 60, 60),
    Survivor = Color3.fromRGB(60, 255, 120)
}

local GeneratorColor = Color3.fromRGB(255, 170, 0)
local PalletColor = Color3.fromRGB(74, 255, 181)
local WindowColor = Color3.fromRGB(74, 255, 181)
local SCPColor = Color3.fromRGB(255, 0, 0)

local MaskedPowers = {"Cobra", "Richter", "Brandon", "Rabbit", "Alex"}

local EmoteList = {
    "Mannrobics",
    "Arm Swing",
    "Schadenfreude",
    "Kyoufuu",
    "Backflip",
    "Griddy",
    "Friday Night",
    "Floating Rest",
    "OnePlays",
    "Quick Combo",
    "WarCry",
    "Wave"
}

local KillerAnims = {
    ["rbxassetid://105374834496520"] = true,
    ["rbxassetid://113255068724446"] = true,
    ["rbxassetid://118907603246885"] = true,
    ["rbxassetid://129784271201071"] = true,
    ["rbxassetid://117042998468241"] = true,
    ["rbxassetid://122812055447896"] = true,
    ["rbxassetid://78935059863801"] = true,
    ["rbxassetid://74968262036854"] = true,
    ["rbxassetid://78432063483146"] = true,
    ["rbxassetid://132817836308238"] = true,
    ["rbxassetid://133963973694098"] = true,
    ["rbxassetid://111920872708571"] = true,
    ["rbxassetid://80411309607666"] = true,
    ["rbxassetid://98163597193511"] = true,
    ["rbxassetid://82666958311998"] = true,
    ["rbxassetid://110355011987939"] = true,
    ["rbxassetid://139369275981139"] = true,
    ["rbxassetid://135002183282873"] = true,
    ["rbxassetid://121216847022485"] = true,
    ["rbxassetid://130593238885843"] = true,
    ["rbxassetid://117070354890871"] = true,
    ["rbxassetid://106871536134254"] = true,
    ["rbxassetid://138720291317243"] = true
}

-- =======================================
-- REMOTES
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local RemotesAvailable = Remotes ~= nil

local CarryEvent = RemotesAvailable and Remotes:FindFirstChild("Carry") and Remotes.Carry:FindFirstChild("CarrySurvivorEvent")
local HookEvent = RemotesAvailable and Remotes:FindFirstChild("Carry") and Remotes.Carry:FindFirstChild("HookEvent")
local AttackEvent = RemotesAvailable and Remotes:FindFirstChild("Attacks") and Remotes.Attacks:FindFirstChild("BasicAttack")
local SkillCheckRemote = RemotesAvailable and Remotes:FindFirstChild("Generator") and Remotes.Generator:FindFirstChild("SkillCheckResultEvent")
local EmoteRemote = RemotesAvailable and Remotes:FindFirstChild("EmoteHandler")

-- Healing Remotes
local HealingRemotes = RemotesAvailable and Remotes:FindFirstChild("Healing")
local HealEvent = HealingRemotes and HealingRemotes:FindFirstChild("HealEvent")
local HealAnim = HealingRemotes and HealingRemotes:FindFirstChild("HealAnim")
local ResetHeal = HealingRemotes and HealingRemotes:FindFirstChild("Reset")

-- =======================================
-- STATE TRACKING
local ESPObjects = {}
local ESPConnections = {}
local StatusESP = {}
local CachedSCP = {}
local ParryCircle = nil
local CrosshairDrawings = {}
local MoonwalkConnection = nil
local MoonwalkButton = nil
local SkillHeartbeat = nil
local StalkConnection = nil
local GunAimConnection = nil
local AttackAimConnection = nil
local NoClipConnection = nil
local WalkSpeedConnection = nil
local KillerBusy = false
local KillerTarget = nil
local ParryActive = false
local busy = false
local lastParry = 0
local LastFlee = 0
local PARRY_DEBOUNCE = 0.2
local TouchID = 8822
local ActionPath = "Survivor-mob.Controls.action.check"
local hookedKillers = {}
local VaultTracks = {}
local currentJerkTool = nil
local DisabledEffects = {}
local OriginalValues = {
    WalkSpeed = 16,
    JumpPower = 50,
    FOV = 70,
}

-- Skill Check state tracking
local SkillCheckActive = false
local SkillCheckHandled = false
local CurrentRandomResult = nil

local Cached = {
    Generators = {},
    Windows = {},
    Pallets = {}
}

local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Blacklist

local EmoteButton = {
    Show = false,
    GuiInstance = nil,
    LabelRef = nil
}

-- =======================================
-- CURRENT CONFIG (will be set by Settings module)
local CurrentConfig = {
    -- Default values to prevent nil errors before config is set
    ESPRadius = 100,
    StatusRadius = 100,
    ParryDistance = 15,
    FaceSensitivity = 0.7,
    CrosshairX = 0,
    CrosshairY = 0,
    CameraFOV = 70,
    MaxZoomDistance = 1000,
    ClockTime = 14,
    Brightness = 2,
    WalkSpeedValue = 17.6,
    JumpPowerValue = 50,
    AttackDelay = 0.45,
    MoonwalkSpamSpeed = 30,
    MoonwalkIntensity = 35,
    AimFOV = 250,
    AimPrediction = 0.12,
    VaultSpeed = 1.2,
    AutoSkillCheck = false,
    SkillCheckMode = "Legit",
}

local function setConfig(config)
    -- Merge with defaults to ensure all required fields exist
    for k, v in pairs(CurrentConfig) do
        if config[k] == nil then
            config[k] = v
        end
    end
    CurrentConfig = config
end

local function getConfig()
    return CurrentConfig
end

-- =======================================
-- HELPER FUNCTIONS
local function getRoot()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function saveOriginalValues()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            OriginalValues.WalkSpeed = hum.WalkSpeed
            OriginalValues.JumpPower = hum.JumpPower
        end
    end
    local cam = workspace.CurrentCamera
    if cam then
        OriginalValues.FOV = cam.FieldOfView
    end
end

saveOriginalValues()

local function GetGameValue(obj, name)
    if not obj then return nil end
    local attr = obj:GetAttribute(name)
    if attr ~= nil then return attr end
    local child = obj:FindFirstChild(name)
    if child then
        local success, val = pcall(function() return child.Value end)
        if success then return val end
    end
    return nil
end

local function GetDowned()
    local root = getRoot()
    if not root then return nil end
    local best, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 and hum.Health <= hum.MaxHealth * 0.25 then
                local d = (hrp.Position - root.Position).Magnitude
                if d < dist then
                    dist = d
                    best = p.Character
                end
            end
        end
    end
    return best
end

local function GetHook()
    local root = getRoot()
    if not root then return nil end
    local bestHook = nil
    local shortestDistance = math.huge
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "HookPoint" and obj:IsA("BasePart") then
            local dist = (obj.Position - root.Position).Magnitude
            if dist < shortestDistance and dist < 400 then
                shortestDistance = dist
                bestHook = obj
            end
        end
    end
    return bestHook
end

local function GetNearestKiller()
    local root = getRoot()
    if not root then return nil, math.huge end
    local closest = nil
    local shortest = math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Team and plr.Team.Name == "Killer" and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = hrp
                end
            end
        end
    end
    return closest, shortest
end

local function GetNearestAliveSurvivor()
    local root = getRoot()
    if not root then return nil end
    local closest, shortest = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 30 then
                local d = (hrp.Position - root.Position).Magnitude
                if d < shortest then
                    shortest = d
                    closest = plr.Character
                end
            end
        end
    end
    return closest
end

local function GetFarthestGeneratorPoint(killerRoot)
    if not killerRoot then return nil end
    local bestPoint = nil
    local farthestDistance = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.match(obj.Name, "^GeneratorPoint%d+$") then
            local dist = (obj.Position - killerRoot.Position).Magnitude
            if dist > farthestDistance then
                farthestDistance = dist
                bestPoint = obj
            end
        end
    end
    return bestPoint
end

local function isDowned()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    return hum.Health <= 0
        or hum.Health < 2
        or char:GetAttribute("Downed") == true
        or char:GetAttribute("IsDown") == true
        or char:GetAttribute("Knocked") == true
end

local function isVisible(part)
    local cam = workspace.CurrentCamera
    if not cam then return false end
    RayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    local origin = cam.CFrame.Position
    local direction = (part.Position - origin)
    local result = workspace:Raycast(origin, direction, RayParams)
    if not result then return true end
    return result.Instance:IsDescendantOf(part.Parent)
end

local function normalizeId(id)
    local num = tostring(id):match("%d+")
    return num and ("rbxassetid://" .. num)
end

-- =======================================
-- CACHE OBJECTS
for _, obj in ipairs(workspace:GetDescendants()) do
    local name = string.lower(obj.Name)
    if string.find(name, "scp") then
        CachedSCP[obj] = true
    end
    if obj.Name == "Generator" then
        Cached.Generators[obj] = true
    elseif obj.Name == "Window" then
        Cached.Windows[obj] = true
    elseif obj.Name == "Pallet" or obj.Name == "Palletwrong" then
        Cached.Pallets[obj] = true
    end
end

workspace.DescendantAdded:Connect(function(obj)
    local name = string.lower(obj.Name)
    if string.find(name, "scp") then
        CachedSCP[obj] = true
    end
    if obj.Name == "Generator" then
        Cached.Generators[obj] = true
    elseif obj.Name == "Window" then
        Cached.Windows[obj] = true
    elseif obj.Name == "Pallet" or obj.Name == "Palletwrong" then
        Cached.Pallets[obj] = true
    end
end)

-- =======================================
-- ESP FUNCTIONS
local function removeESP(obj)
    if ESPObjects[obj] then
        ESPObjects[obj]:Destroy()
        ESPObjects[obj] = nil
    end
    local h = obj:FindFirstChild("GenHighlight")
    if h then h:Destroy() end
    local b = obj:FindFirstChild("GenESP")
    if b then b:Destroy() end
end

workspace.DescendantRemoving:Connect(function(obj)
    CachedSCP[obj] = nil
    Cached.Generators[obj] = nil
    Cached.Windows[obj] = nil
    Cached.Pallets[obj] = nil
    removeESP(obj)
end)

local function removeStatusESP(char)
    if StatusESP[char] then
        StatusESP[char]:Destroy()
        StatusESP[char] = nil
    end
end

local function clearAllESP()
    for obj, h in pairs(ESPObjects) do
        if h then
            h:Destroy()
        end
    end
    ESPObjects = {}

    for char, billboard in pairs(StatusESP) do
        if billboard then
            billboard:Destroy()
        end
    end
    StatusESP = {}

    for gen in pairs(Cached.Generators) do
        local h = gen:FindFirstChild("GenHighlight")
        if h then h:Destroy() end
        local b = gen:FindFirstChild("GenESP")
        if b then b:Destroy() end
    end
end

local function clearESPConnections()
    for _, conn in pairs(ESPConnections) do
        if conn then
            conn:Disconnect()
        end
    end
    ESPConnections = {}
end

local function createESP(obj, color)
    if not obj then return end
    if ESPObjects[obj] then
        ESPObjects[obj].FillColor = color
        ESPObjects[obj].OutlineColor = color
        return
    end
    local h = Instance.new("Highlight")
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = 0.9
    h.OutlineTransparency = 0.3
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = obj
    ESPObjects[obj] = h
    obj.AncestryChanged:Connect(function(_, parent)
        if not parent then
            removeESP(obj)
        end
    end)
end

local function ApplyGenHighlight(object, color)
    local h = object:FindFirstChild("GenHighlight") or Instance.new("Highlight")
    h.Name = "GenHighlight"
    h.Adornee = object
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = 0.9
    h.OutlineTransparency = 0.3
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = object
end

local function CreateBillboard(text, color)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "GenESP"
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.AlwaysOnTop = true
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = billboard
    return billboard
end

local function UpdateGenerator(generator)
    if not generator or not generator.Parent then return end
    if not CurrentConfig.GeneratorESP then
        removeESP(generator)
        return
    end
    local percent = GetGameValue(generator, "RepairProgress") or GetGameValue(generator, "Progress") or 0
    if percent >= 100 then
        removeESP(generator)
        return
    end
    local cp = math.clamp(percent, 0, 100)
    local color = GeneratorColor:Lerp(Color3.fromRGB(0, 255, 120), cp / 100)
    local text = string.format("[%.0f%%]", percent)
    local billboard = generator:FindFirstChild("GenESP")
    if not billboard then
        billboard = CreateBillboard(text, color)
        billboard.Adornee = generator
        billboard.Parent = generator
    else
        local lbl = billboard:FindFirstChildOfClass("TextLabel")
        if lbl then
            lbl.Text = text
            lbl.TextColor3 = color
        end
    end
    ApplyGenHighlight(generator, color)
end

local function UpdateMapESP(obj, root)
    if not obj or not root then return end
    local pos
    if obj:IsA("Model") then
        pos = obj:GetPivot().Position
    elseif obj:IsA("BasePart") then
        pos = obj.Position
    end
    if not pos then return end
    local distance = (pos - root.Position).Magnitude
    if obj.Name == "Window" and CurrentConfig.WindowESP and distance <= CurrentConfig.ESPRadius then
        createESP(obj, WindowColor)
    else
        removeESP(obj)
    end
    if (obj.Name == "Pallet" or obj.Name == "Palletwrong") and CurrentConfig.PalletESP and distance <= CurrentConfig.ESPRadius then
        createESP(obj, PalletColor)
    else
        removeESP(obj)
    end
end

local function createStatusESP(player, char, root)
    if not CurrentConfig.StatusESPEnabled then
        removeStatusESP(char)
        return
    end
    if not root then return end
    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not head or not hum then return end
    local isDown = hum.Health <= 0 or hum.Health < 2 or char:GetAttribute("Downed") == true or char:GetAttribute("IsDown") == true or char:GetAttribute("Knocked") == true
    local dist = (head.Position - root.Position).Magnitude
    if dist > CurrentConfig.StatusRadius then
        removeStatusESP(char)
        return
    end
    local text = ""
    if isDown then
        text = "🔻 DOWN\n"
    end
    if CurrentConfig.StatusShowName then
        text = text .. player.Name .. "\n"
    end
    if CurrentConfig.StatusShowDistance then
        text = text .. string.format("Dist: %.0f\n", dist)
    end
    if CurrentConfig.StatusShowHealth then
        text = text .. string.format("HP: %.0f\n", hum.Health)
    end
    if text == "" then
        removeStatusESP(char)
        return
    end
    local billboard = StatusESP[char]
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 120, 0, 50)
        billboard.AlwaysOnTop = true
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        local teamColor = Color3.new(1, 1, 1)
        if player.Team then
            if player.Team.Name == "Killer" then
                teamColor = TeamColors.Killer
            elseif player.Team.Name == "Survivors" then
                teamColor = TeamColors.Survivor
            end
        end
        if isDown then
            teamColor = Color3.fromRGB(255, 0, 0)
        end
        label.TextColor3 = teamColor
        label.TextStrokeTransparency = 0
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.Text = text
        label.Parent = billboard
        billboard.Adornee = head
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.Parent = char
        StatusESP[char] = billboard
    else
        local label = billboard:FindFirstChildOfClass("TextLabel")
        if label then
            label.Text = text
            local teamColor = Color3.new(1, 1, 1)
            if player.Team then
                if player.Team.Name == "Killer" then
                    teamColor = TeamColors.Killer
                elseif player.Team.Name == "Survivors" then
                    teamColor = TeamColors.Survivor
                end
            end
            if isDown then
                teamColor = Color3.fromRGB(255, 0, 0)
            end
            label.TextColor3 = teamColor
        end
    end
end

local function UpdateSCPEsp(root)
    if not CurrentConfig.SCPESP then
        for obj in pairs(CachedSCP) do
            removeESP(obj)
        end
        return
    end
    for obj in pairs(CachedSCP) do
        if obj and obj.Parent then
            local pos
            if obj:IsA("Model") then
                pos = obj:GetPivot().Position
            elseif obj:IsA("BasePart") then
                pos = obj.Position
            end
            if pos then
                local dist = (pos - root.Position).Magnitude
                if dist <= CurrentConfig.ESPRadius then
                    createESP(obj, SCPColor)
                else
                    removeESP(obj)
                end
            end
        end
    end
end

local function updateESP()
    local root = getRoot()
    if not root then return end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local distance = (hrp.Position - root.Position).Magnitude
                    if distance <= CurrentConfig.ESPRadius then
                        if CurrentConfig.SurvivorESP and p.Team and p.Team.Name == "Survivors" then
                            createESP(char, TeamColors.Survivor)
                        elseif CurrentConfig.KillerESP and p.Team and p.Team.Name == "Killer" then
                            createESP(char, TeamColors.Killer)
                        else
                            removeESP(char)
                        end
                    else
                        removeESP(char)
                    end
                end
                createStatusESP(p, char, root)
            else
                removeESP(char)
            end
        end
    end

    if CurrentConfig.GeneratorESP then
        for gen in pairs(Cached.Generators) do
            UpdateGenerator(gen)
        end
    else
        for gen in pairs(Cached.Generators) do
            removeESP(gen)
        end
    end

    for obj in pairs(Cached.Windows) do
        UpdateMapESP(obj, root)
    end
    for obj in pairs(Cached.Pallets) do
        UpdateMapESP(obj, root)
    end

    UpdateSCPEsp(root)
end

-- =======================================
-- CROSSHAIR
local created = false
local LastCrosshairStyle = nil

local function clearCrosshair()
    for _, v in pairs(CrosshairDrawings) do
        if v and v.Remove then v:Remove() end
    end
    CrosshairDrawings = {}
    created = false
end

local function drawCrosshair()
    if not CurrentConfig.CrosshairEnabled then
        for _, v in pairs(CrosshairDrawings) do
            if v then v.Visible = false end
        end
        return
    end
    if LastCrosshairStyle ~= CurrentConfig.CrosshairStyle then
        clearCrosshair()
        LastCrosshairStyle = CurrentConfig.CrosshairStyle
    end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local center = Vector2.new(
        cam.ViewportSize.X / 2 + CurrentConfig.CrosshairX,
        cam.ViewportSize.Y / 2 + CurrentConfig.CrosshairY
    )
    if not created then
        created = true
        if CurrentConfig.CrosshairStyle == "Plus" then
            for i = 1, 4 do
                local line = Drawing.new("Line")
                line.Visible = true
                table.insert(CrosshairDrawings, line)
            end
        elseif CurrentConfig.CrosshairStyle == "Dot" then
            local dot = Drawing.new("Circle")
            dot.Filled = true
            dot.Visible = true
            table.insert(CrosshairDrawings, dot)
        elseif CurrentConfig.CrosshairStyle == "Circle" then
            local circle = Drawing.new("Circle")
            circle.Filled = false
            circle.Visible = true
            table.insert(CrosshairDrawings, circle)
        end
    end
    local size = 8
    local thickness = 2
    local color = Color3.fromRGB(255, 255, 255)
    if CurrentConfig.CrosshairStyle == "Plus" then
        for _, line in pairs(CrosshairDrawings) do
            line.Color = color
            line.Thickness = thickness
        end
        CrosshairDrawings[1].From = center + Vector2.new(-size, 0)
        CrosshairDrawings[1].To = center + Vector2.new(-2, 0)
        CrosshairDrawings[2].From = center + Vector2.new(size, 0)
        CrosshairDrawings[2].To = center + Vector2.new(2, 0)
        CrosshairDrawings[3].From = center + Vector2.new(0, -size)
        CrosshairDrawings[3].To = center + Vector2.new(0, -2)
        CrosshairDrawings[4].From = center + Vector2.new(0, size)
        CrosshairDrawings[4].To = center + Vector2.new(0, 2)
    elseif CurrentConfig.CrosshairStyle == "Dot" then
        local dot = CrosshairDrawings[1]
        dot.Position = center
        dot.Radius = size / 2
        dot.Color = color
    elseif CurrentConfig.CrosshairStyle == "Circle" then
        local circle = CrosshairDrawings[1]
        circle.Position = center
        circle.Radius = size
        circle.Color = color
        circle.Thickness = thickness
    end
end

-- =======================================
-- PARRY SYSTEM
local function pressRightClick()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
    task.wait()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
end

local function GetActionTarget()
    local current = PlayerGui
    for segment in string.gmatch("Survivor-mob.Controls.Gui-mob", "[^%.]+") do
        current = current and current:FindFirstChild(segment)
    end
    return current
end

local function pressParryButton()
    if UserInputService.TouchEnabled then
        local btn = GetActionTarget()
        if btn and btn:IsA("GuiObject") then
            local pos = btn.AbsolutePosition
            local size = btn.AbsoluteSize
            local inset = GuiService:GetGuiInset()
            local x = pos.X + size.X / 2 + inset.X
            local y = pos.Y + size.Y / 2 + inset.Y
            VirtualInputManager:SendTouchEvent(8823, 0, x, y)
            task.wait(0.01)
            VirtualInputManager:SendTouchEvent(8823, 2, x, y)
        end
    else
        pressRightClick()
    end
end

local function doParry()
    local now = tick()
    if now - lastParry < PARRY_DEBOUNCE then return end
    lastParry = now
    ParryActive = true
    pressParryButton()
    task.delay(0.3, function()
        ParryActive = false
    end)
end

local function isInParryRange(killerChar)
    local myRoot = getRoot()
    if not myRoot or not killerChar then return false end
    local enemyRoot = killerChar:FindFirstChild("HumanoidRootPart")
    if not enemyRoot then return false end
    local dist = (enemyRoot.Position - myRoot.Position).Magnitude
    return dist <= CurrentConfig.ParryDistance
end

local function isFacingTarget(targetChar)
    if not CurrentConfig.FaceSensitivity or CurrentConfig.FaceSensitivity <= -1 then return true end
    local myChar = LocalPlayer.Character
    if not myChar then return false end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local enemyRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not myRoot or not enemyRoot then return false end
    local enemyForward = enemyRoot.CFrame.LookVector
    local directionToMe = (myRoot.Position - enemyRoot.Position).Unit
    local dot = enemyForward:Dot(directionToMe)
    return dot >= CurrentConfig.FaceSensitivity
end

local function hookKiller(char)
    if hookedKillers[char] then return end
    hookedKillers[char] = true
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return end
    animator.AnimationPlayed:Connect(function(track)
        if not CurrentConfig.AutoParry then return end
        local anim = track.Animation
        if not anim then return end
        local id = anim.AnimationId:match("%d+")
        if not id then return end
        local fullId = "rbxassetid://" .. id
        if KillerAnims[fullId] then
            if not isInParryRange(char) then return end
            if not isFacingTarget(char) then return end
            doParry()
        end
    end)
end

local function updateParryCircle()
    local root = getRoot()
    if not CurrentConfig.ShowParryRange or not root then
        if ParryCircle then
            ParryCircle:Destroy()
            ParryCircle = nil
        end
        return
    end
    if not ParryCircle then
        ParryCircle = Instance.new("Part")
        ParryCircle.Shape = Enum.PartType.Cylinder
        ParryCircle.Anchored = true
        ParryCircle.CanCollide = false
        ParryCircle.Material = Enum.Material.Neon
        ParryCircle.Name = "ParryRangeCircle"
        ParryCircle.Parent = workspace
    end
    local size = CurrentConfig.ParryDistance * 2
    ParryCircle.Size = Vector3.new(0.2, size, size)
    local yOffset = root.Size.Y / 2 + 1.5
    ParryCircle.CFrame = CFrame.new(root.Position - Vector3.new(0, yOffset, 0)) * CFrame.Angles(0, 0, math.rad(90))
    ParryCircle.Color = Color3.fromRGB(255, 80, 80)
    ParryCircle.Transparency = 0.9
end

-- =======================================
-- AUTO SKILL CHECK
local function pressSpace()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.wait()
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end

local function TriggerMobileButton()
    local b = GetActionTarget()
    if b and b:IsA("GuiObject") then
        local p, s, i = b.AbsolutePosition, b.AbsoluteSize, GuiService:GetGuiInset()
        local cx, cy = p.X + (s.X / 2) + i.X, p.Y + (s.Y / 2) + i.Y
        pcall(function()
            VirtualInputManager:SendTouchEvent(TouchID, 0, cx, cy)
            task.wait(0.01)
            VirtualInputManager:SendTouchEvent(TouchID, 2, cx, cy)
        end)
    end
end

local function startSkillCheck()
    if SkillHeartbeat then
        SkillHeartbeat:Disconnect()
        SkillHeartbeat = nil
    end
    if not CurrentConfig.AutoSkillCheck then return end

    -- Reset state for new skill check session
    SkillCheckActive = false
    SkillCheckHandled = false
    CurrentRandomResult = nil

    SkillHeartbeat = RunService.RenderStepped:Connect(function()
        if not CurrentConfig.AutoSkillCheck or busy then return end
        
        local prompt = PlayerGui:FindFirstChild("SkillCheckPromptGui")
        if not prompt then 
            -- Skill check prompt disappeared, reset state
            SkillCheckActive = false
            SkillCheckHandled = false
            CurrentRandomResult = nil
            return 
        end
        
        local check = prompt:FindFirstChild("Check")
        if not check or not check.Visible then 
            SkillCheckActive = false
            SkillCheckHandled = false
            CurrentRandomResult = nil
            return 
        end
        
        local line = check:FindFirstChild("Line")
        local goal = check:FindFirstChild("Goal")
        if not line or not goal then return end
        
        -- Detect new skill check
        if not SkillCheckActive then
            SkillCheckActive = true
            SkillCheckHandled = false
            
            -- Determine mode for this skill check
            local mode = CurrentConfig.SkillCheckMode or "Legit"
            if mode == "Random" then
                local modes = {"Instant", "Legit", "Fail"}
                CurrentRandomResult = modes[math.random(1, #modes)]
            else
                CurrentRandomResult = mode
            end
        end
        
        -- Skip if already handled
        if SkillCheckHandled then return end
        
        local lr = line.Rotation % 360
        local gr = goal.Rotation % 360
        local startRange = (gr + 102) % 360
        local endRange = (gr + 116) % 360
        local success = (startRange > endRange and (lr >= startRange or lr <= endRange))
            or (lr >= startRange and lr <= endRange)
        
        -- Handle Instant mode: position line directly to valid area
        if CurrentRandomResult == "Instant" then
            -- Calculate a valid rotation within the goal range
            local validRotation
            if startRange > endRange then
                -- Range wraps around 360
                validRotation = startRange
            else
                validRotation = (startRange + endRange) / 2
            end
            
            -- Set line rotation directly to valid position
            line.Rotation = validRotation
            
            -- Recalculate success after positioning
            lr = line.Rotation % 360
            success = (startRange > endRange and (lr >= startRange or lr <= endRange))
                or (lr >= startRange and lr <= endRange)
        end
        
        -- Handle Fail mode: never trigger
        if CurrentRandomResult == "Fail" then
            return
        end
        
        -- Trigger input when valid (Legit or Instant with valid position)
        if success then
            SkillCheckHandled = true
            busy = true
            task.spawn(function()
                if UserInputService.TouchEnabled then
                    TriggerMobileButton()
                else
                    pressSpace()
                end
                task.wait(0.05)
                busy = false
            end)
        end
    end)
end

local function stopSkillCheck()
    if SkillHeartbeat then
        SkillHeartbeat:Disconnect()
        SkillHeartbeat = nil
    end
    busy = false
    SkillCheckActive = false
    SkillCheckHandled = false
    CurrentRandomResult = nil
end

-- =======================================
-- AUTO STALK
local function getClosestSurvivorForStalk()
    local root = getRoot()
    if not root then return nil end
    local closest, shortest = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 30 then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist <= 150 and dist < shortest then
                    shortest = dist
                    closest = plr
                end
            end
        end
    end
    return closest
end

local function startAutoStalk()
    if StalkConnection then
        StalkConnection:Disconnect()
        StalkConnection = nil
    end
    if not CurrentConfig.AutoStalk then return end

    StalkConnection = RunService.Heartbeat:Connect(function()
        if not CurrentConfig.AutoStalk then return end
        local target = getClosestSurvivorForStalk()
        if not target or not target.Character then return end
        if RemotesAvailable then
            local stalkEvent = Remotes:FindFirstChild("Killers", true)
                and Remotes.Killers:FindFirstChild("Stalker", true)
                and Remotes.Killers.Stalker:FindFirstChild("StartStalking")
            if stalkEvent then
                pcall(function()
                    stalkEvent:FireServer(target)
                end)
            end
        end
    end)
end

local function stopAutoStalk()
    if StalkConnection then
        StalkConnection:Disconnect()
        StalkConnection = nil
    end
end

-- =======================================
-- AIMBOT
local function getClosestGunTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local closest = nil
    local shortest = CurrentConfig.AimFOV or 250
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Team then
            local valid = false
            if CurrentConfig.AimTarget == "Killer" and p.Team.Name == "Killer" then
                valid = true
            elseif CurrentConfig.AimTarget == "Survivor" and p.Team.Name == "Survivors" then
                valid = true
            end
            if valid then
                local hrp = p.Character:FindFirstChild(CurrentConfig.AimPart or "HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local pos, visible = cam:WorldToViewportPoint(hrp.Position)
                    if visible then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist < shortest then
                            if CurrentConfig.AimTarget == "Killer" then
                                if CurrentConfig.VisibilityCheck and not isVisible(hrp) then
                                    continue
                                end
                            end
                            shortest = dist
                            closest = hrp
                        end
                    end
                end
            end
        end
    end
    if CurrentConfig.AimTarget == "SCP" then
        for obj in pairs(CachedSCP) do
            if obj and obj.Parent then
                local part
                if obj:IsA("Model") then
                    part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                elseif obj:IsA("BasePart") then
                    part = obj
                end
                if part then
                    local pos, visible = cam:WorldToViewportPoint(part.Position)
                    if visible then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist < shortest then
                            shortest = dist
                            closest = part
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function getClosestAttackTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local closest = nil
    local shortest = 250
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team and p.Team.Name == "Survivors" and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local pos, visible = cam:WorldToViewportPoint(hrp.Position)
                if visible then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = hrp
                    end
                end
            end
        end
    end
    return closest
end

local function startGunAim()
    if GunAimConnection then
        GunAimConnection:Disconnect()
        GunAimConnection = nil
    end
    if not CurrentConfig.AimLockEnabled then return end

    GunAimConnection = RunService.RenderStepped:Connect(function()
        if not CurrentConfig.AimLockEnabled then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local target = getClosestGunTarget()
        if not target then return end
        local pos = target.Position
        if CurrentConfig.AimPrediction and CurrentConfig.AimPrediction > 0 then
            pos = pos + (target.AssemblyLinearVelocity * CurrentConfig.AimPrediction)
        end
        local cf = CFrame.new(cam.CFrame.Position, pos)
        cam.CFrame = cam.CFrame:Lerp(cf, 1)
    end)
end

local function stopGunAim()
    if GunAimConnection then
        GunAimConnection:Disconnect()
        GunAimConnection = nil
    end
end

local function startAttackAim()
    if AttackAimConnection then
        AttackAimConnection:Disconnect()
        AttackAimConnection = nil
    end
    if not CurrentConfig.AimLockAttack then return end

    AttackAimConnection = RunService.RenderStepped:Connect(function()
        if not CurrentConfig.AimLockAttack then return end
        local target = getClosestAttackTarget()
        if not target then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local pos = target.Position
        cam.CFrame = CFrame.new(cam.CFrame.Position, pos)
    end)
end

local function stopAttackAim()
    if AttackAimConnection then
        AttackAimConnection:Disconnect()
        AttackAimConnection = nil
    end
end

-- =======================================
-- MOONWALK BUTTON UI
local function createMoonwalkButton()
    if MoonwalkButton then MoonwalkButton:Destroy() end
    if not PlayerGui or not PlayerGui.Parent then return end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MoonwalkGui"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui

    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = UDim2.new(0.65, 0, 0.75, 0)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.9
    btn.Image = "rbxassetid://93349170559446"
    btn.ImageTransparency = 0.1
    btn.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = 1.2
    stroke.Color = CurrentConfig.MoonwalkEnabled and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.8
    stroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        toggleMoonwalk()
    end)

    MoonwalkButton = gui
end

local function removeMoonwalkButton()
    if MoonwalkButton then
        MoonwalkButton:Destroy()
        MoonwalkButton = nil
    end
end

-- =======================================
-- FAST VAULT
local function hookVault(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return end
    animator.AnimationPlayed:Connect(function(track)
        if not CurrentConfig.FastVault then return end
        local anim = track.Animation
        if not anim or not anim.AnimationId then return end
        local id = normalizeId(anim.AnimationId)
        if not id then return end
        local replaceMap = {
            ["rbxassetid://83873880822918"] = "rbxassetid://136962284480779"
        }
        local replaceId = replaceMap[id]
        if not replaceId then return end
        if VaultTracks[track] then return end
        VaultTracks[track] = true
        track:Stop()
        local newAnim = Instance.new("Animation")
        newAnim.AnimationId = replaceId
        local newTrack = animator:LoadAnimation(newAnim)
        newTrack.Priority = Enum.AnimationPriority.Action
        newTrack:Play()
        newTrack:AdjustSpeed(CurrentConfig.VaultSpeed or 1.2)
        newTrack.Stopped:Connect(function()
            VaultTracks[track] = nil
        end)
    end)
end

-- =======================================
-- JERK TOOL
local function createJerkTool()
    if currentJerkTool then currentJerkTool:Destroy() end
    if not CurrentConfig.JerkTool then return end

    local speaker = LocalPlayer
    local character = speaker.Character
    if not character then return end
    local humanoid = character:FindFirstChildWhichIsA("Humanoid")
    local backpack = speaker:FindFirstChildWhichIsA("Backpack")
    if not humanoid or not backpack then return end

    local tool = Instance.new("Tool")
    tool.Name = "Jerk Off"
    tool.ToolTip = "in the stripped club. straight up \"jorking it\" . and by \"it\" , haha, well. let's just say. My peanits."
    tool.RequiresHandle = false
    tool.Parent = backpack
    currentJerkTool = tool

    local jorkin = false
    local track = nil

    local function stopTomfoolery()
        jorkin = false
        if track then
            track:Stop()
            track = nil
        end
    end

    tool.Equipped:Connect(function() jorkin = true end)
    tool.Unequipped:Connect(stopTomfoolery)
    humanoid.Died:Connect(stopTomfoolery)

    task.spawn(function()
        while task.wait() do
            if not CurrentConfig.JerkTool or not jorkin then
                if track then track:Stop() end
                continue
            end
            local isR15 = humanoid.RigType == Enum.HumanoidRigType.R15
            if not track then
                local anim = Instance.new("Animation")
                anim.AnimationId = not isR15 and "rbxassetid://72042024" or "rbxassetid://698251653"
                track = humanoid:LoadAnimation(anim)
            end
            track:Play()
            track:AdjustSpeed(isR15 and 0.7 or 0.65)
            track.TimePosition = 0.6
            task.wait(0.1)
            while track and track.TimePosition < (not isR15 and 0.65 or 0.7) do
                task.wait(0.1)
            end
            if track then track:Stop() end
        end
    end)
end

-- =======================================
-- EMOTE
local function playEmote(name)
    if not EmoteRemote then
        return
    end
    pcall(function()
        EmoteRemote:FireServer(name)
    end)
end

local function createEmoteButton()
    if EmoteButton.GuiInstance then
        EmoteButton.GuiInstance:Destroy()
    end
    if not CurrentConfig.ShowEmoteButton then return end

    local gui = Instance.new("ScreenGui")
    gui.Name = "EmoteButtonGui"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui

    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = UDim2.new(0.55, 0, 0.75, 0)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.9
    btn.Image = "rbxassetid://93349170559446"
    btn.ImageTransparency = 0.1
    btn.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = 1.2
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.8
    stroke.Parent = btn

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 80, 0, 20)
    label.Position = UDim2.new(0.5, -40, -0.6, 0)
    label.BackgroundTransparency = 1
    label.Text = CurrentConfig.EmoteSelected or "Mannrobics"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.Parent = btn

    btn.MouseButton1Click:Connect(function()
        playEmote(CurrentConfig.EmoteSelected or "Mannrobics")
        stroke.Color = Color3.fromRGB(90, 120, 210)
        task.delay(0.3, function()
            stroke.Color = Color3.fromRGB(255, 255, 255)
        end)
    end)

    EmoteButton.GuiInstance = gui
    EmoteButton.LabelRef = label
end

local function removeEmoteButton()
    if EmoteButton.GuiInstance then
        EmoteButton.GuiInstance:Destroy()
        EmoteButton.GuiInstance = nil
        EmoteButton.LabelRef = nil
    end
end

-- =======================================
-- MOVEMENT FUNCTIONS
local function applyJumpPower()
    if not CurrentConfig.JumpPowerEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.JumpPower = CurrentConfig.JumpPowerValue
    end
end

local function shouldDisableWalkSpeed()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local anim = track.Animation
                if anim and anim.AnimationId then
                    local id = anim.AnimationId:match("%d+")
                    if id then
                        local fullId = "rbxassetid://" .. id
                        if KillerAnims[fullId] then
                            return true
                        end
                    end
                end
            end
        end
    end
    if hum and (hum.Health <= 0 or hum.Health < 2 or char:GetAttribute("Downed") == true or char:GetAttribute("IsDown") == true or char:GetAttribute("Knocked") == true) then
        return true
    end
    return false
end

local function applyWalkSpeed()
    if WalkSpeedConnection then
        WalkSpeedConnection:Disconnect()
        WalkSpeedConnection = nil
    end
    if not CurrentConfig.WalkSpeedEnabled then return end

    WalkSpeedConnection = RunService.Heartbeat:Connect(function()
        if not CurrentConfig.WalkSpeedEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if shouldDisableWalkSpeed() then return end
        if hum.WalkSpeed ~= CurrentConfig.WalkSpeedValue then
            hum.WalkSpeed = CurrentConfig.WalkSpeedValue
        end
    end)
end

local function stopWalkSpeed()
    if WalkSpeedConnection then
        WalkSpeedConnection:Disconnect()
        WalkSpeedConnection = nil
    end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = OriginalValues.WalkSpeed
        end
    end
end

local function toggleNoClip(state)
    CurrentConfig.NoClip = state
    if state then
        if NoClipConnection then NoClipConnection:Disconnect() end
        NoClipConnection = RunService.RenderStepped:Connect(function()
            if CurrentConfig.NoClip then
                local char = LocalPlayer.Character
                if char then
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") and v.CanCollide then
                            v.CanCollide = false
                        end
                    end
                end
            end
        end)
    else
        if NoClipConnection then
            NoClipConnection:Disconnect()
            NoClipConnection = nil
        end
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
    end
end

local function applyGodMode()
    if not CurrentConfig.AntiKnockDown then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if hum.Health < hum.MaxHealth then
        pcall(function() hum.Health = hum.MaxHealth end)
    end
    local state = hum:GetState()
    if state == Enum.HumanoidStateType.Dead or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Ragdoll then
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
    end
end

local function AutoWiggle()
    if not CurrentConfig.AutoWiggle then return end
    local char = LocalPlayer.Character
    if not char then return end
    local carried = (char:FindFirstChild("IsCarried") and char.IsCarried.Value) or (char:FindFirstChild("IsCarrying") and char.IsCarrying.Value)
    if not carried then return end
    if not RemotesAvailable then return end
    local carry = Remotes:FindFirstChild("Carry")
    if not carry then return end
    local event = carry:FindFirstChild("SelfUnHookEvent")
    if not event then return end
    for i = 1, 5 do
        event:FireServer()
    end
end

-- =======================================
-- VISUAL FUNCTIONS
local originalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    GlobalShadows = Lighting.GlobalShadows
}

local function applyVisual(force)
    if force or not force then
        if CurrentConfig.Fullbright then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        else
            Lighting.Brightness = originalLighting.Brightness
            Lighting.ClockTime = originalLighting.ClockTime
            Lighting.Ambient = originalLighting.Ambient
            Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        end
        Lighting.GlobalShadows = not CurrentConfig.NoShadow
    end
    if CurrentConfig.NoShadow then
        Lighting.GlobalShadows = false
    end
    if not CurrentConfig.NoShadow and not CurrentConfig.Fullbright then
        Lighting.GlobalShadows = originalLighting.GlobalShadows
    end
end

local function applyOptimization(force)
    if force or not force then
        pcall(function()
            if CurrentConfig.LowGraphics then
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            else
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            end
        end)
        if CurrentConfig.CleanSky then
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("Sky") then
                    v:Destroy()
                end
            end
        end
    end
end

local ScreenEffectTypes = {
    "ColorCorrectionEffect",
    "DepthOfFieldEffect",
    "BlurEffect",
    "SunRaysEffect",
    "BloomEffect"
}

local function applyNoScreenEffects()
    if CurrentConfig.NoScreenEffects then
        for _, v in pairs(Lighting:GetChildren()) do
            for _, t in pairs(ScreenEffectTypes) do
                if v:IsA(t) then
                    DisabledEffects[v] = v.Enabled
                    v.Enabled = false
                end
            end
        end
    else
        for obj, state in pairs(DisabledEffects) do
            if obj and obj.Parent then
                obj.Enabled = state
            end
        end
        DisabledEffects = {}
    end
end

Lighting.ChildAdded:Connect(function(v)
    if not CurrentConfig.NoScreenEffects then return end
    task.wait()
    for _, t in pairs(ScreenEffectTypes) do
        if v:IsA(t) then
            DisabledEffects[v] = v.Enabled
            v.Enabled = false
        end
    end
end)

local function applyUnlimitedZoom()
    if CurrentConfig.UnlimitedZoom then
        LocalPlayer.CameraMaxZoomDistance = CurrentConfig.MaxZoomDistance or 1000
        LocalPlayer.CameraMinZoomDistance = 0
    else
        LocalPlayer.CameraMaxZoomDistance = 128
        LocalPlayer.CameraMinZoomDistance = 0.5
    end
end

local function applyCameraFOV()
    local cam = workspace.CurrentCamera
    if not cam then return end
    if CurrentConfig.CustomFOV then
        cam.FieldOfView = CurrentConfig.CameraFOV or 70
    else
        cam.FieldOfView = OriginalValues.FOV
    end
end

-- =======================================
-- TELEPORT FUNCTIONS
local function teleportToFinishLine()
    local root = getRoot()
    if not root then return end
    local found = nil
    for _, obj in ipairs(workspace:GetDescendants()) do
        if string.lower(obj.Name) == "fininshline" and obj:IsA("BasePart") then
            found = obj
            break
        end
    end
    if not found then
        return
    end
    root.CFrame = found.CFrame + Vector3.new(0, 5, 0)
end

-- =======================================
-- SELF HEAL SYSTEM
local isSelfHealing = false
local selfHealConnection = nil

local function canSelfHeal()
    local char = LocalPlayer.Character
    if not char then return false end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    -- Check character attributes for blocking states
    if char:GetAttribute("IsHooked") then return false end
    if char:GetAttribute("IsCarried") then return false end
    if char:GetAttribute("IsCarryingGift") then return false end
    
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if rootPart and rootPart:HasTag("doing action") then return false end
    
    -- Check if already healing
    local scriptContainer = char:FindFirstChild("script") or char:FindFirstChild("LocalPlayer") 
    if scriptContainer and scriptContainer:GetAttribute("isHealing") then return false end
    
    return true
end

local function startSelfHeal()
    if not canSelfHeal() then return end
    if isSelfHealing then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    isSelfHealing = true
    
    -- Set healing attribute
    local scriptContainer = char:FindFirstChild("script") or char
    if scriptContainer then
        scriptContainer:SetAttribute("isHealing", true)
    end
    
    -- Fire heal event to server (heal yourself)
    if HealEvent then
        HealEvent:FireServer(rootPart, true)
    end
    
    -- Optional: Fire anim event
    if HealAnim then
        HealAnim:FireServer(true)
    end
end

local function stopSelfHeal()
    if not isSelfHealing then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    
    -- Reset healing state
    isSelfHealing = false
    
    -- Fire heal event to server (stop healing)
    if HealEvent and rootPart then
        HealEvent:FireServer(rootPart, false)
    end
    
    -- Optional: Fire anim event
    if HealAnim then
        HealAnim:FireServer(false)
    end
    
    -- Reset attribute
    local scriptContainer = char:FindFirstChild("script") or char
    if scriptContainer then
        scriptContainer:SetAttribute("isHealing", false)
    end
    
    -- Send reset event
    if ResetHeal then
        ResetHeal:FireServer()
    end
end

local function toggleSelfHeal(state)
    if state then
        startSelfHeal()
    else
        stopSelfHeal()
    end
end

-- =======================================
-- CHARACTER ADDED
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.8)
    applyJumpPower()
    applyWalkSpeed()
    if CurrentConfig.NoClip then
        task.wait(0.3)
        toggleNoClip(true)
    end
    task.wait(0.5)
    applyVisual(true)
    applyCameraFOV()
    applyUnlimitedZoom()
    hookVault(char)
    applyNoScreenEffects()
    if CurrentConfig.MoonwalkEnabled then
        startMoonwalk()
    end
    if CurrentConfig.JerkTool then
        task.wait(1)
        createJerkTool()
    end
end)

if LocalPlayer.Character then
    hookVault(LocalPlayer.Character)
end

-- =======================================
-- MAIN LOOPS
local lastESPUpdate = 0
local lastGodMode = 0
local lastKillerUpdate = 0

RunService.Heartbeat:Connect(function()
    local now = tick()

    if now - lastGodMode >= 0.1 then
        lastGodMode = now
        applyGodMode()
        AutoWiggle()
    end

    if now - lastKillerUpdate >= 0.05 then
        lastKillerUpdate = now

        if CurrentConfig.AutoSpamAttack and AttackEvent then
            pcall(function() AttackEvent:FireServer(false) end)
        end

        if CurrentConfig.AutoKillAll and AttackEvent then
            local root = getRoot()
            if root then
                if not KillerTarget or not KillerTarget:FindFirstChild("Humanoid") or KillerTarget.Humanoid.Health <= 35 then
                    KillerTarget = GetNearestAliveSurvivor()
                end
                if KillerTarget then
                    local targetHRP = KillerTarget:FindFirstChild("HumanoidRootPart")
                    if targetHRP then
                        local velocity = targetHRP.AssemblyLinearVelocity
                        local predict = velocity * 0.15
                        local targetPos = targetHRP.Position + predict
                        local behind = targetHRP.CFrame.LookVector * -3
                        root.CFrame = CFrame.new(targetPos + behind, targetPos)
                    end
                    pcall(function() AttackEvent:FireServer(false) end)
                end
            end
        end

        if CurrentConfig.WalkSpeedEnabled then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                if shouldDisableWalkSpeed() then
                    if hum.WalkSpeed == CurrentConfig.WalkSpeedValue then
                        hum.WalkSpeed = OriginalValues.WalkSpeed
                    end
                else
                    if hum.WalkSpeed ~= CurrentConfig.WalkSpeedValue then
                        hum.WalkSpeed = CurrentConfig.WalkSpeedValue
                    end
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local root = getRoot()
    if not root then return end

    local now = tick()

    if now - lastESPUpdate >= 0.05 then
        lastESPUpdate = now
        updateESP()
        applyVisual()
        applyNoScreenEffects()
        updateParryCircle()
    end

    drawCrosshair()

    if CurrentConfig.CustomFOV then
        local cam = workspace.CurrentCamera
        if cam and cam.FieldOfView ~= CurrentConfig.CameraFOV then
            cam.FieldOfView = CurrentConfig.CameraFOV
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.8)
        if CurrentConfig.AutoParry then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Team and p.Team.Name == "Killer" then
                    hookKiller(p.Character)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if not CurrentConfig.AutoFlee then continue end
        local root = getRoot()
        if not root then continue end
        local killerRoot, distance = GetNearestKiller()
        if killerRoot and distance <= 50 and tick() - LastFlee > 0.1 then
            local point = GetFarthestGeneratorPoint(killerRoot)
            if point then
                LastFlee = tick()
                root.CFrame = point.CFrame + Vector3.new(0, 5, 0)
            end
        end
    end
end)

-- =======================================
-- MOONWALK - COMPLETE STATE MANAGEMENT
local function startMoonwalk()
    if MoonwalkConnection then
        MoonwalkConnection:Disconnect()
        MoonwalkConnection = nil
    end

    if not CurrentConfig.MoonwalkEnabled then return end

    MoonwalkConnection = RunService.RenderStepped:Connect(function()
        if not CurrentConfig.MoonwalkEnabled or ParryActive or isDowned() then return end

        local char = LocalPlayer.Character
        if not char or not char.Parent then return end

        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local cam = workspace.CurrentCamera

        if humanoid and hrp and cam then
            local look = cam.CFrame.LookVector
            local flatLook = Vector3.new(look.X, 0, look.Z)
            if flatLook.Magnitude > 0 then
                flatLook = flatLook.Unit
                local baseCF = CFrame.new(hrp.Position, hrp.Position + flatLook)
                local angle = math.sin(tick() * CurrentConfig.MoonwalkSpamSpeed) * CurrentConfig.MoonwalkIntensity
                hrp.CFrame = baseCF * CFrame.Angles(0, math.rad(angle), 0)
                humanoid:Move(Vector3.new(0, 0, 1), true)
            end
        end
    end)
end

local function stopMoonwalk()
    if MoonwalkConnection then
        MoonwalkConnection:Disconnect()
        MoonwalkConnection = nil
    end

    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if CurrentConfig.WalkSpeedEnabled then
                hum.WalkSpeed = CurrentConfig.WalkSpeedValue
            else
                hum.WalkSpeed = OriginalValues.WalkSpeed
            end
        end
    end
end

local function toggleMoonwalk(state)
    if state == nil then
        state = not CurrentConfig.MoonwalkEnabled
    end

    CurrentConfig.MoonwalkEnabled = state

    if state then
        startMoonwalk()
    else
        stopMoonwalk()
    end

    if MoonwalkButton then
        local stroke = MoonwalkButton:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Color = state and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(255, 255, 255)
        end
    end

    return CurrentConfig.MoonwalkEnabled
end

-- =======================================
-- EXPORT
return {
    -- State
    ESPObjects = ESPObjects,
    StatusESP = StatusESP,
    CachedSCP = CachedSCP,
    Cached = Cached,
    
    -- Config
    setConfig = setConfig,
    getConfig = getConfig,
    
    -- ESP
    removeESP = removeESP,
    removeStatusESP = removeStatusESP,
    clearAllESP = clearAllESP,
    updateESP = updateESP,
    
    -- Crosshair
    clearCrosshair = clearCrosshair,
    drawCrosshair = drawCrosshair,
    
    -- Parry
    updateParryCircle = updateParryCircle,
    
    -- Skill Check
    startSkillCheck = startSkillCheck,
    stopSkillCheck = stopSkillCheck,
    
    -- Auto Stalk
    startAutoStalk = startAutoStalk,
    stopAutoStalk = stopAutoStalk,
    
    -- Aimbot
    startGunAim = startGunAim,
    stopGunAim = stopGunAim,
    startAttackAim = startAttackAim,
    stopAttackAim = stopAttackAim,
    
    -- Moonwalk
    startMoonwalk = startMoonwalk,
    stopMoonwalk = stopMoonwalk,
    toggleMoonwalk = toggleMoonwalk,
    createMoonwalkButton = createMoonwalkButton,
    removeMoonwalkButton = removeMoonwalkButton,
    
    -- Movement
    applyWalkSpeed = applyWalkSpeed,
    stopWalkSpeed = stopWalkSpeed,
    toggleNoClip = toggleNoClip,
    applyJumpPower = applyJumpPower,
    
    -- Visual
    applyVisual = applyVisual,
    applyOptimization = applyOptimization,
    applyNoScreenEffects = applyNoScreenEffects,
    applyUnlimitedZoom = applyUnlimitedZoom,
    applyCameraFOV = applyCameraFOV,
    applyFPSBoost = function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.ShadowSoftness = 0
        if Lighting:FindFirstChildOfClass("Sky") then
            Lighting:FindFirstChildOfClass("Sky"):Destroy()
        end
    end,
    disableFPSBoost = function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        Lighting.ShadowSoftness = originalLighting and originalLighting.ShadowSoftness or 1
    end,
    applyReduceGraphics = function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.ShadowSoftness = 0
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Sky") then
                v:Destroy()
            end
        end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Texture") or obj:IsA("SurfaceAppearance") then
                pcall(function()
                    obj.Transparency = 1
                end)
            end
        end
    end,
    disableReduceGraphics = function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        Lighting.ShadowSoftness = originalLighting and originalLighting.ShadowSoftness or 1
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Texture") or obj:IsA("SurfaceAppearance") then
                pcall(function()
                    obj.Transparency = 0
                end)
            end
        end
    end,
    
    -- Emote
    playEmote = playEmote,
    createEmoteButton = createEmoteButton,
    removeEmoteButton = removeEmoteButton,
    
    -- Tools
    createJerkTool = createJerkTool,
    
    -- Teleport
    teleportToFinishLine = teleportToFinishLine,
    
    -- Self Heal
    startSelfHeal = startSelfHeal,
    stopSelfHeal = stopSelfHeal,
    toggleSelfHeal = toggleSelfHeal,
    canSelfHeal = canSelfHeal,
    
    -- Constants
    EmoteList = EmoteList,
    MaskedPowers = MaskedPowers,
    
    -- Misc
    getRoot = getRoot,
    getHumanoid = getHumanoid,
    isDowned = isDowned,
    RemotesAvailable = RemotesAvailable,
    OriginalValues = OriginalValues,

    -- Utils setter for remote compatibility
    setUtils = function(utilsModule)
        Utils = utilsModule
    end,
}
