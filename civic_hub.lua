-- Script taken from https://xenoscripts.com website --
-- MIGRATED TO VEXUI - CIVIC HUB EDITION
-- Built by Vinzee

-- LOAD VEXUI LIBRARY
local VexUI = loadstring(game:HttpGet("https://github.com/SSHRKs/VexUI/releases/latest/download/main.lua"))()

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

-- EDIT OPEN BUTTON
Window:EditOpenButton({
    Title = "Open Civic Hub",
    Icon = "door-open",
    Transparency = 0.2,
    StrokeThickness = 1,
    Rotation = 0,
    Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 120, 210)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 90, 180))
    },
    AutoRotation = false,
    Speed = 15,
    CornerRadius = UDim.new(0,16),
})

-- =======================================
-- FLOATING CIVIC LOGO BUTTON (DRAGGABLE + TOGGLE)
local function CreateCivicFloatingButton()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CivicFloatingButton"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game:GetService("CoreGui")

    local MainButton = Instance.new("ImageButton")
    MainButton.Name = "CivicToggleButton"
    MainButton.Image = "rbxassetid://97658052504663"
    MainButton.ScaleType = Enum.ScaleType.Crop

    MainButton.Size = UDim2.fromOffset(50, 50)
    MainButton.Position = UDim2.fromOffset(15, 120)

    MainButton.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    MainButton.BackgroundTransparency = 0.05

    MainButton.Parent = ScreenGui

    -- Corner (Circular)
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = MainButton

    -- Outline
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(70, 85, 130)
    Stroke.Thickness = 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = MainButton

    -- Glow
    local Glow = Instance.new("UIStroke")
    Glow.Color = Color3.fromRGB(45, 75, 145)
    Glow.Thickness = 5
    Glow.Transparency = 0.7
    Glow.Parent = MainButton

    -- Hover Effect
    MainButton.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(
            MainButton,
            TweenInfo.new(.15),
            {
                BackgroundColor3 = Color3.fromRGB(28, 28, 35)
            }
        ):Play()
    end)

    MainButton.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(
            MainButton,
            TweenInfo.new(.15),
            {
                BackgroundColor3 = Color3.fromRGB(18, 18, 22)
            }
        ):Play()
    end)

    -- Click Animation + Toggle GUI
    local isClicking = false
    local hasDragged = false

    MainButton.MouseButton1Click:Connect(function()
        if not hasDragged then
            isClicking = true
            game:GetService("TweenService"):Create(
                MainButton,
                TweenInfo.new(.08),
                {
                    Size = UDim2.fromOffset(45, 45)
                }
            ):Play()

            task.wait(.08)

            game:GetService("TweenService"):Create(
                MainButton,
                TweenInfo.new(.08),
                {
                    Size = UDim2.fromOffset(50, 50)
                }
            ):Play()

            -- Toggle VexUI Window
            Window:Toggle()
        end
        hasDragged = false
    end)

    -- Drag System (Mouse + Touch)
    local UserInputService = game:GetService("UserInputService")
    local dragging = false
    local dragInput, mousePos, framePos

    local function update(input)
        local delta = input.Position - mousePos
        local newPos = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
        
        game:GetService("TweenService"):Create(
            MainButton,
            TweenInfo.new(0.1),
            { Position = newPos }
        ):Play()
    end

    MainButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            hasDragged = false
            mousePos = input.Position
            framePos = MainButton.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    MainButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement 
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            hasDragged = true
            update(input)
        end
    end)

    return MainButton, ScreenGui
end

CreateCivicFloatingButton()

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

local CarryEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Carry"):WaitForChild("CarrySurvivorEvent")
local HookEvent  = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Carry"):WaitForChild("HookEvent")
local AttackEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attacks"):WaitForChild("BasicAttack")
local SkillCheckRemote = ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("Generator")
    :WaitForChild("SkillCheckResultEvent")

-- ============== CONFIG =================

local ESP = {
Survivor = false,
Killer = false,
Generator = false,
Pallet = false,
Window = false,
SCP = false,
Distance = 100
}

local ESPStatus = {
Enabled = false,
ShowName = true,
ShowDistance = true,
ShowHealth = false,
Radius = 100
}

local TeamColors = {
Killer = Color3.fromRGB(255, 60, 60),      -- merah
Survivor = Color3.fromRGB(60, 255, 120)    -- hijau
}

local Auto = {
SkillCheck = false,
Parry = false,
ParryDelay = 0,
ParryCooldown = 1,
ParryDistance = 15,
FaceSensitivity = 0.7,
RequireFacing = true,
Wiggle = false,
WiggleSpam = 5
}

local AutoFlee = {
    Enabled = false,
    DetectDistance = 50,
    Cooldown = 0.1
}

local LastFlee = 0

local GunAim = {
    Enabled = false,
    Holding = false,
    TargetMode = "Killer", 
    Strength = 1,
    Predict = true,
    PredictStrength = 0.12,
    FOV = 250,
    VisibilityCheck = true,
    Target = nil,
    AimPart = "HumanoidRootPart"
}

local AttackAim = {
    Enabled = false,
    Holding = false,
    Strength = 1,
    Predict = true,
    PredictStrength = 0.12,
    FOV = 250,
    VisibilityCheck = true,
    AimPart = "HumanoidRootPart"
}

local Killer = {
    KillAll = false,
    AutoAttack = false,
    AutoCarry = false,
    KillRange = 500,
    AttackDelay = 0.45
}

local KillerBusy = false
local KillerTarget = nil
local ParryActive = false

local Masked = {
    Enabled = false,
    CurrentPower = "Cobra"
}

local MaskedPowers = {"Cobra", "Richter", "Brandon", "Rabbit", "Alex"}

local Moonwalk = {
Enabled = false,
ShowButton = false,
SpamSpeed = 30,
Intensity = 35,
SlowSpeed = 13,
UseSlow = true
}

local MoonwalkConnection = nil
local MoonwalkButton = nil

local CameraZoom = {
    UnlimitedZoom = false,
    MaxDistance = 1000,
    MinDistance = 0,

    FOVEnabled = false,
    FOV = 70,
    DefaultFOV = workspace.CurrentCamera.FieldOfView
}

