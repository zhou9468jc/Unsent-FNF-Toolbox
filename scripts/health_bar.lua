-- ============================================================
-- Unsent's Health Bar
-- Health Smoothing + V-Slice Health Bar
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

-- ============================================================
-- Internal State
-- ============================================================

local displayHealth = 1
local targetHealth = 1

-- 上一帧由本脚本写入的 health。
-- 用它区分：
-- 1. NFE / 其他脚本真正修改了 health
-- 2. 本脚本自己把 health 写回去
local lastWrittenHealth = 1

local initialized = false

-- V-Slice style score
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
-- V-Slice Health Bar
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

local function setupVSliceHealthBar()
	if not originalHealthBar then
		return
	end

	-- Apply V-Slice colors using NFE's own health bar
	-- color refresh system.
	applyVSliceHealthBarColors()

	-- Hide NFE's original score text.
	setProperty('scoreTxt.visible', false)

	-- Create our own single Score text.
	if not originalScoreCreated then
		makeLuaText(
			originalScoreTag,
			'Score: 0',
			0,
			0,
			0
		)

		-- Font files inside the mod's fonts directory are
		-- referenced by filename only.
		setTextFont(originalScoreTag, 'origin.ttf')

		setTextSize(originalScoreTag, 16)
		setTextColor(originalScoreTag, 'FFFFFF')

		-- No black outline.
		setTextBorder(originalScoreTag, 0, '000000')

		setTextAlignment(originalScoreTag, 'left')

		setObjectCamera(originalScoreTag, 'hud')
		addLuaText(originalScoreTag, true)

		originalScoreCreated = true
	end
end

local function updateVSliceHealthBar()
	if not originalHealthBar then
		return
	end

	if not originalScoreCreated then
		return
	end

	-- Keep the original NFE Score hidden.
	setProperty('scoreTxt.visible', false)

	-- Only display one score.
	local currentScore = getProperty('songScore')

	if currentScore == nil then
		currentScore = 0
	end

	setTextString(
		originalScoreTag,
		'Score: ' .. tostring(currentScore)
	)

	-- NFE creates the health bar at:
	--
	-- normal scroll:
	-- FlxG.height * 0.89
	--
	-- downscroll:
	-- FlxG.height * 0.11
	--
	-- and centers it horizontally.
	--
	-- We intentionally calculate the position instead of reading
	-- healthBar.x / healthBar.width because healthBar is a Haxe Bar.

	local healthBarY

	if getPropertyFromClass('backend.ClientPrefs', 'data.downScroll') then
		healthBarY = screenHeight * 0.11
	else
		healthBarY = screenHeight * 0.89
	end

	-- ========================================================
	-- Score Position
	-- ========================================================
	--
	-- X:
	-- screenWidth / 2 + 200
	--
	-- Y:
	-- healthBarY + 35
	--
	-- Change these values directly if you want to adjust
	-- the Score position.

	setProperty(
		originalScoreTag .. '.x',
		(screenWidth / 2) + 200
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
	enable = readSetting('healthSmooth', true)
	smoothSpeed = readSetting('healthSmoothSpeed', 12)

	sustainHealth = readSetting('healthSustainAmount', 0.010)

	enableOpponentPush = readSetting('healthOpponentPush', false)
	opponentPush = readSetting('healthOpponentPushAmount', 0.018)
	opponentPushSustain = readSetting('healthOpponentPushSustain', 0.006)

	originalHealthBar = readSetting('originalHealthBar', false)

	displayHealth = clampHealth(getProperty('health'))
	targetHealth = displayHealth
	lastWrittenHealth = displayHealth

	initialized = true

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

	-- ========================================================
	-- Health Smoothing
	-- ========================================================

	if enable then
		local realHealth = clampHealth(getProperty('health'))

		-- Detect an actual health change made by the engine
		-- or another script.
		--
		-- We compare against lastWrittenHealth instead of
		-- displayHealth so our own setProperty() call does not
		-- create a fake health change.
		if math.abs(realHealth - lastWrittenHealth) > 0.000001 then
			targetHealth = realHealth
		end

		-- Continuous exponential smoothing.
		--
		-- This does not restart a separate tween for every note.
		-- A stream of notes therefore becomes one continuous
		-- health movement.
		local difference = targetHealth - displayHealth

		if math.abs(difference) > 0.000001 then
			local follow = 1 - math.exp(-smoothSpeed * elapsed)

			displayHealth = displayHealth + difference * follow
		else
			displayHealth = targetHealth
		end

		displayHealth = clampHealth(displayHealth)

		setProperty('health', displayHealth)
		lastWrittenHealth = displayHealth
	else
		-- Smoothing disabled:
		-- completely follow the engine's actual health.
		local realHealth = clampHealth(getProperty('health'))

		displayHealth = realHealth
		targetHealth = realHealth
		lastWrittenHealth = realHealth
	end

	-- ========================================================
	-- V-Slice Health Bar
	-- ========================================================

	if originalHealthBar then
		updateVSliceHealthBar()
	end
end

-- ============================================================
-- Sustain Notes
-- ============================================================

function goodNoteHit(id, direction, noteType, isSustainNote)
	-- IMPORTANT:
	--
	-- Do NOT manually add health here.
	--
	-- NFE already handles the health gain for the note.
	-- Adding sustainHealth here would stack another health gain
	-- on top of the engine's own value.
	--
	-- The smoothing system above automatically detects the
	-- actual health change made by NFE and smooths it.
end

-- ============================================================
-- Opponent Notes
-- ============================================================

function opponentNoteHit(id, direction, noteType, isSustainNote)
	if not enableOpponentPush then
		return
	end

	local amount

	if isSustainNote then
		amount = opponentPushSustain
	else
		amount = opponentPush
	end

	-- Opponent Push has a minimum target health of 0.1.
	--
	-- Once targetHealth reaches 0.1, further opponent notes
	-- will no longer push the target health downward.

	local newTarget = math.max(0.1, targetHealth - amount)

	targetHealth = newTarget
end

-- ============================================================
-- Player Sustain Adjustment
-- ============================================================

function onUpdatePost(elapsed)
	if not initialized then
		return
	end

	-- Nothing is manually added here.
	--
	-- This callback is intentionally kept empty so the health
	-- system does not fight NFE's own note judgement system.
end

-- ============================================================
-- Destroy
-- ============================================================

function onDestroy()
	if originalScoreCreated then
		removeLuaText(originalScoreTag, true)
		originalScoreCreated = false
	end
end