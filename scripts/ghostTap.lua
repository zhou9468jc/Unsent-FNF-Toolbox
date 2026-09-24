-- ============================================================
-- Ghost Tap Punishment
-- NFE 1.2.2 Ghost Tap Detection
-- Optimized Version
-- ============================================================

-- ============================================================
-- Settings
-- ============================================================

local enableGhostTapPunishment =
	getModSetting('ghostTapPunishment')

-- Maximum Ghost Taps allowed within one second.
local ghostTapLimit =
	getModSetting('ghostTapLimit')

-- Normal Miss health damage.
local missHealth = 0.0475

-- Ghost Tap counting window.
local ghostTapWindow = 1.0

-- Show Ghost Tap counter.
local showGhostTapCount =
	getModSetting('showGhostTapCount')

-- Enable the Ghost Tap warning color effect.
local enableGhostTapColor =
	getModSetting('enableGhostTapColor')

-- How quickly the warning color changes.
local ghostColorSmoothSpeed = 8

-- Ghost Tap warning color.
-- RGB values: 0 - 255
-- Default: Red
local ghostColorR = 255
local ghostColorG = 0
local ghostColorB = 0

-- ============================================================
-- Runtime
-- ============================================================

-- Ghost Tap timestamps.
--
-- Instead of table.remove(), this uses a queue head index.
-- This avoids repeatedly shifting the entire table.
local ghostTapTimes = {}
local ghostTapHead = 1

-- Last normal note hit time for each direction.
local lastGoodHitTime = {
	[-1] = -999999,
	[0] = -999999,
	[1] = -999999,
	[2] = -999999,
	[3] = -999999
}

-- Direction -> Miss animation.
local missAnimations = {
	[0] = 'singLEFTmiss',
	[1] = 'singDOWNmiss',
	[2] = 'singUPmiss',
	[3] = 'singRIGHTmiss'
}

-- Original player strum colors.
local originalStrumColors = {
	[0] = 0xFFFFFF,
	[1] = 0xFFFFFF,
	[2] = 0xFFFFFF,
	[3] = 0xFFFFFF
}

-- Cached original RGB values.
--
-- This prevents bit operations from being performed
-- every frame for every strum.
local originalStrumRGB = {
	[0] = {255, 255, 255},
	[1] = {255, 255, 255},
	[2] = {255, 255, 255},
	[3] = {255, 255, 255}
}

-- Current warning-color amount.
-- 0 = original color
-- 1 = maximum warning color
local currentGhostColorAmount = 0

-- Last applied color amount.
--
-- Used to avoid writing the same color to the strums
-- when the resulting RGB values have not changed.
local lastAppliedColorAmount = -1

-- Last Ghost Tap count shown by the debug counter.
local lastDebugGhostCount = -1

-- ============================================================
-- Utility
-- ============================================================

local function getGhostTapCount()
	return #ghostTapTimes - ghostTapHead + 1
end