local AutoStalk = {
    Enabled = false,
    StalkRange = 150,
    Target = nil
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

local ParryRangeVisual = {
Enabled = false,
Color = Color3.fromRGB(255, 80, 80),
Transparency = 0.9
}

local ParryCircle = nil

local PlayerMods = {    
    GodMode = false
}

local Movement = {
    JumpPowerEnabled = false,
    JumpPowerValue = 50,
    OriginalJumpPower = 50,
    WalkSpeedEnabled = false,
    WalkSpeedValue = 17.6,
    OriginalWalkSpeed = 16,
    NoClip = false
}

local AvatarStealer = {
    Enabled = true,
    TargetUsername = "",
    OriginalDescription = nil,
    CurrentStealedUserId = nil,
    BlockyBody = true
}

-- ============== HELPER =================
local function GetNil(Name, DebugId)
    if not getnilinstances then return nil end

    for _, Object in pairs(getnilinstances()) do
        if Object.Name == Name then
            if not DebugId or Object:GetDebugId() == DebugId then
                return Object
            end
        end
    end
end

local function getRoot()
return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function getAnimId(id)
return tostring(id):match("%d+")
end

local function GetDowned()
local root = getRoot()
if not root then return nil end

local best, dist = nil, math.huge

for _,p in pairs(Players:GetPlayers()) do
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

local function applyJumpPower()
    if not Movement.JumpPowerEnabled then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.JumpPower = Movement.JumpPowerValue
    end
end

local function shouldDisableWalkSpeed()

    local char = LocalPlayer.Character
    if not char then
        return false
    end

    -- DETEKSI ANIMASI PARRY
local hum = char:FindFirstChildOfClass("Humanoid")
if hum then

    local animator = hum:FindFirstChildOfClass("Animator")

    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do

            local anim = track.Animation

            if anim and anim.AnimationId then

                -- PARRY ANIM
                if anim.AnimationId == "rbxassetid://127096285501517" then
                    return true
                end
                
                -- BREAK PALLET
                if anim.AnimationId == "rbxassetid://112166042383605" then
                    return true
                end
                
                -- WALKCROUCH
                if anim.AnimationId == "http://www.roblox.com/asset/?id=126965695851149" then
                    return true
                end
                
                -- WALKCROUCHINJURED
                if anim.AnimationId == "http://www.roblox.com/asset/?id=135084204086504" then
                    return true
                end
                
                -- STUN
                if anim.AnimationId == "rbxassetid://123047897844134" then
                    return true
                end

                -- KILLER ATTACK ANIM
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

    -- DOWNED CHECK
    if hum and (
        hum.Health <= 0
        or hum.Health < 2
        or char:GetAttribute("Downed") == true
        or char:GetAttribute("IsDown") == true
        or char:GetAttribute("Knocked") == true
    ) then
        return true
    end

    return false
end

local WalkSpeedConnection = nil

local function applyWalkSpeed()

    if WalkSpeedConnection then
        WalkSpeedConnection:Disconnect()
        WalkSpeedConnection = nil
    end

    WalkSpeedConnection =
        RunService.Heartbeat:Connect(function()

            if not Movement.WalkSpeedEnabled then
                return
            end

            local char = LocalPlayer.Character
            if not char then
                return
            end

            local hum =
                char:FindFirstChildOfClass("Humanoid")

            if not hum then
                return
            end

            if shouldDisableWalkSpeed() then
                return
            end

            if hum.WalkSpeed ~= Movement.WalkSpeedValue then
                hum.WalkSpeed = Movement.WalkSpeedValue
            end

        end)
end

-- Auto apply saat respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.8)
    applyJumpPower()
    applyWalkSpeed()
end)

local NoClipConnection = nil

local function applyNoClip()
    local char = LocalPlayer.Character
    if not char then return end

    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") and v.CanCollide then
            if Movement.NoClip then
                v.CanCollide = false
            else
                v.CanCollide = true
            end
        end
    end
end

-- Toggle NoClip
local function toggleNoClip(state)
    Movement.NoClip = state

    if state then
        if NoClipConnection then NoClipConnection:Disconnect() end
        
        NoClipConnection = RunService.RenderStepped:Connect(function()
            if Movement.NoClip then
                applyNoClip()
            end
        end)
    else
        if NoClipConnection then
            NoClipConnection:Disconnect()
            NoClipConnection = nil
        end
        -- Restore collision
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

-- Auto apply saat respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.8)
    applyJumpPower()
    if Movement.NoClip then
        task.wait(0.3)
        toggleNoClip(true)
    end
end)

local function applyGodMode()
    if not PlayerMods.GodMode then return end

    local char = LocalPlayer.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    -- Heal terus
    if hum.Health < hum.MaxHealth then
        pcall(function()
            hum.Health = hum.MaxHealth
        end)
    end

    -- Anti mati / ragdoll
    local state = hum:GetState()

    if state == Enum.HumanoidStateType.Dead 
    or state == Enum.HumanoidStateType.FallingDown 
    or state == Enum.HumanoidStateType.Ragdoll then
        
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
local hum = char:WaitForChild("Humanoid")
task.wait(0.5)

-- RESET PARRY CIRCLE
if ParryCircle then
    ParryCircle:Destroy()
    ParryCircle = nil
end
end)

-- jika karakter sudah ada
if LocalPlayer.Character then
local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
if hum then
end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)

    -- RESET AIM
    GunAim.Target = nil
    GunAim.Holding = false
    applyCameraFOV()
end)

-- ============= ESP SYSTEM ==============
local ESPObjects = {}

local CachedSCP = {}

-- cache SCP sekali saja
for _, obj in ipairs(workspace:GetDescendants()) do
    local name = string.lower(obj.Name)

    if string.find(name, "scp") then
        CachedSCP[obj] = true
    end
end

workspace.DescendantAdded:Connect(function(obj)
    local name = string.lower(obj.Name)

    if string.find(name, "scp") then
        CachedSCP[obj] = true
    end
end)

local function removeESP(obj)
if ESPObjects[obj] then
ESPObjects[obj]:Destroy()
ESPObjects[obj] = nil
end
end

workspace.DescendantRemoving:Connect(function(obj)
    CachedSCP[obj] = nil
    removeESP(obj)
end)

local function createESP(obj, color)
if not obj then return end

if ESPObjects[obj] then
-- update warna saja (tidak recreate)
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

-- auto remove jika character hilang
obj.AncestryChanged:Connect(function(_, parent)
if not parent then
removeESP(obj)
end
end)

end

-- ======= ESP GENERATOR =================

local GeneratorColor = Color3.fromRGB(255, 170, 0)
local PalletColor = Color3.fromRGB(74, 255, 181)
local WindowColor = Color3.fromRGB(74, 255, 181)
local SCPColor = Color3.fromRGB(255, 0, 0)
local MAX_DISTANCE = function()
    return ESP.Distance
end

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

-- kalau ESP mati → hapus
if not ESP.Generator then
local old = generator:FindFirstChild("GenESP")
if old then old:Destroy() end

local h = generator:FindFirstChild("GenHighlight")
if h then h:Destroy() end
return

end

local percent =
GetGameValue(generator, "RepairProgress") or
GetGameValue(generator, "Progress") or 0

local billboard = generator:FindFirstChild("GenESP")

if percent >= 100 then
if billboard then billboard:Destroy() end
return
end

local cp = math.clamp(percent, 0, 100)

local color = GeneratorColor:Lerp(
    Color3.fromRGB(0,255,120),
    cp / 100
)

