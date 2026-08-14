--!strict
-- =============================================
-- CIVIC HUB - VIOLENCE DISTRICT
-- MODULE: SETTINGS
-- BUILT BY VINZEE (REFACTORED BY ZEX)
-- VERSION 3.0.0
-- =============================================

-- =============================================
-- TYPE DEFINITIONS
-- =============================================

export type ThemeName = "Dark" | "Light" | "Forest" | "Amethyst"
export type CrosshairStyle = "Plus" | "Dot" | "Circle"
export type SkillCheckMode = "Instant" | "Legit" | "Random"
export type AimTargetType = "Killer" | "Survivor" | "SCP"
export type AimPartType = "Head" | "HumanoidRootPart" | "Torso"
export type EmoteName = "Mannrobics" | "Arm Swing" | "Schadenfreude" | "Kyoufuu" | "Backflip" | "Griddy" | "Friday Night" | "Floating Rest" | "OnePlays" | "Quick Combo" | "WarCry" | "Wave"
export type MaskedPowerName = "Cobra" | "Richter" | "Brandon" | "Rabbit" | "Alex"

export type SettingsData = {
    -- ESP
    SurvivorESP: boolean,
    KillerESP: boolean,
    GeneratorESP: boolean,
    SCPESP: boolean,
    PalletESP: boolean,
    WindowESP: boolean,
    ESPRadius: number,

    -- ESP Status
    StatusESPEnabled: boolean,
    StatusShowName: boolean,
    StatusShowDistance: boolean,
    StatusShowHealth: boolean,
    StatusRadius: number,

    -- Crosshair
    CrosshairEnabled: boolean,
    CrosshairStyle: CrosshairStyle,
    CrosshairX: number,
    CrosshairY: number,

    -- Player
    AutoSkillCheck: boolean,
    SkillCheckMode: SkillCheckMode,
    AutoWiggle: boolean,
    AutoFlee: boolean,
    AntiKnockDown: boolean,
    FastVault: boolean,
    VaultSpeed: number,
    MoonwalkShowButton: boolean,
    MoonwalkKeybind: string?,
    MoonwalkSpamSpeed: number,
    MoonwalkIntensity: number,
    MoonwalkEnabled: boolean,

    -- Killer
    AutoStalk: boolean,
    AimLockAttack: boolean,
    AutoKillAll: boolean,
    AutoSpamAttack: boolean,
    AttackDelay: number,
    MaskedPower: MaskedPowerName,

    -- Parry
    AutoParry: boolean,
    ShowParryRange: boolean,
    ParryDistance: number,
    FaceSensitivity: number,

    -- AimBot
    AimLockEnabled: boolean,
    AimTarget: AimTargetType,
    AimPart: AimPartType,
    AimFOV: number,
    AimPrediction: number,

    -- Movement
    WalkSpeedEnabled: boolean,
    WalkSpeedValue: number,
    NoClip: boolean,
    JumpPowerEnabled: boolean,
    JumpPowerValue: number,

    -- Emote
    EmoteSelected: EmoteName,
    ShowEmoteButton: boolean,

    -- Fun
    JerkTool: boolean,

    -- Visual
    Fullbright: boolean,
    NoShadow: boolean,
    LowGraphics: boolean,
    NoScreenEffects: boolean,
    CleanSky: boolean,
    ClockTime: number,
    Brightness: number,
    FPSBoost: boolean,
    ReduceGraphics: boolean,

    -- Zoom
    UnlimitedZoom: boolean,
    MaxZoomDistance: number,
    CustomFOV: boolean,
    CameraFOV: number,

    -- Theme
    Theme: ThemeName,
    Transparent: boolean,
}

export type PersistenceData = {
    Settings: SettingsData,
    ConfigName: string,
    AutoLoadEnabled: boolean,
    AutoLoadConfigName: string?,
    LastSaved: number?,
    Version: string,
}

export type UICallbacks = {
    UpdateUI: ((SettingsData) -> ())?,
    Notify: ((string) -> ())?,
}

