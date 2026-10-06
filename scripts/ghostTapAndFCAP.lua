-- ============================================================
-- Unsent's Ghost Tap + FC/AP + BotPlay + Practice Indicator
-- NFE 1.2.2
--
-- Color Priority:
-- 1. Ghost Tap Warning
-- 2. BotPlay Permanent Lock
-- 3. Practice Permanent Lock
-- 4. FC/AP Indicator
-- 5. Original Strum Color
--
-- FC/AP / BotPlay / Practice state detection:
-- onUpdatePost() only
-- ============================================================


-- ============================================================
-- Settings
-- ============================================================

local enableGhostTapPunishment =
	getModSetting('ghostTapPunishment')

local ghostTapLimit =
	getModSetting('ghostTapLimit')

local enableGhostTapColor =
	getModSetting('enableGhostTapColor')

local showGhostTapCount =
	getModSetting('showGhostTapCount')

local enableIndicator =
	getModSetting('fcApIndicator')

if enableIndicator == nil then
	enableIndicator = true
end


-- ============================================================
-- Ghost Tap Settings
-- ============================================================

local missHealth = 0.0475
local ghostTapWindow = 1.0

local ghostColorSmoothSpeed = 8

local ghostColorR = 255
local ghostColorG = 0
local ghostColorB = 0


-- ============================================================
-- FC/AP Settings
-- ============================================================

local indicatorColorSmoothSpeed = 18

local goldR = 255
local goldG = 215
local goldB = 0

local blueR = 77
local blueG = 166
local blueB = 255


-- ============================================================
-- Practice Settings
-- ============================================================

local practiceR = 0
local practiceG = 220
local practiceB = 200


-- ============================================================
-- BotPlay Settings
-- ============================================================

local botplayR = 190
local botplayG = 80
local botplayB = 255


-- ============================================================
-- Runtime
-- ============================================================

local ghostTapTimes = {}
local ghostTapHead = 1

local firstNoteHit = false

local currentGhostColorAmount = 0
local lastAppliedColorAmount = -1

local ghostTapWasActive = false

local currentIndicatorState = -1
local indicatorTransitionActive = false

-- Once enabled, these remain true for the rest of the song.
local botplayEverUsed = false
local practiceEverUsed = false


-- ============================================================
-- Original Colors
-- ============================================================

local originalStrumColors = {
	[0] = 0xFFFFFF,
	[1] = 0xFFFFFF,
	[2] = 0xFFFFFF,
	[3] = 0xFFFFFF
}

local originalStrumRGB = {
	[0] = {255, 255, 255},
	[1] = {255, 255, 255},
	[2] = {255, 255, 255},
	[3] = {255, 255, 255}
}


-- ============================================================
-- Current Displayed Colors
-- ============================================================

local currentStrumRGB = {
	[0] = {255, 255, 255},
	[1] = {255, 255, 255},
	[2] = {255, 255, 255},
	[3] = {255, 255, 255}
}


-- ============================================================
-- Target Colors
-- ============================================================

local targetStrumRGB = {
	[0] = {255, 255, 255},
	[1] = {255, 255, 255},
	[2] = {255, 255, 255},
	[3] = {255, 255, 255}
}


-- ============================================================
-- Last Good Hit Time
-- ============================================================

local lastGoodHitTime = {
	[-1] = -999999,
	[0] = -999999,
	[1] = -999999,
	[2] = -999999,
	[3] = -999999
}


-- ============================================================
-- Miss Animations
-- ============================================================

local missAnimations = {
	[0] = 'singLEFTmiss',
	[1] = 'singDOWNmiss',
	[2] = 'singUPmiss',
	[3] = 'singRIGHTmiss'
}


local lastDebugGhostCount = -1


-- ============================================================
-- Color Utility
-- ============================================================

local function clampColor(value)
	return math.max(
		0,
		math.min(
			255,
			math.floor(value + 0.5)
		)
	)
end


local function buildColor(r, g, b)
	return bit.lshift(
		clampColor(r),
		16
	)
		+ bit.lshift(
			clampColor(g),
			8
		)
		+ clampColor(b)
end


local function applyCurrentStrumColor(i)
	local rgb =
		currentStrumRGB[i]

	setPropertyFromGroup(
		'playerStrums',
		i,
		'color',
		buildColor(
			rgb[1],
			rgb[2],
			rgb[3]
		)
	)
end


local function setCurrentStrumColor(i, r, g, b)
	local rgb =
		currentStrumRGB[i]

	rgb[1] = r
	rgb[2] = g
	rgb[3] = b

	applyCurrentStrumColor(i)
end


-- ============================================================
-- Ghost Tap Utility
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

		ghostTapHead =
			ghostTapHead + 1
	end

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


-- ============================================================
-- Create
-- ============================================================

