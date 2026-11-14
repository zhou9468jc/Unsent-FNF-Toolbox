-- ============================================================
-- Unsent's VSlice HUD
-- ============================================================

-- ============================================================
-- Settings
-- ============================================================

local enable = false
local sustainHealth = 0.008
local enableOpponentPush = false
local opponentPush = 0.018
local opponentPushSustain = 0.007
local forceOpponentPush = false
local originalHealthBar = false
local enableSustainReward = false

-- Score Scroll Settings
local normalScoreScrollRate = 2
local sustainScoreScrollRate = 1
local scoreScrollSpeed = 12
local currentScoreScrollRate = 1

-- ============================================================
-- Internal State
-- ============================================================

local initialized = false
local displayScore = 0
local targetScore = 0

local originalScoreTag = 'unsentOriginalScore'
local originalScoreCreated = false
local scoreLayerFixed = false

local oldPrefs = {
    saved = false
}

local hidden = false

local oldBotplayVisible = nil
local oldScoreTxtX = nil

local oldPositions = {
    healthBar = nil,
    healthBarBG = nil,
    iconP1 = nil,
    iconP2 = nil
}

-- Opponent Push Detection
local pendingOpponentPushes = {
    amount = 0,
    healthBefore = nil
}

-- Strum Movement
local strumMoved = true
local originalStrumPositions = {}

-- ============================================================
-- Utility
-- ============================================================

local function readSetting(name, default)
    local value = getModSetting(name)
    if value == nil then return default end
    return value
end

local function clampHealth(value)
    if value < 0 then return 0 end
    if value > 2 then return 2 end
    return value
end

local function formatNumber(num)
    local formatted = tostring(num)

    while true do
        local count
        formatted, count = string.gsub(
            formatted,
            "^(-?%d+)(%d%d%d)",
            "%1,%2"
        )

        if count == 0 then break end
    end

    return formatted
end

local function isDownScrollEnabled()
    local success, value = pcall(function()
        return getPropertyFromClass(
            'backend.ClientPrefs',
            'data.downScroll'
        )
    end)

    if success and value ~= nil then
        return value == true
    end

    success, value = pcall(function()
        return getPropertyFromClass(
            'ClientPrefs',
            'data.downScroll'
        )
    end)

    if success and value ~= nil then
        return value == true
    end

    return false
end

-- ============================================================
-- NFE UI Control
-- ============================================================

function hideNFEUI()
    if oldPrefs.saved then return end

    local success = pcall(runHaxeCode, [[
        // FPS
        game.variables.set("hideUI_showFPS", ClientPrefs.data.showFPS);
        game.variables.set(
            "hideUI_fpsViewerVisible",
            Main.fpsVar != null ? Main.fpsVar.visible : false
        );

        // Watermark
        game.variables.set("hideUI_showWatermark", ClientPrefs.data.showWatermark);
        game.variables.set(
            "hideUI_watermarkVisible",
            Main.watermark != null ? Main.watermark.visible : false
        );

        // Judgement Counter
        game.variables.set(
            "hideUI_judgementCounter",
            ClientPrefs.data.judgementCounter
        );

        game.variables.set(
            "hideUI_judgementVisible",
            game.judgementCounter_S != null
                ? game.judgementCounter_S.visible
                : false
        );

        game.variables.set(
            "hideUI_judgementExists",
            game.judgementCounter_S != null
                ? game.judgementCounter_S.exists
                : false
        );

        // Keyboard Viewer
        game.variables.set(
            "hideUI_keyboardViewer",
            ClientPrefs.data.keyboardViewer
        );

        game.variables.set(
            "hideUI_keyboardVisible",
            game.keyboardViewer != null
                ? game.keyboardViewer.visible
                : false
        );

        game.variables.set(
            "hideUI_keyboardExists",
            game.keyboardViewer != null
                ? game.keyboardViewer.exists
                : false
        );

        // Hide FPS
        ClientPrefs.data.showFPS = false;
        if (Main.fpsVar != null)
            Main.fpsVar.visible = false;

        // Hide Watermark
        ClientPrefs.data.showWatermark = false;
        if (Main.watermark != null)
            Main.watermark.visible = false;

        // Hide Judgement Counter
        ClientPrefs.data.judgementCounter = false;
        if (game.judgementCounter_S != null)
        {
            game.judgementCounter_S.visible = false;
            game.judgementCounter_S.exists = false;
        }

        // Hide Keyboard Viewer
        ClientPrefs.data.keyboardViewer = false;
        if (game.keyboardViewer != null)
        {
            game.keyboardViewer.visible = false;
            game.keyboardViewer.exists = false;
        }
    ]])

    if success then
        oldPrefs.saved = true
        hidden = true
    else
        debugPrint('[Unsent VSlice HUD] Failed to hide NFE UI')
    end