-- =============================================
-- CONSTANTS
-- =============================================

local CONSTANTS = {
    PERSISTENCE_FOLDER = "CivicHub",
    PERSISTENCE_FILE = "settings.json",
    SAVE_DEBOUNCE_TIME = 0.5,
    VERSION = "3.0.0",

    VALID_THEMES = { "Dark", "Light", "Forest", "Amethyst" },
    VALID_CROSSHAIR_STYLES = { "Plus", "Dot", "Circle" },
    VALID_SKILLCHECK_MODES = { "Instant", "Legit", "Random" },
    VALID_AIM_TARGETS = { "Killer", "Survivor", "SCP" },
    VALID_AIM_PARTS = { "Head", "HumanoidRootPart", "Torso" },
    VALID_EMOTES = {
        "Mannrobics", "Arm Swing", "Schadenfreude", "Kyoufuu",
        "Backflip", "Griddy", "Friday Night", "Floating Rest",
        "OnePlays", "Quick Combo", "WarCry", "Wave"
    },
    VALID_MASKED_POWERS = { "Cobra", "Richter", "Brandon", "Rabbit", "Alex" },
}

-- =============================================
-- DEFAULT SETTINGS
-- =============================================

local DEFAULT_SETTINGS: SettingsData = {
    SurvivorESP = false,
    KillerESP = false,
    GeneratorESP = false,
    SCPESP = false,
    PalletESP = false,
    WindowESP = false,
    ESPRadius = 5000,

    StatusESPEnabled = false,
    StatusShowName = true,
    StatusShowDistance = true,
    StatusShowHealth = false,
    StatusRadius = 5000,

    CrosshairEnabled = false,
    CrosshairStyle = "Plus",
    CrosshairX = 0,
    CrosshairY = 0,

    AutoSkillCheck = false,
    SkillCheckMode = "Legit",
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

    AutoStalk = false,
    AimLockAttack = false,
    AutoKillAll = false,
    AutoSpamAttack = false,
    AttackDelay = 0.45,
    MaskedPower = "Cobra",

    AutoParry = false,
    ShowParryRange = false,
    ParryDistance = 15,
    FaceSensitivity = 0.7,

    AimLockEnabled = false,
    AimTarget = "Killer",
    AimPart = "HumanoidRootPart",
    AimFOV = 250,
    AimPrediction = 0.12,

    WalkSpeedEnabled = false,
    WalkSpeedValue = 17.6,
    NoClip = false,
    JumpPowerEnabled = false,
    JumpPowerValue = 50,

    EmoteSelected = "Mannrobics",
    ShowEmoteButton = false,

    JerkTool = false,

    Fullbright = false,
    NoShadow = false,
    LowGraphics = false,
    NoScreenEffects = false,
    CleanSky = false,
    ClockTime = 14,
    Brightness = 2,
    FPSBoost = false,
    ReduceGraphics = false,

    UnlimitedZoom = false,
    MaxZoomDistance = 1000,
    CustomFOV = false,
    CameraFOV = 70,

    Theme = "Dark",
    Transparent = false,
}

-- =============================================
-- SERVICES
-- =============================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- =============================================
-- STATE
-- =============================================

local CurrentConfig: SettingsData = table.clone(DEFAULT_SETTINGS) -- shallow copy cukup karena semua primitive
local ConfigName: string = "MyConfig"
local AutoLoadEnabled: boolean = false
local AutoLoadConfigName: string? = nil
local IsInitialLoad: boolean = true
local PersistenceInitialized: boolean = false

-- Features module (injected)
local Features: any = nil

-- UI Callbacks
local UICallbacks: UICallbacks = {}

-- Save mutex
local SaveMutex = {
    locked = false,
    pending = false,
    timer = nil :: thread?,
}

-- =============================================
-- FILESYSTEM HELPERS
-- =============================================

local function isFileSystemAvailable(): boolean
    local success = pcall(function()
        return writefile and readfile and isfile and makefolder and isfolder
    end)
    return success
end

