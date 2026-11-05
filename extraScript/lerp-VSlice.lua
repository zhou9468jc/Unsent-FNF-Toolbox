-- ============================================================
-- VSlice Health Bar Smoothing
-- ============================================================

local smoothHealth = 100

local function lerp(a, b, t)
    return (b - a) * t + a
end

local function remap(v, j, u, a, n)
    return a + (v - j) * ((n - a) / (u - j))
end

function onUpdatePost(elapsed)
    if inGameOver then return end

    local realHealth = math.max(getHealth() * 50, 0)

    smoothHealth = lerp(
        smoothHealth,
        realHealth,
        math.min(elapsed * 8, 1)
    )

    local healthPercent = math.min(smoothHealth, 100)

    setProperty('healthBar.percent', healthPercent)

    local fillRatio

    if flip then
        fillRatio = healthPercent * 0.01
    else
        fillRatio = remap(
            healthPercent, 0, 100, 100, 0
        ) * 0.01
    end

    local barX = getProperty('healthBar.x')
        + getProperty('healthBar.width') * fillRatio

    setProperty('iconP1.x', barX - 26)

    setProperty(
        'iconP2.x',
        barX - (getProperty('iconP2.width') - 26)
    )
end