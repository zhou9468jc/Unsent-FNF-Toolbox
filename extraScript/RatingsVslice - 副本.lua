-- ============================================================
-- Unsent's Custom Rating System
-- ============================================================

-- ============================================================
-- Settings
-- ============================================================

local TAG_PREFIX = 'UnsentToolbox_Rating_'

local fileDir = 'Rattings/'
local fileSCL = 1.05
local numDir = ''
local numSCL = 1.05
local tipe = ''
local tipe2 = ''
local antiii = true

local ratingOnStage = getModSetting('makeRatingsOnGame')


RatingLimit = 2
permiteRating = false
comboShowThreshold = 10

local ratingUID = 0
local isPixelStage = false

-- ============================================================
-- Error Function
-- ============================================================

local function erf(x)
    local sign = x < 0 and -1 or 1
    x = math.abs(x)

    local t = 1 / (1 + 0.3275911 * x)

    local y = 1 - (((((1.061405429 * t - 1.453152027) * t)
        + 1.421413741) * t - 0.284496736) * t
        + 0.254829592) * t * math.exp(-x * x)

    return sign * y
end

-- ============================================================
-- Resource Loading
-- ============================================================

local function preloadRatingImages()
    precacheImage(fileDir .. 'shit' .. tipe)
    precacheImage(fileDir .. 'bad' .. tipe)
    precacheImage(fileDir .. 'good' .. tipe)
    precacheImage(fileDir .. 'sick' .. tipe)
    precacheImage(fileDir .. 'marvelous' .. tipe)

    for i = 0, 9 do
        precacheImage(numDir .. 'num' .. tipe2 .. i)
    end
end

-- ============================================================
-- Helper Functions
-- ============================================================

local function getAntialiasing()
    if not antiii then
        return false
    end

    return getPropertyFromClass('ClientPrefs', 'globalAntialiasing')
end

local function getDownscroll()
    return getPropertyFromClass('ClientPrefs', 'data.downScroll') == true
end

local function getMiddleScroll()
    return getPropertyFromClass('ClientPrefs', 'data.middleScroll') == true
end
-- 检测玩家箭头是否被其他脚本移动到中间
local function getPlayerStrumsCentered()
    local screenWidth = getPropertyFromClass('flixel.FlxG', 'width')
    local totalX = 0
    local count = 0

    for i = 4, 7 do
        local x = getPropertyFromGroup('strumLineNotes', i, 'x')
        local width = getPropertyFromGroup('strumLineNotes', i, 'width')

        if x ~= nil and width ~= nil then
            totalX = totalX + x + width / 2
            count = count + 1
        end
    end

    if count ~= 4 then
        return false
    end

    local centerX = totalX / count
    return centerX < screenWidth * 0.68
end

-- 原生 Middle Scroll 或其他脚本移动玩家箭头到中间
local function isMiddleLayout()
    return getMiddleScroll() or getPlayerStrumsCentered()
end
-- ============================================================
-- Create
-- ============================================================

function onCreatePost()
    setProperty('showRating', false)
    setProperty('showComboNum', false)

    isPixelStage = getPropertyFromClass('PlayState', 'isPixelStage') == true

    if isPixelStage then
        fileDir = 'pixelUI/Rattings/'
        fileSCL = 7.05

        numDir = 'pixelUI/Rattings/'
        numSCL = 10

        tipe = ''
        tipe2 = ''
        antiii = false
    end

    preloadRatingImages()
end

-- ============================================================
-- Song Start
-- ============================================================

function onSongStart()
    permiteRating = (songName ~= 'name')
end

-- ============================================================
-- Update
-- ============================================================

function onUpdatePost(elapsed)
    if permiteRating then
        setProperty('showRating', false)
        setProperty('showComboNum', false)
    end
end

-- ============================================================
-- Events
-- ============================================================

function onEvent(name, value1, value2)
    if name == 'MakeRating' then
        fileDir = value1 or fileDir
        numDir = value1 or numDir

        tipe = value2 or ''
        tipe2 = value2 or ''

        preloadRatingImages()
    end
end

-- ============================================================
-- Note Hit
-- ============================================================

