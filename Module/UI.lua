-- =============================================
-- CIVIC HUB - VIOLENCE DISTRICT
-- MODULE: UI
-- BUILT BY VINZEE
-- VERSION 2.0.0
-- =============================================

-- Dependencies will be injected via initialize(deps)
local Features = nil
local Settings = nil
local Utils = nil

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

-- =======================================
-- LOAD VEXUI LIBRARY
local VexUI = loadstring(game:HttpGet(
    "https://github.com/SSHRKs/VexUI/releases/latest/download/main.lua"
))()

-- =======================================
-- CONSTANTS
local CIVIC_LOGO_ASSET = "rbxassetid://123996730599332"

-- Define EmoteList and MaskedPowers locally since Features may not be initialized yet
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

-- =======================================
-- UI REFERENCES
local WindowInstance = nil
local Tabs = {}

local UIRefs = {
    -- ESP Tab
    SurvivorESP_Toggle = nil,
    KillerESP_Toggle = nil,
    GeneratorESP_Toggle = nil,
    SCPEsp_Toggle = nil,
    PalletESP_Toggle = nil,
    WindowESP_Toggle = nil,
    ESPRadius_Slider = nil,
    StatusESPEnabled_Toggle = nil,
    StatusShowName_Toggle = nil,
    StatusShowDistance_Toggle = nil,
    StatusShowHealth_Toggle = nil,
    StatusRadius_Slider = nil,
    CrosshairToggle_Toggle = nil,
    CrosshairStyle_Dropdown = nil,
    CrosshairX_Slider = nil,
    CrosshairY_Slider = nil,

    -- Player Tab
    AutoSkillCheck_Toggle = nil,
    SkillCheckMode_Dropdown = nil,
    AutoWiggle_Toggle = nil,
    AutoFlee_Toggle = nil,
    AntiKnockDown_Toggle = nil,
    FastVault_Toggle = nil,
    VaultSpeed_Slider = nil,
    MoonwalkShowButton_Toggle = nil,
    MoonwalkKeybind_Keybind = nil,
    MoonwalkToggle_Toggle = nil,
    MoonwalkSpamSpeed_Slider = nil,
    MoonwalkIntensity_Slider = nil,
    AutoStalk_Toggle = nil,
    AimLockAttack_Toggle = nil,
    AutoKillAll_Toggle = nil,
    AutoSpamAttack_Toggle = nil,
    AttackDelay_Slider = nil,
    MaskedPower_Dropdown = nil,
    AutoParry_Toggle = nil,
    ShowParryRange_Toggle = nil,
    ParryDistance_Slider = nil,
    FaceSensitivity_Slider = nil,
    AimLockEnabled_Toggle = nil,
    AimTarget_Dropdown = nil,
    AimPart_Dropdown = nil,
    AimFOV_Slider = nil,
    AimPrediction_Slider = nil,

    -- Misc Tab
    WalkSpeed_Toggle = nil,
    WalkSpeedValue_Slider = nil,
    NoClip_Toggle = nil,
    JumpPowerEnabled_Toggle = nil,
    JumpPowerValue_Slider = nil,
    EmoteSelected_Dropdown = nil,
    ShowEmoteButton_Toggle = nil,
    JerkTool_Toggle = nil,
    FPSBoost_Toggle = nil,
    ReduceGraphics_Toggle = nil,

    -- Visual Tab
    Fullbright_Toggle = nil,
    NoShadow_Toggle = nil,
    LowGraphics_Toggle = nil,
    NoScreenEffects_Toggle = nil,
    CleanSky_Toggle = nil,
    ClockTime_Slider = nil,
    Brightness_Slider = nil,
    UnlimitedZoom_Toggle = nil,
    MaxZoomDistance_Slider = nil,
    CustomFOV_Toggle = nil,
    CameraFOV_Slider = nil,

    -- Settings Tab
    Transparent_Toggle = nil,
    Theme_Dropdown = nil,
    ToggleKey_Keybind = nil,
}