local function ensurePersistenceFolder(): boolean
    if not isFileSystemAvailable() then return false end

    local success, err = pcall(function()
        if not isfolder(CONSTANTS.PERSISTENCE_FOLDER) then
            makefolder(CONSTANTS.PERSISTENCE_FOLDER)
        end
    end)

    if not success then
        warn("[Civic Hub] Failed to create persistence folder:", err)
        return false
    end
    return true
end

local function getPersistencePath(): string?
    if not ensurePersistenceFolder() then return nil end
    return CONSTANTS.PERSISTENCE_FOLDER .. "/" .. CONSTANTS.PERSISTENCE_FILE
end

-- =============================================
-- SAFE FEATURES CALL
-- =============================================

local function safeCallFeatures(method: string, ...): boolean
    if not Features then
        warn("[Civic Hub] Features module not initialized, skipping:", method)
        return false
    end

    local fn = Features[method]
    if type(fn) ~= "function" then
        warn("[Civic Hub] Method not found in Features:", method)
        return false
    end

    local success, err = pcall(fn, ...)
    if not success then
        warn("[Civic Hub] Error in Features." .. method .. ":", err)
        return false
    end
    return true
end

-- =============================================
-- SETTINGS VALIDATION
-- =============================================

local function isValidTheme(v: any): boolean
    if type(v) ~= "string" then return false end
    for _, valid in ipairs(CONSTANTS.VALID_THEMES) do
        if v == valid then return true end
    end
    return false
end

local function isValidCrosshairStyle(v: any): boolean
    if type(v) ~= "string" then return false end
    for _, valid in ipairs(CONSTANTS.VALID_CROSSHAIR_STYLES) do
        if v == valid then return true end
    end
    return false
end

local function isValidSkillCheckMode(v: any): boolean
    if type(v) ~= "string" then return false end
    for _, valid in ipairs(CONSTANTS.VALID_SKILLCHECK_MODES) do
        if v == valid then return true end
    end
    return false
end

local function isValidAimTarget(v: any): boolean
    if type(v) ~= "string" then return false end
    for _, valid in ipairs(CONSTANTS.VALID_AIM_TARGETS) do
        if v == valid then return true end
    end
    return false
end

local function isValidAimPart(v: any): boolean
    if type(v) ~= "string" then return false end
    for _, valid in ipairs(CONSTANTS.VALID_AIM_PARTS) do
        if v == valid then return true end
    end
    return false
end

local function isValidEmote(v: any): boolean
    if type(v) ~= "string" then return false end
    for _, valid in ipairs(CONSTANTS.VALID_EMOTES) do
        if v == valid then return true end
    end
    return false
end

local function isValidMaskedPower(v: any): boolean
    if type(v) ~= "string" then return false end
    for _, valid in ipairs(CONSTANTS.VALID_MASKED_POWERS) do
        if v == valid then return true end
    end
    return false
end

-- =============================================
-- SETTINGS VALIDATOR TABLE
-- =============================================

