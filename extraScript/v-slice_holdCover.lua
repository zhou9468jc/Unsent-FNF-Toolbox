-- ============================================================
-- Unsent's Hold Cover
-- V-Slice-style hold cover effect
-- Optimized Animation & Property Updates
-- ============================================================

-- ============================================================
-- Settings
-- ============================================================

local enableHoldCover = getModSetting('holdCover')
if enableHoldCover == nil then enableHoldCover = true end

local holdCoverOffsetX = getModSetting('holdCoverOffsetX')
if holdCoverOffsetX == nil then holdCoverOffsetX = 0 end

local holdCoverOffsetY = getModSetting('holdCoverOffsetY')
if holdCoverOffsetY == nil then holdCoverOffsetY = 0 end

-- Animation FPS
local COVER_FPS = 24

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
    [0] = {-106, -98},
    [1] = {-108, -98},
    [2] = {-108, -98},
    [3] = {-106, -98}
}

-- ============================================================
-- Variables
-- ============================================================

local covers = {}
local active = {}
local endTimers = {}
local lastAlpha = {}

local debugTextTag = 'holdCoverDebugText'

-- ============================================================
-- Hold Cover Configuration
-- ============================================================

local coverData = {
    [0] = {
        image = 'holdCoverPurple',
        start = 'holdCoverStartPurple',
        hold = 'holdCoverPurple',
        finish = 'holdCoverEndPurple'
    },
    [1] = {
        image = 'holdCoverBlue',
        start = 'holdCoverStartBlue',
        hold = 'holdCoverBlue',
        finish = 'holdCoverEndBlue'
    },
    [2] = {
        image = 'holdCoverGreen',
        start = 'holdCoverStartGreen',
        hold = 'holdCoverGreen',
        finish = 'holdCoverEndGreen'
    },
    [3] = {
        image = 'holdCoverRed',
        start = 'holdCoverStartRed',
        hold = 'holdCoverRed',
        finish = 'holdCoverEndRed'
    }
}

-- ============================================================
-- Keyboard Detection
-- ============================================================

local function isDirectionPressed(direction)
    local keys = {
        [0] = 'LEFT',
        [1] = 'DOWN',
        [2] = 'UP',
        [3] = 'RIGHT'
    }

    return keyboardPressed(keys[direction])
end

-- ============================================================
-- Debug Keyboard Detection
-- ============================================================

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

        text = text ..
            prefix .. debugDirectionNames[direction] ..
            '   X: ' .. tostring(offset[1]) ..
            '   Y: ' .. tostring(offset[2]) .. '\n'
    end

    setTextString(debugTextTag, text)
end

-- ============================================================
-- Debug Text Creation
-- ============================================================

local function createDebugText()
    if not debugMode then return end

    makeLuaText(debugTextTag, '', 0, 20, 20)
    setTextSize(debugTextTag, 18)
    setTextBorder(debugTextTag, 2, '000000')
    setObjectCamera(debugTextTag, 'hud')
    addLuaText(debugTextTag, true)

    updateDebugText()
end

-- ============================================================
-- Debug Keyboard
-- ============================================================

local function updateDebugKeyboard()
    if not debugMode then return end

    if keyboardJustPressed('Q') then
        debugSelectedDirection = (debugSelectedDirection + 3) % 4
    end

    if keyboardJustPressed('E') then
        debugSelectedDirection = (debugSelectedDirection + 1) % 4
    end

    local amount = getDebugMoveAmount()
    local offset = baseOffset[debugSelectedDirection]

    if keyboardJustPressed('LEFT') then
        offset[1] = offset[1] - amount
    end

    if keyboardJustPressed('RIGHT') then
        offset[1] = offset[1] + amount
    end

    if keyboardJustPressed('UP') then
        offset[2] = offset[2] - amount
    end

    if keyboardJustPressed('DOWN') then
        offset[2] = offset[2] + amount
    end

    updateDebugText()
end

-- ============================================================
-- Update Showcase Alpha
-- Only write alpha when it changes
-- ============================================================

local function updateShowcaseAlpha(direction, showcase, showcaseAlpha)
    local tag = covers[direction]
    if not tag then return end

    local alpha = 1

    if showcase then
        alpha = showcaseAlpha
    else
        local strum = 'playerStrums.members[' .. direction .. ']'
        local value = getProperty(strum .. '.alpha')

        if value ~= nil then
            alpha = tonumber(value) or 1
        end
    end

    alpha = math.max(0, math.min(1, alpha))

    if lastAlpha[direction] ~= alpha then
        setProperty(tag .. '.alpha', alpha)
        lastAlpha[direction] = alpha
    end
end

-- ============================================================
-- Update All Showcase Alpha
-- ============================================================

local function updateAllShowcaseAlpha()
    local showcase = getModSetting('showCaseMode') == true
    local showcaseAlpha = tonumber(getModSetting('showCaseStrumAlpha')) or 0

    showcaseAlpha = math.max(0, math.min(1, showcaseAlpha))

    for direction = 0, 3 do
        updateShowcaseAlpha(direction, showcase, showcaseAlpha)
    end
end

-- ============================================================
-- Create Cover
-- ============================================================

