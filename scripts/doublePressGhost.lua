-- THE CODE IS NOT MINE!! I JUST DID THE MOVEX AND MOVEY THING

local gfRows, bfRows, ddRows, exRows = {}, {}, {}, {}
local enableGhost = getModSetting("characterGhostTrail")

if enableGhost == nil then
	enableGhost = true
end

local function getIconColor(chr)
    return getColorFromHex(string.format('%.2x%.2x%.2x', math.min(getProperty(chr .. ".healthColorArray")[1] + 50, 255), math.min(getProperty(chr .. ".healthColorArray")[2] + 50, 255), math.min(getProperty(chr .. ".healthColorArray")[3] + 50, 255)))
end
local function ghostTrail(c, d)
	if not enableGhost then
		return
	end
    local ghost = c .. 'Ghost'
    local group = c == 'extra' and 'dad' or c
    makeAnimatedLuaSprite(ghost, getProperty(c .. '.imageFile'), getProperty(c .. '.x'), getProperty(c .. '.y'))
    addAnimationByPrefix(ghost, 'idle', d[1], 24, false)
    setProperty(ghost .. '.antialiasing', getProperty(c .. '.antialiasing'))
    setProperty(ghost .. '.offset.x', d[2])
    setProperty(ghost .. '.offset.y', d[3])
    scaleObject(ghost, getProperty(c .. '.scale.x'), getProperty(c .. '.scale.y'), false)
    setProperty(ghost .. '.flipX', getProperty(c .. '.flipX'))
    setProperty(ghost .. '.flipY', getProperty(c .. '.flipY'))
    setProperty(ghost .. '.visible', getProperty(c .. '.visible'))
    setProperty(ghost .. '.color', getIconColor(c))
    setProperty(ghost .. '.alpha', 0.8 * getProperty(c .. '.alpha'))
    setBlendMode(ghost, 'hardlight')
    addLuaSprite(ghost)
    playAnim(ghost, 'idle', true)
    setObjectOrder(ghost, getObjectOrder(group .. 'Group') - 0.1)

    local dirMap = {
        ['up'] = {0, -45}, ['down'] = {0, 45},
        ['right'] = {45, 0}, ['left'] = {-45, 0}
    }
    local moveX = getProperty(ghost..'.x')
    local moveY = getProperty(ghost..'.y')

    for dir, offset in pairs(dirMap) do
        if getProperty(ghost .. '.animation.frameName'):find(dir) then
            moveX = moveX + offset[1]
            moveY = moveY + offset[2]
        end
    end

    startTween(ghost, ghost, {alpha = 0, x = moveX, y = moveY}, 0.75, {onComplete = 'destroyGhost'})
    function destroyGhost() removeLuaSprite(ghost, true) end
end

local function handleNoteHit(id, n, s, cName, rows, cProp)
    local strumTime, frameName
    if n == 'No Animation' or n == 'Extra sings too' then
        cName = getProperty('extra.curCharacter')
    end
    if not s then
        strumTime = cName .. getPropertyFromGroup('notes', id, 'strumTime')
        if rows[strumTime] then
            ghostTrail(cProp, rows[strumTime])
        end
        frameName = getProperty(cProp .. '.animation.frameName'):sub(1, -4)
        rows[strumTime] = {frameName, getProperty(cProp .. '.offset.x'), getProperty(cProp .. '.offset.y')}
        runTimer(cProp .. 'str' .. strumTime)
    end
end

function goodNoteHit(id,_,n,s)
    if n ~= 'No Animation' and not getPropertyFromGroup('notes', id, 'gfNote') then
        handleNoteHit(id,n,s, 'boyfriend', bfRows, 'boyfriend')
    elseif getPropertyFromGroup('notes', id, 'gfNote') or n == 'GF sings too' then
        handleNoteHit(id, n, s, 'gf', gfRows, 'gf')
    else
        handleNoteHit(id, n, s, 'extra', exRows, 'extra')
    end
end
function opponentNoteHit(id,_,n,s)
    if n ~= 'No Animation' and not getPropertyFromGroup('notes', id, 'gfNote') then
        handleNoteHit(id, n, s, 'dad', ddRows, 'dad')
    elseif getPropertyFromGroup('notes', id, 'gfNote') or n == 'GF sings too' then
        handleNoteHit(id, n, s, 'gf', gfRows, 'gf')
    else
        handleNoteHit(id, n, s, 'extra', exRows, 'extra')
    end
end

function onTimerCompleted(t)
    local key = t:sub(6)
    if t:find('bfstr') then bfRows[key] = nil
    elseif t:find('ddstr') then ddRows[key] = nil
    elseif t:find('exstr') then exRows[key] = nil
    elseif t:find('gfstr') then gfRows[key] = nil
    end
end

function onTweenCompleted(t)
    if t:find('Ghost') then removeLuaSprite(t, true) end
end