-- ============================================================
-- Unsent's Hold Cover
-- V-Slice-style hold cover effect
-- ============================================================

-- ============================================================
-- Settings
-- ============================================================

local enableHoldCover = getModSetting('holdCover')

if enableHoldCover == nil then
	enableHoldCover = true
end

local holdCoverOffsetX = getModSetting('holdCoverOffsetX')

if holdCoverOffsetX == nil then
	holdCoverOffsetX = 0
end

local holdCoverOffsetY = getModSetting('holdCoverOffsetY')

if holdCoverOffsetY == nil then
	holdCoverOffsetY = 0
end


-- ============================================================
-- Base Offset
--
-- 0 = Purple
-- 1 = Blue
-- 2 = Green
-- 3 = Red
-- ============================================================

local baseOffset = {
	[0] = {-108, -98},
	[1] = {-108, -98},
	[2] = {-108, -98},
	[3] = {-108, -98}
}


-- ============================================================
-- Variables
-- ============================================================

local covers = {}
local active = {}
local endTimers = {}


-- ============================================================
-- Hold Cover Configuration
-- ============================================================

local coverData = {
	[0] = {
		image = 'holdCoverPurple',
		start = 'holdCoverStartPurple',
		hold = 'holdCoverPurple',
		finish = 'holdCoverEndPurple'
	},

	[1] = {
		image = 'holdCoverBlue',
		start = 'holdCoverStartBlue',
		hold = 'holdCoverBlue',
		finish = 'holdCoverEndBlue'
	},

	[2] = {
		image = 'holdCoverGreen',
		start = 'holdCoverStartGreen',
		hold = 'holdCoverGreen',
		finish = 'holdCoverEndGreen'
	},

	[3] = {
		image = 'holdCoverRed',
		start = 'holdCoverStartRed',
		hold = 'holdCoverRed',
		finish = 'holdCoverEndRed'
	}
}


-- ============================================================
-- Keyboard Detection
--
-- 0 = LEFT
-- 1 = DOWN
-- 2 = UP
-- 3 = RIGHT
-- ============================================================

local function isDirectionPressed(direction)
	if direction == 0 then
		return keyboardPressed('LEFT')
	elseif direction == 1 then
		return keyboardPressed('DOWN')
	elseif direction == 2 then
		return keyboardPressed('UP')
	elseif direction == 3 then
		return keyboardPressed('RIGHT')
	end

	return false
end


-- ============================================================
-- Update Showcase Alpha
--
-- Normal Mode:
-- Hold Cover alpha = 1
--
-- Showcase Mode:
-- Hold Cover follows showCaseStrumAlpha
-- ============================================================

local function updateShowcaseAlpha(direction)
	local tag = covers[direction]

	if not tag then
		return
	end

	local showcase = getModSetting('showCaseMode')

	if not showcase then
		setProperty(
			tag .. '.alpha',
			1
		)

		return
	end

	local alpha = getModSetting('showCaseStrumAlpha')

	if alpha == nil then
		alpha = 0
	end

	alpha = tonumber(alpha) or 0
	alpha = math.max(0, math.min(1, alpha))

	setProperty(
		tag .. '.alpha',
		alpha
	)
end


-- ============================================================
-- Update All Showcase Alpha
-- ============================================================

local function updateAllShowcaseAlpha()
	for direction = 0, 3 do
		updateShowcaseAlpha(direction)
	end
end


-- ============================================================
-- Create Cover
-- ============================================================

local function makeCover(direction)
	local data = coverData[direction]

	if not data then
		return
	end

	local tag = 'holdCover' .. direction

	makeAnimatedLuaSprite(
		tag,
		data.image,
		0,
		0
	)

	addAnimationByPrefix(
		tag,
		'start',
		data.start,
		24,
		false
	)

	addAnimationByPrefix(
		tag,
		'hold',
		data.hold,
		24,
		true
	)

	addAnimationByPrefix(
		tag,
		'end',
		data.finish,
		24,
		false
	)

	setObjectCamera(
		tag,
		'hud'
	)

	setProperty(
		tag .. '.visible',
		false
	)

	setProperty(
		tag .. '.alpha',
		1
	)

	addLuaSprite(
		tag,
		true
	)

	covers[direction] = tag
	active[direction] = false
	endTimers[direction] = nil
end


-- ============================================================
-- Create All Covers
-- ============================================================

function onCreatePost()
	if not enableHoldCover then
		return
	end

	for direction = 0, 3 do
		makeCover(direction)
	end

	updateAllShowcaseAlpha()
end


-- ============================================================
-- Update Cover Position
--
-- Final position:
--
-- Player Strum Position
-- + Direction Base Offset
-- + Shared X/Y Offset
-- ============================================================

local function updateCoverPosition(direction)
	local tag = covers[direction]

	if not tag then
		return
	end

	local strum =
		'playerStrums.members[' .. direction .. ']'

	local offset =
		baseOffset[direction]

	setProperty(
		tag .. '.x',
		getProperty(strum .. '.x')
			+ offset[1]
			+ holdCoverOffsetX
	)

	setProperty(
		tag .. '.y',
		getProperty(strum .. '.y')
			+ offset[2]
			+ holdCoverOffsetY
	)
