-- =============================================
-- CIVIC HUB - VIOLENCE DISTRICT
-- MAIN.LUA (ENTRY POINT)
-- BUILT BY VINZEE
-- VERSION 2.0.0
-- =============================================

local Root = script.Parent

-- =======================================
-- LOAD MODULES
local UI = require(Root.Module.UI)
local Features = require(Root.Module.Features)
local Settings = require(Root.Module.Settings)
local Utils = require(Root.Module.Utils)

-- =======================================
-- CONNECT DEPENDENCIES
Features.setConfig(Settings:GetCurrentConfig())

-- =======================================
-- INITIALIZE UI
local function initializeCivicHub()
    -- Initialize all modules
    local uiData = UI.initialize()

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
