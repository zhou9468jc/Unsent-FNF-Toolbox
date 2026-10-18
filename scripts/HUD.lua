-- ============================================================
-- Unsent - HUD
-- 写屎山代码，享屎山人生
-- ============================================================
local bottomBGEnabled = getModSetting('unsentBottomHUDBackground')
local showcase = getModSetting('showCaseMode')
local showCaseMode = getModSetting('showCaseMode')
local bottomBGAlpha = tonumber(getModSetting('unsentBottomHUDBackgroundAlpha'))
if bottomBGEnabled == nil then bottomBGEnabled = true end
if showCaseMode == true then bottomBGEnabled = false end
if bottomBGAlpha == nil then bottomBGAlpha = 0.65 end
bottomBGAlpha = math.max(0, math.min(1, bottomBGAlpha))

local boxWidth, boxHeight, bottomOffset = 800, 120, 0
local boxTag = 'unsentBottomHUDBackground'
local imageName = 'unsentBottomHUDBackground'

function onCreatePost()
    if (not bottomBGEnabled) or showcase==true then return end
    local screenWidth = getPropertyFromClass('flixel.FlxG', 'width')
    local screenHeight = getPropertyFromClass('flixel.FlxG', 'height')
    local x = math.floor((screenWidth - boxWidth) / 2)
    local y = screenHeight - boxHeight - bottomOffset
    makeLuaSprite(boxTag, imageName, x, y)
    setGraphicSize(boxTag, boxWidth, boxHeight)
    updateHitbox(boxTag)
    setObjectCamera(boxTag, 'hud')
    setProperty(boxTag .. '.alpha', bottomBGAlpha)
    addLuaSprite(boxTag, false)
    setObjectOrder(boxTag, 0)
	setProperty("iconP1.y",getProperty("iconP1.y")+8)
	setProperty("iconP2.y",getProperty("iconP2.y")+8)
end

-- ============================================================
-- CONFIG
-- ============================================================
local enableCustomRating = getModSetting('betterRank')
local language = getModSetting('language')
if enableCustomRating == nil then enableCustomRating = true end
if language == nil then language = "english" end

-- ============================================================
-- Unsent Custom Final Rating | NFE 1.2.2
-- ============================================================
local customRating = 'N/A'
local customRatingFontSizeSet = false
local customRatingOriginalFontSize = nil

-- ============================================================
-- CUSTOM RATING
-- ============================================================
local function getCustomRating(isScoreCol)
    local ratingPercent = tonumber(getProperty('ratingPercent'))
    if ratingPercent == nil then return 'N/A' end
    local percent = math.floor(ratingPercent * 10000) / 100

    local ranks = {
        {99.5, 'P', 'FF69B4'},
        {98, 'E', 'FEDC21'},
        {96, 'SSS', 'FFA500'},
        {94, 'SS', 'FFFF00'},
        {92, 'S+', '87CEBB'},
        {90, 'S', '87CEBB'},
        {85, 'A+', '6666FF', true},
        {80, 'A', '0000FF', true},
        {75, 'Great', 'C0C0C0'},
        {70, 'Good', 'C77C3C'},
        {60, 'B', '00008B'},
        {50, 'C', 'D2691E'},
        {40, 'D', '808080'},
        {30, 'F', 'D3D3D3'},
        {20, 'F-', 'D3D3D3'},
        {10, 'You SUCK!', '404040'}
    }

    for _, rank in ipairs(ranks) do
        local matched = rank[4] and percent > rank[1] or percent >= rank[1]
        if matched then
            return isScoreCol and rank[3] or rank[2]
        end
    end

    if percent > 0 then
        return isScoreCol and 'FFFFFF' or 'You Not Playing!'
    end

    return 'N/A'
end

-- ============================================================
-- FC LABEL
-- ============================================================
local function shouldKeepFC(fc)
    if fc == 'AP' or fc == 'FC' then return fc end
    if fc == 'SFC' or fc == 'GFC' or fc == 'BFC' then return 'FC' end
    return nil
end