local text = string.format("[%.0f%%]", percent)

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

-- WINDOW
if obj.Name == "Window" then
if ESP.Window and distance <= MAX_DISTANCE() then
createESP(obj, WindowColor)
else
removeESP(obj)
end
end

-- PALLET
if obj.Name == "Pallet" or obj.Name == "Palletwrong" then
if ESP.Pallet and distance <= MAX_DISTANCE() then
createESP(obj, PalletColor)
else
removeESP(obj)
end
end

end

local StatusESP = {}

local function removeStatusESP(char)
if StatusESP[char] then
StatusESP[char]:Destroy()
StatusESP[char] = nil
end
end

local function createStatusESP(player, char, root)
if not ESPStatus.Enabled then
removeStatusESP(char)
return
end

if not root then return end

local head = char:FindFirstChild("Head")
local hum = char:FindFirstChildOfClass("Humanoid")

if not head or not hum then return end

local isDown =
hum.Health <= 0
or hum.Health < 2
or char:GetAttribute("Downed") == true
or char:GetAttribute("IsDown") == true
or char:GetAttribute("Knocked") == true

local dist = (head.Position - root.Position).Magnitude

if dist > ESPStatus.Radius then
removeStatusESP(char)
return
end

local text = ""

if isDown then
text = "🔻 DOWN\n"
end

if ESPStatus.ShowName then
text = text .. player.Name .. "\n"
end

if ESPStatus.ShowDistance then
text = text .. string.format("Dist: %.0f\n", dist)
end

if ESPStatus.ShowHealth then
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
label.Size = UDim2.new(1,0,1,0)
label.BackgroundTransparency = 1
local teamColor = Color3.new(1,1,1)

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

local teamColor = Color3.new(1,1,1)

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

    if not ESP.SCP then
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

                if dist <= ESP.Distance then
                    createESP(obj, SCPColor)
                else
                    removeESP(obj)
                end
            end
        end
    end
end

-- ==========AUTO SYSTEM=================

local function GetNearestKiller()
    local root = getRoot()
    if not root then return nil end

    local closest = nil
    local shortest = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer
        and plr.Team
        and plr.Team.Name == "Killer"
        and plr.Character then

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

local function GetFarthestGeneratorPoint(killerRoot)
    if not killerRoot then
        return nil
    end

    local bestPoint = nil
    local farthestDistance = 0

    for _, obj in ipairs(workspace:GetDescendants()) do

        if obj:IsA("BasePart")
        and string.match(obj.Name, "^GeneratorPoint%d+$") then

            local dist =
                (obj.Position - killerRoot.Position).Magnitude

            if dist > farthestDistance then
                farthestDistance = dist
                bestPoint = obj
            end
        end
    end

    return bestPoint
end

local function AutoWiggle()
    if not Auto.Wiggle then return end

    local char = LocalPlayer.Character
    if not char then return end

    -- cek kondisi lagi digendong
    local carried =
        (char:FindFirstChild("IsCarried") and char.IsCarried.Value) or
        (char:FindFirstChild("IsCarrying") and char.IsCarrying.Value)

    if not carried then return end

    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return end

    local carry = remotes:FindFirstChild("Carry")
    if not carry then return end

    local event = carry:FindFirstChild("SelfUnHookEvent")
    if not event then return end

    -- 🔥 spam wiggle
    for i = 1, Auto.WiggleSpam do
        event:FireServer()
    end
end

local lastParry = 0
local PARRY_DEBOUNCE = 0.2

local function pressRightClick()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
    task.wait()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
end

local AttackPaths = {
    "Slasher-mob.Controls.attack",
    "Masked-mob.Controls.attack",
    "Killer-mob.Controls.attack"
}

local function GetParryButton()
local current = PlayerGui
for segment in string.gmatch("Survivor-mob.Controls.Gui-mob", "[^%.]+") do
current = current and current:FindFirstChild(segment)
end
return current
end

local function GetAttackButtonForParry()

    for _, path in ipairs(AttackPaths) do

        local current = PlayerGui

        for segment in string.gmatch(path, "[^%.]+") do
            current =
                current and current:FindFirstChild(segment)
        end

        if current and current:IsA("GuiObject") then
            return current
        end
    end

    return nil
end

local function GetGunAimButton()
    local aimPath = "Gun-mob.Controls.Gui-mob"

    local current = PlayerGui

    for segment in string.gmatch(aimPath, "[^%.]+") do
        current = current and current:FindFirstChild(segment)
    end

    if current and current:IsA("GuiObject") then
        return current
    end

    return nil
end

local function GetAttackAimButton()
    local attackPath = "Masked-mob.Controls.Gui-mob"

    local current = PlayerGui

    for segment in string.gmatch(attackPath, "[^%.]+") do
        current = current and current:FindFirstChild(segment)
    end

    if current and current:IsA("GuiObject") then
        return current
    end

    return nil
end

-- Input detection untuk gun aim
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        GunAim.Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        GunAim.Holding = false
    end
end)

local function pressParryButton()
    if UserInputService.TouchEnabled then
        task.wait(0.1)
        local btn = GetParryButton()
        if not btn then return end

        local x, y = btn.AbsolutePosition.X + btn.AbsoluteSize.X / 2,
                   btn.AbsolutePosition.Y + btn.AbsoluteSize.Y / 2

        local TouchID = -1

        VirtualInputManager:SendTouchEvent(8823, 0, x, y)
        task.wait(0.05)
        VirtualInputManager:SendTouchEvent(8823, 2, x, y)
    else
        pressRightClick()
    end
end

local function startAutoParry()
    local root = getRoot()
    if not root then return end

    local killer, dist = GetNearestKiller()
    if not killer then return end

    if dist > Auto.ParryDistance then return end

    local now = tick()
    if now - lastParry < PARRY_DEBOUNCE then return end
    lastParry = now

    pressParryButton()
end

pressParryButton()

local Crosshair = {
    Enabled = false,
    OffsetX = 0,
    OffsetY = 0,
    Color = Color3.fromRGB(255, 255, 255),
    Style = "Plus",
    Frame = nil
}

local function createCrosshair()
    if Crosshair.Frame then
        Crosshair.Frame:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CivicCrosshair"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Name = "CrosshairFrame"
    frame.Size = UDim2.new(0, 20, 0, 20)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundTransparency = 1
    frame.Parent = screenGui

    Crosshair.Frame = frame
    Crosshair.ScreenGui = screenGui

    updateCrosshair()
end