-- =======================================
-- WATERMARK
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
            WindowInstance.Title = string.format("Civic Hub | FPS: %d | PING: %d ms", FPS, Ping)
        end
    end
end)

-- =======================================
-- CREATE MAIN WINDOW
local function createWindow()
    local Window = VexUI:CreateWindow({
        Name = "Civic Hub",
        Icon = "door-open",
        SideBarWidth = 160,
        Theme = "Dark",
        Transparent = false,
        Author = "Built by Vinzee",
        User = {
            Enabled = true,
            Anonymous = true,
        },
    })

    WindowInstance = Window

    -- Edit Open Button with Civic branding
    Window:EditOpenButton({
        Icon = "door-open",
        Text = "Civic",
    })

    return Window
end

-- =======================================
-- CREATE TABS
local function createTabs(Window)
    Tabs = {
        Info = Window:Tab({Title = "Info", Icon = "info", Border = true}),
        ESP = Window:Tab({Title = "ESP", Icon = "eye", Border = true}),
        Player = Window:Tab({Title = "Player", Icon = "user", Border = true}),
        Misc = Window:Tab({Title = "Misc", Icon = "sliders-horizontal", Border = true}),
        Visual = Window:Tab({Title = "Visual", Icon = "sparkles", Border = true}),
        Settings = Window:Tab({Title = "Settings", Icon = "settings-2", Border = true})
    }

    Window:SelectTab(1)

    return Tabs
end

-- =======================================
-- INFO TAB
local function createInfoTab(Tabs)
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
    Tabs.Info:Button({
        Title = "Copy Discord Link",
        Desc = "Join our community",
        Callback = function()
            if setclipboard then
                setclipboard("https://discord.gg/52KS4yCD2")
            end
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
            if setclipboard then
                setclipboard("https://sociabuzz.com/amill_al/tribe")
            end
            VexUI:Notification({
                Title = "Civic Hub",
                Desc = "Thanks for the support!",
                Duration = 3
            })
        end
    })
end