local function makeCover(direction)
    local data = coverData[direction]
    if not data then return end

    local tag = 'holdCover' .. direction

    makeAnimatedLuaSprite(tag, data.image, 0, 0)

    addAnimationByPrefix(tag, 'start', data.start, COVER_FPS, false)
    addAnimationByPrefix(tag, 'hold', data.hold, COVER_FPS, true)
    addAnimationByPrefix(tag, 'end', data.finish, COVER_FPS, false)

    setObjectCamera(tag, 'hud')

    setProperty(tag .. '.visible', false)
    setProperty(tag .. '.alpha', 1)

    addLuaSprite(tag, true)

    -- Set order after adding the sprite
    setObjectOrder(tag, 10001)

    covers[direction] = tag
    active[direction] = false
    endTimers[direction] = nil
    lastAlpha[direction] = 1
end

-- ============================================================
-- Create All Covers
-- ============================================================

function onCreatePost()
    if not enableHoldCover then return end

    for direction = 0, 3 do
        makeCover(direction)
    end

    createDebugText()

    if debugMode then
        for direction = 0, 3 do
            local tag = covers[direction]

            if tag then
                setProperty(tag .. '.visible', true)
                playAnim(tag, 'hold', true)
            end
        end
    end

    updateAllShowcaseAlpha()
end

-- ============================================================
-- Update Cover Position
-- ============================================================

local function updateCoverPosition(direction)
    local tag = covers[direction]
    if not tag then return end

    local strum = 'playerStrums.members[' .. direction .. ']'
    local offset = baseOffset[direction]

    local x = getProperty(strum .. '.x')
    local y = getProperty(strum .. '.y')

    if x == nil or y == nil then return end

    setProperty(
        tag .. '.x',
        x + offset[1] + holdCoverOffsetX
    )

    setProperty(
        tag .. '.y',
        y + offset[2] + holdCoverOffsetY
    )
end

-- ============================================================
-- Update All Debug Covers
-- ============================================================

local function updateAllDebugCovers()
    if not debugMode then return end

    for direction = 0, 3 do
        local tag = covers[direction]

        if tag then
            updateCoverPosition(direction)

            setProperty(tag .. '.visible', true)

            local animName = getProperty(tag .. '.animation.curAnim.name')

            if animName ~= 'hold' then
                playAnim(tag, 'hold', true)
            end
        end
    end
end

-- ============================================================
-- Start Cover
-- ============================================================

local function startCover(direction, sustainLength)
    if not sustainLength or sustainLength <= 100 then return end

    local tag = covers[direction]
    if not tag then return end

    local oldTimer = endTimers[direction]

    if oldTimer then
        cancelTimer(oldTimer)
        endTimers[direction] = nil
    end

    local timerName = 'holdCoverEnd' .. direction
    endTimers[direction] = timerName

    updateCoverPosition(direction)
    updateAllShowcaseAlpha()

    setProperty(tag .. '.visible', true)
    playAnim(tag, 'start', true)

    active[direction] = true

    local rate = getProperty('playbackRate')

    if type(rate) ~= 'number' or rate <= 0 then
        rate = 1
    end

    local duration =
        (sustainLength / 1000 / rate) - (1 / COVER_FPS)

    if duration < 0 then duration = 0 end

    runTimer(timerName, duration)
end

-- ============================================================
-- Stop Cover
-- ============================================================

local function stopCover(direction)
    local tag = covers[direction]
    if not tag then return end

    local oldTimer = endTimers[direction]

    if oldTimer then
        cancelTimer(oldTimer)
    end

    endTimers[direction] = nil
    active[direction] = false

    setProperty(tag .. '.visible', false)
end

-- ============================================================
-- End Cover
-- ============================================================

local function endCover(direction)
    local tag = covers[direction]
    if not tag then return end
    if not active[direction] then return end

    active[direction] = false
    endTimers[direction] = nil

    updateCoverPosition(direction)
    updateAllShowcaseAlpha()

    playAnim(tag, 'end', true)
end

-- ============================================================
-- Player Note Hit
-- ============================================================

function goodNoteHit(id, direction, noteType, isSustainNote)
    if not enableHoldCover or debugMode then return end
    if isSustainNote then return end

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

    updateAllShowcaseAlpha()

    if debugMode then
        updateDebugKeyboard()
        updateAllDebugCovers()
        return
    end

    local botplay = getProperty('cpuControlled')

    for direction = 0, 3 do
        local tag = covers[direction]

        if tag and active[direction] then
            updateCoverPosition(direction)

            if not botplay and not isDirectionPressed(direction) then
                stopCover(direction)
            else
                local animName =
                    getProperty(tag .. '.animation.curAnim.name')

                local finished =
                    getProperty(tag .. '.animation.curAnim.finished')

                if animName == 'start' and finished then
                    playAnim(tag, 'hold', true)
                end
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

        if oldTimer then
            cancelTimer(oldTimer)
        end

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
            local animName =
                getProperty(tag .. '.animation.curAnim.name')

            local finished =
                getProperty(tag .. '.animation.curAnim.finished')

            if animName == 'end' and finished then
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
        local timerName = endTimers[direction]

        if timerName then
            cancelTimer(timerName)
        end
    end

    for direction = 0, 3 do
        local tag = covers[direction]

        if tag then
            setProperty(tag .. '.alpha', 1)
        end
    end
end