local function updateCrosshair()
    if not Crosshair.Frame then return end

    Crosshair.Frame.Position = UDim2.new(
        0.5,
        Crosshair.OffsetX,
        0.5,
        Crosshair.OffsetY
    )

    -- Clear existing
    for _, child in ipairs(Crosshair.Frame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("ImageLabel") then
            child:Destroy()
        end
    end

    if not Crosshair.Enabled then return end

    local color = Crosshair.Color

    if Crosshair.Style == "Plus" then
        -- Horizontal
        local h = Instance.new("Frame")
        h.Size = UDim2.new(0, 20, 0, 2)
        h.Position = UDim2.new(0.5, 0, 0.5, -1)
        h.BackgroundColor3 = color
        h.BorderSizePixel = 0
        h.Parent = Crosshair.Frame

        -- Vertical
        local v = Instance.new("Frame")
        v.Size = UDim2.new(0, 2, 0, 20)
        v.Position = UDim2.new(0.5, -1, 0.5, 0)
        v.BackgroundColor3 = color
        v.BorderSizePixel = 0
        v.Parent = Crosshair.Frame

    elseif Crosshair.Style == "Dot" then
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 4, 0, 4)
        dot.Position = UDim2.new(0.5, -2, 0.5, -2)
        dot.BackgroundColor3 = color
        dot.BorderSizePixel = 0
        dot.Parent = Crosshair.Frame

    elseif Crosshair.Style == "Circle" then
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 16, 0, 16)
        circle.Position = UDim2.new(0.5, -8, 0.5, -8)
        circle.BackgroundTransparency = 1
        circle.BorderSizePixel = 0
        circle.Parent = Crosshair.Frame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = circle

        local stroke = Instance.new("UIStroke")
        stroke.Color = color
        stroke.Thickness = 2
        stroke.Parent = circle
    end
end

local function toggleCrosshair(state)
    Crosshair.Enabled = state
    if state then
        if not Crosshair.Frame then
            createCrosshair()
        end
        updateCrosshair()
    else
        if Crosshair.ScreenGui then
            Crosshair.ScreenGui:Destroy()
        end
        Crosshair.Frame = nil
        Crosshair.ScreenGui = nil
    end
end

-- Gun Aim Connection
local GunAimButtonConnection = nil
local CurrentGunButton = nil

local function connectGunAim()
    if GunAimButtonConnection then
        GunAimButtonConnection:Disconnect()
        GunAimButtonConnection = nil
    end

    RunService.RenderStepped:Connect(function()
        if not GunAim.Enabled then return end

        local btn = GetGunAimButton()

        if not btn then
            CurrentGunButton = nil
            return
        end

        if btn ~= CurrentGunButton then
            CurrentGunButton = btn

            if GunAimButtonConnection then
                GunAimButtonConnection:Disconnect()
                GunAimButtonConnection = nil
            end

            btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch
                or input.UserInputType == Enum.UserInputType.MouseButton2 then
                    GunAim.Holding = true
                end
            end)

            btn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch
                or input.UserInputType == Enum.UserInputType.MouseButton2 then
                    GunAim.Holding = false
                end
            end)
        end
    end)
end

-- Attack Aim Connection
local CurrentAttackButton = nil

local function connectAttackAim()
    RunService.RenderStepped:Connect(function()
        if not AttackAim.Enabled then return end

        local btn = GetAttackAimButton()

        if btn and btn ~= CurrentAttackButton then
            CurrentAttackButton = btn

            btn.InputBegan:Connect(function(input)
                if input.UserInputType ==
                    Enum.UserInputType.Touch then
                    AttackAim.Holding = true
                end
            end)

            btn.InputEnded:Connect(function(input)
                if input.UserInputType ==
                    Enum.UserInputType.Touch then
                    AttackAim.Holding = false
                end
            end)
        end
    end)
end

-- Moonwalk
local function startMoonwalk()
    if MoonwalkConnection then
        MoonwalkConnection:Disconnect()
    end

    MoonwalkConnection = RunService.RenderStepped:Connect(function()
        if not Moonwalk.Enabled then return end

        local char = LocalPlayer.Character
        if not char then return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        local moveDir = hum.MoveDirection

        if moveDir.Magnitude > 0 then
            local backward = -moveDir

            if Moonwalk.UseSlow then
                hum.WalkSpeed = Moonwalk.SlowSpeed
            end

            for i = 1, Moonwalk.SpamSpeed do
                hum:Move(backward, true)
                task.wait(Moonwalk.Intensity / 1000)
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
            if PlayerMods.Speed then
                hum.WalkSpeed = SpeedValue
            else
                hum.WalkSpeed = 16
            end
        end
    end
end

local function createMoonwalkButton()
    if MoonwalkButton then MoonwalkButton:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MoonwalkButton"
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui")

    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.fromOffset(40, 40)
    btn.Position = UDim2.fromOffset(100, 300)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.BackgroundTransparency = 0.1
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = "🚶 Moonwalk"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = btn

btn.MouseButton1Click:Connect(function()
    Moonwalk.Enabled = not Moonwalk.Enabled

    if Moonwalk.Enabled then
        startMoonwalk()
        label.Text = "✅ Moonwalk"
    else
        stopMoonwalk()
        label.Text = "🚶 Moonwalk"
    end
end)

    MoonwalkButton = gui
end

local function removeMoonwalkButton()
if MoonwalkButton then
MoonwalkButton:Destroy()
MoonwalkButton = nil
end
end

-- Fast Vault
local FastVault = {
    Enabled = false,
    Speed = 1.2
}

local function applyFastVault()
    if not FastVault.Enabled then return end

    local char = LocalPlayer.Character
    if not char then return end

    local animator = char:FindFirstChildOfClass("Humanoid")
        and char.Humanoid:FindFirstChildOfClass("Animator")

    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            if string.find(track.Name:lower(), "vault") then
                track:AdjustSpeed(FastVault.Speed)
            end
        end
    end
end

-- Teleport to finish line
local function teleportToFinishLine()
    local root = getRoot()
    if not root then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if string.find(obj.Name, "FinishLine") then
            root.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
            return
        end
    end
end

-- Auto Stalk
local function startAutoStalk()
    if not AutoStalk.Enabled then return end

    local root = getRoot()
    if not root then return end

    local nearestKiller, dist = GetNearestKiller()
    if not nearestKiller then return end

    if dist > AutoStalk.StalkRange then return end

    AutoStalk.Target = nearestKiller
end

local function stopAutoStalk()
    AutoStalk.Target = nil
end

-- Jerk Tool
local JerkTool = {
    Enabled = false
}

local currentJerkTool = nil

local function createJerkTool()
    if currentJerkTool then return end

    local tool = Instance.new("Tool")
    tool.Name = "JerkTool"
    tool.RequiresHandle = true
    tool.Parent = LocalPlayer.Backpack

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1, 1)
    handle.Parent = tool

    currentJerkTool = tool
end

-- Emote System
local EmoteList = {
    "Dance",
    "Laugh",
    "Wave",
    "Cheer",
    "Point",
    "Salute",
    "Zombie",
    "Robot",
    "T Pose",
    "Sit"
}

local Emote = {
    Selected = "Dance",
    Show = false
}

local EmoteButton = {
    GuiInstance = nil,
    LabelRef = nil,
    Show = false
}

