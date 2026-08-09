-- Civic Hub - Migrated to VexUI
-- Built by Vinzee

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Load VexUI
local VexUI = loadstring(game:HttpGet("https://github.com/SSHRKs/VexUI/releases/latest/download/main.lua"))()

-- Create Window
local Window = VexUI:CreateWindow({
    Name = "Civic Hub",
    Icon = "shield-check",
    SideBarWidth = 160,
    Theme = "Dark",
    Transparent = true,
    Author = "Built by Vinzee",
    User = {
        Enabled = true,
        Anonymous = true,
    },
})

-- Hide default open button transparency to make it invisible
Window:EditOpenButton({
    Title = "Open Civic Hub",
    Icon = "door-open",
    Transparency = 1,
    StrokeThickness = 0,
    Rotation = 0,
    Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 80)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 90, 255))
    },
    AutoRotation = false,
    Speed = 15,
    CornerRadius = UDim.new(0,16),
})

-- Services & Events
local CarryEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Carry"):WaitForChild("CarrySurvivorEvent")
local HookEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Carry"):WaitForChild("HookEvent")
local AttackEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attacks"):WaitForChild("BasicAttack")
local SkillCheckRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Generator"):WaitForChild("SkillCheckResultEvent")

-- Config Tables
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
    Killer = Color3.fromRGB(255, 60, 60),
    Survivor = Color3.fromRGB(60, 255, 120)
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

local Crosshair = {
    Style = "Dot",
    PosX = 0,
    PosY = 0
}

local EmoteConfig = {
    SelectedEmote = "Salute",
    ShowButton = false
}

local JerkToolEnabled = false

-- Helper Functions
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
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local anim = track.Animation
                if anim and anim.AnimationId then
                    if anim.AnimationId == "rbxassetid://127096285501517" then return true end
                    if anim.AnimationId == "rbxassetid://112166042383605" then return true end
                    if anim.AnimationId == "http://www.roblox.com/asset/?id=126965695851149" then return true end
                    if anim.AnimationId == "http://www.roblox.com/asset/?id=135084204086504" then return true end
                    if anim.AnimationId == "rbxassetid://123047897844134" then return true end
                    local id = anim.AnimationId:match("%d+")
                    if id then
                        local fullId = "rbxassetid://" .. id
                        if KillerAnims[fullId] then return true end
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

local WalkSpeedConnection = nil

local function applyWalkSpeed()
    if WalkSpeedConnection then
        WalkSpeedConnection:Disconnect()
        WalkSpeedConnection = nil
    end
    WalkSpeedConnection = RunService.Heartbeat:Connect(function()
        if not Movement.WalkSpeedEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if shouldDisableWalkSpeed() then return end
        if hum.WalkSpeed ~= Movement.WalkSpeedValue then
            hum.WalkSpeed = Movement.WalkSpeedValue
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.8)
    applyJumpPower()
    applyWalkSpeed()
end)

local NoClipConnection = nil

local function applyNoClip()
    local char = LocalPlayer.Character
    if not char then return end
    if NoClipConnection then
        NoClipConnection:Disconnect()
        NoClipConnection = nil
    end
    if Movement.NoClip then
        NoClipConnection = RunService.Stepped:Connect(function()
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end)
    end
end

-- Create Tabs
local InfoTab = Window:Tab({Title = "Info", Icon = "info", Border = true})
local ESPTab = Window:Tab({Title = "ESP", Icon = "eye", Border = true})
local PlayerTab = Window:Tab({Title = "Player", Icon = "user", Border = true})
local MiscTab = Window:Tab({Title = "Misc", Icon = "sliders-horizontal", Border = true})
local VisualTab = Window:Tab({Title = "Visual", Icon = "sparkles", Border = true})
local SettingsTab = Window:Tab({Title = "UI Settings", Icon = "settings-2", Border = true})

Window:SelectTab(1)