end


-- ============================================================
-- Start Cover
-- ============================================================

local function startCover(
	direction,
	sustainLength
)
	local tag = covers[direction]

	if not tag then
		return
	end

	local oldTimer =
		endTimers[direction]

	if oldTimer then
		cancelTimer(oldTimer)
	end

	local timerName =
		'holdCoverEnd' .. direction

	endTimers[direction] =
		timerName

	updateCoverPosition(direction)
	updateShowcaseAlpha(direction)

	setProperty(
		tag .. '.visible',
		true
	)

	playAnim(
		tag,
		'start',
		true
	)

	active[direction] = true

	if sustainLength and sustainLength > 0 then
		runTimer(
			timerName,
			sustainLength / 1000
		)
	end
end


-- ============================================================
-- Stop Cover
--
-- Used when the player releases the key.
-- No End animation is played.
-- ============================================================

local function stopCover(direction)
	local tag = covers[direction]

	if not tag then
		return
	end

	local oldTimer =
		endTimers[direction]

	if oldTimer then
		cancelTimer(oldTimer)
	end

	endTimers[direction] = nil
	active[direction] = false

	setProperty(
		tag .. '.visible',
		false
	)
end


-- ============================================================
-- End Cover
-- ============================================================

local function endCover(direction)
	local tag = covers[direction]

	if not tag then
		return
	end

	if not active[direction] then
		return
	end

	active[direction] = false
	endTimers[direction] = nil

	updateCoverPosition(direction)
	updateShowcaseAlpha(direction)

	playAnim(
		tag,
		'end',
		true
	)
end


-- ============================================================
-- Player Note Hit
-- ============================================================

function goodNoteHit(
	id,
	direction,
	noteType,
	isSustainNote
)
	if not enableHoldCover then
		return
	end

	if isSustainNote then
		return
	end

	local sustainLength = 0

	local value =
		getPropertyFromGroup(
			'notes',
			id,
			'sustainLength'
		)

	if value ~= nil then
		sustainLength =
			tonumber(value) or 0
	end

	if sustainLength <= 0 then
		return
	end

	startCover(
		direction,
		sustainLength
	)
end


-- ============================================================
-- Update
-- ============================================================

function onUpdate(elapsed)
	if not enableHoldCover then
		return
	end

	-- Hold Cover 自己处理 Showcase 透明度
	updateAllShowcaseAlpha()

	-- Botplay 状态
	local botplay =
		getProperty('cpuControlled')

	for direction = 0, 3 do
		local tag = covers[direction]

		if tag and active[direction] then
			updateCoverPosition(direction)

			-- Botplay 开启时不检测键盘。
			-- 正常玩家游玩时才检测是否松开按键。
			if not botplay
				and not isDirectionPressed(direction) then

				stopCover(direction)
			else
				local animName =
					getProperty(
						tag .. '.animation.curAnim.name'
					)

				local finished =
					getProperty(
						tag .. '.animation.curAnim.finished'
					)

				if animName == 'start'
					and finished then

					playAnim(
						tag,
						'hold',
						true
					)
				end
			end
		end
	end
end


-- ============================================================
-- Timer
-- ============================================================

function onTimerCompleted(tag)
	if not enableHoldCover then
		return
	end

	for direction = 0, 3 do
		if tag == endTimers[direction] then
			endCover(direction)
			return
		end
	end
end


-- ============================================================
-- Missed Note
-- ============================================================

function noteMiss(
	id,
	direction,
	noteType,
	isSustainNote
)
	if not enableHoldCover then
		return
	end

	if active[direction] then
		local oldTimer =
			endTimers[direction]

		if oldTimer then
			cancelTimer(oldTimer)
		end

		endTimers[direction] = nil

		endCover(direction)
	end
end


-- ============================================================
-- Hide Finished End Animation
-- ============================================================

function onUpdatePost()
	if not enableHoldCover then
		return
	end

	for direction = 0, 3 do
		local tag = covers[direction]

		if tag and not active[direction] then
			local animName =
				getProperty(
					tag .. '.animation.curAnim.name'
				)

			local finished =
				getProperty(
					tag .. '.animation.curAnim.finished'
				)

			if animName == 'end'
				and finished then

				setProperty(
					tag .. '.visible',
					false
				)
			end
		end
	end
end


-- ============================================================
-- Cleanup
-- ============================================================

function onDestroy()
	if not enableHoldCover then
		return
	end

	for direction = 0, 3 do
		local timerName =
			endTimers[direction]

		if timerName then
			cancelTimer(timerName)
		end
	end

	-- 防止离开歌曲后残留透明度状态
	for direction = 0, 3 do
		local tag = covers[direction]

		if tag then
			setProperty(
				tag .. '.alpha',
				1
			)
		end
	end
end