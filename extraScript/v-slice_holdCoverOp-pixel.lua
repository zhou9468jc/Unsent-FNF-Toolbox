-- ============================================================
-- Unsent's Opponent Hold Cover
-- Pixel V-Slice-style Opponent Hold Cover
-- Atlas: pixelUI/pixelNoteHoldCover.png + .xml
-- ============================================================

-- ============================================================
-- Settings
-- ============================================================

local enableHoldCover = getModSetting('holdCover')
if enableHoldCover == nil then enableHoldCover = true end

local holdCoverOffsetX = tonumber(getModSetting('holdCoverOffsetX')) or 0
local holdCoverOffsetY = tonumber(getModSetting('holdCoverOffsetY')) or 0

local holdCoverScale = 7

-- ============================================================
-- Base Offset
--
-- 0 = LEFT / Purple
-- 1 = DOWN / Blue
-- 2 = UP / Green
-- 3 = RIGHT / Red
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

local opponentCovers = {}
local opponentActive = {}
local opponentEndTimers = {}

local coverImage = 'pixelUI/pixelNoteHoldCover'

-- ============================================================
-- Update Opponent Hold Cover Alpha
-- ============================================================

local function updateShowcaseAlpha(direction)
    local tag = opponentCovers[direction]
    if not tag then return end

    local strum = 'opponentStrums.members[' .. direction .. ']'

    local strumVisible = getProperty(strum .. '.visible')
    local strumAlpha = tonumber(getProperty(strum .. '.alpha')) or 1

    if strumVisible == false or strumAlpha <= 0 then
        setProperty(tag .. '.alpha', 0)
        setProperty(tag .. '.visible', false)
        return
    end

    local alpha

    if getModSetting('showCaseMode') then
        alpha = tonumber(getModSetting('showCaseStrumAlpha')) or 0
    else
        alpha = strumAlpha
    end

    alpha = math.max(0, math.min(1, alpha * 1.5))
    setProperty(tag .. '.alpha', alpha)

    if alpha <= 0 then
        setProperty(tag .. '.visible', false)
    end
end

local function updateAllShowcaseAlpha()
    for direction = 0, 3 do
        updateShowcaseAlpha(direction)
    end
end

-- ============================================================
-- Create Opponent Cover
-- ============================================================

local function makeOpponentCover(direction)
    local tag = 'opponentHoldCover' .. direction

    makeAnimatedLuaSprite(tag, coverImage, 0, 0)

    addAnimationByPrefix(tag, 'hold', 'loop', 24, true)

    setProperty(tag .. '.scale.x', holdCoverScale)
    setProperty(tag .. '.scale.y', holdCoverScale)
    setProperty(tag .. '.antialiasing', false)

    setObjectCamera(tag, 'hud')
    setObjectOrder(tag, 10001)

    setProperty(tag .. '.visible', false)
    setProperty(tag .. '.alpha', 0)

    addLuaSprite(tag, true)

    opponentCovers[direction] = tag
    opponentActive[direction] = false
    opponentEndTimers[direction] = nil
end

-- ============================================================
-- Create All Opponent Covers
-- ============================================================

function onCreatePost()
    if not enableHoldCover then return end

    for direction = 0, 3 do
        makeOpponentCover(direction)
    end

    updateAllShowcaseAlpha()
end

-- ============================================================
-- Update Opponent Cover Position
-- ============================================================

local function updateCoverPosition(direction)
    local tag = opponentCovers[direction]
    if not tag then return end

    local strum = 'opponentStrums.members[' .. direction .. ']'
    local offset = baseOffset[direction]

    local strumX = getProperty(strum .. '.x')
    local strumY = getProperty(strum .. '.y')

    if strumX == nil or strumY == nil then return end

    setProperty(
        tag .. '.x',
        strumX + offset[1] + holdCoverOffsetX
    )

    setProperty(
        tag .. '.y',
        strumY + offset[2] + holdCoverOffsetY
    )
end

-- ============================================================
-- Start Opponent Hold
--
-- Opponent uses loop animation only.
-- No Start / End animation.
-- ============================================================

local function startCover(direction, sustainLength)
    if not sustainLength or sustainLength <= 150 then return end

    local tag = opponentCovers[direction]
    if not tag then return end

    local oldTimer = opponentEndTimers[direction]

    if oldTimer then
        cancelTimer(oldTimer)
        opponentEndTimers[direction] = nil
    end

    updateCoverPosition(direction)
    updateShowcaseAlpha(direction)

    if (tonumber(getProperty(tag .. '.alpha')) or 0) <= 0 then
        setProperty(tag .. '.visible', false)
        opponentActive[direction] = false
        return
    end

    setProperty(tag .. '.visible', true)
    playAnim(tag, 'hold', true)

    opponentActive[direction] = true

    local rate = tonumber(getProperty('playbackRate')) or 1
    if rate <= 0 then rate = 1 end

    local duration = (sustainLength / 1000 - 0.100) / rate
    local timerName = 'opponentHoldCoverEnd' .. direction

    opponentEndTimers[direction] = timerName
    runTimer(timerName, math.max(0, duration))
end

-- ============================================================
-- End Opponent Hold
-- ============================================================

local function endCover(direction)
    local tag = opponentCovers[direction]
    if not tag then return end
    if not opponentActive[direction] then return end

    opponentActive[direction] = false
    opponentEndTimers[direction] = nil

    setProperty(tag .. '.visible', false)
end

-- ============================================================
-- Opponent Note Hit
-- ============================================================

function opponentNoteHit(id, direction, noteType, isSustainNote)
    if not enableHoldCover then return end
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

    for direction = 0, 3 do
        local tag = opponentCovers[direction]

        if tag and opponentActive[direction] then
            updateCoverPosition(direction)

            local alpha = tonumber(getProperty(tag .. '.alpha')) or 0

            if alpha <= 0 then
                setProperty(tag .. '.visible', false)
            else
                setProperty(tag .. '.visible', true)

                local animName = getProperty(
                    tag .. '.animation.curAnim.name'
                )

                if animName ~= 'hold' then
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
    if not enableHoldCover then return end

    for direction = 0, 3 do
        if tag == opponentEndTimers[direction] then
            endCover(direction)
            return
        end
    end
end

-- ============================================================
-- Opponent Miss
-- ============================================================

function opponentNoteMiss(id, direction, noteType, isSustainNote)
    if not enableHoldCover then return end

    if opponentActive[direction] then
        local oldTimer = opponentEndTimers[direction]

        if oldTimer then
            cancelTimer(oldTimer)
        end

        opponentEndTimers[direction] = nil
        endCover(direction)
    end
end

-- ============================================================
-- Cleanup
-- ============================================================

function onDestroy()
    if not enableHoldCover then return end

    for direction = 0, 3 do
        local timerName = opponentEndTimers[direction]

        if timerName then
            cancelTimer(timerName)
        end

        local tag = opponentCovers[direction]

        if tag then
            setProperty(tag .. '.alpha', 0)
            setProperty(tag .. '.visible', false)
        end
    end
end