function goodNoteHit(id, direction, noteType, isSustainNote)
    if not permiteRating then
        return
    end

    setProperty('showRating', false)
    setProperty('showComboNum', false)

    local combo = getProperty('combo')

    if isSustainNote or combo == nil then
        return
    end

    local strumTime = getPropertyFromGroup('notes', id, 'strumTime')
    local songPos = getPropertyFromClass('Conductor', 'songPosition')
    local rOffset = getPropertyFromClass('ClientPrefs', 'ratingOffset')

    updateAccuracy(strumTime, songPos, rOffset)

    local downscroll = getDownscroll()
    local middleScroll = isMiddleLayout()

    local downscrolloffset = downscroll and 10 or 0

    -- Middle Scroll + HUD 时，评级和数字一起左移
    local middleScrollOffset = (not ratingOnStage and middleScroll) and 300 or 0

    local pbRate = 1

    local screenWidth = getPropertyFromClass('flixel.FlxG', 'width')
    local screenHeight = getPropertyFromClass('flixel.FlxG', 'height')

    ratingUID = ratingUID + 1
    local uid = ratingUID

    -- ========================================================
    -- Rating
    -- ========================================================

    local rating = getPropertyFromGroup('notes', id, 'rating')
    local ratingImg = 'marvelous'

    if rating == 'sick' then
        ratingImg = 'sick'
    elseif rating == 'good' then
        ratingImg = 'good'
    elseif rating == 'bad' then
        ratingImg = 'bad'
    elseif rating == 'shit' then
        ratingImg = 'shit'
    end

    local ratinTag = TAG_PREFIX .. 'Sprite_' .. uid

    makeLuaSprite(ratinTag, fileDir .. ratingImg .. tipe, 0, 0)

    if ratingOnStage then
        setObjectCamera(ratinTag, 'game')

        setProperty(ratinTag .. '.x', getProperty('boyfriend.x') - 180)
        setProperty(ratinTag .. '.y', getProperty('boyfriend.y'))
    else
        setObjectCamera(ratinTag, 'hud')

        local ratingX = middleScroll and 180 or 480

        setProperty(ratinTag .. '.x', ratingX)
        setProperty(ratinTag .. '.y', 245)
    end

    setProperty(ratinTag .. '.antialiasing', getAntialiasing())

    scaleObject(ratinTag, 0.6, 0.6)

    setGraphicSize(
        ratinTag,
        math.floor(getProperty(ratinTag .. '.width') * fileSCL)
    )

    updateHitbox(ratinTag)
    addLuaSprite(ratinTag, true)

    setProperty(ratinTag .. '.acceleration.y', 550 * pbRate * pbRate)
    setProperty(ratinTag .. '.velocity.y', -(math.random(140, 175) * pbRate))
    setProperty(ratinTag .. '.velocity.x', -(math.random(0, 10) * pbRate))

    doTweenAlpha(
        TAG_PREFIX .. 'TweenRating_' .. uid,
        ratinTag,
        0,
        0.8,
        'quartIn'
    )

    -- ========================================================
    -- Combo
    -- ========================================================

    if combo < comboShowThreshold then
        return
    end

    RatingLimit = combo >= 1000 and 3 or 2

    local daLoop = 0

    for i = 0, RatingLimit do
        local tag = TAG_PREFIX .. 'Combo_' .. uid .. '_' .. i

        local digitVal = math.floor(combo / (10 ^ i) % 10)

        local x = screenWidth * 0.35 + 145 - i * 43 + downscrolloffset
        local y = screenHeight / 2 - 90 - downscrolloffset * 3

        makeLuaSprite(
            tag,
            numDir .. 'num' .. tipe2 .. digitVal,
            x,
            y
        )

        if ratingOnStage then
            setObjectCamera(tag, 'game')

            setProperty(
                tag .. '.x',
                getProperty('boyfriend.x') - 180 + (-43 * daLoop) + 40
            )

            setProperty(
                tag .. '.y',
                getProperty('boyfriend.y') + 150
            )
        else
            setObjectCamera(tag, 'hud')

            setProperty(
                tag .. '.x',
                520 + (-43 * daLoop) + 40 - middleScrollOffset
            )

            setProperty(tag .. '.y', 350)
        end

        setProperty(tag .. '.antialiasing', getAntialiasing())

        scaleObject(tag, 0.48, 0.48)

        setProperty(
            tag .. '.acceleration.y',
            math.random(200, 300) * pbRate * pbRate
        )

        setProperty(
            tag .. '.velocity.y',
            -(math.random(140, 160) * pbRate)
        )

        setProperty(
            tag .. '.velocity.x',
            -(math.random(-5, 5) * pbRate)
        )

        doTweenAlpha(
            TAG_PREFIX .. 'TweenCombo_' .. uid .. '_' .. i,
            tag,
            0,
            1,
            'quartIn'
        )

        daLoop = daLoop + 1

        addLuaSprite(tag, true)

        setGraphicSize(
            tag,
            math.floor(getProperty(tag .. '.width') * numSCL)
        )

        updateHitbox(tag)
    end
end

-- ============================================================
-- Tween Cleanup
-- ============================================================

function onTweenCompleted(tag)
    if tag:sub(1, #TAG_PREFIX) ~= TAG_PREFIX then
        return
    end

    local spriteTag

    local uid = tag:match(
        '^' .. TAG_PREFIX .. 'TweenRating_(%d+)$'
    )

    if uid then
        spriteTag = TAG_PREFIX .. 'Sprite_' .. uid
    else
        local comboUID, digit = tag:match(
            '^' .. TAG_PREFIX .. 'TweenCombo_(%d+)_(%d+)$'
        )

        if comboUID and digit then
            spriteTag = TAG_PREFIX .. 'Combo_' .. comboUID .. '_' .. digit
        end
    end

    if spriteTag then
        removeLuaSprite(spriteTag, true)
    end
end

-- ============================================================
-- Accuracy
-- ============================================================

function updateAccuracy(strumTime, songPos, rOffset)
    local noteDiffSign = strumTime - songPos + rOffset
    showMsDiffOnScreen(noteDiffSign)
end

function showMsDiffOnScreen(diff)
    local msDiffStr = string.format('%.3fms', -diff)

    Ratingers(diff)

    lastMsShowUp = getPropertyFromClass('Conductor', 'songPosition')
end

function Ratingers(diff)
    epic = math.abs(diff) < 15.0
end

-- ============================================================
-- Rating Calculation
-- ============================================================

function handleNoteDiff(diff)
    local maxms = diff
    local ts = 1
    local max_points = 1.0
    local miss_weight = -1.0
    local ridic = 5 * ts
    local max_boo_weight = 166
    local ts_pow = 0.75
    local zero = 65 * ts ^ ts_pow
    local power = 2.5
    local dev = 22.7 * ts ^ ts_pow

    if maxms <= ridic then
        return max_points
    elseif maxms <= zero then
        return max_points * erf((zero - maxms) / dev)
    elseif maxms <= max_boo_weight then
        return (maxms - zero) * miss_weight / (max_boo_weight - zero)
    else
        return miss_weight
    end
end