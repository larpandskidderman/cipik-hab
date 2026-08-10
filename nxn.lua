-- =============================================
-- CIVIC HUB - VIOLENCE DISTRICT
-- MIGRATED FROM FALLENS HUB TO VEXUI
-- BUILT BY VINZEE
-- VERSION 2.0.0
-- =============================================

-- LOAD VEXUI LIBRARY
local VexUI = loadstring(game:HttpGet("https://github.com/SSHRKs/VexUI/releases/latest/download/main.lua"))()

-- =======================================
-- SERVICES
local Stats = game:GetService("Stats")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

-- =======================================
-- CONSTANTS
local CIVIC_LOGO_ASSET = "rbxassetid://97658052504663"

-- =======================================
-- DEFAULT CONFIGURATION - SINGLE SOURCE OF TRUTH
local DefaultConfig = {
    -- ESP
    SurvivorESP = false,
    KillerESP = false,
    GeneratorESP = false,
    SCPESP = false,
    PalletESP = false,
    WindowESP = false,
    ESPRadius = 100,
    
    -- ESP Status
    StatusESPEnabled = false,
    StatusShowName = true,
    StatusShowDistance = true,
    StatusShowHealth = false,
    StatusRadius = 100,
    
    -- Crosshair
    CrosshairEnabled = false,
    CrosshairStyle = "Plus",
    CrosshairX = 0,
    CrosshairY = 0,
    
    -- Player
    AutoSkillCheck = false,
    AutoWiggle = false,
    AutoFlee = false,
    AntiKnockDown = false,
    FastVault = false,
    VaultSpeed = 1.2,
    MoonwalkShowButton = false,
    MoonwalkKeybind = nil,
    MoonwalkSpamSpeed = 30,
    MoonwalkIntensity = 35,
    MoonwalkEnabled = false,
    
    -- Killer
    AutoStalk = false,
    AimLockAttack = false,
    AutoKillAll = false,
    AutoSpamAttack = false,
    AttackDelay = 0.45,
    MaskedPower = "Cobra",
    
    -- Parry
    AutoParry = false,
    ShowParryRange = false,
    ParryDistance = 15,
    FaceSensitivity = 0.7,
    
    -- AimBot
    AimLockEnabled = false,
    AimTarget = "Killer",
    AimPart = "HumanoidRootPart",
    AimFOV = 250,
    AimPrediction = 0.12,
    
    -- Movement
    WalkSpeedEnabled = false,
    WalkSpeedValue = 17.6,
    NoClip = false,
    JumpPowerEnabled = false,
    JumpPowerValue = 50,
    
    -- Emote
    EmoteSelected = "Mannrobics",
    ShowEmoteButton = false,
    
    -- Fun
    JerkTool = false,
    
    -- Visual
    Fullbright = false,
    NoShadow = false,
    LowGraphics = false,
    NoScreenEffects = false,
    CleanSky = false,
    ClockTime = 14,
    Brightness = 2,
    
    -- Zoom
    UnlimitedZoom = false,
    MaxZoomDistance = 1000,
    CustomFOV = false,
    CameraFOV = 70,
    
    -- Theme
    Theme = "Dark",
    Transparent = false,
}

-- =======================================
-- CURRENT CONFIG - DEEP COPY
local function deepCopy(t)
    local copy = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            copy[k] = deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

local CurrentConfig = deepCopy(DefaultConfig)
local ConfigStorage = {}
local ConfigName = "MyConfig"
local AutoLoadEnabled = false
local AutoLoadConfigName = nil
local IsInitialLoad = true

-- =======================================
-- FILESYSTEM FUNCTIONS
local function isFileSystemAvailable()
    return pcall(function()
        return writefile and readfile and isfile and makefolder and isfolder
    end)
end

local function getConfigFolder()
    if not isFileSystemAvailable() then return nil end
    local folder = "CivicHub_Configs"
    pcall(function()
        if not isfolder(folder) then
            makefolder(folder)
        end
    end)
    return folder
end

local function getConfigFilePath(name)
    local folder = getConfigFolder()
    if not folder then return nil end
    return folder .. "/" .. name .. ".json"
end

local function saveConfigToFile(name, data)
    if not isFileSystemAvailable() then return false end
    local path = getConfigFilePath(name)
    if not path then return false end
    local success, result = pcall(function()
        local json = HttpService:JSONEncode(data)
        writefile(path, json)
        return true
    end)
    return success and result
end

local function loadConfigFromFile(name)
    if not isFileSystemAvailable() then return nil end
    local path = getConfigFilePath(name)
    if not path then return nil end
    if not isfile(path) then return nil end
    local success, result = pcall(function()
        local json = readfile(path)
        return HttpService:JSONDecode(json)
    end)
    if success then
        return result
    end
    return nil
end

local function listConfigFiles()
    if not isFileSystemAvailable() then return {} end
    local folder = getConfigFolder()
    if not folder then return {} end
    local files = {}
    pcall(function()
        for _, file in ipairs(listfiles(folder)) do
            local name = file:match("([^/\\]+)%.json$")
            if name then
                table.insert(files, name)
            end
        end
    end)
    return files
end

local function deleteConfigFile(name)
    if not isFileSystemAvailable() then return false end
    local path = getConfigFilePath(name)
    if not path then return false end
    if not isfile(path) then return false end
    pcall(function()
        delfile(path)
    end)
    return true
end

-- =======================================
-- STATE TRACKING
local OriginalValues = {
    WalkSpeed = 16,
    JumpPower = 50,
    FOV = 70,
}

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
local EmoteButton = {
    Show = false,
    GuiInstance = nil,
    LabelRef = nil
}
local DisabledEffects = {}
local Cached = {
    Generators = {},
    Windows = {},
    Pallets = {}
}
local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Blacklist

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

-- =======================================
-- CREATE MAIN WINDOW
local Window = VexUI:CreateWindow({
    Name = "Civic Hub",
    Icon = "door-open",
    SideBarWidth = 160,
    Theme = "Dark",
    Transparent = true,
    Author = "Built by Vinzee",
    User = {
        Enabled = true,
        Anonymous = true,
    },
})

local WindowInstance = Window

-- =======================================
-- SAFE REMOTE RETRIEVAL
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local RemotesAvailable = Remotes ~= nil

local CarryEvent = RemotesAvailable and Remotes:FindFirstChild("Carry") and Remotes.Carry:FindFirstChild("CarrySurvivorEvent")
local HookEvent = RemotesAvailable and Remotes:FindFirstChild("Carry") and Remotes.Carry:FindFirstChild("HookEvent")
local AttackEvent = RemotesAvailable and Remotes:FindFirstChild("Attacks") and Remotes.Attacks:FindFirstChild("BasicAttack")
local SkillCheckRemote = RemotesAvailable and Remotes:FindFirstChild("Generator") and Remotes.Generator:FindFirstChild("SkillCheckResultEvent")
local EmoteRemote = RemotesAvailable and Remotes:FindFirstChild("EmoteHandler")