end

function restoreNFEUI()
    if not oldPrefs.saved then return end

    local success = pcall(runHaxeCode, [[
        // Restore FPS
        ClientPrefs.data.showFPS =
            game.variables.get("hideUI_showFPS");

        if (Main.fpsVar != null)
            Main.fpsVar.visible =
                game.variables.get("hideUI_fpsViewerVisible");

        // Restore Watermark
        ClientPrefs.data.showWatermark =
            game.variables.get("hideUI_showWatermark");

        if (Main.watermark != null)
            Main.watermark.visible =
                game.variables.get("hideUI_watermarkVisible");

        // Restore Judgement Counter
        ClientPrefs.data.judgementCounter =
            game.variables.get("hideUI_judgementCounter");

        if (game.judgementCounter_S != null)
        {
            game.judgementCounter_S.visible =
                game.variables.get("hideUI_judgementVisible");

            game.judgementCounter_S.exists =
                game.variables.get("hideUI_judgementExists");
        }

        // Restore Keyboard Viewer
        ClientPrefs.data.keyboardViewer =
            game.variables.get("hideUI_keyboardViewer");

        if (game.keyboardViewer != null)
        {
            game.keyboardViewer.visible =
                game.variables.get("hideUI_keyboardVisible");

            game.keyboardViewer.exists =
                game.variables.get("hideUI_keyboardExists");
        }
    ]])

    if success then
        oldPrefs.saved = false
        hidden = false
    else
        debugPrint('[Unsent VSlice HUD] Failed to restore NFE UI')
    end
end

-- ============================================================
-- V-Slice Health Bar
-- ============================================================

local function applyVSliceHealthBarColors()
    if not originalHealthBar then return end

    setHealthBarColors('FF0000', '00FF00')
end

local function updateScoreLayer()
    if not originalScoreCreated or scoreLayerFixed then return end

    local success, result = pcall(runHaxeCode, [[
        var scoreObj = game.getLuaObject('unsentOriginalScore');

        if (scoreObj == null || game.noteGroup == null)
            return false;

        scoreObj.cameras = [game.camHUD];

        var noteIndex = game.members.indexOf(game.noteGroup);
        var scoreIndex = game.members.indexOf(scoreObj);

        if (noteIndex < 0)
            return false;

        var desiredIndex = noteIndex - 1;

        if (scoreIndex != desiredIndex)
        {
            game.remove(scoreObj, false);

            noteIndex = game.members.indexOf(game.noteGroup);

            if (noteIndex < 0)
                return false;

            game.insert(noteIndex, scoreObj);
        }

        return true;
    ]])

    if success and result == true then
        scoreLayerFixed = true
    end
end

local function setupVSliceHealthBar()
    if not originalHealthBar then return end

    addLuaScript("extraScript/RatingsVslice.lua", true)

    if originalScoreCreated then return end

    makeLuaText(originalScoreTag, 'Score: 0', 0, 0, 0)
    setTextFont(originalScoreTag, 'origin.ttf')
    setTextSize(originalScoreTag, 16.5)
    setTextColor(originalScoreTag, 'FFFFFF')
    setTextBorder(originalScoreTag, 1, '000000')
    setTextAlignment(originalScoreTag, 'left')
    setObjectCamera(originalScoreTag, 'hud')
    addLuaText(originalScoreTag, true)
    setProperty(originalScoreTag .. '.letterSpacing', 0.7)

    originalScoreCreated = true
    scoreLayerFixed = false
end

-- ============================================================
-- Strum Movement
-- ============================================================

local function moveStrums()
    if strumMoved then return end

    for i = 0, 7 do
        local x = getPropertyFromGroup('strumLineNotes', i, 'x')

        if x ~= nil then
            originalStrumPositions[i] = x

            local offset = i < 4 and 50 or 40

            setPropertyFromGroup(
                'strumLineNotes',
                i,
                'x',
                x - offset
            )
        end
    end

    strumMoved = true
end

local function restoreStrums()
    if not strumMoved then return end

    for i = 0, 7 do
        local x = originalStrumPositions[i]

        if x ~= nil then
            pcall(function()
                setPropertyFromGroup(
                    'strumLineNotes',
                    i,
                    'x',
                    x
                )
            end)
        end
    end

    originalStrumPositions = {}
    strumMoved = false
end

function onCountdownTick(cou)
    if getPropertyFromClass(
        'backend.ClientPrefs',
        'data.middleScroll'
    ) then
        return
    end

    if cou ~= 0 or strumMoved then return end
    if not originalHealthBar then return end
    if getModSetting("fullWindow") == true then return end

    moveStrums()
end

-- ============================================================
-- Smooth Score Display
-- ============================================================