-- INFO TAB
InfoTab:Section({Title = "Script Info", Icon = "info"})
InfoTab:Paragraph({Title = "Civic Hub", Desc = "Advanced Roblox Utility Script"})
InfoTab:Paragraph({Title = "Developer", Desc = "Built by Vinzee"})
InfoTab:Paragraph({Title = "Version", Desc = "1.0.0 - VexUI Migration"})

InfoTab:Section({Title = "Credits", Icon = "user"})
InfoTab:Button({
    Title = "Copy Discord Link",
    Callback = function()
        setclipboard("https://discord.gg/fallens")
        VexUI:Notification({Title = "Discord Copied", Desc = "Link copied to clipboard", Duration = 2})
    end
})
InfoTab:Button({
    Title = "Copy Support Link",
    Callback = function()
        setclipboard("https://discord.gg/fallens")
        VexUI:Notification({Title = "Support Link Copied", Desc = "Link copied to clipboard", Duration = 2})
    end
})

-- ESP TAB
ESPTab:Section({Title = "ESP Cham", Icon = "scan-eye"})
ESPTab:Toggle({
    Title = "Survivor ESP",
    Callback = function(Value)
        ESP.Survivor = Value
    end
})
ESPTab:Toggle({
    Title = "Killer ESP",
    Callback = function(Value)
        ESP.Killer = Value
    end
})
ESPTab:Toggle({
    Title = "Generator ESP",
    Callback = function(Value)
        ESP.Generator = Value
    end
})
ESPTab:Toggle({
    Title = "Pallet ESP",
    Callback = function(Value)
        ESP.Pallet = Value
    end
})
ESPTab:Toggle({
    Title = "Window ESP",
    Callback = function(Value)
        ESP.Window = Value
    end
})
ESPTab:Toggle({
    Title = "SCP ESP",
    Callback = function(Value)
        ESP.SCP = Value
    end
})
ESPTab:Slider({
    Title = "ESP Distance",
    Value = {Min = 50, Max = 500, Default = 100},
    Step = 10,
    Callback = function(Value)
        ESP.Distance = Value
    end
})

ESPTab:Section({Title = "ESP Status", Icon = "scan-eye"})
ESPTab:Toggle({
    Title = "Enable ESP Status",
    Callback = function(Value)
        ESPStatus.Enabled = Value
    end
})
ESPTab:Toggle({
    Title = "Show Name",
    Callback = function(Value)
        ESPStatus.ShowName = Value
    end
})
ESPTab:Toggle({
    Title = "Show Distance",
    Callback = function(Value)
        ESPStatus.ShowDistance = Value
    end
})
ESPTab:Toggle({
    Title = "Show Health",
    Callback = function(Value)
        ESPStatus.ShowHealth = Value
    end
})
ESPTab:Slider({
    Title = "Status Radius",
    Value = {Min = 50, Max = 300, Default = 100},
    Step = 10,
    Callback = function(Value)
        ESPStatus.Radius = Value
    end
})

-- PLAYER TAB
local SurvivorTab = PlayerTab:Tab({Title = "Survivor", Icon = "user", Border = true})
local KillerSubTab = PlayerTab:Tab({Title = "Killer", Icon = "skull", Border = true})

