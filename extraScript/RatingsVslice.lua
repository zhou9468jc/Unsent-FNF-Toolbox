
-- ============================================================
-- Unsent's Custom Rating System
-- V-Slice Style Rating & Combo
-- ============================================================

-- ============================================================
-- Settings
-- ============================================================
local TAG_PREFIX = 'UnsentToolbox_Rating_'

local fileDir = 'Rattings/'
local fileSCL = 1.05
local numDir = ''
local numSCL = 0.98
local tipe = ''
local tipe2 = ''
local antiii = true

local ratingOnStage = getModSetting('makeRatingsOnGame')

RatingLimit = 2
permiteRating = false
comboShowThreshold = 10

local ratingUID = 0
local isPixelStage = false

local spriteByTween = {}
local pendingTweens = {}
local pixelPhysics = {}
local activeComboSprites = {}

-- 000 状态锁：直到正常 Combo 出现才解除
local zeroComboActive = false
local lastCombo = 0

-- ============================================================
-- Physics & Fade Settings
-- ============================================================

local RATING_GRAVITY = 550

-- 固定隐藏时间（单位：秒）
local RATING_FADE_TIME = 0.25
local RATING_FADE_DELAY = 0.3

local COMBO_FADE_TIME = 0.25
local COMBO_FADE_DELAY = 0.6

-- 连击数字间距，同时决定四位数及以上的整体偏移
local COMBO_SPACING = 38

-- Pixel movement
local PIXEL_PHYSICS_FPS = 24
local PIXEL_PHYSICS_STEP = 1 / PIXEL_PHYSICS_FPS

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

    return getPropertyFromClass(
        'ClientPrefs',
        'globalAntialiasing'
    )
end

local function getDownscroll()
    return getPropertyFromClass(
        'ClientPrefs',
        'data.downScroll'
    ) == true
end

local function getMiddleScroll()
    return getPropertyFromClass(
        'ClientPrefs',
        'data.middleScroll'
    ) == true
end

local function getPlayerStrumsCentered()
    local screenWidth = getPropertyFromClass(
        'flixel.FlxG',
        'width'
    )

    local totalX = 0
    local count = 0

    for i = 4, 7 do
        local x = getPropertyFromGroup(
            'strumLineNotes',
            i,
            'x'
        )

        local width = getPropertyFromGroup(
            'strumLineNotes',
            i,
            'width'
        )

        if x ~= nil and width ~= nil then
            totalX = totalX + x + width / 2
            count = count + 1
        end
    end

    if count ~= 4 then
        return false
    end

    return totalX / count < screenWidth * 0.68
end

local function isMiddleLayout()
    return getMiddleScroll() or getPlayerStrumsCentered()
end

-- ============================================================
-- Display Position
-- ============================================================

local function getRatingPosition()
    if ratingOnStage then
        return getProperty('boyfriend.x') - 180,
               getProperty('boyfriend.y')
    end

    local screenWidth = getPropertyFromClass('flixel.FlxG', 'width')
    local screenHeight = getPropertyFromClass('flixel.FlxG', 'height')

    local x = screenWidth * 0.50 - 136
    local y = screenHeight * 0.40 - 50

    if isMiddleLayout() then
        x = x - 450
    end

    return x, y
end

local function getComboPosition(index, digitCount)
    -- 超过三位数后，每增加一位，整个数字组向右移动一个数字间距
    local offset = math.max(0, digitCount - 3) * COMBO_SPACING

    if ratingOnStage then
        return getProperty('boyfriend.x') - 140
            - index * COMBO_SPACING + offset,
            getProperty('boyfriend.y') + 150
    end

    local screenWidth = getPropertyFromClass('flixel.FlxG', 'width')
    local screenHeight = getPropertyFromClass('flixel.FlxG', 'height')

    local x = screenWidth * 0.50
        - COMBO_SPACING * (index + 1) + offset - 15
    local y = screenHeight * 0.40 + 40

    if isMiddleLayout() then
        x = x - 450
    end

    return x, y
end

-- ============================================================
-- Physics System
-- ============================================================