-- ============== WATERMARK =================
local FPS = 0
local Frames = 0
local LastTick = tick()

RunService.RenderStepped:Connect(function()
    Frames += 1
    if tick() - LastTick >= 1 then
        FPS = Frames
        Frames = 0
        LastTick = tick()
        local Ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        if WindowInstance then
            WindowInstance:SetName(string.format("Civic Hub | FPS: %d | PING: %d ms", FPS, Ping))
        end
    end
end)

-- =======================================
-- TEAM COLORS
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
-- UTILITY FUNCTIONS
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

workspace.DescendantRemoving:Connect(function(obj)
    CachedSCP[obj] = nil
    Cached.Generators[obj] = nil
    Cached.Windows[obj] = nil
    Cached.Pallets[obj] = nil
    removeESP(obj)
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
-- ESP - COMPLETE CLEANUP SYSTEM
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
local function clearCrosshair()
    for _, v in pairs(CrosshairDrawings) do
        if v and v.Remove then v:Remove() end
    end
    CrosshairDrawings = {}
end

local created = false
local LastCrosshairStyle = nil

local function drawCrosshair()
    if not CurrentConfig.CrosshairEnabled then
        for _, v in pairs(CrosshairDrawings) do
            if v then v.Visible = false end
        end
        return
    end
    if LastCrosshairStyle ~= CurrentConfig.CrosshairStyle then
        clearCrosshair()
        created = false
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

local function GetParryButton()
    local current = PlayerGui
    for segment in string.gmatch("Survivor-mob.Controls.Gui-mob", "[^%.]+") do
        current = current and current:FindFirstChild(segment)
    end
    return current
end

local function pressParryButton()
    if UserInputService.TouchEnabled then
        local btn = GetParryButton()
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
    if CurrentConfig.MoonwalkEnabled then
        CurrentConfig.MoonwalkEnabled = false
        stopMoonwalk()
        if MoonwalkButton then
            local stroke = MoonwalkButton:FindFirstChildOfClass("UIStroke")
            if stroke then
                stroke.Color = Color3.fromRGB(255, 255, 255)
            end
        end
    end
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

local function GetActionTarget()
    local current = PlayerGui
    for segment in string.gmatch(ActionPath, "[^%.]+") do
        current = current and current:FindFirstChild(segment)
    end
    return current
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
    
    SkillHeartbeat = RunService.RenderStepped:Connect(function()
        if not CurrentConfig.AutoSkillCheck or busy then return end
        local prompt = PlayerGui:FindFirstChild("SkillCheckPromptGui")
        if not prompt then return end
        local check = prompt:FindFirstChild("Check")
        if not check or not check.Visible then return end
        local line = check:FindFirstChild("Line")
        local goal = check:FindFirstChild("Goal")
        if not line or not goal then return end
        local lr = line.Rotation % 360
        local gr = goal.Rotation % 360
        local startRange = (gr + 102) % 360
        local endRange = (gr + 116) % 360
        local success = (startRange > endRange and (lr >= startRange or lr <= endRange))
            or (lr >= startRange and lr <= endRange)
        if success then
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
        VexUI:Notification({
            Title = "Civic Hub",
            Desc = "Emote not available in this game",
            Duration = 2
        })
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
        VexUI:Notification({
            Title = "Civic Hub",
            Desc = "Finish line not found",
            Duration = 2
        })
        return
    end
    root.CFrame = found.CFrame + Vector3.new(0, 5, 0)
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
-- SAVE/LOAD CONFIG FUNCTIONS
function SaveAllSettings(configName)
    local configData = {
        Name = configName,
        Settings = deepCopy(CurrentConfig),
        AutoLoad = AutoLoadEnabled
    }
    
    if configName == ConfigName then
        ConfigName = configName
    end
    
    if isFileSystemAvailable() then
        local success = saveConfigToFile(configName, configData)
        if success then
            VexUI:Notification({
                Title = "Civic Hub",
                Desc = "Setting saved: " .. configName,
                Duration = 3
            })
        else
            VexUI:Notification({
                Title = "Civic Hub",
                Desc = "Failed to save config: " .. configName,
                Duration = 3
            })
        end
        return success
    else
        ConfigStorage[configName] = configData
        VexUI:Notification({
            Title = "Civic Hub",
            Desc = "Config saved in memory: " .. configName,
            Duration = 3
        })
        return true
    end
end

function LoadAllSettings(configName)
    local configData
    
    if isFileSystemAvailable() then
        configData = loadConfigFromFile(configName)
    else
        configData = ConfigStorage[configName]
    end
    
    if not configData then
        VexUI:Notification({
            Title = "Civic Hub",
            Desc = "Setting not found: " .. configName,
            Duration = 3
        })
        return false
    end
    
    local loadedSettings = configData.Settings
    
    -- Validate and apply settings
    local function validateValue(key, defaultValue, validator)
        local val = loadedSettings[key]
        if val ~= nil and (not validator or validator(val)) then
            return val
        end
        return defaultValue
    end
    
    -- Apply all settings with validation
    CurrentConfig.SurvivorESP = validateValue("SurvivorESP", false, type(_) == "boolean")
    CurrentConfig.KillerESP = validateValue("KillerESP", false, type(_) == "boolean")
    CurrentConfig.GeneratorESP = validateValue("GeneratorESP", false, type(_) == "boolean")
    CurrentConfig.SCPESP = validateValue("SCPESP", false, type(_) == "boolean")
    CurrentConfig.PalletESP = validateValue("PalletESP", false, type(_) == "boolean")
    CurrentConfig.WindowESP = validateValue("WindowESP", false, type(_) == "boolean")
    CurrentConfig.ESPRadius = validateValue("ESPRadius", 100, type(_) == "number")
    CurrentConfig.StatusESPEnabled = validateValue("StatusESPEnabled", false, type(_) == "boolean")
    CurrentConfig.StatusShowName = validateValue("StatusShowName", true, type(_) == "boolean")
    CurrentConfig.StatusShowDistance = validateValue("StatusShowDistance", true, type(_) == "boolean")
    CurrentConfig.StatusShowHealth = validateValue("StatusShowHealth", false, type(_) == "boolean")
    CurrentConfig.StatusRadius = validateValue("StatusRadius", 100, type(_) == "number")
    CurrentConfig.CrosshairEnabled = validateValue("CrosshairEnabled", false, type(_) == "boolean")
    CurrentConfig.CrosshairStyle = validateValue("CrosshairStyle", "Plus", function(v) return v == "Plus" or v == "Dot" or v == "Circle" end)
    CurrentConfig.CrosshairX = validateValue("CrosshairX", 0, type(_) == "number")
    CurrentConfig.CrosshairY = validateValue("CrosshairY", 0, type(_) == "number")
    CurrentConfig.AutoSkillCheck = validateValue("AutoSkillCheck", false, type(_) == "boolean")
    CurrentConfig.AutoWiggle = validateValue("AutoWiggle", false, type(_) == "boolean")
    CurrentConfig.AutoFlee = validateValue("AutoFlee", false, type(_) == "boolean")
    CurrentConfig.AntiKnockDown = validateValue("AntiKnockDown", false, type(_) == "boolean")
    CurrentConfig.FastVault = validateValue("FastVault", false, type(_) == "boolean")
    CurrentConfig.VaultSpeed = validateValue("VaultSpeed", 1.2, type(_) == "number")
    CurrentConfig.MoonwalkShowButton = validateValue("MoonwalkShowButton", false, type(_) == "boolean")
    CurrentConfig.MoonwalkKeybind = validateValue("MoonwalkKeybind", nil, function(v) return v == nil or type(v) == "string" end)
    CurrentConfig.MoonwalkSpamSpeed = validateValue("MoonwalkSpamSpeed", 30, type(_) == "number")
    CurrentConfig.MoonwalkIntensity = validateValue("MoonwalkIntensity", 35, type(_) == "number")
    CurrentConfig.AutoStalk = validateValue("AutoStalk", false, type(_) == "boolean")
    CurrentConfig.AimLockAttack = validateValue("AimLockAttack", false, type(_) == "boolean")
    CurrentConfig.AutoKillAll = validateValue("AutoKillAll", false, type(_) == "boolean")
    CurrentConfig.AutoSpamAttack = validateValue("AutoSpamAttack", false, type(_) == "boolean")
    CurrentConfig.AttackDelay = validateValue("AttackDelay", 0.45, type(_) == "number")
    CurrentConfig.MaskedPower = validateValue("MaskedPower", "Cobra", function(v) 
        for _, p in pairs(MaskedPowers) do
            if p == v then return true end
        end
        return false
    end)
    CurrentConfig.AutoParry = validateValue("AutoParry", false, type(_) == "boolean")
    CurrentConfig.ShowParryRange = validateValue("ShowParryRange", false, type(_) == "boolean")
    CurrentConfig.ParryDistance = validateValue("ParryDistance", 15, type(_) == "number")
    CurrentConfig.FaceSensitivity = validateValue("FaceSensitivity", 0.7, type(_) == "number")
    CurrentConfig.AimLockEnabled = validateValue("AimLockEnabled", false, type(_) == "boolean")
    CurrentConfig.AimTarget = validateValue("AimTarget", "Killer", function(v) return v == "Killer" or v == "Survivor" or v == "SCP" end)
    CurrentConfig.AimPart = validateValue("AimPart", "HumanoidRootPart", function(v) return v == "Head" or v == "HumanoidRootPart" or v == "Torso" end)
    CurrentConfig.AimFOV = validateValue("AimFOV", 250, type(_) == "number")
    CurrentConfig.AimPrediction = validateValue("AimPrediction", 0.12, type(_) == "number")
    CurrentConfig.WalkSpeedEnabled = validateValue("WalkSpeedEnabled", false, type(_) == "boolean")
    CurrentConfig.WalkSpeedValue = validateValue("WalkSpeedValue", 17.6, type(_) == "number")
    CurrentConfig.NoClip = validateValue("NoClip", false, type(_) == "boolean")
    CurrentConfig.JumpPowerEnabled = validateValue("JumpPowerEnabled", false, type(_) == "boolean")
    CurrentConfig.JumpPowerValue = validateValue("JumpPowerValue", 50, type(_) == "number")
    CurrentConfig.EmoteSelected = validateValue("EmoteSelected", "Mannrobics", function(v)
        for _, e in pairs(EmoteList) do
            if e == v then return true end
        end
        return false
    end)
    CurrentConfig.ShowEmoteButton = validateValue("ShowEmoteButton", false, type(_) == "boolean")
    CurrentConfig.JerkTool = validateValue("JerkTool", false, type(_) == "boolean")
    CurrentConfig.Fullbright = validateValue("Fullbright", false, type(_) == "boolean")
    CurrentConfig.NoShadow = validateValue("NoShadow", false, type(_) == "boolean")
    CurrentConfig.LowGraphics = validateValue("LowGraphics", false, type(_) == "boolean")
    CurrentConfig.NoScreenEffects = validateValue("NoScreenEffects", false, type(_) == "boolean")
    CurrentConfig.CleanSky = validateValue("CleanSky", false, type(_) == "boolean")
    CurrentConfig.ClockTime = validateValue("ClockTime", 14, type(_) == "number")
    CurrentConfig.Brightness = validateValue("Brightness", 2, type(_) == "number")
    CurrentConfig.UnlimitedZoom = validateValue("UnlimitedZoom", false, type(_) == "boolean")
    CurrentConfig.MaxZoomDistance = validateValue("MaxZoomDistance", 1000, type(_) == "number")
    CurrentConfig.CustomFOV = validateValue("CustomFOV", false, type(_) == "boolean")
    CurrentConfig.CameraFOV = validateValue("CameraFOV", 70, type(_) == "number")
    
    -- Theme and Transparency
    local theme = validateValue("Theme", "Dark", function(v) return v == "Dark" or v == "Light" or v == "Forest" or v == "Amethyst" end)
    local transparent = validateValue("Transparent", false, type(_) == "boolean")
    WindowInstance:SetTheme(theme)
    WindowInstance:SetTransparency(transparent)
    
    -- Moonwalk - only apply if explicitly enabled in config
    local moonwalkEnabled = validateValue("MoonwalkEnabled", false, type(_) == "boolean")
    if IsInitialLoad and AutoLoadEnabled then
        toggleMoonwalk(moonwalkEnabled)
    else
        toggleMoonwalk(false)
    end
    
    -- Apply all features
    applyVisual(true)
    applyOptimization(true)
    applyUnlimitedZoom()
    applyCameraFOV()
    applyNoScreenEffects()
    applyWalkSpeed()
    applyJumpPower()
    toggleNoClip(CurrentConfig.NoClip)
    startGunAim()
    startAttackAim()
    startSkillCheck()
    startAutoStalk()
    
    if CurrentConfig.MoonwalkShowButton then
        createMoonwalkButton()
    else
        removeMoonwalkButton()
    end
    
    if CurrentConfig.ShowEmoteButton then
        createEmoteButton()
    else
        removeEmoteButton()
    end
    
    if CurrentConfig.JerkTool then
        createJerkTool()
    else
        if currentJerkTool then
            currentJerkTool:Destroy()
            currentJerkTool = nil
        end
    end
    
    VexUI:Notification({
        Title = "Civic Hub",
        Desc = "Setting loaded: " .. configName,
        Duration = 3
    })
    
    return true
end

function UpdateAllSettings(configName)
    local configData
    
    if isFileSystemAvailable() then
        configData = loadConfigFromFile(configName)
    else
        configData = ConfigStorage[configName]
    end
    
    if not configData then
        VexUI:Notification({
            Title = "Civic Hub",
            Desc = "Config not found: " .. configName,
            Duration = 3
        })
        return false
    end
    
    return SaveAllSettings(configName)
end

function DeleteAllSettings(configName)
    if isFileSystemAvailable() then
        local success = deleteConfigFile(configName)
        if success then
            VexUI:Notification({
                Title = "Civic Hub",
                Desc = "Config deleted: " .. configName,
                Duration = 3
            })
        else
            VexUI:Notification({
                Title = "Civic Hub",
                Desc = "Failed to delete config",
                Duration = 3
            })
        end
        return success
    else
        ConfigStorage[configName] = nil
        VexUI:Notification({
            Title = "Civic Hub",
            Desc = "Config removed from memory: " .. configName,
            Duration = 3
        })
        return true
    end
end

function RefreshConfigList()
    local files = listConfigFiles()
    local options = {"Select Config"}
    for _, name in ipairs(files) do
        table.insert(options, name)
    end
    return options
end

-- =======================================
-- AUTO LOAD ON START
local function performAutoLoad()
    if not AutoLoadEnabled then return end
    local configName = AutoLoadConfigName or ConfigName
    if not configName or configName == "" or configName == "Select Config" then
        VexUI:Notification({
            Title = "Civic Hub",
            Desc = "No auto-load config specified",
            Duration = 3
        })
        return
    end
    IsInitialLoad = true
    local success = LoadAllSettings(configName)
    IsInitialLoad = false
    if success then
        VexUI:Notification({
            Title = "Civic Hub",
            Desc = "Auto-loaded: " .. configName,
            Duration = 3
        })
    else
        VexUI:Notification({
            Title = "Civic Hub",
            Desc = "No auto-load setting found: " .. configName,
            Duration = 3
        })
    end
end

-- =======================================
-- UI REFERENCES FOR SYNC
local SurvivorESP_Toggle
local KillerESP_Toggle
local GeneratorESP_Toggle
local SCPEsp_Toggle
local PalletESP_Toggle
local WindowESP_Toggle
local ESPRadius_Slider
local StatusESPEnabled_Toggle
local StatusShowName_Toggle
local StatusShowDistance_Toggle
local StatusShowHealth_Toggle
local StatusRadius_Slider
local CrosshairToggle_Toggle
local CrosshairStyle_Dropdown
local CrosshairX_Slider
local CrosshairY_Slider
local AutoSkillCheck_Toggle
local AutoWiggle_Toggle
local AutoFlee_Toggle
local AntiKnockDown_Toggle
local FastVault_Toggle
local VaultSpeed_Slider
local MoonwalkShowButton_Toggle
local MoonwalkKeybind_Keybind
local MoonwalkToggle_Toggle
local MoonwalkSpamSpeed_Slider
local MoonwalkIntensity_Slider
local AutoStalk_Toggle
local AimLockAttack_Toggle
local AutoKillAll_Toggle
local AutoSpamAttack_Toggle
local AttackDelay_Slider
local MaskedPower_Dropdown
local AutoParry_Toggle
local ShowParryRange_Toggle
local ParryDistance_Slider
local FaceSensitivity_Slider
local AimLockEnabled_Toggle
local AimTarget_Dropdown
local AimPart_Dropdown
local AimFOV_Slider
local AimPrediction_Slider
local WalkSpeed_Toggle
local WalkSpeedValue_Slider
local NoClip_Toggle
local JumpPowerEnabled_Toggle
local JumpPowerValue_Slider
local EmoteSelected_Dropdown
local ShowEmoteButton_Toggle
local JerkTool_Toggle
local Fullbright_Toggle
local NoShadow_Toggle
local LowGraphics_Toggle
local NoScreenEffects_Toggle
local CleanSky_Toggle
local ClockTime_Slider
local Brightness_Slider
local UnlimitedZoom_Toggle
local MaxZoomDistance_Slider
local CustomFOV_Toggle
local CameraFOV_Slider
local Transparent_Toggle
local Theme_Dropdown
local ToggleKey_Keybind

-- =======================================
-- UI CREATION
if not RemotesAvailable then
    VexUI:Notification({
        Title = "Civic Hub",
        Desc = "Some features may not work (Remotes not found)",
        Duration = 5
    })
end

-- TABS
local Tabs = {
    Info = Window:Tab({Title = "Info", Icon = "info", Border = true}),
    ESP = Window:Tab({Title = "ESP", Icon = "eye", Border = true}),
    Player = Window:Tab({Title = "Player", Icon = "user", Border = true}),
    Misc = Window:Tab({Title = "Misc", Icon = "sliders-horizontal", Border = true}),
    Visual = Window:Tab({Title = "Visual", Icon = "sparkles", Border = true}),
    Settings = Window:Tab({Title = "Settings", Icon = "settings-2", Border = true})
}

Window:SelectTab(1)

-- ============== INFO TAB =================
Tabs.Info:Section({Title = "Script Info", Icon = "info"})
Tabs.Info:Paragraph({
    Title = "Civic Hub",
    Desc = "Version: 2.0.0 | Game: Violence District",
    Icon = "circle-help"
})
Tabs.Info:Paragraph({
    Title = "Developer",
    Desc = "Built by Vinzee",
    Icon = "user"
})
Tabs.Info:Paragraph({
    Title = "Original Script",
    Desc = "•༶amill༶• (Fallens Hub)",
    Icon = "code"
})
Tabs.Info:Button({
    Title = "Copy Discord Link",
    Desc = "Join our community",
    Callback = function()
        setclipboard("https://discord.gg/52KS4yCD2")
        VexUI:Notification({
            Title = "Civic Hub",
            Desc = "Discord link copied!",
            Duration = 3
        })
    end
})
Tabs.Info:Button({
    Title = "Support Developer",
    Desc = "Copy support link",
    Callback = function()
        setclipboard("https://sociabuzz.com/amill_al/tribe")
        VexUI:Notification({
            Title = "Civic Hub",
            Desc = "Thanks for the support!",
            Duration = 3
        })
    end
})

-- ============== ESP TAB =================
Tabs.ESP:Section({Title = "ESP Cham", Icon = "scan-eye"})

SurvivorESP_Toggle = Tabs.ESP:Toggle({
    Title = "ESP Survivor",
    Value = false,
    Callback = function(v)
        CurrentConfig.SurvivorESP = v
    end
})

KillerESP_Toggle = Tabs.ESP:Toggle({
    Title = "ESP Killer",
    Value = false,
    Callback = function(v)
        CurrentConfig.KillerESP = v
    end
})

GeneratorESP_Toggle = Tabs.ESP:Toggle({
    Title = "Generator",
    Value = false,
    Callback = function(v)
        CurrentConfig.GeneratorESP = v
    end
})

SCPEsp_Toggle = Tabs.ESP:Toggle({
    Title = "SCP",
    Value = false,
    Callback = function(v)
        CurrentConfig.SCPESP = v
    end
})

PalletESP_Toggle = Tabs.ESP:Toggle({
    Title = "Pallet",
    Value = false,
    Callback = function(v)
        CurrentConfig.PalletESP = v
    end
})

WindowESP_Toggle = Tabs.ESP:Toggle({
    Title = "Window",
    Value = false,
    Callback = function(v)
        CurrentConfig.WindowESP = v
    end
})

ESPRadius_Slider = Tabs.ESP:Slider({
    Title = "ESP Radius",
    Value = {
        Min = 10,
        Max = 1000,
        Default = 100,
    },
    Step = 1,
    Callback = function(v)
        CurrentConfig.ESPRadius = v
    end
})

Tabs.ESP:Section({Title = "ESP Status", Icon = "activity"})

StatusESPEnabled_Toggle = Tabs.ESP:Toggle({
    Title = "Enable Status ESP",
    Value = false,
    Callback = function(v)
        CurrentConfig.StatusESPEnabled = v
    end
})

StatusShowName_Toggle = Tabs.ESP:Toggle({
    Title = "Show Name",
    Value = true,
    Callback = function(v)
        CurrentConfig.StatusShowName = v
    end
})

StatusShowDistance_Toggle = Tabs.ESP:Toggle({
    Title = "Show Distance",
    Value = true,
    Callback = function(v)
        CurrentConfig.StatusShowDistance = v
    end
})

StatusShowHealth_Toggle = Tabs.ESP:Toggle({
    Title = "Show Health",
    Value = false,
    Callback = function(v)
        CurrentConfig.StatusShowHealth = v
    end
})

StatusRadius_Slider = Tabs.ESP:Slider({
    Title = "Status Radius",
    Value = {
        Min = 20,
        Max = 500,
        Default = 100,
    },
    Step = 1,
    Callback = function(v)
        CurrentConfig.StatusRadius = v
    end
})

Tabs.ESP:Section({Title = "Crosshair", Icon = "crosshair"})

CrosshairToggle_Toggle = Tabs.ESP:Toggle({
    Title = "Enable Crosshair",
    Value = false,
    Callback = function(v)
        CurrentConfig.CrosshairEnabled = v
    end
})

CrosshairStyle_Dropdown = Tabs.ESP:Dropdown({
    Title = "Style",
    Option = {"Plus", "Dot", "Circle"},
    Value = "Plus",
    Multi = false,
    Callback = function(v)
        CurrentConfig.CrosshairStyle = v
    end
})

CrosshairX_Slider = Tabs.ESP:Slider({
    Title = "Position X",
    Value = {
        Min = -100,
        Max = 100,
        Default = 0,
    },
    Step = 1,
    Callback = function(v)
        CurrentConfig.CrosshairX = v
    end
})

CrosshairY_Slider = Tabs.ESP:Slider({
    Title = "Position Y",
    Value = {
        Min = -100,
        Max = 100,
        Default = 0,
    },
    Step = 1,
    Callback = function(v)
        CurrentConfig.CrosshairY = v
    end
})

-- ============== PLAYER TAB =================
Tabs.Player:Section({Title = "Survivor", Icon = "user-check"})

AutoSkillCheck_Toggle = Tabs.Player:Toggle({
    Title = "Auto Skill Check",
    Value = false,
    Callback = function(v)
        CurrentConfig.AutoSkillCheck = v
        if v then
            startSkillCheck()
        else
            stopSkillCheck()
        end
    end
})

AutoWiggle_Toggle = Tabs.Player:Toggle({
    Title = "Auto Wiggle",
    Value = false,
    Callback = function(v)
        CurrentConfig.AutoWiggle = v
    end
})

AutoFlee_Toggle = Tabs.Player:Toggle({
    Title = "Auto Flee Killer",
    Value = false,
    Callback = function(v)
        CurrentConfig.AutoFlee = v
    end
})

AntiKnockDown_Toggle = Tabs.Player:Toggle({
    Title = "Anti KnockDown",
    Value = false,
    Callback = function(v)
        CurrentConfig.AntiKnockDown = v
    end
})

FastVault_Toggle = Tabs.Player:Toggle({
    Title = "Fast Vault",
    Value = false,
    Callback = function(v)
        CurrentConfig.FastVault = v
    end
})

VaultSpeed_Slider = Tabs.Player:Slider({
    Title = "Vault Speed",
    Value = {
        Min = 1,
        Max = 5,
        Default = 1.2,
    },
    Step = 0.1,
    Callback = function(v)
        CurrentConfig.VaultSpeed = v
    end
})

MoonwalkShowButton_Toggle = Tabs.Player:Toggle({
    Title = "Moonwalk Button",
    Value = false,
    Callback = function(v)
        CurrentConfig.MoonwalkShowButton = v
        if v then
            createMoonwalkButton()
        else
            removeMoonwalkButton()
        end
    end
})

MoonwalkKeybind_Keybind = Tabs.Player:Keybind({
    Title = "Moonwalk Keybind",
    Value = "None",
    Callback = function(key)
        if key and key ~= "None" then
            CurrentConfig.MoonwalkKeybind = key
        end
        toggleMoonwalk()
    end
})

MoonwalkToggle_Toggle = Tabs.Player:Toggle({
    Title = "Moonwalk",
    Value = false,
    Callback = function(v)
        toggleMoonwalk(v)
    end
})

MoonwalkSpamSpeed_Slider = Tabs.Player:Slider({
    Title = "Moonwalk Spam Speed",
    Value = {
        Min = 1,
        Max = 50,
        Default = 30,
    },
    Step = 1,
    Callback = function(v)
        CurrentConfig.MoonwalkSpamSpeed = v
    end
})

MoonwalkIntensity_Slider = Tabs.Player:Slider({
    Title = "Moonwalk Intensity",
    Value = {
        Min = 1,
        Max = 50,
        Default = 35,
    },
    Step = 1,
    Callback = function(v)
        CurrentConfig.MoonwalkIntensity = v
    end
})

Tabs.Player:Button({
    Title = "Instant Escape",
    Desc = "Teleport to finish line",
    Callback = function()
        teleportToFinishLine()
    end
})

Tabs.Player:Section({Title = "Killer", Icon = "skull"})

AutoStalk_Toggle = Tabs.Player:Toggle({
    Title = "Auto Stalk",
    Value = false,
    Callback = function(v)
        CurrentConfig.AutoStalk = v
        if v then
            startAutoStalk()
        else
            stopAutoStalk()
        end
    end
})

AimLockAttack_Toggle = Tabs.Player:Toggle({
    Title = "AimLock Attack",
    Value = false,
    Callback = function(v)
        CurrentConfig.AimLockAttack = v
        if v then
            startAttackAim()
        else
            stopAttackAim()
        end
    end
})

AutoKillAll_Toggle = Tabs.Player:Toggle({
    Title = "Auto Kill All",
    Value = false,
    Callback = function(v)
        CurrentConfig.AutoKillAll = v
    end
})

AutoSpamAttack_Toggle = Tabs.Player:Toggle({
    Title = "Auto Spam Attack",
    Value = false,
    Callback = function(v)
        CurrentConfig.AutoSpamAttack = v
    end
})

AttackDelay_Slider = Tabs.Player:Slider({
    Title = "Attack Delay",
    Value = {
        Min = 0.1,
        Max = 1,
        Default = 0.45,
    },
    Step = 0.01,
    Callback = function(v)
        CurrentConfig.AttackDelay = v
    end
})

MaskedPower_Dropdown = Tabs.Player:Dropdown({
    Title = "Select Power",
    Option = MaskedPowers,
    Value = "Cobra",
    Multi = false,
    Callback = function(v)
        CurrentConfig.MaskedPower = v
    end
})

Tabs.Player:Button({
    Title = "Activate Power",
    Callback = function()
        if RemotesAvailable then
            local Event = Remotes:FindFirstChild("Killers", true)
                and Remotes.Killers:FindFirstChild("Masked", true)
                and Remotes.Killers.Masked:FindFirstChild("Activatepower")
            if Event then
                Event:FireServer(CurrentConfig.MaskedPower)
            else
                VexUI:Notification({
                    Title = "Civic Hub",
                    Desc = "Power not available",
                    Duration = 2
                })
            end
        end
    end
})

Tabs.Player:Button({
    Title = "Deactivate Power",
    Callback = function()
        if RemotesAvailable then
            local Event = Remotes:FindFirstChild("Killers", true)
                and Remotes.Killers:FindFirstChild("Masked", true)
                and Remotes.Killers.Masked:FindFirstChild("Deactivatepower")
            if Event then
                Event:FireServer()
            else
                VexUI:Notification({
                    Title = "Civic Hub",
                    Desc = "Power not available",
                    Duration = 2
                })
            end
        end
    end
})

Tabs.Player:Section({Title = "Parry", Icon = "swords"})

AutoParry_Toggle = Tabs.Player:Toggle({
    Title = "Auto Parry",
    Value = false,
    Callback = function(v)
        CurrentConfig.AutoParry = v
        if not v then
            CurrentConfig.ShowParryRange = false
            if ParryCircle then
                ParryCircle:Destroy()
                ParryCircle = nil
            end
        end
    end
})

ShowParryRange_Toggle = Tabs.Player:Toggle({
    Title = "Show Parry Range",
    Value = false,
    Callback = function(v)
        CurrentConfig.ShowParryRange = v
        if not v and ParryCircle then
            ParryCircle:Destroy()
            ParryCircle = nil
        end
    end
})

ParryDistance_Slider = Tabs.Player:Slider({
    Title = "Parry Distance",
    Value = {
        Min = 5,
        Max = 20,
        Default = 15,
    },
    Step = 1,
    Callback = function(v)
        CurrentConfig.ParryDistance = v
    end
})

FaceSensitivity_Slider = Tabs.Player:Slider({
    Title = "Face Sensitivity",
    Value = {
        Min = -1,
        Max = 1,
        Default = 0.7,
    },
    Step = 0.01,
    Callback = function(v)
        CurrentConfig.FaceSensitivity = v
    end
})

Tabs.Player:Section({Title = "AimBot", Icon = "crosshair"})

AimLockEnabled_Toggle = Tabs.Player:Toggle({
    Title = "Aim Lock",
    Value = false,
    Callback = function(v)
        CurrentConfig.AimLockEnabled = v
        if v then
            startGunAim()
        else
            stopGunAim()
        end
    end
})

AimTarget_Dropdown = Tabs.Player:Dropdown({
    Title = "Target",
    Option = {"Killer", "Survivor", "SCP"},
    Value = "Killer",
    Multi = false,
    Callback = function(v)
        CurrentConfig.AimTarget = v
    end
})

AimPart_Dropdown = Tabs.Player:Dropdown({
    Title = "Aim Part",
    Option = {"Head", "HumanoidRootPart", "Torso"},
    Value = "HumanoidRootPart",
    Multi = false,
    Callback = function(v)
        CurrentConfig.AimPart = v
    end
})

AimFOV_Slider = Tabs.Player:Slider({
    Title = "FOV",
    Value = {
        Min = 50,
        Max = 1000,
        Default = 250,
    },
    Step = 1,
    Callback = function(v)
        CurrentConfig.AimFOV = v
    end
})

AimPrediction_Slider = Tabs.Player:Slider({
    Title = "Prediction",
    Value = {
        Min = 0,
        Max = 1,
        Default = 0.12,
    },
    Step = 0.01,
    Callback = function(v)
        CurrentConfig.AimPrediction = v
    end
})

-- ============== MISC TAB =================
Tabs.Misc:Section({Title = "Movement", Icon = "move"})

WalkSpeed_Toggle = Tabs.Misc:Toggle({
    Title = "Walk Speed",
    Value = false,
    Callback = function(v)
        CurrentConfig.WalkSpeedEnabled = v
        if v then
            applyWalkSpeed()
        else
            stopWalkSpeed()
        end
    end
})

WalkSpeedValue_Slider = Tabs.Misc:Slider({
    Title = "Walk Speed Value",
    Value = {
        Min = 16,
        Max = 32,
        Default = 17.6,
    },
    Step = 0.1,
    Callback = function(v)
        CurrentConfig.WalkSpeedValue = v
        if CurrentConfig.WalkSpeedEnabled then
            applyWalkSpeed()
        end
    end
})

NoClip_Toggle = Tabs.Misc:Toggle({
    Title = "No Clip",
    Value = false,
    Callback = function(v)
        toggleNoClip(v)
    end
})

JumpPowerEnabled_Toggle = Tabs.Misc:Toggle({
    Title = "Custom Jump Power",
    Value = false,
    Callback = function(v)
        CurrentConfig.JumpPowerEnabled = v
        if v then
            applyJumpPower()
        else
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.JumpPower = OriginalValues.JumpPower
            end
        end
    end
})

JumpPowerValue_Slider = Tabs.Misc:Slider({
    Title = "Jump Power Value",
    Value = {
        Min = 0,
        Max = 300,
        Default = 50,
    },
    Step = 1,
    Callback = function(v)
        CurrentConfig.JumpPowerValue = v
        if CurrentConfig.JumpPowerEnabled then
            applyJumpPower()
        end
    end
})

Tabs.Misc:Section({Title = "Emote", Icon = "music"})

EmoteSelected_Dropdown = Tabs.Misc:Dropdown({
    Title = "Select Emote",
    Option = EmoteList,
    Value = "Mannrobics",
    Multi = false,
    Callback = function(v)
        CurrentConfig.EmoteSelected = v
        if EmoteButton.LabelRef then
            EmoteButton.LabelRef.Text = v
        end
    end
})

Tabs.Misc:Button({
    Title = "Play Emote",
    Callback = function()
        playEmote(CurrentConfig.EmoteSelected)
    end
})

ShowEmoteButton_Toggle = Tabs.Misc:Toggle({
    Title = "Show Emote Button",
    Value = false,
    Callback = function(v)
        CurrentConfig.ShowEmoteButton = v
        if v then
            createEmoteButton()
        else
            removeEmoteButton()
        end
    end
})

Tabs.Misc:Section({Title = "Fun", Icon = "smile"})

JerkTool_Toggle = Tabs.Misc:Toggle({
    Title = "Jerk Tool",
    Value = false,
    Callback = function(v)
        CurrentConfig.JerkTool = v
        if v then
            createJerkTool()
        else
            if currentJerkTool then
                currentJerkTool:Destroy()
                currentJerkTool = nil
            end
        end
    end
})

Tabs.Misc:Section({Title = "Morph Avatar", Icon = "user-cog"})

local targetUsernameInput
Tabs.Misc:Input({
    Title = "Target Username",
    Desc = "Enter username to copy avatar",
    Callback = function(val)
        targetUsernameInput = val
    end
})

Tabs.Misc:Button({
    Title = "Copy Avatar",
    Callback = function()
        if not targetUsernameInput or targetUsernameInput == "" then
            VexUI:Notification({
                Title = "Civic Hub",
                Desc = "Please enter a username",
                Duration = 2
            })
            return
        end
        local username = targetUsernameInput
        task.spawn(function()
            local success, userId = pcall(function()
                return Players:GetUserIdFromNameAsync(username)
            end)
            if not success then
                VexUI:Notification({
                    Title = "Civic Hub",
                    Desc = "Failed to find user: " .. username,
                    Duration = 2
                })
                return
            end
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local desc = Players:GetHumanoidDescriptionFromUserId(userId)
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("Accessory") or v:IsA("Clothing") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then
                    v:Destroy()
                end
            end
            hum:ApplyDescriptionClientServer(desc)
            VexUI:Notification({
                Title = "Civic Hub",
                Desc = "Avatar copied from: " .. username,
                Duration = 2
            })
        end)
    end
})

-- ============== VISUAL TAB =================
Tabs.Visual:Section({Title = "Graphics", Icon = "sun"})

Fullbright_Toggle = Tabs.Visual:Toggle({
    Title = "Fullbright",
    Value = false,
    Callback = function(v)
        CurrentConfig.Fullbright = v
        applyVisual(true)
    end
})

NoShadow_Toggle = Tabs.Visual:Toggle({
    Title = "No Shadow",
    Value = false,
    Callback = function(v)
        CurrentConfig.NoShadow = v
        applyVisual(true)
    end
})

LowGraphics_Toggle = Tabs.Visual:Toggle({
    Title = "Low Graphics",
    Value = false,
    Callback = function(v)
        CurrentConfig.LowGraphics = v
        applyOptimization(true)
    end
})

NoScreenEffects_Toggle = Tabs.Visual:Toggle({
    Title = "No Screen Effects",
    Value = false,
    Callback = function(v)
        CurrentConfig.NoScreenEffects = v
        applyNoScreenEffects()
    end
})

CleanSky_Toggle = Tabs.Visual:Toggle({
    Title = "Clean Sky",
    Value = false,
    Callback = function(v)
        CurrentConfig.CleanSky = v
        applyOptimization(true)
    end
})

Tabs.Visual:Section({Title = "Clock & Ambient", Icon = "alarm-clock-check"})

ClockTime_Slider = Tabs.Visual:Slider({
    Title = "Clock Time",
    Value = {
        Min = 0,
        Max = 24,
        Default = 14,
    },
    Step = 1,
    Callback = function(v)
        CurrentConfig.ClockTime = v
        applyVisual(true)
    end
})

Brightness_Slider = Tabs.Visual:Slider({
    Title = "Brightness",
    Value = {
        Min = 0,
        Max = 5,
        Default = 2,
    },
    Step = 0.1,
    Callback = function(v)
        CurrentConfig.Brightness = v
        applyVisual(true)
    end
})

Tabs.Visual:Section({Title = "Zoom Out", Icon = "fullscreen"})

UnlimitedZoom_Toggle = Tabs.Visual:Toggle({
    Title = "Unlimited Zoom Out",
    Value = false,
    Callback = function(v)
        CurrentConfig.UnlimitedZoom = v
        applyUnlimitedZoom()
    end
})

MaxZoomDistance_Slider = Tabs.Visual:Slider({
    Title = "Max Zoom Distance",
    Value = {
        Min = 100,
        Max = 5000,
        Default = 1000,
    },
    Step = 1,
    Callback = function(v)
        CurrentConfig.MaxZoomDistance = v
        if CurrentConfig.UnlimitedZoom then
            applyUnlimitedZoom()
        end
    end
})

CustomFOV_Toggle = Tabs.Visual:Toggle({
    Title = "Custom FOV",
    Value = false,
    Callback = function(v)
        CurrentConfig.CustomFOV = v
        applyCameraFOV()
    end
})

CameraFOV_Slider = Tabs.Visual:Slider({
    Title = "Camera FOV",
    Value = {
        Min = 40,
        Max = 120,
        Default = 70,
    },
    Step = 1,
    Callback = function(v)
        CurrentConfig.CameraFOV = v
        if CurrentConfig.CustomFOV then
            applyCameraFOV()
        end
    end
})

-- ============== SETTINGS TAB =================
Tabs.Settings:Section({Title = "Configuration", Icon = "save"})

Tabs.Settings:Input({
    Title = "Setting Name",
    Desc = "Enter a name for your configuration",
    Value = "MyConfig",
    Callback = function(val)
        ConfigName = val
    end
})

local configOptions = {"Select Config"}
local configDropdown

local function updateConfigDropdown()
    local files = listConfigFiles()
    local options = {"Select Config"}
    for _, name in ipairs(files) do
        table.insert(options, name)
    end
    if configDropdown then
        configDropdown:SetOptions(options)
    end
    return options
end

configDropdown = Tabs.Settings:Dropdown({
    Title = "Saved Settings",
    Option = configOptions,
    Value = "Select Config",
    Multi = false,
    Callback = function(val)
        if val ~= "Select Config" then
            ConfigName = val
        end
    end
})

Tabs.Settings:Button({
    Title = "Refresh Config List",
    Callback = function()
        updateConfigDropdown()
        VexUI:Notification({
            Title = "Civic Hub",
            Desc = "Config list refreshed",
            Duration = 2
        })
    end
})

Tabs.Settings:Button({
    Title = "Save Setting",
    Desc = "Save current configuration",
    Callback = function()
        if ConfigName and ConfigName ~= "" and ConfigName ~= "Select Config" then
            SaveAllSettings(ConfigName)
            updateConfigDropdown()
        else
            VexUI:Notification({
                Title = "Civic Hub",
                Desc = "Please enter a valid setting name",
                Duration = 2
            })
        end
    end
})

Tabs.Settings:Button({
    Title = "Load Setting",
    Desc = "Load selected configuration",
    Callback = function()
        if ConfigName and ConfigName ~= "Select Config" then
            IsInitialLoad = false
            LoadAllSettings(ConfigName)
        else
            VexUI:Notification({
                Title = "Civic Hub",
                Desc = "Please select a configuration",
                Duration = 2
            })
        end
    end
})

Tabs.Settings:Button({
    Title = "Update Setting",
    Desc = "Update selected configuration with current settings",
    Callback = function()
        if ConfigName and ConfigName ~= "Select Config" then
            UpdateAllSettings(ConfigName)
            VexUI:Notification({
                Title = "Civic Hub",
                Desc = "Setting updated: " .. ConfigName,
                Duration = 3
            })
        else
            VexUI:Notification({
                Title = "Civic Hub",
                Desc = "Please select a configuration to update",
                Duration = 2
            })
        end
    end
})

Tabs.Settings:Button({
    Title = "Delete Setting",
    Desc = "Delete selected configuration",
    Callback = function()
        if ConfigName and ConfigName ~= "Select Config" then
            DeleteAllSettings(ConfigName)
            updateConfigDropdown()
            ConfigName = "MyConfig"
        else
            VexUI:Notification({
                Title = "Civic Hub",
                Desc = "Please select a configuration to delete",
                Duration = 2
            })
        end
    end
})

Tabs.Settings:Toggle({
    Title = "Auto Load Setting",
    Value = false,
    Callback = function(v)
        AutoLoadEnabled = v
    end
})

local autoLoadInput
Tabs.Settings:Input({
    Title = "Auto Load Config Name",
    Desc = "Name of config to auto-load",
    Value = "",
    Callback = function(val)
        AutoLoadConfigName = val
    end
})

Tabs.Settings:Button({
    Title = "Set Auto Load Config",
    Desc = "Set the config to auto-load",
    Callback = function()
        if AutoLoadConfigName and AutoLoadConfigName ~= "" then
            VexUI:Notification({
                Title = "Civic Hub",
                Desc = "Auto-load config set to: " .. AutoLoadConfigName,
                Duration = 3
            })
        else
            VexUI:Notification({
                Title = "Civic Hub",
                Desc = "Please enter a config name",
                Duration = 2
            })
        end
    end
})

Tabs.Settings:Section({Title = "Menu", Icon = "wrench"})

Transparent_Toggle = Tabs.Settings:Toggle({
    Title = "Transparent",
    Value = false,
    Callback = function(v)
        CurrentConfig.Transparent = v
        Window:SetTransparency(v)
    end
})

Theme_Dropdown = Tabs.Settings:Dropdown({
    Title = "Theme",
    Option = {"Dark", "Light", "Forest", "Amethyst"},
    Value = "Dark",
    Multi = false,
    Callback = function(v)
        CurrentConfig.Theme = v
        Window:SetTheme(v)
        VexUI:Notification({
            Title = "Civic Hub",
            Desc = "Theme changed to " .. v,
            Duration = 2
        })
    end
})

ToggleKey_Keybind = Tabs.Settings:Keybind({
    Title = "Toggle Key",
    Callback = function(key)
        Window:SetToggleKey(key)
    end
})

Tabs.Settings:Button({
    Title = "Center Window",
    Callback = function()
        Window:ToCenter()
    end
})

Tabs.Settings:Button({
    Title = "Join Discord",
    Callback = function()
        setclipboard("https://discord.gg/3kmTx8Aeew")
        VexUI:Notification({
            Title = "Civic Hub",
            Desc = "Discord link copied!",
            Duration = 3
        })
    end
})

Tabs.Settings:Button({
    Title = "Unload Script",
    Callback = function()
        -- Cleanup everything
        stopMoonwalk()
        stopSkillCheck()
        stopAutoStalk()
        stopGunAim()
        stopAttackAim()
        stopWalkSpeed()
        clearAllESP()
        clearCrosshair()
        if ParryCircle then
            ParryCircle:Destroy()
            ParryCircle = nil
        end
        if NoClipConnection then
            NoClipConnection:Disconnect()
            NoClipConnection = nil
        end
        Window:Destroy()
    end
})

-- =======================================
-- INITIALIZATION

-- Ensure moonwalk is OFF by default
CurrentConfig.MoonwalkEnabled = false
stopMoonwalk()

-- Start services
startGunAim()
applyUnlimitedZoom()
applyCameraFOV()
applyVisual(true)
applyOptimization(true)

-- Show moonwalk button if configured
if CurrentConfig.MoonwalkShowButton then
    createMoonwalkButton()
end

-- Perform auto load
task.wait(0.5)
IsInitialLoad = true
performAutoLoad()
IsInitialLoad = false

-- Show notification
VexUI:Notification({
    Title = "Civic Hub",
    Desc = "Loaded successfully! Built by Vinzee",
    Duration = 3
})

-- Update config dropdown
task.wait(0.2)
updateConfigDropdown()

print("=========================================")
print("CIVIC HUB v2.0.0 LOADED SUCCESSFULLY")
print("Built by Vinzee")
print("Game: Violence District")
print("=========================================")
