-- =============================================
-- CIVIC HUB - VIOLENCE DISTRICT
-- MAIN.LUA (ENTRY POINT)
-- BUILT BY VINZEE
-- VERSION 2.0.0
-- =============================================

local BaseURL = "https://raw.githubusercontent.com/larpandskidderman/cipik-hab/main/Module/"

-- =======================================
-- LOAD MODULES VIA REMOTE
local function loadModule(name)
    local success, result = pcall(function()
        local source = game:HttpGet(BaseURL .. name .. ".lua")
        local func = loadstring(source)
        if func then
            return func()
        end
        return nil
    end)
    if not success then
        warn("[Civic Hub] Failed to load module:", name, result)
    end
    return result or {}
end

local UI = loadModule("UI")
local Features = loadModule("Features")
local Settings = loadModule("Settings")
local Utils = loadModule("Utils")

-- =======================================
-- CONNECT DEPENDENCIES
Features.setUtils(Utils)
Settings:setFeatures(Features)
Features.setConfig(Settings:GetCurrentConfig())

-- =======================================
-- INITIALIZE UI
local function initializeCivicHub()
    -- Auto-load settings from CivicHub/settings.json first (persistence system)
    local autoLoadFunc = Settings.getAutoLoadSettings()
    if autoLoadFunc then
        local loaded = autoLoadFunc()
        if loaded then
            print("[Civic Hub] Persistence settings loaded from CivicHub/settings.json")
        end
    end
    
    -- Inject dependencies into UI module
    local uiData = UI.initialize({
        Features = Features,
        Settings = Settings,
        Utils = Utils
    })

    -- Start core features with loaded config (from persistence)
    Features.applyVisual(true)
    Features.applyOptimization(true)
    Features.applyUnlimitedZoom()
    Features.applyCameraFOV()
    Features.applyNoScreenEffects()

    -- Ensure moonwalk is OFF by default unless loaded from persistence
    local moonwalkLoaded = Settings:Get("MoonwalkEnabled")
    Features.toggleMoonwalk(moonwalkLoaded or false)

    -- Show moonwalk button if configured
    if Settings:Get("MoonwalkShowButton") then
        Features.createMoonwalkButton()
    end

    -- Perform auto load after short delay
    task.wait(0.5)
    Settings:SetIsInitialLoad(true)

    -- Try to load auto-save first (local environment settings - legacy)
    local autoSaveData = Settings:getAutoSaveData()
    if autoSaveData and autoSaveData.Settings then
        -- Apply auto-saved settings (only if persistence didn't load anything)
        local persistenceConfig = Settings:GetCurrentConfig()
        local hasPersistenceData = false
        
        -- Check if any meaningful setting was loaded from persistence
        for key, value in pairs(persistenceConfig) do
            local defaultValue = Settings.GetDefaultSettings()[key]
            if defaultValue ~= nil and value ~= defaultValue then
                hasPersistenceData = true
                break
            end
        end
        
        if not hasPersistenceData then
            local loadedConfig = autoSaveData.Settings
            for key, value in pairs(loadedConfig) do
                Settings:Set(key, value)
            end
            
            -- Apply features with auto-saved settings
            Features.applyVisual(true)
            Features.applyOptimization(true)
            Features.applyUnlimitedZoom()
            Features.applyCameraFOV()
            Features.applyNoScreenEffects()
            if Settings:Get("FPSBoost") then
                Features.applyFPSBoost()
            end
            if Settings:Get("ReduceGraphics") then
                Features.applyReduceGraphics()
            end
            Features.applyWalkSpeed()
            Features.applyJumpPower()
            Features.toggleNoClip(Settings:Get("NoClip"))
            Features.startGunAim()
            Features.startAttackAim()
            Features.startSkillCheck()
            Features.startAutoStalk()
            
            if Settings:Get("MoonwalkShowButton") then
                Features.createMoonwalkButton()
            else
                Features.removeMoonwalkButton()
            end
            
            if Settings:Get("ShowEmoteButton") then
                Features.createEmoteButton()
            else
                Features.removeEmoteButton()
            end
            
            if Settings:Get("JerkTool") then
                Features.createJerkTool()
            end
            
            UI.notify("Legacy autosave settings loaded")
        end
    end

    -- Then try named auto-load config if enabled
    local autoLoadEnabled = Settings:GetAutoLoad()
    local autoLoadConfigName = Settings:GetAutoLoadConfig()

    if autoLoadEnabled and autoLoadConfigName and autoLoadConfigName ~= "" then
        local success = Settings:Load(autoLoadConfigName)
        if success then
            UI.notify("Auto-loaded: " .. autoLoadConfigName)
        else
            UI.notify("No auto-load setting found: " .. autoLoadConfigName)
        end
    end

    Settings:SetIsInitialLoad(false)

    -- Show welcome notification
    UI.notify("Loaded successfully! Built by Vinzee")

    -- Print to console
    print("=========================================")
    print("CIVIC HUB v2.0.0 LOADED SUCCESSFULLY")
    print("Built by Vinzee")
    print("Game: Violence District")
    print("=========================================")

    return {
        Window = uiData.Window,
        Tabs = uiData.Tabs,
        Features = Features,
        Settings = Settings,
        Utils = Utils,
    }
end

-- =======================================
-- RUN CIVIC HUB
local CivicHub = initializeCivicHub()

-- =======================================
-- EXPORT FOR DEBUGGING (optional)
return CivicHub
