-- ============================================================
-- Unsent's Health Smoothing
-- IL Mode - Legacy Health Smoothing
-- ============================================================

local smoothSpeed
local displayHealth = 1
local targetHealth = 1
local lastWrittenHealth = 1
local initialized = false

-- ============================================================
-- Utility
-- ============================================================

local function clampHealth(value)
    if value < 0 then return 0 end
    if value > 2 then return 2 end
    return value
end

local function readSetting(name, default)
    local value = getModSetting(name)
    if value == nil then return default end
    return value
end

-- ============================================================
-- Create
-- ============================================================

function onCreate()
    smoothSpeed = readSetting('healthSmoothSpeed', 10) * 1.15

    displayHealth = clampHealth(getProperty('health') or 1)
    targetHealth = displayHealth
    lastWrittenHealth = displayHealth

    initialized = true
end

-- ============================================================
-- Update
-- ============================================================

function onUpdate(elapsed)
    if not initialized then return end

    local realHealth = clampHealth(getProperty('health') or 0)

    -- Detect external health changes.
    if math.abs(realHealth - lastWrittenHealth) > 0.000001 then
        targetHealth = realHealth

        -- Death handling.
        if realHealth <= 0 then
            displayHealth = 0
            targetHealth = 0

            setProperty('health', 0)
            lastWrittenHealth = 0
            return
        end
    end

    -- Legacy exponential smoothing.
    local difference = targetHealth - displayHealth

    if math.abs(difference) > 0.000001 then
        local follow = 1 - math.exp(-smoothSpeed * elapsed)
        displayHealth = displayHealth + difference * follow
    else
        displayHealth = targetHealth
    end

    displayHealth = clampHealth(displayHealth)

    setProperty('health', displayHealth)
    lastWrittenHealth = displayHealth
end