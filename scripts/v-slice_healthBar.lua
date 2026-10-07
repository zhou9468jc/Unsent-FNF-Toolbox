-- ============================================================
-- Unsent's Health Bar
-- Health Smoothing + V-Slice Health Bar
-- Smooth Score Display
-- ============================================================

-- ============================================================
-- Settings
-- ============================================================

local enable = getModSetting('healthSmooth')
local smoothSpeed = getModSetting('healthSmoothSpeed')
local sustainHealth = getModSetting('healthSustainAmount')

local enableOpponentPush = getModSetting('healthOpponentPush')
local opponentPush = getModSetting('healthOpponentPushAmount')
local opponentPushSustain = getModSetting('healthOpponentPushSustain')

local forceOpponentPush = getModSetting('healthOpponentPushForce')

local originalHealthBar = getModSetting('originalHealthBar')
local enableSustainReward = getModSetting('healthSustainReward')

local isShowcase = getModSetting('showCaseMode')

-- ============================================================
-- Score Scroll Settings
-- ============================================================

local normalScoreScrollRate = 2
local sustainScoreScrollRate = 1
local scoreScrollSpeed = 12
local currentScoreScrollRate = 1

-- ============================================================
-- Internal State
-- ============================================================

local displayHealth = 1
local targetHealth = 1
local lastWrittenHealth = 1

local initialized = false

local displayScore = 0
local targetScore = 0

local originalScoreTag = 'unsentOriginalScore'
local originalScoreCreated = false

-- Score layer only needs to be fixed once.
local scoreLayerFixed = false

-- ============================================================
-- Opponent Push Detection
-- ============================================================

local pendingOpponentPushes = {}

-- ============================================================
-- Utility
-- ============================================================

local function clampHealth(value)
	if value < 0 then
		return 0
	end

	if value > 2 then
		return 2
	end

	return value
end

local function readSetting(name, default)
	local value = getModSetting(name)

	if value == nil then
		return default
	end

	return value
end

-- ============================================================
-- V-Slice Health Bar Colors
-- ============================================================

local function applyVSliceHealthBarColors()
	if not originalHealthBar then
		return
	end

	runHaxeCode([[
		if (game.healthBar != null)
		{
			game.healthBar.leftBar.color = FlxColor.RED;
			game.healthBar.rightBar.color = FlxColor.GREEN;
		}
	]])
end

-- ============================================================
-- Score Layer
--
-- Score stays on camHUD.
--
-- It is placed immediately before noteGroup:
--
-- HUD Elements
--      ↓
-- Score
--      ↓
-- noteGroup
--      ↓
-- Strums / Notes / Sustain
--
-- This is done only once.
-- ============================================================

local function updateScoreLayer()
	if not originalScoreCreated then
		return
	end

	if scoreLayerFixed then
		return
	end

	runHaxeCode([[
		var scoreObj = game.getLuaObject('unsentOriginalScore');

		if (scoreObj != null && game.noteGroup != null)
		{
			scoreObj.cameras = [game.camHUD];

			var noteIndex = game.members.indexOf(game.noteGroup);
			var scoreIndex = game.members.indexOf(scoreObj);

			if (noteIndex >= 0 && scoreIndex >= 0)
			{
				// We want the score directly before noteGroup.
				var desiredIndex = noteIndex - 1;

				if (scoreIndex != desiredIndex)
				{
					// IMPORTANT:
					// false = remove from display list WITHOUT destroying
					// the Lua text object.
					game.remove(scoreObj, false);

					// Recalculate the noteGroup index because removing
					// the score may have shifted the array.
					noteIndex = game.members.indexOf(game.noteGroup);

					if (noteIndex >= 0)
					{
						game.insert(noteIndex, scoreObj);
					}
				}
			}
		}
	]])

	scoreLayerFixed = true
end

-- ============================================================
-- V-Slice Health Bar Setup
-- ============================================================

local function setupVSliceHealthBar()
	if not originalHealthBar then
		return
	end

	applyVSliceHealthBarColors()

	setProperty(
		'scoreTxt.visible',
		false
	)

	if not originalScoreCreated then
		makeLuaText(
			originalScoreTag,
			'Score: 0',
			0,
			0,
			0
		)

		setTextFont(
			originalScoreTag,
			'origin.ttf'
		)

		setTextSize(
			originalScoreTag,
			16
		)

		setTextColor(
			originalScoreTag,
			'FFFFFF'
		)

		setTextBorder(
			originalScoreTag,
			1,
			'000000'
		)

		setTextAlignment(
			originalScoreTag,
			'left'
		)

		setObjectCamera(
			originalScoreTag,
			'hud'
		)

		addLuaText(
			originalScoreTag,
			true
		)

		setProperty(
			originalScoreTag .. '.letterSpacing',
			1.2
		)

		originalScoreCreated = true
		scoreLayerFixed = false
	end
