
-- ============================================================
-- Unsent's Health Bar
-- Health Smoothing + V-Slice Health Bar
-- Smooth Score Display
-- ============================================================

-- Settings
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

-- Internal State
local initialized = false
local displayScore = 0
local targetScore = 0

local originalScoreTag = 'unsentOriginalScore'
local originalScoreCreated = false
local scoreLayerFixed = false

-- Opponent Push Detection
local pendingOpponentPushes = {}

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

-- ============================================================
-- V-Slice Health Bar
-- ============================================================

local function applyVSliceHealthBarColors()
	if not originalHealthBar then return end
	setHealthBarColors('FF0000', '00FF00')
end

local function updateScoreLayer()
	if not originalScoreCreated or scoreLayerFixed then return end

	runHaxeCode([[
		var scoreObj = game.getLuaObject('unsentOriginalScore');

		if (scoreObj != null && game.noteGroup != null)
		{
			scoreObj.cameras = [game.camHUD];

			var noteIndex = game.members.indexOf(game.noteGroup);
			var scoreIndex = game.members.indexOf(scoreObj);

			if (noteIndex >= 0 && scoreIndex >= 0)
			{
				var desiredIndex = noteIndex - 1;

				if (scoreIndex != desiredIndex)
				{
					game.remove(scoreObj, false);
					noteIndex = game.members.indexOf(game.noteGroup);

					if (noteIndex >= 0)
						game.insert(noteIndex, scoreObj);
				}
			}
		}
	]])

	scoreLayerFixed = true
end

local function setupVSliceHealthBar()
	if not originalHealthBar then return end
	addLuaScript("extraScript/changeNoteSplash.lua",true)
	setProperty('scoreTxt.visible', false)

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

local strumMoved = false
function onCountdownTick(cou)
	if cou ~= 0 or strumMoved then return end
	if not originalHealthBar then return end
	for i = 0, 3 do
		setPropertyFromGroup('strumLineNotes', i, 'x', getPropertyFromGroup('strumLineNotes', i, 'x') - 50)
	end
	for i = 4, 7 do
		setPropertyFromGroup('strumLineNotes', i, 'x', getPropertyFromGroup('strumLineNotes', i, 'x') - 40)
	end
end
-- ============================================================
-- Smooth Score Display
-- ============================================================

local function updateVSliceHealthBar(elapsed)
	if not originalHealthBar or not originalScoreCreated then return end

	setProperty('scoreTxt.visible', false)

	local realScore = getProperty('songScore') or 0
	targetScore = realScore

	local scoreDifference = targetScore - displayScore

	if math.abs(scoreDifference) > 0.5 then
		local effectiveSpeed = scoreScrollSpeed * currentScoreScrollRate
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
		setTextString(originalScoreTag, 'Score: ' .. formatNumber(shownScore))
	end

	local healthBarY

	if getPropertyFromClass('backend.ClientPrefs', 'data.downScroll') then
		healthBarY = screenHeight * 0.11
	else
		healthBarY = screenHeight * 0.89
	end

	setProperty(originalScoreTag .. '.x', (screenWidth / 2) + 100)
	setProperty(originalScoreTag .. '.y', healthBarY + 38)
end

-- ============================================================
-- Create
-- ============================================================

function onCreate()
	enable = readSetting('healthSmooth', false)
	sustainHealth = readSetting('healthSustainAmount', 0.008)

	enableOpponentPush = readSetting('healthOpponentPush', false)
	opponentPush = readSetting('healthOpponentPushAmount', 0.018)
	opponentPushSustain = readSetting('healthOpponentPushSustain', 0.007)

	forceOpponentPush = readSetting('healthOpponentPushForce', false)
	originalHealthBar = readSetting('originalHealthBar', false)
	enableSustainReward = readSetting('healthSustainReward', false)

	displayScore = getProperty('songScore') or 0
	targetScore = displayScore
	currentScoreScrollRate = 1
	initialized = true

	if originalHealthBar then
		setupVSliceHealthBar()
	end

	if enable then
		addLuaScript('extraScript/lerp.lua', true)
	end
end

local originalAlpha = nil
function onCreatePost()
	if not initialized or not originalHealthBar or not originalScoreCreated then
		return
	end
	if originalHealthBar then
		local value = 10
		setProperty('healthBar.y', getProperty('healthBar.y') + value)
		setProperty('healthBarBG.y', getProperty('healthBarBG.y') + value)
		setProperty('iconP1.y', getProperty('iconP1.y') + value)
		setProperty('iconP2.y', getProperty('iconP2.y') + value)
	end
	updateScoreLayer()
end

-- ============================================================
-- Update
-- ============================================================

function onUpdate(elapsed)
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
			addHealth(sustainHealth/2)
			addHealth(sustainHealth/2) --只是看着更平滑

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

	local currentHealth = getProperty('health')
	if currentHealth ~= nil and currentHealth < 0.25 then return end

	local amount = isSustainNote and opponentPushSustain or opponentPush

	if forceOpponentPush then
		setProperty('health', math.max(0.2, (getProperty('health') or 0) - amount))
		return
	end

	table.insert(pendingOpponentPushes, {
		amount = amount,
		healthBefore = currentHealth
	})
end

-- ============================================================
-- Update Post
-- ============================================================

function onUpdatePost(elapsed)
	if not initialized then return end
	applyVSliceHealthBarColors()
	-- Opponent Push Detection
	if enableOpponentPush and not forceOpponentPush and #pendingOpponentPushes > 0 then
		local currentHealth = clampHealth(getProperty('health') or 0)
		local engineHealthChanged = false

		for i = 1, #pendingOpponentPushes do
			local pending = pendingOpponentPushes[i]

			if currentHealth < pending.healthBefore - 0.000001 then
				engineHealthChanged = true
				break
			end
		end

		if not engineHealthChanged then
			local totalAmount = 0

			for i = 1, #pendingOpponentPushes do
				totalAmount = totalAmount + pendingOpponentPushes[i].amount
			end

			local health = getProperty('health') or 0
			setProperty('health', math.max(0.2, health - totalAmount))
		end

		pendingOpponentPushes = {}
	end

	-- V-Slice Score
	if not originalHealthBar or not originalScoreCreated then return end

	setObjectCamera(originalScoreTag, 'hud')

	if readSetting('showCaseMode', false) then
		setProperty(originalScoreTag .. '.visible', false)
		setProperty(originalScoreTag .. '.alpha', 0)
	else
		setProperty(originalScoreTag .. '.visible', true)
		setProperty(originalScoreTag .. '.alpha', getProperty('scoreTxt.alpha'))
	end
end

-- ============================================================
-- Destroy
-- ============================================================

function onDestroy()
	pendingOpponentPushes = {}

	if originalScoreCreated then
		removeLuaText(originalScoreTag, true)
		originalScoreCreated = false
	end
end