local function applyPhysics(tag, vx, vy, ax, ay)
    if isPixelStage then
        setProperty(tag .. '.velocity.x', 0)
        setProperty(tag .. '.velocity.y', 0)
        setProperty(tag .. '.acceleration.x', 0)
        setProperty(tag .. '.acceleration.y', 0)

        pixelPhysics[tag] = {
            x = getProperty(tag .. '.x'),
            y = getProperty(tag .. '.y'),
            vx = vx,
            vy = vy,
            ax = ax,
            ay = ay,
            accumulator = 0
        }
    else
        setProperty(tag .. '.velocity.x', vx)
        setProperty(tag .. '.velocity.y', vy)
        setProperty(tag .. '.acceleration.x', ax)
        setProperty(tag .. '.acceleration.y', ay)
    end
end

local function applyRatingPhysics(tag)
    applyPhysics(
        tag,
        -math.random(0, 10),
        -math.random(140, 175),
        0,
        RATING_GRAVITY
    )
end

local function applyComboPhysics(tag)
    applyPhysics(
        tag,
        math.random(-5, 5),
        -math.random(140, 160),
        0,
        math.random(200, 300)
    )
end

-- ============================================================
-- Pixel Physics Update
-- ============================================================

local function updatePixelPhysics(elapsed)
    if not isPixelStage then
        return
    end

    for tag, physics in pairs(pixelPhysics) do
        if luaSpriteExists(tag) then
            physics.accumulator = physics.accumulator + elapsed

            while physics.accumulator >= PIXEL_PHYSICS_STEP do
                local dt = PIXEL_PHYSICS_STEP

                physics.vx = physics.vx + physics.ax * dt
                physics.vy = physics.vy + physics.ay * dt

                physics.x = physics.x + physics.vx * dt
                physics.y = physics.y + physics.vy * dt

                physics.accumulator = physics.accumulator
                    - PIXEL_PHYSICS_STEP
            end

            setProperty(tag .. '.x', physics.x)
            setProperty(tag .. '.y', physics.y)
        else
            pixelPhysics[tag] = nil
        end
    end
end

-- ============================================================
-- Delayed Fade System
-- ============================================================

-- delay 和 duration 均为固定秒数
local function scheduleFade(spriteTag, tweenTag, duration, delay)
    local timerTag = TAG_PREFIX .. 'Start_' .. tweenTag

    pendingTweens[timerTag] = {
        sprite = spriteTag,
        tween = tweenTag,
        duration = duration
    }

    runTimer(timerTag, delay)
end

local function startFade(spriteTag, tweenTag, duration)
    if not luaSpriteExists(spriteTag) then
        pixelPhysics[spriteTag] = nil
        activeComboSprites[spriteTag] = nil
        return
    end

    spriteByTween[tweenTag] = spriteTag

    doTweenAlpha(
        tweenTag,
        spriteTag,
        0,
        duration,
        'quartIn'
    )
end

-- ============================================================
-- Create Rating
-- ============================================================

local function createRating(rating, uid)
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

    local tag = TAG_PREFIX .. 'Sprite_' .. uid
    local tweenTag = TAG_PREFIX .. 'TweenRating_' .. uid

    local x, y = getRatingPosition()

    makeLuaSprite(
        tag,
        fileDir .. ratingImg .. tipe,
        x,
        y
    )

    setObjectCamera(
        tag,
        ratingOnStage and 'game' or 'hud'
    )

    setProperty(
        tag .. '.antialiasing',
        getAntialiasing()
    )

    scaleObject(tag, 0.6, 0.6)

    setGraphicSize(
        tag,
        math.floor(
            getProperty(tag .. '.width') * fileSCL
        )
    )

    updateHitbox(tag)
    addLuaSprite(tag, true)

    applyRatingPhysics(tag)

    scheduleFade(
        tag,
        tweenTag,
        RATING_FADE_TIME,
        RATING_FADE_DELAY
    )
end

-- ============================================================
-- Create Combo
-- ============================================================