local VALIDATORS = {
    SurvivorESP = function(v) return type(v) == "boolean" end,
    KillerESP = function(v) return type(v) == "boolean" end,
    GeneratorESP = function(v) return type(v) == "boolean" end,
    SCPESP = function(v) return type(v) == "boolean" end,
    PalletESP = function(v) return type(v) == "boolean" end,
    WindowESP = function(v) return type(v) == "boolean" end,
    ESPRadius = function(v) return type(v) == "number" and v > 0 end,

    StatusESPEnabled = function(v) return type(v) == "boolean" end,
    StatusShowName = function(v) return type(v) == "boolean" end,
    StatusShowDistance = function(v) return type(v) == "boolean" end,
    StatusShowHealth = function(v) return type(v) == "boolean" end,
    StatusRadius = function(v) return type(v) == "number" and v > 0 end,

    CrosshairEnabled = function(v) return type(v) == "boolean" end,
    CrosshairStyle = isValidCrosshairStyle,
    CrosshairX = function(v) return type(v) == "number" end,
    CrosshairY = function(v) return type(v) == "number" end,

    AutoSkillCheck = function(v) return type(v) == "boolean" end,
    SkillCheckMode = isValidSkillCheckMode,
    AutoWiggle = function(v) return type(v) == "boolean" end,
    AutoFlee = function(v) return type(v) == "boolean" end,
    AntiKnockDown = function(v) return type(v) == "boolean" end,
    FastVault = function(v) return type(v) == "boolean" end,
    VaultSpeed = function(v) return type(v) == "number" and v > 0 end,
    MoonwalkShowButton = function(v) return type(v) == "boolean" end,
    MoonwalkKeybind = function(v) return v == nil or type(v) == "string" end,
    MoonwalkSpamSpeed = function(v) return type(v) == "number" and v > 0 end,
    MoonwalkIntensity = function(v) return type(v) == "number" end,
    MoonwalkEnabled = function(v) return type(v) == "boolean" end,

    AutoStalk = function(v) return type(v) == "boolean" end,
    AimLockAttack = function(v) return type(v) == "boolean" end,
    AutoKillAll = function(v) return type(v) == "boolean" end,
    AutoSpamAttack = function(v) return type(v) == "boolean" end,
    AttackDelay = function(v) return type(v) == "number" and v >= 0 end,
    MaskedPower = isValidMaskedPower,

    AutoParry = function(v) return type(v) == "boolean" end,
    ShowParryRange = function(v) return type(v) == "boolean" end,
    ParryDistance = function(v) return type(v) == "number" and v > 0 end,
    FaceSensitivity = function(v) return type(v) == "number" and v >= 0 and v <= 1 end,

    AimLockEnabled = function(v) return type(v) == "boolean" end,
    AimTarget = isValidAimTarget,
    AimPart = isValidAimPart,
    AimFOV = function(v) return type(v) == "number" and v > 0 end,
    AimPrediction = function(v) return type(v) == "number" and v >= 0 end,

    WalkSpeedEnabled = function(v) return type(v) == "boolean" end,
    WalkSpeedValue = function(v) return type(v) == "number" and v > 0 end,
    NoClip = function(v) return type(v) == "boolean" end,
    JumpPowerEnabled = function(v) return type(v) == "boolean" end,
    JumpPowerValue = function(v) return type(v) == "number" and v > 0 end,

    EmoteSelected = isValidEmote,
    ShowEmoteButton = function(v) return type(v) == "boolean" end,

    JerkTool = function(v) return type(v) == "boolean" end,

    Fullbright = function(v) return type(v) == "boolean" end,
    NoShadow = function(v) return type(v) == "boolean" end,
    LowGraphics = function(v) return type(v) == "boolean" end,
    NoScreenEffects = function(v) return type(v) == "boolean" end,
    CleanSky = function(v) return type(v) == "boolean" end,
    ClockTime = function(v) return type(v) == "number" and v >= 0 and v <= 24 end,
    Brightness = function(v) return type(v) == "number" and v >= 0 end,
    FPSBoost = function(v) return type(v) == "boolean" end,
    ReduceGraphics = function(v) return type(v) == "boolean" end,

    UnlimitedZoom = function(v) return type(v) == "boolean" end,
    MaxZoomDistance = function(v) return type(v) == "number" and v > 0 end,
    CustomFOV = function(v) return type(v) == "boolean" end,
    CameraFOV = function(v) return type(v) == "number" and v > 0 end,

    Theme = isValidTheme,
    Transparent = function(v) return type(v) == "boolean" end,
}

-- =============================================
-- VALIDATION HELPER
-- =============================================

local function validateAndApplyValue(
    target: SettingsData,
    key: string,
    value: any,
    default: any
): boolean
    local validator = VALIDATORS[key]
    if not validator then
        warn("[Civic Hub] Unknown setting key:", key)
        return false
    end

    if validator(value) then
        target[key] = value
        return true
    else
        target[key] = default
        return false
    end
end

-- =============================================
-- PERSISTENCE - INTERNAL
-- =============================================