local function removeExpiredGhostTaps(currentTime)
	local expireTime =
		currentTime
		- ghostTapWindow * 1000

	while ghostTapHead <= #ghostTapTimes do
		if ghostTapTimes[ghostTapHead] > expireTime then
			break
		end

		ghostTapHead = ghostTapHead + 1
	end

	-- Periodically compact the array.
	--
	-- This prevents old entries from staying in memory forever,
	-- while avoiding table.remove() on every expired entry.
	if ghostTapHead > 64
		and ghostTapHead > #ghostTapTimes * 0.5 then

		local newTimes = {}

		for i = ghostTapHead, #ghostTapTimes do
			newTimes[#newTimes + 1] =
				ghostTapTimes[i]
		end

		ghostTapTimes = newTimes
		ghostTapHead = 1
	end
end

local function buildColor(r, g, b)
	return bit.lshift(r, 16)
		+ bit.lshift(g, 8)
		+ b
end

-- ============================================================
-- Create
-- ============================================================

function onCreatePost()
	-- Completely disable the feature.
	if not enableGhostTapPunishment then
		return
	end

	-- Store the original player strum colors.
	if enableGhostTapColor then
		for i = 0, 3 do
			local color = getPropertyFromGroup(
				'playerStrums',
				i,
				'color'
			)

			if color ~= nil then
				originalStrumColors[i] = color

				local r =
					bit.band(
						bit.rshift(color, 16),
						0xFF
					)

				local g =
					bit.band(
						bit.rshift(color, 8),
						0xFF
					)

				local b =
					bit.band(
						color,
						0xFF
					)

				originalStrumRGB[i][1] = r
				originalStrumRGB[i][2] = g
				originalStrumRGB[i][3] = b
			end
		end
	end

	-- Create Ghost Tap counter.
	if showGhostTapCount then
		makeLuaText(
			'ghostTapDebug',
			'Ghost Tap: 0 / ' .. ghostTapLimit,
			0,
			0,
			screenHeight - 100
		)

		setTextSize(
			'ghostTapDebug',
			24
		)

		setTextAlignment(
			'ghostTapDebug',
			'center'
		)

		setObjectCamera(
			'ghostTapDebug',
			'hud'
		)

		addLuaText(
			'ghostTapDebug'
		)

		-- Center only once.
		screenCenter(
			'ghostTapDebug',
			'x'
		)
	end
end

-- ============================================================
-- Normal Note Hit
-- ============================================================

function goodNoteHit(
	id,
	direction,
	noteType,
	isSustainNote
)
	if not enableGhostTapPunishment then
		return
	end

	if isSustainNote then
		return
	end

	lastGoodHitTime[direction] =
		getSongPosition()
end

-- ============================================================
-- Key Press
-- ============================================================

function onKeyPress(key)
	if not enableGhostTapPunishment then
		return
	end

	local currentTime =
		getSongPosition()

	-- Ignore a key press that is immediately associated
	-- with a normal note hit on the same lane.
	if currentTime - lastGoodHitTime[key] > 20 then
		registerGhostTap(
			currentTime,
			key
		)
	end
end

-- ============================================================
-- Register Ghost Tap
-- ============================================================

function registerGhostTap(
	currentTime,
	direction
)
	if not enableGhostTapPunishment then
		return
	end

	-- Remove expired Ghost Taps.
	removeExpiredGhostTaps(
		currentTime
	)

	-- Add this Ghost Tap.
	ghostTapTimes[#ghostTapTimes + 1] =
		currentTime

	-- Punish every Ghost Tap after the limit is exceeded.
	if getGhostTapCount() > ghostTapLimit then
		punishGhostTap(direction)
	end
end

-- ============================================================
-- Ghost Tap Punishment
-- ============================================================

function punishGhostTap(direction)
	-- Apply normal Miss-style health damage.
	-- Health is allowed to reach 0.
	local health =
		getProperty('health')

	setProperty(
		'health',
		math.max(
			0,
			health - missHealth
		)
	)

	-- Play a normal random Miss sound.
	playSound(
		'missnote' .. getRandomInt(1, 3),
		1
	)

	addMisses(1)

	-- Play the corresponding BF Miss animation.
	local animation =
		missAnimations[direction]

	if animation ~= nil then
		characterPlayAnim(
			'boyfriend',
			animation,
			true
		)
	end
end

-- ============================================================
-- Ghost Tap Color
-- ============================================================

local function updateGhostTapColor(elapsed)
	if not enableGhostTapPunishment then
		return
	end

	if not enableGhostTapColor then
		if currentGhostColorAmount ~= 0
			or lastAppliedColorAmount ~= 0 then

			currentGhostColorAmount = 0

			for i = 0, 3 do
				setPropertyFromGroup(
					'playerStrums',
					i,
					'color',
					originalStrumColors[i]
				)
			end

			lastAppliedColorAmount = 0
		end

		return
	end

	local ghostCount =
		getGhostTapCount()

	-- Prevent division by zero if the setting is changed.
	local targetColorAmount = 0

	if ghostTapLimit > 0 then
		targetColorAmount =
			math.min(
				ghostCount / ghostTapLimit,
				1
			)
	end

	-- Smoothly transition the warning color.
	local smoothAmount =
		math.min(
			elapsed * ghostColorSmoothSpeed,
			1
		)

	local oldAmount =
		currentGhostColorAmount

	currentGhostColorAmount =
		oldAmount
		+ (
			targetColorAmount
			- oldAmount
		)
		* smoothAmount

	-- Nothing visibly changed enough to require
	-- another color calculation.
	if math.abs(
		currentGhostColorAmount
		- lastAppliedColorAmount
	) < 0.003 then
		return
	end

	-- Calculate the final RGB values.
	for i = 0, 3 do
		local rgb =
			originalStrumRGB[i]

		local originalR = rgb[1]
		local originalG = rgb[2]
		local originalB = rgb[3]

		local amount =
			currentGhostColorAmount

		local r =
			math.floor(
				originalR * (1 - amount)
				+ ghostColorR * amount
			)

		local g =
			math.floor(
				originalG * (1 - amount)
				+ ghostColorG * amount
			)

		local b =
			math.floor(
				originalB * (1 - amount)
				+ ghostColorB * amount
			)

		local newColor =
			buildColor(r, g, b)

		setPropertyFromGroup(
			'playerStrums',
			i,
			'color',
			newColor
		)
	end

	lastAppliedColorAmount =
		currentGhostColorAmount
end

-- ============================================================
-- Update
-- ============================================================

function onUpdate(elapsed)
	if not enableGhostTapPunishment then
		return
	end

	local currentTime =
		getSongPosition()

	-- Remove expired Ghost Taps.
	removeExpiredGhostTaps(
		currentTime
	)

	local ghostCount =
		getGhostTapCount()

	-- Update Ghost Tap counter only when
	-- the displayed number actually changes.
	if showGhostTapCount
		and ghostCount ~= lastDebugGhostCount then

		setTextString(
			'ghostTapDebug',
			'Ghost Tap: '
				.. ghostCount
				.. ' / '
				.. ghostTapLimit
		)

		lastDebugGhostCount =
			ghostCount
	end

	-- Update warning color.
	updateGhostTapColor(
		elapsed
	)
end

-- ============================================================
-- Destroy
-- ============================================================

function onDestroy()
	ghostTapTimes = {}
	ghostTapHead = 1

	-- Restore original player strum colors.
	if enableGhostTapPunishment
		and enableGhostTapColor then

		for i = 0, 3 do
			setPropertyFromGroup(
				'playerStrums',
				i,
				'color',
				originalStrumColors[i]
			)
		end
	end
end