function onCreatePost()
	for i = 0, 3 do
		local color =
			getPropertyFromGroup(
				'playerStrums',
				i,
				'color'
			)

		if color ~= nil then
			originalStrumColors[i] =
				color

			local r =
				bit.band(
					bit.rshift(
						color,
						16
					),
					0xFF
				)

			local g =
				bit.band(
					bit.rshift(
						color,
						8
					),
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

			currentStrumRGB[i][1] = r
			currentStrumRGB[i][2] = g
			currentStrumRGB[i][3] = b

			targetStrumRGB[i][1] = r
			targetStrumRGB[i][2] = g
			targetStrumRGB[i][3] = b
		end
	end

	if enableGhostTapPunishment
		and showGhostTapCount then

		makeLuaText(
			'ghostTapDebug',
			'Ghost Tap: 0 / '
				.. ghostTapLimit,
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

		screenCenter(
			'ghostTapDebug',
			'x'
		)
	end
end


-- ============================================================
-- Successful Note Hit
-- ============================================================

function goodNoteHit(
	id,
	direction,
	noteType,
	isSustainNote
)
	if enableIndicator then
		firstNoteHit = true
	end

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

	if currentTime
		- lastGoodHitTime[key] > 20 then

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

	removeExpiredGhostTaps(
		currentTime
	)

	ghostTapTimes[#ghostTapTimes + 1] =
		currentTime

	if getGhostTapCount() > ghostTapLimit then
		punishGhostTap(direction)
	end
end


-- ============================================================
-- Ghost Tap Punishment
-- ============================================================

function punishGhostTap(direction)
	local health =
		getProperty('health')

	-- 扣血
	setProperty(
		'health',
		math.max(
			0,
			health - missHealth
		)
	)

	-- Miss 音效
	playSound(
		'missnote' .. getRandomInt(1, 3),
		1
	)

	-- 记一次真正的 Miss
	addMisses(1)

	-- 断连击
	setProperty(
		'combo',
		0
	)

	-- Ghost Tap 已经算一次 Miss
	-- 立即让 FC/AP 状态重新检测
	if enableIndicator then
		currentIndicatorState = -1
		indicatorTransitionActive = true
		firstNoteHit = true
	end

	-- 触发 Miss 回调
	callOnLuas(
		'noteMiss',
		0,
		direction,
		'',
		false
	)

	-- 播放 Miss 动画
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
	if not enableGhostTapPunishment
		or not enableGhostTapColor then

		currentGhostColorAmount = 0
		lastAppliedColorAmount = -1
		ghostTapWasActive = false

		return
	end

	local ghostCount =
		getGhostTapCount()

	local targetAmount = 0

	if ghostTapLimit > 0 then
		targetAmount =
			math.min(
				ghostCount / ghostTapLimit,
				1
			)
	end

	local smoothAmount =
		math.min(
			elapsed
			* ghostColorSmoothSpeed,
			1
		)

	currentGhostColorAmount =
		currentGhostColorAmount
		+ (
			targetAmount
			- currentGhostColorAmount
		)
		* smoothAmount

	if currentGhostColorAmount > 0.003 then
		ghostTapWasActive = true

		if math.abs(
			currentGhostColorAmount
			- lastAppliedColorAmount
		) < 0.003 then

			return
		end

		for i = 0, 3 do
			local original =
				originalStrumRGB[i]

			local amount =
				currentGhostColorAmount

			local r =
				original[1]
				+ (
					ghostColorR
					- original[1]
				)
				* amount

			local g =
				original[2]
				+ (
					ghostColorG
					- original[2]
				)
				* amount

			local b =
				original[3]
				+ (
					ghostColorB
					- original[3]
				)
				* amount

			setCurrentStrumColor(
				i,
				r,
				g,
				b
			)
		end

		lastAppliedColorAmount =
			currentGhostColorAmount

		return
	end

	if ghostTapWasActive then
		ghostTapWasActive = false
		currentGhostColorAmount = 0
		lastAppliedColorAmount = -1

		indicatorTransitionActive = true
	end
end


-- ============================================================
-- Detect Indicator State
--
-- 0 = Original
-- 1 = Gold / AP
-- 2 = Blue / FC
-- 3 = Cyan / Practice
-- 4 = Purple / BotPlay
-- ============================================================

local function detectIndicatorState()
	if botplayEverUsed then
		return 4
	end

	if practiceEverUsed then
		return 3
	end

	local misses =
		getProperty('songMisses') or 0

	local accuracy =
		getProperty('ratingPercent') or 0

	-- 还没有成功击中过第一颗玩家 Note
	if not firstNoteHit then
		return 1
	end

	-- 只要有过 Miss，就绝对不能再显示 Gold
	if misses > 0 then
		return 0
	end

	if accuracy >= 0.999999 then
		return 1
	end

	return 2
end


-- ============================================================
-- Set Indicator Target
-- ============================================================

local function setIndicatorTarget(state)
	for i = 0, 3 do
		if state == 1 then
			-- Gold
			targetStrumRGB[i][1] =
				goldR

			targetStrumRGB[i][2] =
				goldG

			targetStrumRGB[i][3] =
				goldB

		elseif state == 2 then
			-- Blue
			targetStrumRGB[i][1] =
				blueR

			targetStrumRGB[i][2] =
				blueG

			targetStrumRGB[i][3] =
				blueB

		elseif state == 3 then
			-- Cyan / Practice
			targetStrumRGB[i][1] =
				practiceR

			targetStrumRGB[i][2] =
				practiceG

			targetStrumRGB[i][3] =
				practiceB

		elseif state == 4 then
			-- Purple / BotPlay
			targetStrumRGB[i][1] =
				botplayR

			targetStrumRGB[i][2] =
				botplayG

			targetStrumRGB[i][3] =
				botplayB

		else
			-- Original
			targetStrumRGB[i][1] =
				originalStrumRGB[i][1]

			targetStrumRGB[i][2] =
				originalStrumRGB[i][2]

			targetStrumRGB[i][3] =
				originalStrumRGB[i][3]
		end
	end
end


-- ============================================================
-- Smooth Indicator Transition
-- ============================================================

local function updateIndicatorColor(elapsed)
	if not enableIndicator then
		return
	end

	if ghostTapWasActive then
		return
	end

	if not indicatorTransitionActive then
		return
	end

	local amount =
		math.min(
			elapsed
			* indicatorColorSmoothSpeed,
			1
		)

	local finished = true

	for i = 0, 3 do
		local current =
			currentStrumRGB[i]

		local target =
			targetStrumRGB[i]

		current[1] =
			current[1]
			+ (
				target[1]
				- current[1]
			)
			* amount

		current[2] =
			current[2]
			+ (
				target[2]
				- current[2]
			)
			* amount

		current[3] =
			current[3]
			+ (
				target[3]
				- current[3]
			)
			* amount

		applyCurrentStrumColor(i)

		if math.abs(
			current[1]
			- target[1]
		) > 0.5 then

			finished = false
		end

		if math.abs(
			current[2]
			- target[2]
		) > 0.5 then

			finished = false
		end

		if math.abs(
			current[3]
			- target[3]
		) > 0.5 then

			finished = false
		end
	end

	if finished then
		for i = 0, 3 do
			currentStrumRGB[i][1] =
				targetStrumRGB[i][1]

			currentStrumRGB[i][2] =
				targetStrumRGB[i][2]

			currentStrumRGB[i][3] =
				targetStrumRGB[i][3]

			applyCurrentStrumColor(i)
		end

		indicatorTransitionActive =
			false
	end
end


-- ============================================================
-- Update
-- ============================================================

function onUpdate(elapsed)
	if enableGhostTapPunishment then
		removeExpiredGhostTaps(
			getSongPosition()
		)

		local ghostCount =
			getGhostTapCount()

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

		updateGhostTapColor(elapsed)
	end

	updateIndicatorColor(elapsed)
end


-- ============================================================
-- Post Update
--
-- FC/AP, Practice and BotPlay detection happens here.
-- ============================================================

function onUpdatePost()
	if not enableIndicator then
		return
	end

	-- ========================================================
	-- BotPlay Detection
	-- ========================================================

	if getProperty('cpuControlled') == true
		and not botplayEverUsed then

		botplayEverUsed = true

		-- Force a state refresh.
		currentIndicatorState = -1
	end


	-- ========================================================
	-- Practice Detection
	-- ========================================================
	--
	-- practiceMode is the NFE/Psych-style practice state.
	-- Once detected, it remains locked for this song.
	--

	if getProperty('practiceMode') == true
		and not practiceEverUsed then

		practiceEverUsed = true

		-- Force a state refresh.
		currentIndicatorState = -1
	end


	-- Ghost Tap has the highest visual priority.
	if ghostTapWasActive then
		return
	end

	local state =
		detectIndicatorState()

	if state ~= currentIndicatorState then
		currentIndicatorState =
			state

		-- Only update the target.
		-- updateIndicatorColor() handles the smooth transition.
		setIndicatorTarget(
			state
		)

		indicatorTransitionActive =
			true
	end
end


-- ============================================================
-- Destroy
-- ============================================================

function onDestroy()
	ghostTapTimes = {}
	ghostTapHead = 1

	currentGhostColorAmount = 0
	lastAppliedColorAmount = -1

	ghostTapWasActive = false
	indicatorTransitionActive = false

	botplayEverUsed = false
	practiceEverUsed = false

	for i = 0, 3 do
		setPropertyFromGroup(
			'playerStrums',
			i,
			'color',
			originalStrumColors[i]
		)
	end
end