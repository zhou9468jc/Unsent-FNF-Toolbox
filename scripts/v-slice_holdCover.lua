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
-- Debug Mode
--
-- false = Normal Hold Cover behavior
-- true  = Hold Cover offset adjustment mode
--
-- Q / E:
-- Select arrow
--
-- Arrow Keys:
-- Normal = 1 pixel
-- Shift  = 4 pixels
-- Ctrl   = 8 pixels
-- Alt    = 32 pixels
--
-- Debug mode directly modifies baseOffset.
-- ============================================================

local debugMode = false

local debugSelectedDirection = 0

local debugDirectionNames = {
	[0] = 'LEFT',
	[1] = 'DOWN',
	[2] = 'UP',
	[3] = 'RIGHT'
}


-- ============================================================
-- Base Offset
--
-- 0 = Purple / LEFT
-- 1 = Blue   / DOWN
-- 2 = Green  / UP
-- 3 = Red    / RIGHT
--
-- These values are directly modified by Debug Mode.
-- ============================================================

local baseOffset = {
	[0] = {-106, -98},
	[1] = {-108, -98},
	[2] = {-108, -98},
	[3] = {-106, -98}
}


-- ============================================================
-- Variables
-- ============================================================

local covers = {}
local active = {}
local endTimers = {}

local debugTextTag = 'holdCoverDebugText'


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
-- Debug Keyboard Detection
-- ============================================================

local function getDebugMoveAmount()
	if keyboardPressed('ALT') then
		return 32
	end

	if keyboardPressed('CONTROL') then
		return 8
	end

	if keyboardPressed('SHIFT') then
		return 4
	end

	return 1
end


-- ============================================================
-- Debug Text
-- ============================================================

local function updateDebugText()
	if not debugMode then
		return
	end

	local text =
		'Hold Cover Offset Debug\n' ..
		'Q / E : Select Arrow\n' ..
		'Arrow : ±1    Shift : ±4    Ctrl : ±8    Alt : ±32\n\n'

	for direction = 0, 3 do
		local offset = baseOffset[direction]

		local prefix = '  '

		if direction == debugSelectedDirection then
			prefix = '> '
		end

		text = text ..
			prefix ..
			debugDirectionNames[direction] ..
			'   X: ' ..
			tostring(offset[1]) ..
			'   Y: ' ..
			tostring(offset[2]) ..
			'\n'
	end

	setTextString(
		debugTextTag,
		text
	)
end


-- ============================================================
-- Debug Text Creation
-- ============================================================

local function createDebugText()
	if not debugMode then
		return
	end

	makeLuaText(
		debugTextTag,
		'',
		0,
		20,
		20
	)

	setTextSize(
		debugTextTag,
		18
	)

	setTextBorder(
		debugTextTag,
		2,
		'000000'
	)

	setObjectCamera(
		debugTextTag,
		'hud'
	)

	addLuaText(
		debugTextTag,
		true
	)

	updateDebugText()
end


-- ============================================================
-- Debug Keyboard
-- ============================================================

local function updateDebugKeyboard()
	if not debugMode then
		return
	end

	-- Select previous arrow
	if keyboardJustPressed('Q') then
		debugSelectedDirection =
			debugSelectedDirection - 1

		if debugSelectedDirection < 0 then
			debugSelectedDirection = 3
		end
	end

	-- Select next arrow
	if keyboardJustPressed('E') then
		debugSelectedDirection =
			debugSelectedDirection + 1

		if debugSelectedDirection > 3 then
			debugSelectedDirection = 0
		end
	end

	local amount = getDebugMoveAmount()
	local offset = baseOffset[debugSelectedDirection]

	-- Left
	if keyboardJustPressed('LEFT') then
		offset[1] =
			offset[1] - amount
	end

	-- Right
	if keyboardJustPressed('RIGHT') then
		offset[1] =
			offset[1] + amount
	end

	-- Up
	if keyboardJustPressed('UP') then
		offset[2] =
			offset[2] - amount
	end

	-- Down
	if keyboardJustPressed('DOWN') then
		offset[2] =
			offset[2] + amount
	end

	updateDebugText()
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


	local showcase =
		getModSetting('showCaseMode')


	-- Showcase 模式
	if showcase then

		local alpha =
			getModSetting('showCaseStrumAlpha')


		if alpha == nil then
			alpha = 0
		end


		alpha =
			tonumber(alpha) or 0


		alpha =
			math.max(
				0,
				math.min(
					1,
					alpha
				)
			)


		setProperty(
			tag .. '.alpha',
			alpha
		)

		return
	end


	-- 普通模式：跟随玩家箭头透明度
	local strum =
		'playerStrums.members[' .. direction .. ']'


	local alpha = 1


	if getProperty(strum .. '.alpha') ~= nil then
		alpha =
			getProperty(strum .. '.alpha')
	end


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
	
	setObjectOrder(tag,10001)
	
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

	-- Debug text
	createDebugText()

	-- Debug Mode:
	-- Keep all four Hold Covers visible and looping.
	if debugMode then
		for direction = 0, 3 do
			local tag = covers[direction]

			if tag then
				setProperty(
					tag .. '.visible',
					true
				)

				playAnim(
					tag,
					'hold',
					true
				)
			end
		end
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
-- Update All Debug Covers
-- ============================================================

local function updateAllDebugCovers()
	if not debugMode then
		return
	end

	for direction = 0, 3 do
		local tag = covers[direction]

		if tag then
			updateCoverPosition(direction)

			setProperty(
				tag .. '.visible',
				true
			)

			local animName =
				getProperty(
					tag .. '.animation.curAnim.name'
				)

			if animName ~= 'hold' then
				playAnim(
					tag,
					'hold',
					true
				)
			end
		end
	end
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

	if debugMode then
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

	-- ========================================================
	-- Debug Mode
	-- ========================================================

	if debugMode then
		updateDebugKeyboard()
		updateAllDebugCovers()
		updateAllShowcaseAlpha()

		-- 不执行正常 Hold Cover 的按键释放逻辑
		return
	end

	-- ========================================================
	-- Normal Mode
	-- ========================================================

	updateAllShowcaseAlpha()

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

	if debugMode then
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

	if debugMode then
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

	if debugMode then
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