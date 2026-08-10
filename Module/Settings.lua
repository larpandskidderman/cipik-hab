-- =============================================
-- CIVIC HUB - VIOLENCE DISTRICT
-- MODULE: SETTINGS
-- BUILT BY VINZEE
-- VERSION 2.0.0
-- =============================================

-- Dependencies will be injected via setFeatures/setUI
local Features = nil

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

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- =======================================
-- FILESYSTEM HELPERS
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
-- DEEP COPY
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

-- =======================================
-- DEFAULT CONFIGURATION
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
-- CURRENT STATE
local CurrentConfig = deepCopy(DefaultConfig)
local ConfigStorage = {}
local ConfigName = "MyConfig"
local AutoLoadEnabled = false
local AutoLoadConfigName = nil
local IsInitialLoad = true

-- =======================================
-- UI REFERENCES (will be set by Main)
local UICallbacks = {}

local function setUICallbacks(callbacks)
    UICallbacks = callbacks
end

-- =======================================
-- API
local Settings = {}

function Settings:Save(name)
    local configName = name or ConfigName
    local configData = {
        Name = configName,
        Settings = deepCopy(CurrentConfig),
        AutoLoad = AutoLoadEnabled
    }

    if isFileSystemAvailable() then
        local success = saveConfigToFile(configName, configData)
        if success then
            if UICallbacks.Notify then
                UICallbacks.Notify("Setting saved: " .. configName)
            end
        else
            if UICallbacks.Notify then
                UICallbacks.Notify("Failed to save config: " .. configName)
            end
        end
        return success
    else
        ConfigStorage[configName] = configData
        if UICallbacks.Notify then
            UICallbacks.Notify("Config saved in memory: " .. configName)
        end
        return true
    end
end