-- =======================================
-- ESP TAB
local function createESPTab(Tabs)
    Tabs.ESP:Section({Title = "ESP Cham", Icon = "scan-eye"})

    UIRefs.SurvivorESP_Toggle = Tabs.ESP:Toggle({
        Title = "ESP Survivor",
        Value = false,
        Callback = function(v)
            Settings:Set("SurvivorESP", v)
        end
    })

    UIRefs.KillerESP_Toggle = Tabs.ESP:Toggle({
        Title = "ESP Killer",
        Value = false,
        Callback = function(v)
            Settings:Set("KillerESP", v)
        end
    })

    UIRefs.GeneratorESP_Toggle = Tabs.ESP:Toggle({
        Title = "Generator",
        Value = false,
        Callback = function(v)
            Settings:Set("GeneratorESP", v)
        end
    })

    UIRefs.SCPEsp_Toggle = Tabs.ESP:Toggle({
        Title = "SCP",
        Value = false,
        Callback = function(v)
            Settings:Set("SCPESP", v)
        end
    })

    UIRefs.PalletESP_Toggle = Tabs.ESP:Toggle({
        Title = "Pallet",
        Value = false,
        Callback = function(v)
            Settings:Set("PalletESP", v)
        end
    })

    UIRefs.WindowESP_Toggle = Tabs.ESP:Toggle({
        Title = "Window",
        Value = false,
        Callback = function(v)
            Settings:Set("WindowESP", v)
        end
    })

    UIRefs.ESPRadius_Slider = Tabs.ESP:Slider({
        Title = "ESP Radius",
        Value = {
            Min = 10,
            Max = 5000,
            Default = 100,
        },
        Step = 1,
        Callback = function(v)
            Settings:Set("ESPRadius", v)
        end
    })

    Tabs.ESP:Section({Title = "ESP Status", Icon = "activity"})

    UIRefs.StatusESPEnabled_Toggle = Tabs.ESP:Toggle({
        Title = "Enable Status ESP",
        Value = false,
        Callback = function(v)
            Settings:Set("StatusESPEnabled", v)
        end
    })

    UIRefs.StatusShowName_Toggle = Tabs.ESP:Toggle({
        Title = "Show Name",
        Value = true,
        Callback = function(v)
            Settings:Set("StatusShowName", v)
        end
    })

    UIRefs.StatusShowDistance_Toggle = Tabs.ESP:Toggle({
        Title = "Show Distance",
        Value = true,
        Callback = function(v)
            Settings:Set("StatusShowDistance", v)
        end
    })

    UIRefs.StatusShowHealth_Toggle = Tabs.ESP:Toggle({
        Title = "Show Health",
        Value = false,
        Callback = function(v)
            Settings:Set("StatusShowHealth", v)
        end
    })

    UIRefs.StatusRadius_Slider = Tabs.ESP:Slider({
        Title = "Status Radius",
        Value = {
            Min = 20,
            Max = 500,
            Default = 100,
        },
        Step = 1,
        Callback = function(v)
            Settings:Set("StatusRadius", v)
        end
    })

    Tabs.ESP:Section({Title = "Crosshair", Icon = "crosshair"})

    UIRefs.CrosshairToggle_Toggle = Tabs.ESP:Toggle({
        Title = "Enable Crosshair",
        Value = false,
        Callback = function(v)
            Settings:Set("CrosshairEnabled", v)
        end
    })

    UIRefs.CrosshairStyle_Dropdown = Tabs.ESP:Dropdown({
        Title = "Style",
        Option = {"Plus", "Dot", "Circle"},
        Value = "Plus",
        Multi = false,
        Callback = function(v)
            Settings:Set("CrosshairStyle", v)
        end
    })

    UIRefs.CrosshairX_Slider = Tabs.ESP:Slider({
        Title = "Position X",
        Value = {
            Min = -100,
            Max = 100,
            Default = 0,
        },
        Step = 1,
        Callback = function(v)
            Settings:Set("CrosshairX", v)
        end
    })

    UIRefs.CrosshairY_Slider = Tabs.ESP:Slider({
        Title = "Position Y",
        Value = {
            Min = -100,
            Max = 100,
            Default = 0,
        },
        Step = 1,
        Callback = function(v)
            Settings:Set("CrosshairY", v)
        end
    })
end