local function updateVSliceHealthBar(elapsed)
    if not originalHealthBar or not originalScoreCreated then
        return
    end

    local realScore = getProperty('songScore') or 0
    targetScore = realScore

    local scoreDifference = targetScore - displayScore

    if math.abs(scoreDifference) > 0.5 then
        local effectiveSpeed =
            scoreScrollSpeed * currentScoreScrollRate

        local follow = 1 - math.exp(-effectiveSpeed * elapsed)

        displayScore = displayScore + scoreDifference * follow
    else
        displayScore = targetScore
    end

    local shownScore = math.floor(displayScore + 0.5)
    local isBotplay = getProperty('cpuControlled') or false

    if isBotplay and readSetting('showBotText', true) then
        setTextString(originalScoreTag, 'Bot Play Enabled')
    else
        setTextString(
            originalScoreTag,
            'Score: ' .. formatNumber(shownScore)
        )
    end

    local healthBarY

    if isDownScrollEnabled() then
        healthBarY = screenHeight * 0.11
    else
        healthBarY = screenHeight * 0.89
    end

    setProperty(originalScoreTag .. '.x', (screenWidth / 2) + 100)

    if isDownScrollEnabled() then
        setProperty(originalScoreTag .. '.y', healthBarY + 3)
    else
        setProperty(originalScoreTag .. '.y', healthBarY + 38)
    end
end

-- ============================================================
-- Create
-- ============================================================

function onCreate()
    enable = readSetting('healthSmooth', false)
    local runMode = readSetting('healthSmoothMode', 'IL Mode')

    sustainHealth = readSetting('healthSustainAmount', 0.015)

    enableOpponentPush = readSetting('healthOpponentPush', false)
    opponentPush = readSetting('healthOpponentPushAmount', 0.020)
    opponentPushSustain = readSetting('healthOpponentPushSustain', 0.012)

    forceOpponentPush = readSetting('healthOpponentPushForce', false)
    originalHealthBar = readSetting('originalHealthBar', false)
    enableSustainReward = readSetting('healthSustainReward', false)

    displayScore = getProperty('songScore') or 0
    targetScore = displayScore
    currentScoreScrollRate = 1

    initialized = true

    if originalHealthBar then
        setupVSliceHealthBar()
        addHScript("extraScript/iconScale.hx")
    end

    if enable then
        if runMode == 'VSlice mode' then
            addLuaScript('extraScript/lerp-VSlice.lua')
        elseif runMode == 'UTB Old Mode' then
            addLuaScript('extraScript/lerp-old.lua')
        else
            addLuaScript('extraScript/lerp-IL.lua')
        end
    end
end

-- ============================================================
-- Create Post
-- ============================================================

function onCreatePost()
    if not originalHealthBar then return end

    -- Save Botplay state
    oldBotplayVisible = getProperty('botplayTxt.visible')

    -- Save original score position
    oldScoreTxtX = getProperty('scoreTxt.x')

    -- Move original score text outside the screen
    local scoreTxtX = oldScoreTxtX or 0

    setProperty(
        'scoreTxt.x',
        -screenWidth * 2 - math.abs(scoreTxtX)
    )

    -- Move icon layer
    pcall(function()
        setObjectOrder(
            'iconP1',
            getObjectOrder('iconP2', 'uiGroup') + 1,
            'uiGroup'
        )
    end)

    -- Hide NFE UI
    hideNFEUI()

    if not initialized or not originalScoreCreated then
        return
    end

    -- Save original positions
    oldPositions.healthBar = getProperty('healthBar.y')
    oldPositions.healthBarBG = getProperty('healthBarBG.y')
    oldPositions.iconP1 = getProperty('iconP1.y')
    oldPositions.iconP2 = getProperty('iconP2.y')

    -- Adjust health bar
    local value = 10

    if not isDownScrollEnabled() then
        setProperty(
            'healthBar.y',
            (oldPositions.healthBar or 0) + value
        )

        setProperty(
            'healthBarBG.y',
            (oldPositions.healthBarBG or 0) + value
        )

        setProperty(
            'iconP1.y',
            (oldPositions.iconP1 or 0) + value
        )

        setProperty(
            'iconP2.y',
            (oldPositions.iconP2 or 0) + value
        )
    end

    -- Try fixing score layer
    updateScoreLayer()
end

-- ============================================================
-- Spawn Note
-- ============================================================

function onSpawnNote(id, direction, noteType, isSustainNote)
    if isSustainNote and originalHealthBar then
        setPropertyFromGroup('notes', id, 'alpha', 1)
        setPropertyFromGroup('notes', id, 'multAlpha', 1)
    end
end

-- ============================================================
-- Update
-- ============================================================

