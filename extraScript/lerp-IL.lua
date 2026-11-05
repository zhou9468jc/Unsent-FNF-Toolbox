local p = getModSetting('healthSmoothSpeed')
if p == nil then
	p = 20
end
function lerp(a, b, t)
	return (b - a) * t + a
end

function w(v, j, u, a, n)
	return a + (v - j) * ((n - a) / (u - j))
end
function onUpdatePost(elapsed)
    if not inGameOver then
        p = lerp(p, math.max(getHealth() * 50, 0), elapsed * 5)
        local q = (flip and p or w(p, 0, 100, 100, 0)) * 0.01
        local j = getProperty('healthBar.x') + getProperty('healthBar.width') * q
        
        setProperty('healthBar.percent', math.min(p, 100))
        setProperty('iconP1.x', j + (150 * getProperty('iconP1.scale.x') - 150) / 2 - 26)
        setProperty('iconP2.x', j - (150 * getProperty('iconP2.scale.x')) / 2 - 26 * 2)
    end
end