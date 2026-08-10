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
    -- Inject dependencies into UI module
    local uiData = UI.initialize({
        Features = Features,
        Settings = Settings,
        Utils = Utils
    })

    -- Start core features with default config
    Features.applyVisual(true)
    Features.applyOptimization(true)
    Features.applyUnlimitedZoom()
    Features.applyCameraFOV()
    Features.applyNoScreenEffects()

    -- Ensure moonwalk is OFF by default
    Features.toggleMoonwalk(false)

    -- Show moonwalk button if configured
    if Settings:Get("MoonwalkShowButton") then
        Features.createMoonwalkButton()
    end

    -- Perform auto load after short delay
    task.wait(0.5)
    Settings:SetIsInitialLoad(true)

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