SurvivorTab:Section({Title = "Auto Actions", Icon = "zap"})
SurvivorTab:Toggle({
    Title = "Auto Skill Check",
    Callback = function(Value)
        Auto.SkillCheck = Value
    end
})
SurvivorTab:Toggle({
    Title = "Auto Wiggle",
    Callback = function(Value)
        Auto.Wiggle = Value
    end
})
SurvivorTab:Slider({
    Title = "Wiggle Spam Speed",
    Value = {Min = 1, Max = 20, Default = 5},
    Step = 1,
    Callback = function(Value)
        Auto.WiggleSpam = Value
    end
})
SurvivorTab:Slider({
    Title = "Vault Speed",
    Value = {Min = 0.5, Max = 5, Default = 1},
    Step = 0.1,
    Callback = function(Value)
        -- Vault speed logic would go here
    end
})
SurvivorTab:Slider({
    Title = "Moonwalk Spam Speed",
    Value = {Min = 10, Max = 100, Default = 30},
    Step = 5,
    Callback = function(Value)
        Moonwalk.SpamSpeed = Value
    end
})
SurvivorTab:Slider({
    Title = "Moonwalk Intensity",
    Value = {Min = 10, Max = 100, Default = 35},
    Step = 5,
    Callback = function(Value)
        Moonwalk.Intensity = Value
    end
})
SurvivorTab:Button({
    Title = "Activate Moonwalk",
    Callback = function()
        Moonwalk.Enabled = true
    end
})

KillerSubTab:Section({Title = "Killer Actions", Icon = "skull"})
KillerSubTab:Slider({
    Title = "Attack Delay",
    Value = {Min = 0.1, Max = 2, Default = 0.45},
    Step = 0.05,
    Callback = function(Value)
        Killer.AttackDelay = Value
    end
})
KillerSubTab:Toggle({
    Title = "Kill All",
    Callback = function(Value)
        Killer.KillAll = Value
    end
})
KillerSubTab:Toggle({
    Title = "Auto Attack",
    Callback = function(Value)
        Killer.AutoAttack = Value
    end
})
KillerSubTab:Toggle({
    Title = "Auto Carry",
    Callback = function(Value)
        Killer.AutoCarry = Value
    end
})
KillerSubTab:Dropdown({
    Title = "Masked Power",
    Option = MaskedPowers,
    Value = "Cobra",
    Callback = function(Value)
        Masked.CurrentPower = Value
    end
})
KillerSubTab:Button({
    Title = "Activate Power",
    Callback = function()
        Masked.Enabled = true
    end
})
KillerSubTab:Button({
    Title = "Deactivate Power",
    Callback = function()
        Masked.Enabled = false
    end
})

PlayerTab:Section({Title = "Parry", Icon = "swords"})
PlayerTab:Slider({
    Title = "Parry Distance",
    Value = {Min = 5, Max = 50, Default = 15},
    Step = 1,
    Callback = function(Value)
        Auto.ParryDistance = Value
    end
})
PlayerTab:Slider({
    Title = "Face Sensitivity",
    Value = {Min = 0.1, Max = 1, Default = 0.7},
    Step = 0.1,
    Callback = function(Value)
        Auto.FaceSensitivity = Value
    end
})
PlayerTab:Toggle({
    Title = "Auto Parry",
    Callback = function(Value)
        Auto.Parry = Value
    end
})

PlayerTab:Section({Title = "AimBot", Icon = "crosshair"})
PlayerTab:Toggle({
    Title = "Gun Aim Enabled",
    Callback = function(Value)
        GunAim.Enabled = Value
    end
})
PlayerTab:Dropdown({
    Title = "Target Mode",
    Option = {"Killer", "Survivor", "Closest"},
    Value = "Killer",
    Callback = function(Value)
        GunAim.TargetMode = Value
    end
})
PlayerTab:Dropdown({
    Title = "Aim Part",
    Option = {"HumanoidRootPart", "Head", "Torso"},
    Value = "HumanoidRootPart",
    Callback = function(Value)
        GunAim.AimPart = Value
    end
})
PlayerTab:Slider({
    Title = "Aim FOV",
    Value = {Min = 50, Max = 500, Default = 250},
    Step = 10,
    Callback = function(Value)
        GunAim.FOV = Value
    end
})
PlayerTab:Slider({
    Title = "Prediction Strength",
    Value = {Min = 0, Max = 1, Default = 0.12},
    Step = 0.01,
    Callback = function(Value)
        GunAim.PredictStrength = Value
    end
})

