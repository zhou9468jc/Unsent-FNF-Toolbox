local fileDir = 'Rattings/'
local fileSCL = '1.05'
local numDir  = ''
local numSCL  = '1.05'
local tipe    = ''
local tipe2   = ''
local antiii  = true

RatingLimit = 2
permiteRating = false
comboShowThreshold = 10
local ratingUID = 0

local function erf(x)
    local sign = x < 0 and -1 or 1
    x = math.abs(x)
    local t = 1 / (1 + 0.3275911 * x)
    local y = 1 - (((((1.061405429 * t - 1.453152027) * t) + 1.421413741) * t - 0.284496736) * t + 0.254829592) * t * math.exp(-x * x)
    return sign * y
end

function onCreatePost()
    -- 提前关闭原生 rating / combo 显示（解决第一下露出来）
    setProperty('showRating', false)
    setProperty('showComboNum', false)

    precacheImage(fileDir..'shit'..tipe)
    precacheImage(fileDir..'bad'..tipe)
    precacheImage(fileDir..'good'..tipe)
    precacheImage(fileDir..'sick'..tipe)
    precacheImage(fileDir..'marvelous'..tipe)
    for i = 0, 9 do
        precacheImage(numDir..'num'..tipe2..i)
    end
end

function onSongStart()
    permiteRating = (songName ~= 'name')

    if getPropertyFromClass('PlayState', 'isPixelStage') then
        fileDir = 'pixelUI/Rattings/'
        fileSCL = '7.05'
        numDir  = 'pixelUI/Rattings/'
        numSCL  = '10'
        tipe    = ''
        tipe2   = ''
        antiii  = false
    end
end

-- 每帧压制原生 rating / combo 显示，防止第一下或引擎重置后露出来
function onUpdatePost(elapsed)
    if permiteRating then
        setProperty('showRating', false)
        setProperty('showComboNum', false)
    end
end

function onEvent(name, value1, value2)
    if name == 'MakeRating' then
        fileDir = value1
        numDir  = value1
        tipe    = value2
        tipe2   = value2
    end
end

function goodNoteHit(id, direction, noteType, isSustainNote)
    if not permiteRating then return end
    setProperty('showRating', false)
    setProperty('showComboNum', false)

    local combo = getProperty('combo')
    if isSustainNote or combo == nil then return end

    local strumTime = getPropertyFromGroup('notes', id, 'strumTime')
    local songPos   = getPropertyFromClass('Conductor', 'songPosition')
    local rOffset   = getPropertyFromClass('ClientPrefs', 'ratingOffset')
    updateAccuracy(strumTime, songPos, rOffset)

    local downscrolloffset = downscroll and 10 or 0
    local pbRate = 1

    ratingUID = ratingUID + 1
    local uid = ratingUID

    local rating = getPropertyFromGroup('notes', id, 'rating')
    local ratingImg = 'marvelous'
	if rating == 'sick' then ratingImg = 'sick'
    elseif rating == 'good' then ratingImg = 'good'
    elseif rating == 'bad' then ratingImg = 'bad'
    elseif rating == 'shit' then ratingImg = 'shit' end

    local ratinTag = 'ratin_' .. uid
    makeLuaSprite(ratinTag, fileDir..ratingImg..tipe, 0, 0)
    setObjectCamera(ratinTag, 'hud')
    scaleObject(ratinTag, 0.7, 0.7)
    addLuaSprite(ratinTag, true)
    setProperty(ratinTag..'.acceleration.y', 550 * pbRate * pbRate)
    setProperty(ratinTag..'.velocity.y', -(math.random(140, 175) * pbRate))
    setProperty(ratinTag..'.velocity.x', -(math.random(0, 10) * pbRate))
    doTweenAlpha('tweenRating_' .. uid, ratinTag, 0, 0.8, 'quartIn')
    setProperty(ratinTag..'.x', 400)
    setProperty(ratinTag..'.y', 230)
    setProperty(ratinTag..'.antialiasing',
        antiii and getPropertyFromClass('ClientPrefs', 'globalAntialiasing') or false)

    setGraphicSize(ratinTag, math.floor(getProperty(ratinTag..'.width') * fileSCL))
    updateHitbox(ratinTag)

    if combo < comboShowThreshold then return end

    if combo >= 1000 then
        RatingLimit = 3
    else
        RatingLimit = 2
    end

    local daLoop = 0
    for i = 0, RatingLimit do
        local tag = 'combodigit_' .. uid .. '_' .. i
        local digitVal = math.floor(combo / 10 ^ i % 10)
        makeLuaSprite(tag, numDir..'num'..tipe2..digitVal,
            screenWidth * 0.35 + 145 - i * 43 + downscrolloffset,
            screenHeight / 2 - 90 - downscrolloffset * 3)
        setObjectCamera(tag, 'camHUD')
        scaleObject(tag, 0.5, 0.5)
        setProperty(tag..'.acceleration.y', math.random(200, 300) * pbRate * pbRate)
        setProperty(tag..'.velocity.y', -(math.random(140, 160) * pbRate))
        setProperty(tag..'.velocity.x', -(math.random(-5, 5) * pbRate))
        setProperty(tag..'.antialiasing',
            antiii and getPropertyFromClass('ClientPrefs', 'globalAntialiasing') or false)
        doTweenAlpha('tweenTag_' .. uid .. '_' .. i, tag, 0, 1, 'quartIn')
        setProperty(tag..'.x', 400 + (-43 * daLoop) + 40)
        setProperty(tag..'.y', 260 + 120)
        daLoop = daLoop + 1
        addLuaSprite(tag, true)

        setGraphicSize(tag, math.floor(getProperty(tag..'.width') * numSCL))
        updateHitbox(tag)
    end
end

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