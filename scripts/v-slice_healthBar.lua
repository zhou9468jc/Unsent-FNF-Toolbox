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

local originalHealthBar = getModSetting('originalHealthBar')
local enableSustainReward = getModSetting('healthSustainReward')

local isShowcase = getModSetting('showCaseMode')

-- ============================================================
-- Score Scroll Settings
-- ============================================================
-- 普通点击音符的分数滚动速度倍率
-- 2 = 普通速度的 2 倍
local normalScoreScrollRate = 2

-- 长按音符的分数滚动速度倍率
-- 1 = 普通速度
local sustainScoreScrollRate = 1

-- 基础分数滚动速度
-- 数值越大，分数追赶目标越快
local scoreScrollSpeed = 12

-- 当前分数滚动倍率
local currentScoreScrollRate = 1

-- ============================================================
-- Internal State
-- ============================================================

local displayHealth = 1
local targetHealth = 1
local lastWrittenHealth = 1

local initialized = false

-- Smooth score
local displayScore = 0
local targetScore = 0

-- Original score replacement
local originalScoreTag = 'unsentOriginalScore'
local originalScoreCreated = false

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

		originalScoreCreated = true
	end
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
		-- 根据当前音符类型使用不同的滚动速度
		local effectiveSpeed =
			scoreScrollSpeed * currentScoreScrollRate

		local follow =
			1 - math.exp(-effectiveSpeed * elapsed)

		displayScore =
			displayScore + scoreDifference * follow
	else
		displayScore = targetScore
	end

	-- 防止显示小数
	local shownScore =
		math.floor(displayScore + 0.5)
		local isBotplay = getProperty('cpuControlled') or false
		local changeBotText = readSetting('showBotText',true)
	if isBotplay == true and changeBotText == true then
		setTextString(
			originalScoreTag,
			"Bot Play Enabled"
		)
	else
		setTextString(
			originalScoreTag,
			'Score: ' .. tostring(shownScore)
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
		healthBarY + 35
	)
end

-- ============================================================
-- Create
-- ============================================================

function onCreate()
	-- ========================================================
	-- Load Settings
	-- ========================================================

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

	displayHealth = clampHealth(
		getProperty('health')
	)

	targetHealth = displayHealth
	lastWrittenHealth = displayHealth

	-- ========================================================
	-- Initialize Score
	-- ========================================================

	displayScore = getProperty('songScore') or 0
	targetScore = displayScore

	currentScoreScrollRate = 1

	initialized = true

	-- ========================================================
	-- Setup V-Slice Health Bar
	-- ========================================================

	if originalHealthBar then
		setupVSliceHealthBar()
	end
end

-- ============================================================
-- Update
-- ============================================================

function onUpdate(elapsed)
	if not initialized then
		return
	end
	if originalHealthBar == true then
		setProperty('botplayTxt.visible',false)
	end
	-- ========================================================
	-- Health Smoothing
	-- ========================================================

	if enable then
		local realHealth = clampHealth(
			getProperty('health')
		)

		-- Detect external health changes
		if math.abs(
			realHealth - lastWrittenHealth
		) > 0.000001 then

			targetHealth = realHealth

			-- =================================================
			-- Immediate Death
			-- =================================================

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

		-- Smooth health movement
		local difference =
			targetHealth - displayHealth

		if math.abs(difference) > 0.000001 then
			local follow =
				1 - math.exp(-smoothSpeed * elapsed)

			displayHealth =
				displayHealth + difference * follow
		else
			displayHealth = targetHealth
		end

		displayHealth = clampHealth(
			displayHealth
		)

		setProperty(
			'health',
			displayHealth
		)

		lastWrittenHealth = displayHealth
	else
		-- Smoothing disabled
		local realHealth = clampHealth(
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
		-- 长按：使用普通分数滚动速度
		local isBotplay = getProperty('cpuControlled') or false
		currentScoreScrollRate = sustainScoreScrollRate

		if enableSustainReward then
			addHealth(sustainHealth)
			if isBotplay == false then
				addScore(30)
			end
		end
	else
		-- 普通点击：使用更快的分数滚动速度
		currentScoreScrollRate = normalScoreScrollRate
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

	local amount

	if isSustainNote then
		amount = opponentPushSustain
	else
		amount = opponentPush
	end

	local newTarget =
		math.max(
			0.1,
			targetHealth - amount
		)

	targetHealth = newTarget
end

-- ============================================================
-- Update Post
-- ============================================================

function onUpdatePost()
	if not initialized then
		return
	end

	if not originalHealthBar or not originalScoreCreated then
		return
	end

	if getModSetting('showCaseMode') then
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
	if originalScoreCreated then
		removeLuaText(
			originalScoreTag,
			true
		)

		originalScoreCreated = false
	end
end