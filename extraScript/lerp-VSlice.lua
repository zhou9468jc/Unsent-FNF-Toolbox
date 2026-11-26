
-- ============================================================
-- VSlice Health Bar Smoothing
-- ============================================================

local p = getModSetting('healthSmoothSpeed')
if p == nil then p = 20 end

local smoothHealth = 100
local healthInitialized = false

local function lerp(a, b, t)
    return (b - a) * t + a
end

local function remap(v, j, u, a, n)
    return a + (v - j) * ((n - a) / (u - j))
end

function onUpdatePost(elapsed)
    if inGameOver then return end

    local realHealth = math.max(getHealth() * 50, 0)

    if not healthInitialized then
        smoothHealth = realHealth
        healthInitialized = true
    else
        smoothHealth = lerp(
            smoothHealth,
            realHealth,
            math.min(elapsed * 8, 1)
        )
    end

    local healthPercent = math.min(smoothHealth, 100)

    local q = (flip and healthPercent
        or remap(healthPercent, 0, 100, 100, 0)) * 0.01

    local j = getProperty('healthBar.x')
        + getProperty('healthBar.width') * q

    setProperty('healthBar.percent', healthPercent)

    -- Preserve original V-Slice icon scaling logic
    local p1Scale = getProperty('iconP1.scale.x')
    local p2Scale = getProperty('iconP2.scale.x')

    setProperty(
        'iconP1.x',
        j + (150 * p1Scale - 150) / 2 - 26
    )

    setProperty(
        'iconP2.x',
        j - (150 * p2Scale) / 2 - 26 * 2
    )
end
