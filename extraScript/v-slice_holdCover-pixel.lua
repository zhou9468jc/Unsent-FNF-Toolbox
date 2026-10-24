-- ============================================================
-- Unsent's Hold Cover
-- Pixel V-Slice-style Hold Cover
-- Atlas: pixelNoteHoldCover.png + pixelNoteHoldCover.xml
-- ============================================================

-- ============================================================
-- Settings
-- ============================================================

local enableHoldCover = getModSetting('holdCover')
if enableHoldCover == nil then enableHoldCover = true end

local holdCoverOffsetX = tonumber(getModSetting('holdCoverOffsetX')) or 0
local holdCoverOffsetY = tonumber(getModSetting('holdCoverOffsetY')) or 0

-- ============================================================
-- Debug Mode
-- ============================================================

local debugMode = false
local debugSelectedDirection = 0

local debugDirectionNames = {
    [0] = 'LEFT',
    [1] = 'DOWN',
    [2] = 'UP',
    [3] = 'RIGHT'
}

-- ============================================================
-- Base Offset
-- ============================================================

local baseOffset = {
    [0] = {140, 25},
    [1] = {140, 25},
    [2] = {140, 25},
    [3] = {140, 25}
}

-- ============================================================
-- Variables
-- ============================================================

local covers = {}
local active = {}
local endTimers = {}
local debugTextTag = 'holdCoverDebugText'

-- All directions use the same pixel atlas.
-- XML prefixes: loop0000-loop0007, explode0000-explode0007.
local coverImage = 'pixelUI/pixelNoteHoldCover'

local function isDirectionPressed(direction)
    local keys = {'LEFT', 'DOWN', 'UP', 'RIGHT'}
    return keyboardPressed(keys[direction + 1])
end

local function getDebugMoveAmount()
    if keyboardPressed('ALT') then return 32 end
    if keyboardPressed('CONTROL') then return 8 end
    if keyboardPressed('SHIFT') then return 4 end
    return 1
end

-- ============================================================
-- Debug Text
-- ============================================================

local function updateDebugText()
    if not debugMode then return end

    local text =
        'Hold Cover Offset Debug\n' ..
        'Q / E : Select Arrow\n' ..
        'Arrow : ±1    Shift : ±4    Ctrl : ±8    Alt : ±32\n\n'

    for direction = 0, 3 do
        local offset = baseOffset[direction]
        local prefix = direction == debugSelectedDirection and '> ' or '  '

        text = text .. prefix .. debugDirectionNames[direction] ..
            '   X: ' .. tostring(offset[1]) ..
            '   Y: ' .. tostring(offset[2]) .. '\n'
    end

    setTextString(debugTextTag, text)
end

local function createDebugText()
    if not debugMode then return end

    makeLuaText(debugTextTag, '', 0, 20, 20)
    setTextSize(debugTextTag, 18)
    setTextBorder(debugTextTag, 2, '000000')
    setObjectCamera(debugTextTag, 'other')
    addLuaText(debugTextTag, true)

    updateDebugText()
end

local function updateDebugKeyboard()
    if not debugMode then return end

    if keyboardJustPressed('Q') then
        debugSelectedDirection = (debugSelectedDirection - 1) % 4
    end

    if keyboardJustPressed('E') then
        debugSelectedDirection = (debugSelectedDirection + 1) % 4
    end

    local amount = getDebugMoveAmount()
    local offset = baseOffset[debugSelectedDirection]

    if keyboardJustPressed('LEFT') then offset[1] = offset[1] - amount end
    if keyboardJustPressed('RIGHT') then offset[1] = offset[1] + amount end
    if keyboardJustPressed('UP') then offset[2] = offset[2] - amount end
    if keyboardJustPressed('DOWN') then offset[2] = offset[2] + amount end

    updateDebugText()
end

-- ============================================================
-- Showcase Alpha
-- ============================================================

local function updateShowcaseAlpha(direction)
    local tag = covers[direction]
    if not tag then return end

    local alpha

    if getModSetting('showCaseMode') then
        alpha = tonumber(getModSetting('showCaseStrumAlpha')) or 0
    else
        local strum = 'playerStrums.members[' .. direction .. ']'
        alpha = getProperty(strum .. '.alpha')
        if alpha == nil then alpha = 1 end
    end

    setProperty(tag .. '.alpha', math.max(0, math.min(1, alpha)))
end

local function updateAllShowcaseAlpha()
    for direction = 0, 3 do
        updateShowcaseAlpha(direction)
    end
end

-- ============================================================
-- Create Cover
-- ============================================================

local function makeCover(direction)
    local tag = 'holdCover' .. direction

    makeAnimatedLuaSprite(tag, coverImage, 0, 0)

    addAnimationByPrefix(tag, 'loop', 'loop', 24, true)
    addAnimationByPrefix(tag, 'explode', 'explode', 24, false)

    setObjectCamera(tag, 'hud')
    setObjectOrder(tag, 10001)
    setProperty(tag .. '.visible', false)
    setProperty(tag .. '.alpha', 1)
	setProperty(tag .. '.scale.x',7)
	setProperty(tag .. '.scale.y',7)
	setProperty(tag .. '.antialiasing', false)

    addLuaSprite(tag, true)

    covers[direction] = tag
    active[direction] = false
    endTimers[direction] = nil
