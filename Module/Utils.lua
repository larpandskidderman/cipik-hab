-- =============================================
-- CIVIC HUB - VIOLENCE DISTRICT
-- MODULE: UTILS
-- BUILT BY VINZEE
-- VERSION 2.0.0
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- =======================================
-- CONNECTION CLEANUP
local function cleanupConnection(conn)
    if conn then
        pcall(function()
            conn:Disconnect()
        end)
    end
end

local function cleanupConnections(connections)
    if not connections then return end
    for _, conn in pairs(connections) do
        cleanupConnection(conn)
    end
end

-- =======================================
-- SAFE CALL
local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[Civic Hub] Error:", result)
        return nil
    end
    return result
end

-- =======================================
-- STATE CLEANUP
local function cleanupDrawing(drawings)
    if not drawings then return end
    for _, drawing in pairs(drawings) do
        if drawing and drawing.Remove then
            pcall(function()
                drawing:Remove()
            end)
        end
    end
end

local function cleanupInstances(instances)
    if not instances then return end
    for _, inst in pairs(instances) do
        if inst and inst.Destroy then
            pcall(function()
                inst:Destroy()
            end)
        end
    end
end

-- =======================================
-- TABLE UTILS
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

local function mergeTables(default, custom)
    local result = deepCopy(default)
    for k, v in pairs(custom) do
        if type(v) == "table" and type(result[k]) == "table" then
            result[k] = mergeTables(result[k], v)
        else
            result[k] = v
        end
    end
    return result
end

-- =======================================
-- SERVICE HELPER
local function getService(name)
    return game:GetService(name)
end

-- =======================================
-- CHARACTER HELPERS
local function getRoot()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function isCharacterValid(char)
    return char and char.Parent and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid")
end

-- =======================================
-- DELAYED EXECUTION
local function delayedCall(delay, func, ...)
    task.delay(delay, function()
        safeCall(func, ...)
    end)
end

-- =======================================
-- LOOP WITH CLEANUP
local function createLoop(interval, callback)
    local connection = nil
    local running = false

    local function start()
        if running then return end
        running = true
        connection = RunService.Heartbeat:Connect(function()
            if not running then return end
            callback()
        end)
    end

    local function stop()
        running = false
        cleanupConnection(connection)
        connection = nil
    end

    return {
        Start = start,
        Stop = stop,
        IsRunning = function() return running end
    }
end

-- =======================================
-- EXPORT
return {
    cleanupConnection = cleanupConnection,
    cleanupConnections = cleanupConnections,
    safeCall = safeCall,
    cleanupDrawing = cleanupDrawing,
    cleanupInstances = cleanupInstances,
    deepCopy = deepCopy,
    mergeTables = mergeTables,
    getService = getService,
    getRoot = getRoot,
    getHumanoid = getHumanoid,
    isCharacterValid = isCharacterValid,
    delayedCall = delayedCall,
    createLoop = createLoop,
}