local function serializeConfig(): PersistenceData
    return {
        Settings = table.clone(CurrentConfig),
        ConfigName = ConfigName,
        AutoLoadEnabled = AutoLoadEnabled,
        AutoLoadConfigName = AutoLoadConfigName,
        LastSaved = os.time(),
        Version = CONSTANTS.VERSION,
    }
end

local function deserializeConfig(data: any): PersistenceData?
    if type(data) ~= "table" then return nil end
    if type(data.Settings) ~= "table" then return nil end

    return data :: PersistenceData
end

local function saveSettingsInternal(): boolean
    if not isFileSystemAvailable() then return false end

    local path = getPersistencePath()
    if not path then return false end

    local configData = serializeConfig()

    local success, result = pcall(function()
        local json = HttpService:JSONEncode(configData)
        writefile(path, json)
        return true
    end)

    if not success then
        warn("[Civic Hub] Save failed:", result)
        return false
    end

    return result
end

local function loadSettingsInternal(): PersistenceData?
    if not isFileSystemAvailable() then return nil end

    local path = getPersistencePath()
    if not path then return nil end
    if not isfile(path) then return nil end

    local success, result = pcall(function()
        local json = readfile(path)
        return HttpService:JSONDecode(json)
    end)

    if not success then
        warn("[Civic Hub] Load failed:", result)
        return nil
    end

    return deserializeConfig(result)
end

-- =============================================
-- PERSISTENCE - PUBLIC (THROTTLED)
-- =============================================

local function scheduleSave()
    if SaveMutex.locked then
        SaveMutex.pending = true
        return
    end

    SaveMutex.locked = true

    if SaveMutex.timer then
        task.cancel(SaveMutex.timer)
        SaveMutex.timer = nil
    end

    SaveMutex.timer = task.delay(CONSTANTS.SAVE_DEBOUNCE_TIME, function()
        SaveMutex.timer = nil
        SaveMutex.locked = false

        local success = saveSettingsInternal()

        if SaveMutex.pending then
            SaveMutex.pending = false
            scheduleSave()
        end

        return success
    end)
end

-- =============================================
-- SETTINGS MANAGEMENT - INTERNAL
-- =============================================

local function initializeDefaultSettings()
    CurrentConfig = table.clone(DEFAULT_SETTINGS)
end

local function mergeSettings(loadedData: PersistenceData): boolean
    local loadedSettings = loadedData.Settings

    -- Start with defaults
    local newConfig = table.clone(DEFAULT_SETTINGS)

    -- Apply each setting with validation
    for key, defaultValue in pairs(DEFAULT_SETTINGS) do
        local loadedValue = loadedSettings[key]
        if loadedValue ~= nil then
            validateAndApplyValue(newConfig, key, loadedValue, defaultValue)
        end
    end

    CurrentConfig = newConfig

    -- Load metadata
    if loadedData.ConfigName then
        ConfigName = loadedData.ConfigName
    end
    if loadedData.AutoLoadEnabled ~= nil then
        AutoLoadEnabled = loadedData.AutoLoadEnabled
    end
    if loadedData.AutoLoadConfigName then
        AutoLoadConfigName = loadedData.AutoLoadConfigName
    end

    return true
end

-- =============================================
-- FEATURES APPLICATION
-- =============================================