-- =======================================
-- PLAYER TAB
local function createPlayerTab(Tabs)
    Tabs.Player:Section({Title = "Survivor", Icon = "user-check"})

    UIRefs.AutoSkillCheck_Toggle = Tabs.Player:Toggle({
        Title = "Auto Skill Check",
        Value = false,
        Callback = function(v)
            Settings:Set("AutoSkillCheck", v)
            if v then
                Features.startSkillCheck()
            else
                Features.stopSkillCheck()
            end
        end
    })

    UIRefs.SkillCheckMode_Dropdown = Tabs.Player:Dropdown({
        Title = "Skill Check Mode",
        Option = {"Instant", "Legit", "Random"},
        Value = "Legit",
        Multi = false,
        Callback = function(v)
            Settings:Set("SkillCheckMode", v)
        end
    })

    UIRefs.AutoWiggle_Toggle = Tabs.Player:Toggle({
        Title = "Auto Wiggle",
        Value = false,
        Callback = function(v)
            Settings:Set("AutoWiggle", v)
        end
    })

    UIRefs.AutoFlee_Toggle = Tabs.Player:Toggle({
        Title = "Auto Flee Killer",
        Value = false,
        Callback = function(v)
            Settings:Set("AutoFlee", v)
        end
    })

    UIRefs.AntiKnockDown_Toggle = Tabs.Player:Toggle({
        Title = "Anti KnockDown",
        Value = false,
        Callback = function(v)
            Settings:Set("AntiKnockDown", v)
        end
    })

    UIRefs.FastVault_Toggle = Tabs.Player:Toggle({
        Title = "Fast Vault",
        Value = false,
        Callback = function(v)
            Settings:Set("FastVault", v)
        end
    })

    UIRefs.VaultSpeed_Slider = Tabs.Player:Slider({
        Title = "Vault Speed",
        Value = {
            Min = 1,
            Max = 5,
            Default = 1.2,
        },
        Step = 0.1,
        Callback = function(v)
            Settings:Set("VaultSpeed", v)
        end
    })

    UIRefs.MoonwalkShowButton_Toggle = Tabs.Player:Toggle({
        Title = "Moonwalk Button",
        Value = false,
        Callback = function(v)
            Settings:Set("MoonwalkShowButton", v)
            if v then
                Features.createMoonwalkButton()
            else
                Features.removeMoonwalkButton()
            end
        end
    })

    UIRefs.MoonwalkKeybind_Keybind = Tabs.Player:Keybind({
        Title = "Moonwalk Keybind",
        Value = "None",
        Callback = function(key)
            if key and key ~= "None" then
                Settings:Set("MoonwalkKeybind", key)
            end
            Features.toggleMoonwalk()
        end
    })

    UIRefs.MoonwalkToggle_Toggle = Tabs.Player:Toggle({
        Title = "Moonwalk",
        Value = false,
        Callback = function(v)
            Features.toggleMoonwalk(v)
        end
    })

    UIRefs.MoonwalkSpamSpeed_Slider = Tabs.Player:Slider({
        Title = "Moonwalk Spam Speed",
        Value = {
            Min = 1,
            Max = 50,
            Default = 30,
        },
        Step = 1,
        Callback = function(v)
            Settings:Set("MoonwalkSpamSpeed", v)
        end
    })

    UIRefs.MoonwalkIntensity_Slider = Tabs.Player:Slider({
        Title = "Moonwalk Intensity",
        Value = {
            Min = 1,
            Max = 50,
            Default = 35,
        },
        Step = 1,
        Callback = function(v)
            Settings:Set("MoonwalkIntensity", v)
        end
    })

    Tabs.Player:Button({
        Title = "Instant Escape",
        Desc = "Teleport to finish line",
        Callback = function()
            Features.teleportToFinishLine()
        end
    })

    Tabs.Player:Section({Title = "Killer", Icon = "skull"})

    UIRefs.AutoStalk_Toggle = Tabs.Player:Toggle({
        Title = "Auto Stalk",
        Value = false,
        Callback = function(v)
            Settings:Set("AutoStalk", v)
            if v then
                Features.startAutoStalk()
            else
                Features.stopAutoStalk()
            end
        end
    })

    UIRefs.AimLockAttack_Toggle = Tabs.Player:Toggle({
        Title = "AimLock Attack",
        Value = false,
        Callback = function(v)
            Settings:Set("AimLockAttack", v)
            if v then
                Features.startAttackAim()
            else
                Features.stopAttackAim()
            end
        end
    })

    UIRefs.AutoKillAll_Toggle = Tabs.Player:Toggle({
        Title = "Auto Kill All",
        Value = false,
        Callback = function(v)
            Settings:Set("AutoKillAll", v)
        end
    })

    UIRefs.AutoSpamAttack_Toggle = Tabs.Player:Toggle({
        Title = "Auto Spam Attack",
        Value = false,
        Callback = function(v)
            Settings:Set("AutoSpamAttack", v)
        end
    })

    UIRefs.AttackDelay_Slider = Tabs.Player:Slider({
        Title = "Attack Delay",
        Value = {
            Min = 0.1,
            Max = 1,
            Default = 0.45,
        },
        Step = 0.01,
        Callback = function(v)
            Settings:Set("AttackDelay", v)
        end
    })

    UIRefs.MaskedPower_Dropdown = Tabs.Player:Dropdown({
        Title = "Select Power",
        Option = MaskedPowers,
        Value = "Cobra",
        Multi = false,
        Callback = function(v)
            Settings:Set("MaskedPower", v)
        end
    })

    Tabs.Player:Button({
        Title = "Activate Power",
        Callback = function()
            local Remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
            if Remotes then
                local Event = Remotes:FindFirstChild("Killers", true)
                    and Remotes.Killers:FindFirstChild("Masked", true)
                    and Remotes.Killers.Masked:FindFirstChild("Activatepower")
                if Event then
                    Event:FireServer(Settings:Get("MaskedPower"))
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
            local Remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
            if Remotes then
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

    UIRefs.AutoParry_Toggle = Tabs.Player:Toggle({
        Title = "Auto Parry",
        Value = false,
        Callback = function(v)
            Settings:Set("AutoParry", v)
            if not v then
                Settings:Set("ShowParryRange", false)
                if UIRefs.ShowParryRange_Toggle then
                    UIRefs.ShowParryRange_Toggle:SetValue(false)
                end
            end
        end
    })

    UIRefs.ShowParryRange_Toggle = Tabs.Player:Toggle({
        Title = "Show Parry Range",
        Value = false,
        Callback = function(v)
            Settings:Set("ShowParryRange", v)
            if not v then
                Features.updateParryCircle()
            end
        end
    })

    UIRefs.ParryDistance_Slider = Tabs.Player:Slider({
        Title = "Parry Distance",
        Value = {
            Min = 5,
            Max = 20,
            Default = 15,
        },
        Step = 1,
        Callback = function(v)
            Settings:Set("ParryDistance", v)
        end
    })

    UIRefs.FaceSensitivity_Slider = Tabs.Player:Slider({
        Title = "Face Sensitivity",
        Value = {
            Min = -1,
            Max = 1,
            Default = 0.7,
        },
        Step = 0.01,
        Callback = function(v)
            Settings:Set("FaceSensitivity", v)
        end
    })

    Tabs.Player:Section({Title = "AimBot", Icon = "crosshair"})

    UIRefs.AimLockEnabled_Toggle = Tabs.Player:Toggle({
        Title = "Aim Lock",
        Value = false,
        Callback = function(v)
            Settings:Set("AimLockEnabled", v)
            if v then
                Features.startGunAim()
            else
                Features.stopGunAim()
            end
        end
    })

    UIRefs.AimTarget_Dropdown = Tabs.Player:Dropdown({
        Title = "Target",
        Option = {"Killer", "Survivor", "SCP"},
        Value = "Killer",
        Multi = false,
        Callback = function(v)
            Settings:Set("AimTarget", v)
        end
    })

    UIRefs.AimPart_Dropdown = Tabs.Player:Dropdown({
        Title = "Aim Part",
        Option = {"Head", "HumanoidRootPart", "Torso"},
        Value = "HumanoidRootPart",
        Multi = false,
        Callback = function(v)
            Settings:Set("AimPart", v)
        end
    })

    UIRefs.AimFOV_Slider = Tabs.Player:Slider({
        Title = "FOV",
        Value = {
            Min = 50,
            Max = 1000,
            Default = 250,
        },
        Step = 1,
        Callback = function(v)
            Settings:Set("AimFOV", v)
        end
    })

    UIRefs.AimPrediction_Slider = Tabs.Player:Slider({
        Title = "Prediction",
        Value = {
            Min = 0,
            Max = 1,
            Default = 0.12,
        },
        Step = 0.01,
        Callback = function(v)
            Settings:Set("AimPrediction", v)
        end
    })
end

-- =======================================
-- MISC TAB
local function createMiscTab(Tabs)
    Tabs.Misc:Section({Title = "Movement", Icon = "move"})

    UIRefs.WalkSpeed_Toggle = Tabs.Misc:Toggle({
        Title = "Walk Speed",
        Value = false,
        Callback = function(v)
            Settings:Set("WalkSpeedEnabled", v)
            if v then
                Features.applyWalkSpeed()
            else
                Features.stopWalkSpeed()
            end
        end
    })

    UIRefs.WalkSpeedValue_Slider = Tabs.Misc:Slider({
        Title = "Walk Speed Value",
        Value = {
            Min = 16,
            Max = 32,
            Default = 17.6,
        },
        Step = 0.1,
        Callback = function(v)
            Settings:Set("WalkSpeedValue", v)
            if Settings:Get("WalkSpeedEnabled") then
                Features.applyWalkSpeed()
            end
        end
    })

    UIRefs.NoClip_Toggle = Tabs.Misc:Toggle({
        Title = "No Clip",
        Value = false,
        Callback = function(v)
            Features.toggleNoClip(v)
        end
    })

    UIRefs.JumpPowerEnabled_Toggle = Tabs.Misc:Toggle({
        Title = "Custom Jump Power",
        Value = false,
        Callback = function(v)
            Settings:Set("JumpPowerEnabled", v)
            if v then
                Features.applyJumpPower()
            else
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.JumpPower = Features.OriginalValues.JumpPower
                end
            end
        end
    })

    UIRefs.JumpPowerValue_Slider = Tabs.Misc:Slider({
        Title = "Jump Power Value",
        Value = {
            Min = 0,
            Max = 300,
            Default = 50,
        },
        Step = 1,
        Callback = function(v)
            Settings:Set("JumpPowerValue", v)
            if Settings:Get("JumpPowerEnabled") then
                Features.applyJumpPower()
            end
        end
    })

    Tabs.Misc:Section({Title = "Emote", Icon = "music"})

    UIRefs.EmoteSelected_Dropdown = Tabs.Misc:Dropdown({
        Title = "Select Emote",
        Option = EmoteList,
        Value = "Mannrobics",
        Multi = false,
        Callback = function(v)
            Settings:Set("EmoteSelected", v)
        end
    })

    Tabs.Misc:Button({
        Title = "Play Emote",
        Callback = function()
            Features.playEmote(Settings:Get("EmoteSelected"))
        end
    })

    UIRefs.ShowEmoteButton_Toggle = Tabs.Misc:Toggle({
        Title = "Show Emote Button",
        Value = false,
        Callback = function(v)
            Settings:Set("ShowEmoteButton", v)
            if v then
                Features.createEmoteButton()
            else
                Features.removeEmoteButton()
            end
        end
    })

    Tabs.Misc:Section({Title = "Fun", Icon = "smile"})

    UIRefs.JerkTool_Toggle = Tabs.Misc:Toggle({
        Title = "Jerk Tool",
        Value = false,
        Callback = function(v)
            Settings:Set("JerkTool", v)
            if v then
                Features.createJerkTool()
            else
                local char = LocalPlayer.Character
                if char then
                    local tool = char:FindFirstChild("Jerk Off")
                    if tool then tool:Destroy() end
                    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                    if backpack then
                        local tool = backpack:FindFirstChild("Jerk Off")
                        if tool then tool:Destroy() end
                    end
                end
            end
        end
    })

    Tabs.Misc:Section({Title = "Morph Avatar", Icon = "user-cog"})

    -- Performance Section
    Tabs.Misc:Section({Title = "Performance", Icon = "gauge"})

    UIRefs.FPSBoost_Toggle = Tabs.Misc:Toggle({
        Title = "Boost FPS",
        Value = false,
        Callback = function(v)
            Settings:Set("FPSBoost", v)
            if v then
                Features.applyFPSBoost()
            else
                Features.disableFPSBoost()
            end
        end
    })

    UIRefs.ReduceGraphics_Toggle = Tabs.Misc:Toggle({
        Title = "Reduce Graphics",
        Value = false,
        Callback = function(v)
            Settings:Set("ReduceGraphics", v)
            if v then
                Features.applyReduceGraphics()
            else
                Features.disableReduceGraphics()
            end
        end
    })

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
end

-- =======================================
-- VISUAL TAB
local function createVisualTab(Tabs)
    Tabs.Visual:Section({Title = "Graphics", Icon = "sun"})

    UIRefs.Fullbright_Toggle = Tabs.Visual:Toggle({
        Title = "Fullbright",
        Value = false,
        Callback = function(v)
            Settings:Set("Fullbright", v)
            Features.applyVisual(true)
        end
    })

    UIRefs.NoShadow_Toggle = Tabs.Visual:Toggle({
        Title = "No Shadow",
        Value = false,
        Callback = function(v)
            Settings:Set("NoShadow", v)
            Features.applyVisual(true)
        end
    })

    UIRefs.LowGraphics_Toggle = Tabs.Visual:Toggle({
        Title = "Low Graphics",
        Value = false,
        Callback = function(v)
            Settings:Set("LowGraphics", v)
            Features.applyOptimization(true)
        end
    })

    UIRefs.NoScreenEffects_Toggle = Tabs.Visual:Toggle({
        Title = "No Screen Effects",
        Value = false,
        Callback = function(v)
            Settings:Set("NoScreenEffects", v)
            Features.applyNoScreenEffects()
        end
    })

    UIRefs.CleanSky_Toggle = Tabs.Visual:Toggle({
        Title = "Clean Sky",
        Value = false,
        Callback = function(v)
            Settings:Set("CleanSky", v)
            Features.applyOptimization(true)
        end
    })

    Tabs.Visual:Section({Title = "Clock & Ambient", Icon = "alarm-clock-check"})

    UIRefs.ClockTime_Slider = Tabs.Visual:Slider({
        Title = "Clock Time",
        Value = {
            Min = 0,
            Max = 24,
            Default = 14,
        },
        Step = 1,
        Callback = function(v)
            Settings:Set("ClockTime", v)
            Features.applyVisual(true)
        end
    })

    UIRefs.Brightness_Slider = Tabs.Visual:Slider({
        Title = "Brightness",
        Value = {
            Min = 0,
            Max = 5,
            Default = 2,
        },
        Step = 0.1,
        Callback = function(v)
            Settings:Set("Brightness", v)
            Features.applyVisual(true)
        end
    })

    Tabs.Visual:Section({Title = "Zoom Out", Icon = "fullscreen"})

    UIRefs.UnlimitedZoom_Toggle = Tabs.Visual:Toggle({
        Title = "Unlimited Zoom Out",
        Value = false,
        Callback = function(v)
            Settings:Set("UnlimitedZoom", v)
            Features.applyUnlimitedZoom()
        end
    })

    UIRefs.MaxZoomDistance_Slider = Tabs.Visual:Slider({
        Title = "Max Zoom Distance",
        Value = {
            Min = 100,
            Max = 5000,
            Default = 1000,
        },
        Step = 1,
        Callback = function(v)
            Settings:Set("MaxZoomDistance", v)
            if Settings:Get("UnlimitedZoom") then
                Features.applyUnlimitedZoom()
            end
        end
    })

    UIRefs.CustomFOV_Toggle = Tabs.Visual:Toggle({
        Title = "Custom FOV",
        Value = false,
        Callback = function(v)
            Settings:Set("CustomFOV", v)
            Features.applyCameraFOV()
        end
    })

    UIRefs.CameraFOV_Slider = Tabs.Visual:Slider({
        Title = "Camera FOV",
        Value = {
            Min = 40,
            Max = 120,
            Default = 70,
        },
        Step = 1,
        Callback = function(v)
            Settings:Set("CameraFOV", v)
            if Settings:Get("CustomFOV") then
                Features.applyCameraFOV()
            end
        end
    })
end

-- =======================================
-- SETTINGS TAB
local function createSettingsTab(Tabs, Window)
    Tabs.Settings:Section({Title = "Configuration", Icon = "save"})

    local ConfigName = Settings:GetConfigName()

    Tabs.Settings:Input({
        Title = "Setting Name",
        Desc = "Enter a name for your configuration",
        Value = ConfigName,
        Callback = function(val)
            Settings:SetConfigName(val)
        end
    })

    local configOptions = Settings:ListConfigs()
    table.insert(configOptions, 1, "Select Config")

    local configDropdown
    configDropdown = Tabs.Settings:Dropdown({
        Title = "Saved Settings",
        Option = configOptions,
        Value = "Select Config",
        Multi = false,
        Callback = function(val)
            if val ~= "Select Config" then
                Settings:SetConfigName(val)
            end
        end
    })

    Tabs.Settings:Button({
        Title = "Refresh Config List",
        Callback = function()
            local options = Settings:ListConfigs()
            table.insert(options, 1, "Select Config")
            configDropdown:SetOptions(options)
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
            local name = Settings:GetConfigName()
            if name and name ~= "" and name ~= "Select Config" then
                Settings:Save(name)
                local options = Settings:ListConfigs()
                table.insert(options, 1, "Select Config")
                configDropdown:SetOptions(options)
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
            local name = Settings:GetConfigName()
            if name and name ~= "Select Config" then
                Settings:SetIsInitialLoad(false)
                Settings:Load(name)
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
            local name = Settings:GetConfigName()
            if name and name ~= "Select Config" then
                Settings:Update(name)
                VexUI:Notification({
                    Title = "Civic Hub",
                    Desc = "Setting updated: " .. name,
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
            local name = Settings:GetConfigName()
            if name and name ~= "Select Config" then
                Settings:Delete(name)
                local options = Settings:ListConfigs()
                table.insert(options, 1, "Select Config")
                configDropdown:SetOptions(options)
                Settings:SetConfigName("MyConfig")
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
            Settings:SetAutoLoad(v)
        end
    })

    local autoLoadInput
    Tabs.Settings:Input({
        Title = "Auto Load Config Name",
        Desc = "Name of config to auto-load",
        Value = "",
        Callback = function(val)
            Settings:SetAutoLoadConfig(val)
        end
    })

    Tabs.Settings:Button({
        Title = "Set Auto Load Config",
        Desc = "Set the config to auto-load",
        Callback = function()
            local autoLoadName = Settings:GetAutoLoadConfig()
            if autoLoadName and autoLoadName ~= "" then
                VexUI:Notification({
                    Title = "Civic Hub",
                    Desc = "Auto-load config set to: " .. autoLoadName,
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

    UIRefs.Transparent_Toggle = Tabs.Settings:Toggle({
        Title = "Transparent",
        Value = false,
        Callback = function(v)
            Window:SetTransparency(v)
        end
    })

    UIRefs.Theme_Dropdown = Tabs.Settings:Dropdown({
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

    UIRefs.ToggleKey_Keybind = Tabs.Settings:Keybind({
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
            if setclipboard then
                setclipboard("https://discord.gg/3kmTx8Aeew")
            end
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
            Features.stopMoonwalk()
            Features.stopSkillCheck()
            Features.stopAutoStalk()
            Features.stopGunAim()
            Features.stopAttackAim()
            Features.stopWalkSpeed()
            Features.clearAllESP()
            Features.clearCrosshair()
            Window:Destroy()
        end
    })
end

-- =======================================
-- UPDATE UI FROM CONFIG
local function updateUIFromConfig(config)
    -- This function can be used to sync UI with loaded config
    -- Implementation depends on VexUI API for setting values programmatically
end

-- =======================================
-- NOTIFY CALLBACK
local function notify(message)
    VexUI:Notification({
        Title = "Civic Hub",
        Desc = message,
        Duration = 3
    })
end

-- =======================================
-- SET UI CALLBACKS IN SETTINGS
-- This must be called AFTER Settings is injected via initialize()
local function registerUICallbacks()
    if Settings and type(Settings.setUICallbacks) == "function" then
        Settings:setUICallbacks({
            Notify = notify,
            UpdateUI = updateUIFromConfig
        })
    end
end

-- =======================================
-- MAIN INITIALIZATION
local function initialize(deps)
    -- Inject dependencies from Main.lua
    if deps then
        Features = deps.Features or Features
        Settings = deps.Settings or Settings
        Utils = deps.Utils or Utils
    end

    local Window = createWindow()
    local Tabs = createTabs(Window)

    createInfoTab(Tabs)
    createESPTab(Tabs)
    createPlayerTab(Tabs)
    createMiscTab(Tabs)
    createVisualTab(Tabs)
    createSettingsTab(Tabs, Window)

    -- Register UI callbacks after all dependencies are injected
    registerUICallbacks()

    return {
        Window = Window,
        Tabs = Tabs,
        UIRefs = UIRefs,
    }
end

-- =======================================
-- EXPORT
return {
    initialize = initialize,
    updateUIFromConfig = updateUIFromConfig,
    notify = notify,
    WindowInstance = WindowInstance,
}