function onUpdate(elapsed)
	applyVSliceHealthBarColors()
    if not initialized then return end

    if originalHealthBar then
        setProperty('botplayTxt.visible', false)
        updateVSliceHealthBar(elapsed)
    end
end

-- ============================================================
-- Good Note Hit
-- ============================================================

function goodNoteHit(id, direction, noteType, isSustainNote)
    if isSustainNote then
        currentScoreScrollRate = sustainScoreScrollRate

        if enableSustainReward then
            addHealth(sustainHealth)

            if not (getProperty('cpuControlled') or false) then
                addScore(30)
            end
        end
    else
        currentScoreScrollRate = normalScoreScrollRate
    end
end

-- ============================================================
-- Opponent Notes
-- ============================================================

function opponentNoteHit(id, direction, noteType, isSustainNote)
    if not enableOpponentPush then return end
    if not enableSustainReward and isSustainNote then return end

    local currentHealth = getProperty('health') or 0

    if currentHealth < 0.25 then return end

    local amount = isSustainNote
        and opponentPushSustain
        or opponentPush

    if forceOpponentPush then
        setProperty(
            'health',
            math.max(0.2, currentHealth - amount)
        )
        return
    end

    -- Record the first health value of this batch
    if pendingOpponentPushes.healthBefore == nil then
        pendingOpponentPushes.healthBefore = currentHealth
    end

    pendingOpponentPushes.amount =
        pendingOpponentPushes.amount + amount
end

-- ============================================================
-- Update Post
-- ============================================================

function onUpdatePost(elapsed)
    applyVSliceHealthBarColors()
    if not initialized then return end

    -- Retry score layer adjustment until successful
    if originalHealthBar and originalScoreCreated and not scoreLayerFixed then
        updateScoreLayer()
    end

    -- Opponent Push Detection
    if enableOpponentPush
        and not forceOpponentPush
        and pendingOpponentPushes.healthBefore ~= nil then

        local healthBefore = pendingOpponentPushes.healthBefore
        local totalAmount = pendingOpponentPushes.amount
        local currentHealth = clampHealth(getProperty('health') or 0)

        -- Calculate how much damage the engine already applied
        local engineDamage = math.max(
            0,
            healthBefore - currentHealth
        )

        -- Only compensate for the missing damage
        local missingDamage = math.max(
            0,
            totalAmount - engineDamage
        )

        if missingDamage > 0 then
            setProperty(
                'health',
                math.max(
                    0.2,
                    currentHealth - missingDamage
                )
            )
        end

        pendingOpponentPushes.amount = 0
        pendingOpponentPushes.healthBefore = nil
    end

    -- Custom score text synchronization
    if not originalHealthBar or not originalScoreCreated then
        return
    end

    setObjectCamera(originalScoreTag, 'hud')

    local originalVisible = getProperty('scoreTxt.visible')
    local originalAlpha = getProperty('scoreTxt.alpha')

    if originalVisible == nil then originalVisible = true end
    if originalAlpha == nil then originalAlpha = 1 end

    if readSetting('showCaseMode', false) then
        setProperty(originalScoreTag .. '.visible', false)
        setProperty(originalScoreTag .. '.alpha', 0)
    else
        setProperty(originalScoreTag .. '.visible', originalVisible)
        setProperty(originalScoreTag .. '.alpha', originalAlpha)
    end
end

function noteMiss(id,dtrection,notetype,isSus)
	if not isSus and originalHealthBar then
		playSound(
			'missnote' .. getRandomInt(1, 3),
			1
		)
	end
end
-- ============================================================
-- Destroy
-- ============================================================

function onDestroy()
    -- Clear pending data
    pendingOpponentPushes.amount = 0
    pendingOpponentPushes.healthBefore = nil

    -- Restore NFE UI
    restoreNFEUI()

    -- Restore Botplay text
    if oldBotplayVisible ~= nil then
        pcall(function()
            setProperty('botplayTxt.visible', oldBotplayVisible)
        end)
    end

    -- Restore original score text position
    if oldScoreTxtX ~= nil then
        pcall(function()
            setProperty('scoreTxt.x', oldScoreTxtX)
        end)
    end

    -- Restore health bar positions
    if oldPositions.healthBar ~= nil then
        pcall(function()
            setProperty('healthBar.y', oldPositions.healthBar)
            setProperty('healthBarBG.y', oldPositions.healthBarBG)
            setProperty('iconP1.y', oldPositions.iconP1)
            setProperty('iconP2.y', oldPositions.iconP2)
        end)
    end

    -- Restore Strum positions
    restoreStrums()

    -- Remove custom score text
    if originalScoreCreated then
        removeLuaText(originalScoreTag, true)
        originalScoreCreated = false
    end

    initialized = false
    scoreLayerFixed = false
end