local function createCombo(combo, uid)
    -- 正常 Combo 出现时解除 000 锁定
    if tonumber(combo) and tonumber(combo) > 0 then
        zeroComboActive = false
    end

    local digits = string.format(
        '%03d',
        math.max(0, math.floor(combo))
    )

    local digitCount = #digits

    RatingLimit = digitCount - 1

    -- 从个位开始生成数字
    for i = 0, digitCount - 1 do
        local digit = tonumber(
            digits:sub(digitCount - i, digitCount - i)
        )

        local tag = TAG_PREFIX
            .. 'Combo_' .. uid .. '_' .. i

        local tweenTag = TAG_PREFIX
            .. 'TweenCombo_' .. uid .. '_' .. i

        -- 根据总位数调整整体位置
        local x, y = getComboPosition(i, digitCount)

        makeLuaSprite(
            tag,
            numDir .. 'num' .. tipe2 .. digit,
            x,
            y
        )

        setObjectCamera(
            tag,
            ratingOnStage and 'game' or 'hud'
        )

        setProperty(
            tag .. '.antialiasing',
            getAntialiasing()
        )

        scaleObject(tag, 0.48, 0.48)

        setGraphicSize(
            tag,
            math.floor(
                getProperty(tag .. '.width') * numSCL
            )
        )

        updateHitbox(tag)
        addLuaSprite(tag, true)

        activeComboSprites[tag] = true

        applyComboPhysics(tag)

        scheduleFade(
            tag,
            tweenTag,
            COMBO_FADE_TIME,
            COMBO_FADE_DELAY
        )
    end
end

-- ============================================================
-- Miss Combo Override
-- ============================================================

function noteMiss(id, direction, noteType, isSustainNote)
    if not permiteRating or isSustainNote or zeroComboActive then
        return
    end

    if lastCombo < comboShowThreshold then
        lastCombo = 0
        return
    end

    -- 创建一次新的 000，不隐藏已经存在的 Combo 数字
    zeroComboActive = true
    lastCombo = 0

    ratingUID = ratingUID + 1
    createCombo(0, ratingUID)
end

-- ============================================================
-- Create
-- ============================================================

function onCreatePost()
    setProperty('showRating', false)
    setProperty('showComboNum', false)

    isPixelStage = getPropertyFromClass(
        'PlayState',
        'isPixelStage'
    ) == true

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
    permiteRating = songName ~= 'name'
    lastCombo = 0
    zeroComboActive = false
end

-- ============================================================
-- Update
-- ============================================================

function onUpdatePost(elapsed)
    if permiteRating then
        setProperty('showRating', false)
        setProperty('showComboNum', false)
    end

    updatePixelPhysics(elapsed)
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

    lastCombo = combo

    local strumTime = getPropertyFromGroup(
        'notes',
        id,
        'strumTime'
    )

    local songPos = getPropertyFromClass(
        'Conductor',
        'songPosition'
    )

    local rOffset = getPropertyFromClass(
        'ClientPrefs',
        'ratingOffset'
    )

    updateAccuracy(strumTime, songPos, rOffset)

    ratingUID = ratingUID + 1

    local uid = ratingUID

    local rating = getPropertyFromGroup(
        'notes',
        id,
        'rating'
    )

    createRating(rating, uid)

    if combo < comboShowThreshold then
        return
    end

    createCombo(combo, uid)
end

-- ============================================================
-- Timer Callback
-- ============================================================

function onTimerCompleted(tag)
    local data = pendingTweens[tag]

    if not data then
        return
    end

    pendingTweens[tag] = nil

    startFade(
        data.sprite,
        data.tween,
        data.duration
    )
end

-- ============================================================
-- Tween Cleanup
-- ============================================================

function onTweenCompleted(tag)
    local spriteTag = spriteByTween[tag]

    if not spriteTag then
        return
    end

    spriteByTween[tag] = nil
    pixelPhysics[spriteTag] = nil
    activeComboSprites[spriteTag] = nil

    if luaSpriteExists(spriteTag) then
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

    lastMsShowUp = getPropertyFromClass(
        'Conductor',
        'songPosition'
    )
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
        return (maxms - zero) * miss_weight
            / (max_boo_weight - zero)
    else
        return miss_weight
    end
end