PlayerTab:Section({Title = "Crosshair", Icon = "crosshair"})
PlayerTab:Dropdown({
    Title = "Crosshair Style",
    Option = {"Dot", "Circle", "Cross", "Plus"},
    Value = "Dot",
    Callback = function(Value)
        Crosshair.Style = Value
    end
})
PlayerTab:Slider({
    Title = "Crosshair Pos X",
    Value = {Min = -500, Max = 500, Default = 0},
    Step = 10,
    Callback = function(Value)
        Crosshair.PosX = Value
    end
})
PlayerTab:Slider({
    Title = "Crosshair Pos Y",
    Value = {Min = -500, Max = 500, Default = 0},
    Step = 10,
    Callback = function(Value)
        Crosshair.PosY = Value
    end
})

-- MISC TAB
MiscTab:Section({Title = "Movement", Icon = "move"})
MiscTab:Slider({
    Title = "WalkSpeed",
    Value = {Min = 16, Max = 100, Default = 17.6},
    Step = 0.1,
    Callback = function(Value)
        Movement.WalkSpeedValue = Value
        Movement.WalkSpeedEnabled = true
        applyWalkSpeed()
    end
})
MiscTab:Slider({
    Title = "JumpPower",
    Value = {Min = 50, Max = 200, Default = 50},
    Step = 1,
    Callback = function(Value)
        Movement.JumpPowerValue = Value
        Movement.JumpPowerEnabled = true
        applyJumpPower()
    end
})
MiscTab:Toggle({
    Title = "NoClip",
    Callback = function(Value)
        Movement.NoClip = Value
        applyNoClip()
    end
})

MiscTab:Section({Title = "Emote", Icon = "music"})
MiscTab:Dropdown({
    Title = "Select Emote",
    Option = {"Salute", "Wave", "Cheer", "Dance", "Laugh", "Point", "Shrug"},
    Value = "Salute",
    Callback = function(Value)
        EmoteConfig.SelectedEmote = Value
    end
})
MiscTab:Button({
    Title = "Play Emote",
    Callback = function()
        -- Play emote logic
    end
})
MiscTab:Toggle({
    Title = "Show Emote Button",
    Callback = function(Value)
        EmoteConfig.ShowButton = Value
    end
})

MiscTab:Section({Title = "Fun", Icon = "smile"})
MiscTab:Toggle({
    Title = "Jerk Tool",
    Callback = function(Value)
        JerkToolEnabled = Value
    end
})

-- VISUAL TAB
VisualTab:Section({Title = "Graphics", Icon = "sun"})
VisualTab:Toggle({
    Title = "Fullbright",
    Callback = function(Value)
        if Value then
            Lighting.Brightness = 2
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
        end
    end
})
VisualTab:Toggle({
    Title = "No Shadows",
    Callback = function(Value)
        Lighting.GlobalShadows = not Value
    end
})
VisualTab:Toggle({
    Title = "Low Graphics",
    Callback = function(Value)
        if Value then
            Lighting.ShadowSoftness = 0
            Lighting.Technology = Enum.Technology.Compatibility
        else
            Lighting.ShadowSoftness = 0.5
            Lighting.Technology = Enum.Technology.Future
        end
    end
})

VisualTab:Section({Title = "Morph Avatar", Icon = "user"})
VisualTab:Input({
    Title = "Username to Steal",
    Callback = function(Value)
        AvatarStealer.TargetUsername = Value
    end
})
VisualTab:Button({
    Title = "Copy Avatar",
    Callback = function()
        -- Avatar steal logic
    end
})
VisualTab:Button({
    Title = "Reset to Original Skin",
    Callback = function()
        -- Reset avatar logic
    end
})
VisualTab:Button({
    Title = "Save Current as Original",
    Callback = function()
        -- Save avatar logic
    end
})