local function applyAllFeatures()
    safeCallFeatures("applyVisual", true)
    safeCallFeatures("applyOptimization", true)
    safeCallFeatures("applyUnlimitedZoom")
    safeCallFeatures("applyCameraFOV")
    safeCallFeatures("applyNoScreenEffects")

    if CurrentConfig.FPSBoost then
        safeCallFeatures("applyFPSBoost")
    end
    if CurrentConfig.ReduceGraphics then
        safeCallFeatures("applyReduceGraphics")
    end

    safeCallFeatures("applyWalkSpeed")
    safeCallFeatures("applyJumpPower")
    safeCallFeatures("toggleNoClip", CurrentConfig.NoClip)
    safeCallFeatures("startGunAim")
    safeCallFeatures("startAttackAim")
    safeCallFeatures("startSkillCheck")
    safeCallFeatures("startAutoStalk")

    -- Moonwalk
    if IsInitialLoad and AutoLoadEnabled then
        safeCallFeatures("toggleMoonwalk", CurrentConfig.MoonwalkEnabled)
    else
        safeCallFeatures("toggleMoonwalk", false)
    end

    -- UI Buttons
    if CurrentConfig.MoonwalkShowButton then
        safeCallFeatures("createMoonwalkButton")
    else
        safeCallFeatures("removeMoonwalkButton")
    end

    if CurrentConfig.ShowEmoteButton then
        safeCallFeatures("createEmoteButton")
    else
        safeCallFeatures("removeEmoteButton")
    end

    -- Jerk Tool cleanup
    if not CurrentConfig.JerkTool then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChild("Jerk Off")
                if tool then tool:Destroy() end
            end
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
            if backpack then
                local tool = backpack:FindFirstChild("Jerk Off")
                if tool then tool:Destroy() end
            end
        end)
    end
end

-- =============================================
-- SETTINGS MANAGEMENT - PUBLIC API
-- =============================================

local Settings = {}

-- =============================================
-- PERSISTENCE SYSTEM FUNCTIONS
-- =============================================

function Settings.SaveSettings(): boolean
    return saveSettingsInternal()
end

function Settings.LoadSettings(): PersistenceData?
    return loadSettingsInternal()
end

function Settings.UpdateSetting(key: string, value: any): boolean
    if DEFAULT_SETTINGS[key] == nil then
        warn("[Civic Hub] Unknown setting key:", key)
        return false
    end

    local defaultValue = DEFAULT_SETTINGS[key]
    local success = validateAndApplyValue(CurrentConfig, key, value, defaultValue)
    if success then
        scheduleSave()
    end
    return success
end

function Settings.ResetSettings(): boolean
    initializeDefaultSettings()
    return saveSettingsInternal()
end

function Settings.AutoLoadSettings(): boolean
    initializeDefaultSettings()

    local loadedData = loadSettingsInternal()
    if loadedData then
        local success = mergeSettings(loadedData)
        if success then
            PersistenceInitialized = true
            applyAllFeatures()
            return true
        end
    end

    -- Fallback to defaults
    initializeDefaultSettings()
    PersistenceInitialized = true
    return false
end

function Settings.GetCurrentConfig(): SettingsData
    return CurrentConfig
end

function Settings.GetDefaultSettings(): SettingsData
    return DEFAULT_SETTINGS
end

function Settings.IsPersistenceInitialized(): boolean
    return PersistenceInitialized
end

-- =============================================
-- CONFIG MANAGEMENT FUNCTIONS
-- =============================================

function Settings.Save(name: string?): boolean
    local configName = name or ConfigName

    if isFileSystemAvailable() then
        local path = getPersistencePath()
        if not path then return false end

        local configData = serializeConfig()
        configData.ConfigName = configName

        local success, err = pcall(function()
            local json = HttpService:JSONEncode(configData)
            writefile(path, json)
            return true
        end)

        if success and err then
            if UICallbacks.Notify then
                UICallbacks.Notify("Settings saved: " .. configName)
            end
            return true
        else
            warn("[Civic Hub] Save config failed:", err)
            if UICallbacks.Notify then
                UICallbacks.Notify("Failed to save config: " .. configName)
            end
            return false
        end
    else
        if UICallbacks.Notify then
            UICallbacks.Notify("File system not available, cannot save")
        end
        return false
    end
end