end

-- ============================================================
-- Number Format
-- ============================================================

local function formatNumber(num)
	local str = tostring(num)
	local formatted = str

	while true do
		local count

		formatted, count = string.gsub(
			formatted,
			"^(-?%d+)(%d%d%d)",
			"%1,%2"
		)

		if count == 0 then
			break
		end
	end

	return formatted
end

-- ============================================================
-- V-Slice Health Bar + Smooth Score
-- ============================================================

local function updateVSliceHealthBar(elapsed)
	if not originalHealthBar then
		return
	end

	if not originalScoreCreated then
		return
	end

	setProperty(
		'scoreTxt.visible',
		false
	)

	-- ========================================================
	-- Smooth Score
	-- ========================================================

	local realScore = getProperty('songScore')

	if realScore == nil then
		realScore = 0
	end

	targetScore = realScore

	local scoreDifference =
		targetScore - displayScore

	if math.abs(scoreDifference) > 0.5 then
		local effectiveSpeed =
			scoreScrollSpeed * currentScoreScrollRate

		local follow =
			1 - math.exp(
				-effectiveSpeed * elapsed
			)

		displayScore =
			displayScore + scoreDifference * follow
	else
		displayScore = targetScore
	end

	local shownScore =
		math.floor(displayScore + 0.5)

	local isBotplay =
		getProperty('cpuControlled') or false

	local changeBotText =
		readSetting('showBotText', true)

	if isBotplay == true and changeBotText == true then
		setTextString(
			originalScoreTag,
			'Bot Play Enabled'
		)
	else
		setTextString(
			originalScoreTag,
			'Score: ' .. formatNumber(shownScore)
		)
	end

	-- ========================================================
	-- Position
	-- ========================================================

	local healthBarY

	if getPropertyFromClass(
		'backend.ClientPrefs',
		'data.downScroll'
	) then
		healthBarY = screenHeight * 0.11
	else
		healthBarY = screenHeight * 0.89
	end

	setProperty(
		originalScoreTag .. '.x',
		(screenWidth / 2) + 100
	)

	setProperty(
		originalScoreTag .. '.y',
		healthBarY + 38
	)
end

-- ============================================================
-- Create
-- ============================================================

function onCreate()
	enable = readSetting(
		'healthSmooth',
		false
	)

	smoothSpeed = readSetting(
		'healthSmoothSpeed',
		12
	)

	sustainHealth = readSetting(
		'healthSustainAmount',
		0.008
	)

	enableOpponentPush = readSetting(
		'healthOpponentPush',
		false
	)

	opponentPush = readSetting(
		'healthOpponentPushAmount',
		0.020
	)

	opponentPushSustain = readSetting(
		'healthOpponentPushSustain',
		0.007
	)

	forceOpponentPush = readSetting(
		'healthOpponentPushForce',
		false
	)

	originalHealthBar = readSetting(
		'originalHealthBar',
		false
	)

	isShowcase = readSetting(
		'showCaseMode',
		false
	)

	-- ========================================================
	-- Initialize Health
	-- ========================================================

	displayHealth =
		clampHealth(
			getProperty('health')
		)

	targetHealth = displayHealth
	lastWrittenHealth = displayHealth

	-- ========================================================
	-- Initialize Score
	-- ========================================================

	displayScore =
		getProperty('songScore') or 0

	targetScore = displayScore
	currentScoreScrollRate = 1

	initialized = true

	-- ========================================================
	-- Setup
	-- ========================================================

	if originalHealthBar then
		setupVSliceHealthBar()
	end
end

-- ============================================================
-- Create Post
--
-- The noteGroup already exists here, so the score can be
-- placed in its correct layer without doing it every frame.
-- ============================================================

function onCreatePost()
	if not initialized then
		return
	end

	if not originalHealthBar then
		return
	end

	if not originalScoreCreated then
		return
	end

	updateScoreLayer()
end

-- ============================================================
-- Update
-- ============================================================