-- ============================================================
-- UPDATE CUSTOM RATING AND SCORE TEXT
-- ============================================================
local function updateCustomRating()
    if not enableCustomRating or not getProperty('scoreTxt.visible') then return end
    local text = getProperty('scoreTxt.text')
    if type(text) ~= 'string' or text == '' then return end

    -- 中文字体
    if language == 'Chinese' then
        setTextFont('scoreTxt', 'unsentScoreText.ttf')
        if not customRatingFontSizeSet then
            customRatingOriginalFontSize = tonumber(getProperty('scoreTxt.size')) or 16
            setTextSize('scoreTxt', customRatingOriginalFontSize + 4)
            customRatingFontSizeSet = true
        end
    elseif customRatingFontSizeSet then
        if customRatingOriginalFontSize then setTextSize('scoreTxt', customRatingOriginalFontSize) end
        customRatingFontSizeSet = false
    end

    -- 仅识别 NFE HUD 的统计格式；其他引擎的文本不由本脚本改写
    local isNFEText = text:match('^NPS:%s*') ~= nil
        and text:find('|', 1, true) ~= nil
        and (text:find('准确率:', 1, true) ~= nil
            or text:find('Accuracy:', 1, true) ~= nil)
    if not isNFEText then return end

    local ratingPercent = math.floor((tonumber(getProperty('ratingPercent')) or 0) * 10000 + 0.5) / 100
    local score = tonumber(getProperty('songScore')) or 0
    local misses = tonumber(getProperty('songMisses')) or 0
    local missLimit = tonumber(getModSetting('missLimit'))
    local accuracyText = string.format('%.2f', ratingPercent):gsub('0+$', ''):gsub('%.$', '')
    local missText = ''
    if missLimit and missLimit ~= -1 then missText = '/' .. tostring(missLimit) end

    -- 移除脚本上一次添加的自定义评级，保留 NPS 前缀
    local before = text:match('^(NPS:.-%|)')
    if not before then return end

    -- FC/AP 完全由 Toolbox 根据实时数据判定，不读取 NFE 原有标记
    local fc = nil
    if misses <= 0 then 
		if customRating == 'N/A' then
			fc = nil
		elseif ratingPercent >= 100 then
			fc = 'AP' 
		else
			fc = 'FC'
		end
	end
    customRating = getCustomRating()

    local newText
    if language == 'Chinese' then
        newText = before
            .. ' 分数: ' .. score
            .. ' | 失误: ' .. misses .. missText
            .. ' | 准确率: ' .. accuracyText .. '%'
            .. ' | 评级: ' .. customRating
        if fc then newText = newText .. ' (' .. fc .. ')' end
    else
        -- NFE 英文 HUD：保留原始 NPS，使用引擎实时统计重建其余字段
        newText = before
            .. ' Score: ' .. score
            .. ' | Misses: ' .. misses .. missText
            .. ' | Accuracy: ' .. accuracyText .. '%'
            .. ' Rank: ' .. customRating
        if fc then newText = newText .. ' (' .. fc .. ')' end
    end

    if newText ~= text then setProperty('scoreTxt.text', newText) end
end

-- ============================================================
-- COLOR CONFIG
-- ============================================================
local scoreColors = {
    White='FFFFFF', Black='000000',
    Red='FF0000', DarkRed='8B0000',
    Green='00FF00', DarkGreen='006400',
    Blue='0000FF', DarkBlue='00008B',
    SkyBlue='87CEEB', DodgerBlue='1E90FF',
    Cyan='00FFFF', Teal='008080',
    Yellow='FFFF00', Gold='FFD700',
    Orange='FFA500', Coral='FF7F50',
    Purple='800080', Violet='EE82EE',
    Pink='FF69B4', HotPink='FF1493',
    Magenta='FF00FF',
    Brown='A52A2A', Chocolate='D2691E',
    Gray='808080', DarkGray='404040',
    LightGray='D3D3D3', Silver='C0C0C0'
}

local scoreColorList = {
    'FFFFFF','000000','FF0000','8B0000',
    '00FF00','006400','0000FF','00008B',
    '87CEEB','1E90FF','00FFFF','008080',
    'FFFF00','FFD700','FFA500','FF7F50',
    '800080','EE82EE','FF69B4','FF1493',
    'FF00FF','A52A2A','D2691E','808080',
    '404040','D3D3D3','C0C0C0'
}

local rainbowTime = 0

-- ============================================================
-- COLOR HELPERS
-- ============================================================
local function hexToRGB(hex)
    return tonumber(hex:sub(1,2),16),
        tonumber(hex:sub(3,4),16),
        tonumber(hex:sub(5,6),16)
end

local function rgbToHex(r,g,b)
    return string.format('%02X%02X%02X',
        math.floor(math.max(0,math.min(255,r))),
        math.floor(math.max(0,math.min(255,g))),
        math.floor(math.max(0,math.min(255,b))))
end

local function clampColor(value)
    value = tonumber(value) or 255
    return math.floor(math.max(0,math.min(255,value)))
end

local function isValidHexColor(color)
    return type(color) == 'string'
        and color:match('^%x%x%x%x%x%x$') ~= nil
end

-- ============================================================
-- SMOOTH RANK COLOR
-- ============================================================
local rankCurrentColor = nil
local rankTransitionSpeed = 5