VisualTab:Section({Title = "Clock & Ambient", Icon = "alarm-clock-check"})
VisualTab:Slider({
    Title = "Clock Time",
    Value = {Min = 0, Max = 24, Default = 12},
    Step = 0.5,
    Callback = function(Value)
        Lighting.ClockTime = Value
    end
})
VisualTab:Slider({
    Title = "Brightness",
    Value = {Min = 0, Max = 3, Default = 1},
    Step = 0.1,
    Callback = function(Value)
        Lighting.Brightness = Value
    end
})

VisualTab:Section({Title = "Zoom Out", Icon = "fullscreen"})
VisualTab:Toggle({
    Title = "Unlimited Zoom",
    Callback = function(Value)
        CameraZoom.UnlimitedZoom = Value
        if Value then
            Camera.MaxDistance = CameraZoom.MaxDistance
            Camera.MinDistance = CameraZoom.MinDistance
        else
            Camera.MaxDistance = 100
            Camera.MinDistance = 0.5
        end
    end
})
VisualTab:Slider({
    Title = "Max Zoom Distance",
    Value = {Min = 100, Max = 1000, Default = 1000},
    Step = 50,
    Callback = function(Value)
        CameraZoom.MaxDistance = Value
        if CameraZoom.UnlimitedZoom then
            Camera.MaxDistance = Value
        end
    end
})
VisualTab:Toggle({
    Title = "Custom FOV",
    Callback = function(Value)
        CameraZoom.FOVEnabled = Value
    end
})
VisualTab:Slider({
    Title = "Camera FOV",
    Value = {Min = 30, Max = 120, Default = 70},
    Step = 1,
    Callback = function(Value)
        CameraZoom.FOV = Value
        if CameraZoom.FOVEnabled then
            Camera.FieldOfView = Value
        end
    end
})

-- SETTINGS TAB
SettingsTab:Section({Title = "Menu", Icon = "wrench"})
SettingsTab:Toggle({
    Title = "Show Custom Cursor",
    Callback = function(Value)
        Window:SetCursorEnabled(Value)
    end
})
SettingsTab:Dropdown({
    Title = "Notification Side",
    Option = {"Left", "Right"},
    Value = "Right",
    Callback = function(Value)
        -- Notification side logic
    end
})
SettingsTab:Dropdown({
    Title = "DPI Scale",
    Option = {"1", "1.25", "1.5", "1.75", "2"},
    Value = "1",
    Callback = function(Value)
        -- DPI scale logic
    end
})
SettingsTab:Slider({
    Title = "UI Corner Radius",
    Value = {Min = 0, Max = 30, Default = 20},
    Step = 1,
    Callback = function(Value)
        -- Corner radius logic
    end
})
SettingsTab:Toggle({
    Title = "Show Watermark",
    Callback = function(Value)
        -- Watermark toggle logic
    end
})
SettingsTab:Button({
    Title = "Join Discord",
    Callback = function()
        setclipboard("https://discord.gg/fallens")
        VexUI:Notification({Title = "Discord Link Copied", Desc = "Join our community!", Duration = 2})
    end
})
SettingsTab:Button({
    Title = "Unload Script",
    Callback = function()
        Window:Destroy()
        if FloatingLogo then
            FloatingLogo:Destroy()
        end
    end
})

SettingsTab:Section({Title = "Theme", Icon = "palette"})
SettingsTab:Dropdown({
    Title = "Theme",
    Option = {"Dark", "Light", "Forest", "Amethyst"},
    Value = "Dark",
    Callback = function(Value)
        Window:SetTheme(Value)
        VexUI:Notification({Title = "Theme Changed", Desc = "Selected: " .. Value, Duration = 2})
    end
})
SettingsTab:Toggle({
    Title = "Transparent Background",
    Callback = function(Value)
        Window:SetTransparency(Value)
    end
})

local SettingsGroup = SettingsTab:Group({})
SettingsGroup:Toggle({
    Title = "Resizable Window",
    Default = true,
    Callback = function(Value)
        Window:SetResizable(Value)
    end
})
SettingsGroup:Keybind({
    Title = "Toggle Key",
    Callback = function(Key)
        Window:SetToggleKey(Enum.KeyCode[Key])
    end
})