local function playEmote(emoteName)
    local char = LocalPlayer.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return end

    -- Simple emote mapping (you can expand this)
    local emoteIds = {
        ["Dance"] = "rbxassetid://182872719",
        ["Laugh"] = "rbxassetid://5918603033",
        ["Wave"] = "rbxassetid://5918603033",
        ["Cheer"] = "rbxassetid://182872719",
        ["Point"] = "rbxassetid://5918603033",
        ["Salute"] = "rbxassetid://5918603033",
        ["Zombie"] = "rbxassetid://182872719",
        ["Robot"] = "rbxassetid://182872719",
        ["T Pose"] = "rbxassetid://182872719",
        ["Sit"] = "rbxassetid://182872719"
    }

    local emoteId = emoteIds[emoteName]
    if emoteId then
        local anim = Instance.new("Animation")
        anim.AnimationId = emoteId
        local track = animator:LoadAnimation(anim)
        track:Play()
    end
end

local function createEmoteButton()
    if EmoteButton.GuiInstance then
        EmoteButton.GuiInstance:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "EmoteButtonGui"
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui")

    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.fromOffset(120, 40)
    btn.Position = UDim2.fromOffset(100, 200)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.BackgroundTransparency = 0.1
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = Emote.Selected
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = btn

btn.MouseButton1Click:Connect(function()
    playEmote(Emote.Selected)
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

-- Avatar Stealer
local function copyAvatar(username)
    if username == "" then return end

    -- Simplified avatar copying logic
    local success, result = pcall(function()
        local userId = Players:GetUserIdFromNameAsync(username)
        return userId
    end)

    if success then
        AvatarStealer.CurrentStealedUserId = result
        VexUI:Notification({
            Title = "Civic Hub",
            Desc = "Avatar copied: " .. username,
            Duration = 3
        })
    end
end

local function resetAvatar()
    -- Reset to original appearance
    local char = LocalPlayer.Character
    if not char then return end

    if AvatarStealer.OriginalDescription then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Description = AvatarStealer.OriginalDescription
        end
    end

    VexUI:Notification({
        Title = "Civic Hub",
        Desc = "Avatar reset to original",
        Duration = 3
    })
end

local function saveOriginalAppearance()
    local char = LocalPlayer.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        AvatarStealer.OriginalDescription = hum.Description
    end

    VexUI:Notification({
        Title = "Civic Hub",
        Desc = "Current appearance saved",
        Duration = 3
    })
end

-- Visual Settings
local Visual = {
    Fullbright = false,
    NoShadow = false,
    LowGraphics = false,
    NoScreenEffects = false,
    CleanSky = false,
    ClockTime = 14,
    Brightness = 2,
    Ambient = false
}

local function applyVisual()
    if Visual.Fullbright then
        Lighting.Brightness = 2
        Lighting.ClockTime = Visual.ClockTime
        Lighting.FogEnd = 100000
    end

    if Visual.NoShadow then
        Lighting.GlobalShadows = false
    end

    if Visual.Ambient then
        Lighting.ClockTime = Visual.ClockTime
        Lighting.Brightness = Visual.Brightness
    end
end

local function applyOptimization()
    if Visual.LowGraphics then
        Lighting.ShadowSoftness = 0
        Lighting.Technology = Enum.Technology.Compatibility
    end

    if Visual.CleanSky then
        Lighting.SkyboxBlobSize = 0
    end
end

local function applyNoScreenEffects()
    if Visual.NoScreenEffects then
        local char = LocalPlayer.Character
        if char then
            local effects = char:FindFirstChildOfClass("BlurEffect")
            if effects then effects:Destroy() end
        end
    end
end

-- Camera Zoom
local function applyUnlimitedZoom()
    if CameraZoom.UnlimitedZoom then
        Camera.CameraType = Enum.CameraType.Custom
        Camera.MinZoomDistance = CameraZoom.MinDistance
        Camera.MaxZoomDistance = CameraZoom.MaxDistance
    else
        Camera.CameraType = Enum.CameraType.Custom
        Camera.MinZoomDistance = 0.5
        Camera.MaxZoomDistance = 50
    end
end

local function applyCameraFOV()
    if CameraZoom.FOVEnabled then
        Camera.FieldOfView = CameraZoom.FOV
    else
        Camera.FieldOfView = CameraZoom.DefaultFOV
    end
end

-- Skill Check System
local function startSkillCheck()
    if not Auto.SkillCheck then return end

    SkillCheckRemote.OnClientEvent:Connect(function(success)
        if Auto.SkillCheck then
            SkillCheckRemote:FireServer(true)
        end
    end)
end

-- Auto Flee
RunService.RenderStepped:Connect(function()
    if not AutoFlee.Enabled then return end

    local root = getRoot()
    if not root then return end

    local killer, dist = GetNearestKiller()
    if not killer then return end

    if dist < AutoFlee.DetectDistance then
        local now = tick()
        if now - LastFlee >= AutoFlee.Cooldown then
            LastFlee = now

            local fleeDir = (root.Position - killer.Position).Unit
            fleeDir = Vector3.new(fleeDir.X, 0, fleeDir.Z)

            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:Move(fleeDir, true)
                end
            end
        end
    end
end)

-- ESP Loop
RunService.RenderStepped:Connect(function()
    local root = getRoot()
    if not root then return end

    -- Survivor ESP
    if ESP.Survivor then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer
            and player.Team
            and player.Team.Name == "Survivors"
            and player.Character then

                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - root.Position).Magnitude <= ESP.Distance then
                    createESP(player.Character, TeamColors.Survivor)
                else
                    removeESP(player.Character)
                end
            end
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                removeESP(player.Character)
            end
        end
    end

    -- Killer ESP
    if ESP.Killer then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer
            and player.Team
            and player.Team.Name == "Killer"
            and player.Character then

                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - root.Position).Magnitude <= ESP.Distance then
                    createESP(player.Character, TeamColors.Killer)
                else
                    removeESP(player.Character)
                end
            end
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if player.Team and player.Team.Name == "Killer" then
                    removeESP(player.Character)
                end
            end
        end
    end

    -- Generator ESP
    for _, obj in ipairs(workspace:GetDescendants()) do
        if string.find(obj.Name, "Generator") then
            UpdateGenerator(obj)
        end
    end

    -- Map ESP
    for _, obj in ipairs(workspace:GetDescendants()) do
        UpdateMapESP(obj, root)
    end

    -- Status ESP
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            createStatusESP(player, player.Character, root)
        end
    end

    -- SCP ESP
    UpdateSCPEsp(root)

    -- Auto Parry
    if Auto.Parry then
        startAutoParry()
    end

    -- Auto Wiggle
    AutoWiggle()

    -- God Mode
    if PlayerMods.GodMode then
        applyGodMode()
    end

    -- Fast Vault
    if FastVault.Enabled then
        applyFastVault()
    end

    -- Auto Stalk
    if AutoStalk.Enabled and AutoStalk.Target then
        local root = getRoot()
        if root then
            local targetPos = AutoStalk.Target.Position
            local dir = (targetPos - root.Position).Unit
            dir = Vector3.new(dir.X, 0, dir.Z)

            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:Move(dir, true)
                end
            end
        end
    end

    -- Gun Aimbot
    if GunAim.Enabled and GunAim.Holding then
        local root = getRoot()
        if root then
            local target = nil
            local shortest = GunAim.FOV

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local checkTeam = true

                    if GunAim.TargetMode == "Killer" then
                        checkTeam = player.Team and player.Team.Name == "Killer"
                    elseif GunAim.TargetMode == "Survivor" then
                        checkTeam = player.Team and player.Team.Name == "Survivors"
                    end

                    if checkTeam and player.Character then
                        local hrp = player.Character:FindFirstChild(GunAim.AimPart)
                        if hrp then
                            local dist = (hrp.Position - root.Position).Magnitude
                            if dist < shortest then
                                shortest = dist
                                target = hrp
                            end
                        end
                    end
                end
            end

            if target then
                local predictPos = target.Position
                if GunAim.Predict then
                    predictPos = predictPos + target.Velocity * GunAim.PredictStrength
                end

                local cf = CFrame.new(root.Position, predictPos)
                root.CFrame = cf
            end
        end
    end

    -- Attack Aimbot
    if AttackAim.Enabled and AttackAim.Holding then
        local root = getRoot()
        if root then
            local target = nil
            local shortest = AttackAim.FOV

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local hrp = player.Character:FindFirstChild(AttackAim.AimPart)
                    if hrp then
                        local dist = (hrp.Position - root.Position).Magnitude
                        if dist < shortest then
                            shortest = dist
                            target = hrp
                        end
                    end
                end
            end

            if target then
                local predictPos = target.Position
                if AttackAim.Predict then
                    predictPos = predictPos + target.Velocity * AttackAim.PredictStrength
                end

                local cf = CFrame.new(root.Position, predictPos)
                root.CFrame = cf
            end
        end
    end

    -- Auto Attack (Killer)
    if Killer.AutoAttack then
        local root = getRoot()
        if root and not KillerBusy then
            local nearest, dist = GetNearestKiller()
            if nearest and dist <= Killer.KillRange then
                KillerBusy = true

                task.spawn(function()
                    while Killer.AutoAttack do
                        AttackEvent:FireServer()
                        task.wait(Killer.AttackDelay)
                    end
                end)
            end
        end
    end

    -- Auto Carry (Killer)
    if Killer.AutoCarry then
        local downed = GetDowned()
        if downed then
            local hook = GetHook()
            if hook then
                HookEvent:FireServer(hook)
            end
        end
    end

    -- Kill All (Killer)
    if Killer.KillAll then
        local root = getRoot()
        if root then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and (hrp.Position - root.Position).Magnitude <= Killer.KillRange then
                        KillerTarget = hrp
                    end
                end
            end
        end
    end