function Settings:Load(name)
    local configName = name or ConfigName
    local configData

    if isFileSystemAvailable() then
        configData = loadConfigFromFile(configName)
    else
        configData = ConfigStorage[configName]
    end

    if not configData then
        if UICallbacks.Notify then
            UICallbacks.Notify("Setting not found: " .. configName)
        end
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
    CurrentConfig.SurvivorESP = validateValue("SurvivorESP", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.KillerESP = validateValue("KillerESP", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.GeneratorESP = validateValue("GeneratorESP", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.SCPESP = validateValue("SCPESP", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.PalletESP = validateValue("PalletESP", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.WindowESP = validateValue("WindowESP", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.ESPRadius = validateValue("ESPRadius", 100, function(v) return type(v) == "number" end)
    CurrentConfig.StatusESPEnabled = validateValue("StatusESPEnabled", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.StatusShowName = validateValue("StatusShowName", true, function(v) return type(v) == "boolean" end)
    CurrentConfig.StatusShowDistance = validateValue("StatusShowDistance", true, function(v) return type(v) == "boolean" end)
    CurrentConfig.StatusShowHealth = validateValue("StatusShowHealth", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.StatusRadius = validateValue("StatusRadius", 100, function(v) return type(v) == "number" end)
    CurrentConfig.CrosshairEnabled = validateValue("CrosshairEnabled", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.CrosshairStyle = validateValue("CrosshairStyle", "Plus", function(v) return v == "Plus" or v == "Dot" or v == "Circle" end)
    CurrentConfig.CrosshairX = validateValue("CrosshairX", 0, function(v) return type(v) == "number" end)
    CurrentConfig.CrosshairY = validateValue("CrosshairY", 0, function(v) return type(v) == "number" end)
    CurrentConfig.AutoSkillCheck = validateValue("AutoSkillCheck", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.AutoWiggle = validateValue("AutoWiggle", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.AutoFlee = validateValue("AutoFlee", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.AntiKnockDown = validateValue("AntiKnockDown", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.FastVault = validateValue("FastVault", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.VaultSpeed = validateValue("VaultSpeed", 1.2, function(v) return type(v) == "number" end)
    CurrentConfig.MoonwalkShowButton = validateValue("MoonwalkShowButton", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.MoonwalkKeybind = validateValue("MoonwalkKeybind", nil, function(v) return v == nil or type(v) == "string" end)
    CurrentConfig.MoonwalkSpamSpeed = validateValue("MoonwalkSpamSpeed", 30, function(v) return type(v) == "number" end)
    CurrentConfig.MoonwalkIntensity = validateValue("MoonwalkIntensity", 35, function(v) return type(v) == "number" end)
    CurrentConfig.AutoStalk = validateValue("AutoStalk", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.AimLockAttack = validateValue("AimLockAttack", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.AutoKillAll = validateValue("AutoKillAll", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.AutoSpamAttack = validateValue("AutoSpamAttack", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.AttackDelay = validateValue("AttackDelay", 0.45, function(v) return type(v) == "number" end)
    CurrentConfig.MaskedPower = validateValue("MaskedPower", "Cobra", function(v)
        for _, p in pairs(MaskedPowers) do
            if p == v then return true end
        end
        return false
    end)
    CurrentConfig.AutoParry = validateValue("AutoParry", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.ShowParryRange = validateValue("ShowParryRange", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.ParryDistance = validateValue("ParryDistance", 15, function(v) return type(v) == "number" end)
    CurrentConfig.FaceSensitivity = validateValue("FaceSensitivity", 0.7, function(v) return type(v) == "number" end)
    CurrentConfig.AimLockEnabled = validateValue("AimLockEnabled", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.AimTarget = validateValue("AimTarget", "Killer", function(v) return v == "Killer" or v == "Survivor" or v == "SCP" end)
    CurrentConfig.AimPart = validateValue("AimPart", "HumanoidRootPart", function(v) return v == "Head" or v == "HumanoidRootPart" or v == "Torso" end)
    CurrentConfig.AimFOV = validateValue("AimFOV", 250, function(v) return type(v) == "number" end)
    CurrentConfig.AimPrediction = validateValue("AimPrediction", 0.12, function(v) return type(v) == "number" end)
    CurrentConfig.WalkSpeedEnabled = validateValue("WalkSpeedEnabled", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.WalkSpeedValue = validateValue("WalkSpeedValue", 17.6, function(v) return type(v) == "number" end)
    CurrentConfig.NoClip = validateValue("NoClip", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.JumpPowerEnabled = validateValue("JumpPowerEnabled", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.JumpPowerValue = validateValue("JumpPowerValue", 50, function(v) return type(v) == "number" end)
    CurrentConfig.EmoteSelected = validateValue("EmoteSelected", "Mannrobics", function(v)
        for _, e in pairs(EmoteList) do
            if e == v then return true end
        end
        return false
    end)
    CurrentConfig.ShowEmoteButton = validateValue("ShowEmoteButton", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.JerkTool = validateValue("JerkTool", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.Fullbright = validateValue("Fullbright", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.NoShadow = validateValue("NoShadow", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.LowGraphics = validateValue("LowGraphics", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.NoScreenEffects = validateValue("NoScreenEffects", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.CleanSky = validateValue("CleanSky", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.ClockTime = validateValue("ClockTime", 14, function(v) return type(v) == "number" end)
    CurrentConfig.Brightness = validateValue("Brightness", 2, function(v) return type(v) == "number" end)
    CurrentConfig.UnlimitedZoom = validateValue("UnlimitedZoom", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.MaxZoomDistance = validateValue("MaxZoomDistance", 1000, function(v) return type(v) == "number" end)
    CurrentConfig.CustomFOV = validateValue("CustomFOV", false, function(v) return type(v) == "boolean" end)
    CurrentConfig.CameraFOV = validateValue("CameraFOV", 70, function(v) return type(v) == "number" end)

    -- Theme and Transparency
    local theme = validateValue("Theme", "Dark", function(v) return v == "Dark" or v == "Light" or v == "Forest" or v == "Amethyst" end)
    local transparent = validateValue("Transparent", false, function(v) return type(v) == "boolean" end)

    -- Moonwalk - only apply if explicitly enabled in config
    local moonwalkEnabled = validateValue("MoonwalkEnabled", false, function(v) return type(v) == "boolean" end)

    -- Apply features
    Features.applyVisual(true)
    Features.applyOptimization(true)
    Features.applyUnlimitedZoom()
    Features.applyCameraFOV()
    Features.applyNoScreenEffects()
    Features.applyWalkSpeed()
    Features.applyJumpPower()
    Features.toggleNoClip(CurrentConfig.NoClip)
    Features.startGunAim()
    Features.startAttackAim()
    Features.startSkillCheck()
    Features.startAutoStalk()

    -- Only enable moonwalk on initial auto-load
    if IsInitialLoad and AutoLoadEnabled then
        Features.toggleMoonwalk(moonwalkEnabled)
    else
        Features.toggleMoonwalk(false)
    end

    if CurrentConfig.MoonwalkShowButton then
        Features.createMoonwalkButton()
    else
        Features.removeMoonwalkButton()
    end

    if CurrentConfig.ShowEmoteButton then
        Features.createEmoteButton()
    else
        Features.removeEmoteButton()
    end

    if CurrentConfig.JerkTool then
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

    -- Update UI if callbacks exist
    if UICallbacks.UpdateUI then
        UICallbacks.UpdateUI(CurrentConfig)
    end

    if UICallbacks.Notify then
        UICallbacks.Notify("Setting loaded: " .. configName)
    end

    return true
end

function Settings:Update(name)
    local configName = name or ConfigName
    local configData

    if isFileSystemAvailable() then
        configData = loadConfigFromFile(configName)
    else
        configData = ConfigStorage[configName]
    end

    if not configData then
        if UICallbacks.Notify then
            UICallbacks.Notify("Config not found: " .. configName)
        end
        return false
    end

    return self:Save(configName)
end

function Settings:SetAutoLoad(value)
    AutoLoadEnabled = value
end

function Settings:GetAutoLoad()
    return AutoLoadEnabled
end

function Settings:SetAutoLoadConfig(name)
    AutoLoadConfigName = name
end

function Settings:GetAutoLoadConfig()
    return AutoLoadConfigName
end

function Settings:Get(name)
    if name == "ConfigName" then
        return ConfigName
    elseif name == "AutoLoadEnabled" then
        return AutoLoadEnabled
    elseif name == "AutoLoadConfigName" then
        return AutoLoadConfigName
    else
        return CurrentConfig[name]
    end
end

function Settings:Set(name, value)
    if name == "ConfigName" then
        ConfigName = value
    elseif name == "AutoLoadEnabled" then
        AutoLoadEnabled = value
    elseif name == "AutoLoadConfigName" then
        AutoLoadConfigName = value
    else
        CurrentConfig[name] = value
    end
end

function Settings:GetCurrentConfig()
    return CurrentConfig
end

function Settings:SetConfigName(name)
    ConfigName = name
end

function Settings:GetConfigName()
    return ConfigName
end

function Settings:Delete(name)
    local configName = name or ConfigName
    if isFileSystemAvailable() then
        local success = deleteConfigFile(configName)
        if success then
            if UICallbacks.Notify then
                UICallbacks.Notify("Config deleted: " .. configName)
            end
        else
            if UICallbacks.Notify then
                UICallbacks.Notify("Failed to delete config")
            end
        end
        return success
    else
        ConfigStorage[configName] = nil
        if UICallbacks.Notify then
            UICallbacks.Notify("Config removed from memory: " .. configName)
        end
        return true
    end
end

function Settings:ListConfigs()
    return listConfigFiles()
end

function Settings:SetIsInitialLoad(value)
    IsInitialLoad = value
end

function Settings:GetIsInitialLoad()
    return IsInitialLoad
end

function Settings:setUICallbacks(callbacks)
    setUICallbacks(callbacks)
end

-- Set Features module for remote compatibility
function Settings:setFeatures(featuresModule)
    Features = featuresModule
end

-- =======================================
-- EXPORT
return Settings