local function smoothRankColor(target, elapsed)
    if not isValidHexColor(target) then
        return rankCurrentColor or 'FFFFFF'
    end

    if not isValidHexColor(rankCurrentColor) then
        rankCurrentColor = target
        return target
    end

    local cr,cg,cb = hexToRGB(rankCurrentColor)
    local tr,tg,tb = hexToRGB(target)

    -- 帧率无关的指数平滑
    local dt = math.max(0, tonumber(elapsed) or 0)
    local factor = 1 - math.exp(-rankTransitionSpeed * dt)

    local r = cr + (tr-cr)*factor
    local g = cg + (tg-cg)*factor
    local b = cb + (tb-cb)*factor

    rankCurrentColor = rgbToHex(r,g,b)

    -- 接近目标时直接完成
    local nr,ng,nb = hexToRGB(rankCurrentColor)
    if math.abs(nr-tr) <= 1 and math.abs(ng-tg) <= 1 and math.abs(nb-tb) <= 1 then
        rankCurrentColor = target
    end

    return rankCurrentColor
end

-- ============================================================
-- RAINBOW
-- ============================================================
local function getRainbowColor(elapsed)
    local speed = tonumber(getModSetting('rainbowSpeed')) or 1
    rainbowTime = rainbowTime + (tonumber(elapsed) or 0) * speed

    local count = #scoreColorList
    local pos = rainbowTime % count
    local index = math.floor(pos) + 1
    local nextIndex = index % count + 1
    local t = pos - math.floor(pos)

    local r1,g1,b1 = hexToRGB(scoreColorList[index])
    local r2,g2,b2 = hexToRGB(scoreColorList[nextIndex])

    return rgbToHex(
        r1+(r2-r1)*t,
        g1+(g2-g1)*t,
        b1+(b2-b1)*t
    )
end

-- ============================================================
-- GET SCORE TEXT COLOR
-- ============================================================
local function getScoreTextColor(elapsed)
    local color = getModSetting('scoreTextColor')

    if color == 'Rainbow' then
        return getRainbowColor(elapsed or 0)

    elseif color == 'Follow Rank' then
        return getCustomRating(true)

    elseif color == 'Follow Player' or color == 'Follow Op.' then
        local prefix = color == 'Follow Player' and 'boyfriend' or 'dad'
        local r = tonumber(getProperty(prefix .. '.healthColorArray[0]'))
        local g = tonumber(getProperty(prefix .. '.healthColorArray[1]'))
        local b = tonumber(getProperty(prefix .. '.healthColorArray[2]'))

        if r and g and b then
            return rgbToHex(r,g,b)
        end

    elseif color == 'Custom' then
        return string.format('%02X%02X%02X',
            clampColor(getModSetting('textColorR')),
            clampColor(getModSetting('textColorG')),
            clampColor(getModSetting('textColorB')))

    elseif scoreColors[color] then
        return scoreColors[color]
    end

    return nil
end

-- ============================================================
-- APPLY COLOR
-- ============================================================
-- 仅在 Follow Rank 模式下，BotPlay 开启后才永久锁定白色
local botPlayWasEnabled = false

local function isBotPlayActive()
    return getProperty('cpuControlled') == true
end

local function scoreTextColorCreate()
    local mode = getModSetting('scoreTextColor')
    if mode == 'Follow Rank' and isBotPlayActive() then
        botPlayWasEnabled = true
    end

    if mode == 'Follow Rank' and botPlayWasEnabled then
        rankCurrentColor = nil
        setTextColor('scoreTxt', 'FFFFFF')
        return
    end

    local color = getScoreTextColor(0)

    if mode == 'Follow Rank' and isValidHexColor(color) then
        rankCurrentColor = color
    end

    if isValidHexColor(color) then
        setTextColor('scoreTxt',color)
    end
end

local function scoreTextColorUpdate(elapsed)
    local mode = getModSetting('scoreTextColor')

    -- 仅 Follow Rank 模式记录 BotPlay；其他颜色模式完全沿用原有逻辑
    if mode == 'Follow Rank' and isBotPlayActive() then
        botPlayWasEnabled = true
    end

    -- 只在 Follow Rank 模式下锁白色，避免影响其他颜色选项
    if mode == 'Follow Rank' and botPlayWasEnabled then
        rankCurrentColor = nil
        setTextColor('scoreTxt', 'FFFFFF')
        return
    end

    local color = getScoreTextColor(elapsed)

    if mode == 'Follow Rank' then
        color = smoothRankColor(color,elapsed)
    else
        -- 切换其他模式时重置渐变起点
        rankCurrentColor = nil
    end

    if isValidHexColor(color) then
        setTextColor('scoreTxt',color)
    end
end

-- ============================================================
-- UPDATE
-- ============================================================
function onCreate()
    scoreTextColorCreate()
end

function onUpdatePost(elapsed)
    updateCustomRating()
    scoreTextColorUpdate(elapsed)
end