function Settings.Load(name: string?): boolean
    local configName = name or ConfigName

    if not isFileSystemAvailable() then
        if UICallbacks.Notify then
            UICallbacks.Notify("File system not available")
        end
        return false
    end

    local loadedData = loadSettingsInternal()
    if not loadedData then
        if UICallbacks.Notify then
            UICallbacks.Notify("Config not found: " .. configName)
        end
        return false
    end

    -- Update config name if different
    if loadedData.ConfigName and loadedData.ConfigName ~= configName then
        ConfigName = loadedData.ConfigName
    end

    local success = mergeSettings(loadedData)
    if not success then
        if UICallbacks.Notify then
            UICallbacks.Notify("Failed to load config: " .. configName)
        end
        return false
    end

    applyAllFeatures()

    if UICallbacks.UpdateUI then
        UICallbacks.UpdateUI(CurrentConfig)
    end

    if UICallbacks.Notify then
        UICallbacks.Notify("Config loaded: " .. configName)
    end

    return true
end

function Settings.Update(name: string?): boolean
    return Settings.Save(name)
end

function Settings.SetAutoLoad(value: boolean): nil
    AutoLoadEnabled = value
    scheduleSave()
end

function Settings.GetAutoLoad(): boolean
    return AutoLoadEnabled
end

function Settings.SetAutoLoadConfig(name: string): nil
    AutoLoadConfigName = name
    scheduleSave()
end

function Settings.GetAutoLoadConfig(): string?
    return AutoLoadConfigName
end

function Settings.Get(name: string): any
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

function Settings.Set(name: string, value: any): nil
    if name == "ConfigName" then
        ConfigName = tostring(value)
    elseif name == "AutoLoadEnabled" then
        AutoLoadEnabled = value == true
    elseif name == "AutoLoadConfigName" then
        AutoLoadConfigName = value
    else
        local defaultValue = DEFAULT_SETTINGS[name]
        if defaultValue ~= nil then
            validateAndApplyValue(CurrentConfig, name, value, defaultValue)
            scheduleSave()
        else
            warn("[Civic Hub] Unknown setting key in Set:", name)
        end
    end
end

function Settings.SetConfigName(name: string): nil
    ConfigName = name
    scheduleSave()
end

function Settings.GetConfigName(): string
    return ConfigName
end

function Settings.Delete(name: string?): boolean
    local configName = name or ConfigName

    local path = getPersistencePath()
    if not path then return false end

    if not isfile(path) then
        if UICallbacks.Notify then
            UICallbacks.Notify("Config not found: " .. configName)
        end
        return false
    end

    local success, err = pcall(function()
        delfile(path)
        return true
    end)

    if success and err then
        if UICallbacks.Notify then
            UICallbacks.Notify("Config deleted: " .. configName)
        end
        return true
    else
        warn("[Civic Hub] Delete failed:", err)
        if UICallbacks.Notify then
            UICallbacks.Notify("Failed to delete config")
        end
        return false
    end
end

function Settings.ListConfigs(): { string }
    if not isFileSystemAvailable() then return {} end

    local path = getPersistencePath()
    if not path then return {} end

    local results = {}
    if isfile(path) then
        table.insert(results, CONSTANTS.PERSISTENCE_FILE)
    end
    return results
end

function Settings.SetIsInitialLoad(value: boolean): nil
    IsInitialLoad = value
end

function Settings.GetIsInitialLoad(): boolean
    return IsInitialLoad
end

-- =============================================
-- DEPENDENCY INJECTION
-- =============================================

function Settings.setUICallbacks(callbacks: UICallbacks): nil
    UICallbacks = callbacks or {}
end

function Settings.setFeatures(featuresModule: any): nil
    Features = featuresModule
end

-- =============================================
-- CLEANUP
-- =============================================

local function cleanup(): nil
    -- Cancel pending save
    if SaveMutex.timer then
        task.cancel(SaveMutex.timer)
        SaveMutex.timer = nil
    end

    -- Flush pending save
    if SaveMutex.pending then
        SaveMutex.pending = false
        saveSettingsInternal()
    end

    -- Clear callbacks to prevent memory leaks
    UICallbacks = {}

    -- Clear features reference
    Features = nil
end

-- =============================================
-- MODULE EXPORT
-- =============================================

return setmetatable(Settings, {
    __gc = cleanup,
    __tostring = function()
        return "CivicHub.Settings (v" .. CONSTANTS.VERSION .. ")"
    end,
})