-- FLOATING CIVIC LOGO
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CivicHub_FloatingLogo"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local FloatingLogo = Instance.new("ImageButton")
FloatingLogo.Name = "CivicLogo"
FloatingLogo.Image = "rbxassetid://97658052504663"
FloatingLogo.Size = UDim2.new(0, 50, 0, 50)
FloatingLogo.Position = UDim2.new(0.02, 0, 0.5, 0)
FloatingLogo.BackgroundTransparency = 1
FloatingLogo.BorderSizePixel = 0
FloatingLogo.Parent = ScreenGui

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(1, 0)
LogoCorner.Parent = FloatingLogo

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = Color3.fromRGB(70, 85, 130)
LogoStroke.Thickness = 1
LogoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
LogoStroke.Parent = FloatingLogo

local LogoGlow = Instance.new("UIStroke")
LogoGlow.Color = Color3.fromRGB(45, 75, 145)
LogoGlow.Thickness = 5
LogoGlow.Transparency = 0.7
LogoGlow.Parent = FloatingLogo

-- Dragging System
local dragging = false
local dragInput = nil
local mousePos = nil
local startMousePos = nil
local startPos = nil
local isDragging = false
local dragThreshold = 5

local function updatePosition(input)
    local delta = input.Position - startMousePos
    local newX = startPos.X.Offset + delta.X
    local newY = startPos.Y.Offset + delta.Y
    
    -- Keep within screen bounds
    local maxX = ScreenGui.AbsoluteSize.X - FloatingLogo.AbsoluteSize.X
    local maxY = ScreenGui.AbsoluteSize.Y - FloatingLogo.AbsoluteSize.Y
    newX = math.clamp(newX, 0, maxX)
    newY = math.clamp(newY, 0, maxY)
    
    FloatingLogo.Position = UDim2.new(0, newX, 0, newY)
end

FloatingLogo.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        startMousePos = input.Position
        startPos = FloatingLogo.Position
        isDragging = false
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

FloatingLogo.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - startMousePos
        if delta.Magnitude > dragThreshold then
            isDragging = true
        end
        updatePosition(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - startMousePos
        if delta.Magnitude > dragThreshold then
            isDragging = true
        end
        updatePosition(input)
    end
end)

-- Click/Tap to Toggle GUI
FloatingLogo.MouseButton1Click:Connect(function()
    if not isDragging then
        -- Small delay to ensure drag state is final
        task.spawn(function()
            task.wait(0.1)
            if not isDragging then
                -- Toggle window visibility
                local mainWindow = ScreenGui:FindFirstChildWhichIsA("Frame")
                if mainWindow then
                    mainWindow.Visible = not mainWindow.Visible
                end
            end
            isDragging = false
        end)
    end
end)

-- Hover Effects
FloatingLogo.MouseEnter:Connect(function()
    TweenService:Create(FloatingLogo, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    }):Play()
end)

FloatingLogo.MouseLeave:Connect(function()
    TweenService:Create(FloatingLogo, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    }):Play()
end)

-- Click Animation
FloatingLogo.MouseButton1Down:Connect(function()
    TweenService:Create(FloatingLogo, TweenInfo.new(0.08), {
        Size = UDim2.fromOffset(45, 45)
    }):Play()
end)

FloatingLogo.MouseButton1Up:Connect(function()
    TweenService:Create(FloatingLogo, TweenInfo.new(0.08), {
        Size = UDim2.fromOffset(50, 50)
    }):Play()
end)

-- Notification on Load
VexUI:Notification({
    Title = "Civic Hub Loaded",
    Desc = "Welcome to Civic Hub! Built by Vinzee",
    Duration = 3,
    Icon = "shield-check"
})

-- Cleanup old connections when character respawns
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    applyJumpPower()
    applyWalkSpeed()
    applyNoClip()
end)