end)

-- Character Added Events
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)

    -- Reset visuals
    applyVisual()
    applyCameraFOV()
    applyUnlimitedZoom()

    -- Reset connections
    if MoonwalkConnection then
        MoonwalkConnection:Disconnect()
        MoonwalkConnection = nil
    end

    if Moonwalk.Enabled then
        startMoonwalk()
    end
end)

-- Initial setup
if Moonwalk.ShowButton then
createMoonwalkButton()
end

-- =======================================
-- UI SETUP - VEXUI
-- =======================================

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

-- INFO TAB
local InfoSection = Tabs.Info:Section({Title = "Script Info", Icon = "info"})
InfoSection:Paragraph({
    Title = "Civic Hub",
    Desc = "Version: 2.0.0 | Game: Violence District",
    Icon = "circle-help"
})

InfoSection:Paragraph({
    Title = "Developer",
    Desc = "Built by Vinzee",
    Icon = "user"
})

InfoSection:Button({
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

local CreditsSection = Tabs.Info:Section({Title = "Credits", Icon = "award"})
CreditsSection:Paragraph({
    Title = "Original Script",
    Desc = "•༶amill༶•",
    Icon = "code"
})

CreditsSection:Paragraph({
    Title = "UI Library",
    Desc = "VexUI by .s.h.ark.",
    Icon = "palette"
})

CreditsSection:Button({
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

-- ESP TAB
local ESPSection = Tabs.ESP:Section({Title = "ESP Cham", Icon = "scan-eye"})

local SurvivorESP = ESPSection:Toggle({
    Title = "ESP Survivor",
    Callback = function(v)
        ESP.Survivor = v
    end
})

local KillerESP = ESPSection:Toggle({
    Title = "ESP Killer",
    Callback = function(v)
        ESP.Killer = v
    end
})

local GeneratorESP = ESPSection:Toggle({
    Title = "Generator",
    Callback = function(v)
        ESP.Generator = v
    end
})

local SCPEsp = ESPSection:Toggle({
    Title = "SCP",
    Callback = function(v)
        ESP.SCP = v
    end
})

local PalletESP = ESPSection:Toggle({
    Title = "Pallet",
    Callback = function(v)
        ESP.Pallet = v
    end
})

local WindowESP = ESPSection:Toggle({
    Title = "Window",
    Callback = function(v)
        ESP.Window = v
    end
})

ESPSection:Slider({
    Title = "ESP Radius",
    Value = {
        Min = 10,
        Max = 1000,
        Default = 100,
    },
    Step = 1,
    Callback = function(v)
        ESP.Distance = v
    end
})

-- ESP Status Section
local ESPStatusSection = Tabs.ESP:Section({Title = "ESP Status", Icon = "activity"})

ESPStatusSection:Toggle({
    Title = "Enable Status ESP",
    Callback = function(v)
        ESPStatus.Enabled = v
    end
})

ESPStatusSection:Toggle({
    Title = "Show Name",
    Callback = function(v)
        ESPStatus.ShowName = v
    end
})

ESPStatusSection:Toggle({
    Title = "Show Distance",
    Callback = function(v)
        ESPStatus.ShowDistance = v
    end
})

ESPStatusSection:Toggle({
    Title = "Show Health",
    Callback = function(v)
        ESPStatus.ShowHealth = v
    end
})

ESPStatusSection:Slider({
    Title = "Status Radius",
    Value = {
        Min = 20,
        Max = 500,
        Default = 100,
    },
    Step = 1,
    Callback = function(v)
        ESPStatus.Radius = v
    end
})

-- PLAYER TAB - Survivor
local SurvivorSection = Tabs.Player:Section({Title = "Survivor", Icon = "user-check"})

SurvivorSection:Toggle({
    Title = "Auto Skill Check",
    Callback = function(v)
        Auto.SkillCheck = v
        if v then startSkillCheck() end
    end
})

SurvivorSection:Toggle({
    Title = "Auto Wiggle",
    Callback = function(v)
        Auto.Wiggle = v
    end
})

SurvivorSection:Toggle({
    Title = "Auto Flee Killer",
    Callback = function(v)
        AutoFlee.Enabled = v
    end
})

SurvivorSection:Toggle({
    Title = "Anti KnockDown",
    Callback = function(v)
        PlayerMods.GodMode = v
    end
})

SurvivorSection:Toggle({
    Title = "Fast Vault",
    Callback = function(v)
        FastVault.Enabled = v
    end
})

SurvivorSection:Slider({
    Title = "Vault Speed",
    Value = {
        Min = 1,
        Max = 5,
        Default = 1.2,
    },
    Step = 0.1,
    Callback = function(v)
        FastVault.Speed = v
    end
})

SurvivorSection:Toggle({
    Title = "Moonwalk Button",
    Callback = function(v)
        Moonwalk.ShowButton = v
        if v then
            createMoonwalkButton()
        else
            removeMoonwalkButton()
        end
    end
})

SurvivorSection:Keybind({
    Title = "Moonwalk Keybind",
    Callback = function(key)
        Moonwalk.Enabled = not Moonwalk.Enabled
        if Moonwalk.Enabled then
            startMoonwalk()
        else
            stopMoonwalk()
        end
    end
})

SurvivorSection:Slider({
    Title = "Moonwalk Spam Speed",
    Value = {
        Min = 1,
        Max = 50,
        Default = 30,
    },
    Step = 1,
    Callback = function(v)
        Moonwalk.SpamSpeed = v
    end
})

SurvivorSection:Slider({
    Title = "Moonwalk Intensity",
    Value = {
        Min = 1,
        Max = 50,
        Default = 35,
    },
    Step = 1,
    Callback = function(v)
        Moonwalk.Intensity = v
    end
})

SurvivorSection:Button({
    Title = "Instant Escape",
    Desc = "Teleport to finish line",
    Callback = function()
        teleportToFinishLine()
    end
})

-- PLAYER TAB - Killer
local KillerSection = Tabs.Player:Section({Title = "Killer", Icon = "skull"})

KillerSection:Toggle({
    Title = "Auto Stalk",
    Callback = function(v)
        AutoStalk.Enabled = v
        if v then
            startAutoStalk()
        else
            stopAutoStalk()
        end
    end
})

KillerSection:Toggle({
    Title = "AimLock Attack",
    Callback = function(v)
        AttackAim.Enabled = v
        if v then
            connectAttackAim()
        end
    end
})

KillerSection:Toggle({
    Title = "Auto Kill All",
    Callback = function(v)
        Killer.KillAll = v
    end
})

KillerSection:Toggle({
    Title = "Auto Spam Attack",
    Callback = function(v)
        Killer.AutoAttack = v
    end
})

KillerSection:Slider({
    Title = "Attack Delay",
    Value = {
        Min = 0.1,
        Max = 1,
        Default = 0.45,
    },
    Step = 0.01,
    Callback = function(v)
        Killer.AttackDelay = v
    end
})

KillerSection:Dropdown({
    Title = "Select Power",
    Option = MaskedPowers,
    Value = "Cobra",
    Multi = false,
    Callback = function(val)
        Masked.CurrentPower = val
    end
})

KillerSection:Button({
    Title = "Activate Power",
    Callback = function()
        local Event = ReplicatedStorage:FindFirstChild("Remotes", true)
            and ReplicatedStorage.Remotes:FindFirstChild("Killers", true)
            and ReplicatedStorage.Remotes.Killers:FindFirstChild("Masked", true)
            and ReplicatedStorage.Remotes.Killers.Masked:FindFirstChild("Activatepower")
        
        if Event then
            Event:FireServer(Masked.CurrentPower)
        end
    end
})

KillerSection:Button({
    Title = "Deactivate Power",
    Callback = function()
        local Event = ReplicatedStorage:FindFirstChild("Remotes", true)
            and ReplicatedStorage.Remotes:FindFirstChild("Killers", true)
            and ReplicatedStorage.Remotes.Killers:FindFirstChild("Masked", true)
            and ReplicatedStorage.Remotes.Killers.Masked:FindFirstChild("Deactivatepower")
        
        if Event then
            Event:FireServer()
        end
    end
})

-- Parry Section
local ParrySection = Tabs.Player:Section({Title = "Parry", Icon = "swords"})

ParrySection:Toggle({
    Title = "Auto Parry",
    Callback = function(v)
        Auto.Parry = v
        ParryRangeVisual.Enabled = v
    end
})

ParrySection:Toggle({
    Title = "Show Parry Range",
    Callback = function(v)
        ParryRangeVisual.Enabled = v
        if not v and ParryCircle then
            ParryCircle:Destroy()
            ParryCircle = nil
        end
    end
})

ParrySection:Slider({
    Title = "Parry Distance",
    Value = {
        Min = 5,
        Max = 20,
        Default = 15,
    },
    Step = 1,
    Callback = function(v)
        Auto.ParryDistance = v
    end
})

ParrySection:Slider({
    Title = "Face Sensitivity",
    Value = {
        Min = -1,
        Max = 1,
        Default = 0.7,
    },
    Step = 0.01,
    Callback = function(v)
        Auto.FaceSensitivity = v
    end
})

-- Aimlock Section
local AimlockSection = Tabs.Player:Section({Title = "AimBot", Icon = "crosshair"})

AimlockSection:Toggle({
    Title = "Aim Lock",
    Callback = function(v)
        GunAim.Enabled = v
        if v then connectGunAim() end
    end
})

AimlockSection:Dropdown({
    Title = "Target",
    Option = {"Killer", "Survivor", "SCP"},
    Value = "Killer",
    Multi = false,
    Callback = function(v)
        GunAim.TargetMode = v
    end
})

AimlockSection:Dropdown({
    Title = "Aim Part",
    Option = {"Head", "HumanoidRootPart", "Torso"},
    Value = "HumanoidRootPart",
    Multi = false,
    Callback = function(v)
        GunAim.AimPart = v
    end
})

AimlockSection:Slider({
    Title = "FOV",
    Value = {
        Min = 50,
        Max = 1000,
        Default = 250,
    },
    Step = 1,
    Callback = function(v)
        GunAim.FOV = v
    end
})

AimlockSection:Slider({
    Title = "Prediction",
    Value = {
        Min = 0,
        Max = 1,
        Default = 0.12,
    },
    Step = 0.01,
    Callback = function(v)
        GunAim.PredictStrength = v
    end
})

-- MOVEMENT TAB
local MovementSection = Tabs.Misc:Section({Title = "Movement", Icon = "move"})

MovementSection:Toggle({
    Title = "Walk Speed",
    Callback = function(v)
        Movement.WalkSpeedEnabled = v
        if v then
            applyWalkSpeed()
        else
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = Movement.OriginalWalkSpeed
            end
        end
    end
})

MovementSection:Slider({
    Title = "Walk Speed Value",
    Value = {
        Min = 16,
        Max = 32,
        Default = 17.6,
    },
    Step = 0.1,
    Callback = function(v)
        Movement.WalkSpeedValue = v
        if Movement.WalkSpeedEnabled then
            applyWalkSpeed()
        end
    end
})

MovementSection:Toggle({
    Title = "No Clip",
    Callback = function(v)
        toggleNoClip(v)
    end
})

MovementSection:Toggle({
    Title = "Custom Jump Power",
    Callback = function(v)
        Movement.JumpPowerEnabled = v
        if v then
            applyJumpPower()
        else
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.JumpPower = Movement.OriginalJumpPower
            end
        end
    end
})

MovementSection:Slider({
    Title = "Jump Power Value",
    Value = {
        Min = 0,
        Max = 300,
        Default = 50,
    },
    Step = 1,
    Callback = function(v)
        Movement.JumpPowerValue = v
        if Movement.JumpPowerEnabled then
            applyJumpPower()
        end
    end
})

-- EMOTE SECTION
local EmoteSection = Tabs.Misc:Section({Title = "Emote", Icon = "music"})

EmoteSection:Dropdown({
    Title = "Select Emote",
    Option = EmoteList,
    Value = "Dance",
    Multi = false,
    Callback = function(v)
        Emote.Selected = v
    end
})

EmoteSection:Button({
    Title = "Play Emote",
    Callback = function()
        playEmote(Emote.Selected)
    end
})

EmoteSection:Toggle({
    Title = "Show Emote Button",
    Callback = function(v)
        EmoteButton.Show = v
        if v then
            createEmoteButton()
        else
            removeEmoteButton()
        end
    end
})

-- FUN SECTION
local FunSection = Tabs.Misc:Section({Title = "Fun", Icon = "smile"})

FunSection:Toggle({
    Title = "Jerk Tool",
    Callback = function(v)
        JerkTool.Enabled = v
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

-- AVATAR STEALER SECTION
local AvatarSection = Tabs.Misc:Section({Title = "Morph Avatar", Icon = "user-cog"})

AvatarSection:Input({
    Title = "Target Username",
    Desc = "Enter username to copy avatar",
    Callback = function(val)
        AvatarStealer.TargetUsername = val
    end
})

AvatarSection:Button({
    Title = "Copy Avatar",
    Callback = function()
        copyAvatar(AvatarStealer.TargetUsername)
    end
})

AvatarSection:Button({
    Title = "Reset to Original Skin",
    Callback = function()
        resetAvatar()
    end
})

AvatarSection:Button({
    Title = "Save Current as Original",
    Callback = function()
        saveOriginalAppearance()
    end
})

-- VISUAL TAB
local GraphicsSection = Tabs.Visual:Section({Title = "Graphics", Icon = "sun"})

GraphicsSection:Toggle({
    Title = "Fullbright",
    Callback = function(v)
        Visual.Fullbright = v
        applyVisual()
    end
})

GraphicsSection:Toggle({
    Title = "No Shadow",
    Callback = function(v)
        Visual.NoShadow = v
        applyVisual()
    end
})

GraphicsSection:Toggle({
    Title = "Low Graphics",
    Callback = function(v)
        Visual.LowGraphics = v
        applyOptimization()
    end
})

GraphicsSection:Toggle({
    Title = "No Screen Effects",
    Callback = function(v)
        Visual.NoScreenEffects = v
        applyNoScreenEffects()
    end
})

GraphicsSection:Toggle({
    Title = "Clean Sky",
    Callback = function(v)
        Visual.CleanSky = v
        applyOptimization()
    end
})

-- ZOOM SECTION
local ZoomSection = Tabs.Visual:Section({Title = "Zoom Out", Icon = "fullscreen"})

ZoomSection:Toggle({
    Title = "Unlimited Zoom Out",
    Callback = function(v)
        CameraZoom.UnlimitedZoom = v
        applyUnlimitedZoom()
    end
})

ZoomSection:Slider({
    Title = "Max Zoom Distance",
    Value = {
        Min = 100,
        Max = 5000,
        Default = 1000,
    },
    Step = 1,
    Callback = function(v)
        CameraZoom.MaxDistance = v
        if CameraZoom.UnlimitedZoom then
            applyUnlimitedZoom()
        end
    end
})

ZoomSection:Toggle({
    Title = "Custom FOV",
    Callback = function(v)
        CameraZoom.FOVEnabled = v
        applyCameraFOV()
    end
})

ZoomSection:Slider({
    Title = "Camera FOV",
    Value = {
        Min = 40,
        Max = 120,
        Default = 70,
    },
    Step = 1,
    Callback = function(v)
        CameraZoom.FOV = v
        if CameraZoom.FOVEnabled then
            applyCameraFOV()
        end
    end
})

-- TIME & AMBIENT SECTION
local TimeSection = Tabs.Visual:Section({Title = "Clock & Ambient", Icon = "alarm-clock-check"})

TimeSection:Slider({
    Title = "Clock Time",
    Value = {
        Min = 0,
        Max = 24,
        Default = 14,
    },
    Step = 1,
    Callback = function(v)
        Visual.ClockTime = v
        Visual.Ambient = true
        applyVisual()
    end
})

TimeSection:Slider({
    Title = "Brightness",
    Value = {
        Min = 0,
        Max = 5,
        Default = 2,
    },
    Step = 0.1,
    Callback = function(v)
        Visual.Brightness = v
        Visual.Ambient = true
        applyVisual()
    end
})

-- SETTINGS TAB
local MenuSection = Tabs.Settings:Section({Title = "Menu", Icon = "wrench"})

MenuSection:Toggle({
    Title = "Transparent",
    Callback = function(v)
        Window:SetTransparency(v)
    end
})

MenuSection:Dropdown({
    Title = "Theme",
    Option = {"Dark", "Light", "Forest", "Amethyst"},
    Value = "Dark",
    Multi = false,
    Callback = function(v)
        Window:SetTheme(v)
        VexUI:Notification({
            Title = "Civic Hub",
            Desc = "Theme changed to " .. v,
            Duration = 2
        })
    end
})

MenuSection:Keybind({
    Title = "Toggle Key",
    Callback = function(key)
        Window:SetToggleKey(key)
    end
})

MenuSection:Button({
    Title = "Center Window",
    Callback = function()
        Window:ToCenter()
    end
})

MenuSection:Button({
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

MenuSection:Button({
    Title = "Unload Script",
    Callback = function()
        Window:Destroy()
    end
})

-- Notification test
VexUI:Notification({
    Title = "Civic Hub",
    Desc = "Script loaded successfully! Built by Vinzee",
    Duration = 3
})
