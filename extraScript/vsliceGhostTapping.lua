-- ============================================================
-- Unsent's Directional Ghost Tap
-- NovaFlare Engine 1.2.x
-- ============================================================

local enabled = true
local missHealth = 0.07
local missSound = true

local hitNormalNote = false
local currentKey = -1

local missAnimations = {
    'singLEFTmiss',
    'singDOWNmiss',
    'singUPmiss',
    'singRIGHTmiss'
}

-- ============================================================
-- Punishment
-- ============================================================

local function punish(direction)
    setProperty('health', getProperty('health') - missHealth)
    setProperty('songScore', getProperty('songScore') - 10)

    if missSound then
        playSound(
            'missnote' .. getRandomInt(1, 3),
            1
        )
    end

    callOnLuas('onGhostTap', direction)

    if getProperty('boyfriend.hasMissAnimations') then
        characterPlayAnim(
            'boyfriend',
            missAnimations[direction + 1],
            true
        )
    end
end

-- ============================================================
-- Input begins
-- ============================================================

function preKeyPress(key)
    currentKey = key
    hitNormalNote = false
end

-- ============================================================
-- Successful normal note hit
-- ============================================================

function goodNoteHit(membersIndex, noteData, noteType, isSustainNote)
    if not isSustainNote then
        hitNormalNote = true
    end
end

-- ============================================================
-- Input ends
-- ============================================================

function onKeyPress(key)
    if not enabled or key < 0 or key > 3 then
        return
    end

    if getProperty('cpuControlled') then
        return
    end

    -- Only process the input that was initialized by preKeyPress.
    if currentKey ~= key then
        return
    end

    -- A normal note was hit during this input.
    if hitNormalNote then
        currentKey = -1
        return
    end

    local currentHasNote = false
    local otherHasNote = false

    local noteCount = getProperty('notes.length')

    for i = 0, noteCount - 1 do
        local prefix = 'notes.members[' .. i .. '].'

        local mustPress = getProperty(prefix .. 'mustPress')
        local canBeHit = getProperty(prefix .. 'canBeHit')
        local wasGoodHit = getProperty(prefix .. 'wasGoodHit')
        local tooLate = getProperty(prefix .. 'tooLate')
        local blockHit = getProperty(prefix .. 'blockHit')

        if mustPress and canBeHit and not wasGoodHit
        and not tooLate and not blockHit then
            local direction = getProperty(prefix .. 'noteData')

            if direction == key then
                currentHasNote = true
            elseif direction >= 0 and direction <= 3 then
                otherHasNote = true
            end
        end
    end

    if not currentHasNote and otherHasNote then
        punish(key)
    end

    currentKey = -1
    hitNormalNote = false
end

function onUpdatePost(elapsed)
    -- Prevent stale input state from affecting the next key press.
    currentKey = -1
    hitNormalNote = false
end