end

function onCreatePost()
    if not enableHoldCover then return end

    for direction = 0, 3 do
        makeCover(direction)
    end

    createDebugText()

    if debugMode then
        for direction = 0, 3 do
            local tag = covers[direction]
            setProperty(tag .. '.visible', true)
            playAnim(tag, 'loop', true)
        end
    end

    updateAllShowcaseAlpha()
end

-- ============================================================
-- Position
-- ============================================================

local function updateCoverPosition(direction)
    local tag = covers[direction]
    if not tag then return end

    local strum = 'playerStrums.members[' .. direction .. ']'
    local offset = baseOffset[direction]

    local strumX = getProperty(strum .. '.x')
    local strumY = getProperty(strum .. '.y')

    if strumX == nil or strumY == nil then return end

    setProperty(tag .. '.x', strumX + offset[1] + holdCoverOffsetX)
    setProperty(tag .. '.y', strumY + offset[2] + holdCoverOffsetY)
end

local function updateAllDebugCovers()
    if not debugMode then return end

    for direction = 0, 3 do
        local tag = covers[direction]

        if tag then
            updateCoverPosition(direction)
            setProperty(tag .. '.visible', true)

            local animName = getProperty(tag .. '.animation.curAnim.name')
            if animName ~= 'loop' then
                playAnim(tag, 'loop', true)
            end
        end
    end
end

-- ============================================================
-- Start Cover
-- ============================================================

local function startCover(direction, sustainLength)
    if not sustainLength or sustainLength <= 150 then return end

    local tag = covers[direction]
    if not tag then return end

    local oldTimer = endTimers[direction]
    if oldTimer then
        cancelTimer(oldTimer)
        endTimers[direction] = nil
    end

    updateCoverPosition(direction)
    updateShowcaseAlpha(direction)

    setProperty(tag .. '.visible', true)
    playAnim(tag, 'loop', true)

    active[direction] = true

    local rate = tonumber(getProperty('playbackRate')) or 1
    if rate <= 0 then rate = 1 end

    local duration = sustainLength / 1000 / rate
    local timerName = 'holdCoverEnd' .. direction

    endTimers[direction] = timerName
    runTimer(timerName, math.max(0, duration))
end

-- ============================================================
-- Stop Cover
-- ============================================================

local function stopCover(direction)
    local tag = covers[direction]
    if not tag then return end

    local oldTimer = endTimers[direction]
    if oldTimer then cancelTimer(oldTimer) end

    endTimers[direction] = nil
    active[direction] = false

    setProperty(tag .. '.visible', false)
end

-- ============================================================
-- End Cover
-- ============================================================

local function endCover(direction)
    local tag = covers[direction]
    if not tag or not active[direction] then return end

    active[direction] = false
    endTimers[direction] = nil

    updateCoverPosition(direction)
    updateShowcaseAlpha(direction)

    playAnim(tag, 'explode', true)
end

-- ============================================================
-- Player Note Hit
-- ============================================================

function goodNoteHit(id, direction, noteType, isSustainNote)
    if not enableHoldCover or debugMode or isSustainNote then return end

    local sustainLength = tonumber(
        getPropertyFromGroup('notes', id, 'sustainLength')
    ) or 0

    if sustainLength <= 0 then return end

    startCover(direction, sustainLength)
end

-- ============================================================
-- Update
-- ============================================================

function onUpdate(elapsed)
    if not enableHoldCover then return end

    if debugMode then
        updateDebugKeyboard()
        updateAllDebugCovers()
        updateAllShowcaseAlpha()
        return
    end

    updateAllShowcaseAlpha()

    local botplay = getProperty('cpuControlled')

    for direction = 0, 3 do
        local tag = covers[direction]

        if tag and active[direction] then
            updateCoverPosition(direction)

            if not botplay and not isDirectionPressed(direction) then
                stopCover(direction)
            end
        end
    end
end

-- ============================================================
-- Timer
-- ============================================================

function onTimerCompleted(tag)
    if not enableHoldCover or debugMode then return end

    for direction = 0, 3 do
        if tag == endTimers[direction] then
            endCover(direction)
            return
        end
    end
end

-- ============================================================
-- Missed Note
-- ============================================================

function noteMiss(id, direction, noteType, isSustainNote)
    if not enableHoldCover or debugMode then return end

    if active[direction] then
        local oldTimer = endTimers[direction]
        if oldTimer then cancelTimer(oldTimer) end

        endTimers[direction] = nil
        endCover(direction)
    end
end

-- ============================================================
-- Hide Finished End Animation
-- ============================================================

function onUpdatePost()
    if not enableHoldCover or debugMode then return end

    for direction = 0, 3 do
        local tag = covers[direction]

        if tag and not active[direction] then
            local animName = getProperty(tag .. '.animation.curAnim.name')
            local finished = getProperty(tag .. '.animation.curAnim.finished')

            if animName == 'explode' and finished then
                setProperty(tag .. '.visible', false)
            end
        end
    end
end

-- ============================================================
-- Cleanup
-- ============================================================

function onDestroy()
    if not enableHoldCover then return end

    for direction = 0, 3 do
        if endTimers[direction] then
            cancelTimer(endTimers[direction])
        end

        local tag = covers[direction]
        if tag then
            setProperty(tag .. '.alpha', 1)
        end
    end
end