function onUpdate(elapsed)
	if not initialized then
		return
	end

	if originalHealthBar == true then
		setProperty(
			'botplayTxt.visible',
			false
		)
	end

	-- ========================================================
	-- Health Smoothing
	-- ========================================================

	if enable then
		local realHealth =
			clampHealth(
				getProperty('health')
			)

		if math.abs(
			realHealth - lastWrittenHealth
		) > 0.000001 then

			targetHealth = realHealth

			if realHealth <= 0 then
				displayHealth = 0
				targetHealth = 0

				setProperty(
					'health',
					0
				)

				lastWrittenHealth = 0

				if originalHealthBar then
					updateVSliceHealthBar(elapsed)
				end

				return
			end
		end

		local difference =
			targetHealth - displayHealth

		if math.abs(difference) > 0.000001 then
			local follow =
				1 - math.exp(
					-smoothSpeed * elapsed
				)

			displayHealth =
				displayHealth + difference * follow
		else
			displayHealth = targetHealth
		end

		displayHealth =
			clampHealth(displayHealth)

		setProperty(
			'health',
			displayHealth
		)

		lastWrittenHealth = displayHealth
	else
		local realHealth =
			clampHealth(
				getProperty('health')
			)

		displayHealth = realHealth
		targetHealth = realHealth
		lastWrittenHealth = realHealth
	end

	-- ========================================================
	-- V-Slice HUD
	-- ========================================================

	if originalHealthBar then
		updateVSliceHealthBar(elapsed)
	end
end

-- ============================================================
-- Good Note Hit
-- ============================================================

function goodNoteHit(
	id,
	direction,
	noteType,
	isSustainNote
)
	if isSustainNote then
		local isBotplay =
			getProperty('cpuControlled') or false

		currentScoreScrollRate =
			sustainScoreScrollRate

		if enableSustainReward then
			addHealth(sustainHealth)

			if isBotplay == false then
				addScore(30)
			end
		end
	else
		currentScoreScrollRate =
			normalScoreScrollRate
	end
end

-- ============================================================
-- Opponent Notes
-- ============================================================

function opponentNoteHit(
	id,
	direction,
	noteType,
	isSustainNote
)
	if not enableOpponentPush then
		return
	end

	local currentHealth =
		getProperty('health')

	if currentHealth ~= nil
		and currentHealth < 0.25 then
		return
	end

	local amount

	if isSustainNote then
		amount = opponentPushSustain
	else
		amount = opponentPush
	end

	if forceOpponentPush then
		targetHealth =
			math.max(
				0.25,
				targetHealth - amount
			)

		return
	end

	table.insert(
		pendingOpponentPushes,
		{
			amount = amount,
			targetBefore = targetHealth,
			healthBefore = currentHealth
		}
	)
end

-- ============================================================
-- Update Post
-- ============================================================

function onUpdatePost()
	if not initialized then
		return
	end

	-- ========================================================
	-- External Opponent Push Detection
	-- ========================================================

	if enableOpponentPush
		and not forceOpponentPush then

		if #pendingOpponentPushes > 0 then
			local currentHealth =
				clampHealth(
					getProperty('health')
				)

			local currentTarget =
				targetHealth

			for i = 1, #pendingOpponentPushes do
				local pending =
					pendingOpponentPushes[i]

				local externalChanged = false

				if currentHealth <
					pending.healthBefore - 0.000001 then

					externalChanged = true
				end

				if currentTarget <
					pending.targetBefore - 0.000001 then

					externalChanged = true
				end

				if not externalChanged then
					targetHealth =
						math.max(
							0.25,
							targetHealth - pending.amount
						)
				end
			end

			pendingOpponentPushes = {}
		end
	end

	-- ========================================================
	-- V-Slice Score
	-- ========================================================

	if not originalHealthBar
		or not originalScoreCreated then
		return
	end

	-- Keep the camera on HUD.
	-- DO NOT reorder the object here.
	setObjectCamera(
		originalScoreTag,
		'hud'
	)

	if getModSetting('showCaseMode') then
		setProperty(
			originalScoreTag .. '.visible',
			false
		)

		setProperty(
			originalScoreTag .. '.alpha',
			0
		)
	else
		setProperty(
			originalScoreTag .. '.visible',
			true
		)

		setProperty(
			originalScoreTag .. '.alpha',
			getProperty('scoreTxt.alpha')
		)
	end
end

-- ============================================================
-- Destroy
-- ============================================================

function onDestroy()
	pendingOpponentPushes = {}

	if originalScoreCreated then
		removeLuaText(
			originalScoreTag,
			true
		)

		originalScoreCreated = false
	end
end