-- ============================================================
-- Unsent's Opponent Hold Cover
-- V-Slice-style opponent hold cover effect
--
-- Opponent:
-- Hold animation only
-- No Start / End animation
--
-- Uses the same assets as Player Hold Cover
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

local opponentCovers = {}
local opponentActive = {}
local opponentEndTimers = {}


-- ============================================================
-- Hold Cover Configuration
-- ============================================================

local coverData = {

	[0] = {
		image = 'holdCoverPurple',
		hold = 'holdCoverPurple'
	},

	[1] = {
		image = 'holdCoverBlue',
		hold = 'holdCoverBlue'
	},

	[2] = {
		image = 'holdCoverGreen',
		hold = 'holdCoverGreen'
	},

	[3] = {
		image = 'holdCoverRed',
		hold = 'holdCoverRed'
	}

}


-- ============================================================
-- Update Opponent Hold Cover Alpha
--
-- Cover Alpha:
--
-- Opponent Strum Alpha
-- *
-- Showcase Alpha
--
-- ============================================================

local function updateShowcaseAlpha(direction)

	local tag =
		opponentCovers[direction]

	if not tag then
		return
	end


	local alpha = 1


	local showcase =
		getModSetting('showCaseMode')


	-- Showcase模式
	if showcase then

		alpha =
			getModSetting('showCaseStrumAlpha')


		if alpha == nil then
			alpha = 0
		end


		alpha =
			tonumber(alpha) or 0

	else

		-- 普通模式跟随对手箭头透明度
		local strum =
			'opponentStrums.members[' .. direction .. ']'


		if getProperty(strum .. '.alpha') ~= nil then
			alpha =
				getProperty(strum .. '.alpha')
		end

	end


	-- 最终增强 1.5 倍
	alpha =
		math.min(
			1,
			alpha * 1.5
		)


	setProperty(
		tag .. '.alpha',
		alpha
	)

end


local function updateAllShowcaseAlpha()

	for direction = 0, 3 do
		updateShowcaseAlpha(direction)
	end

end


-- ============================================================
-- Create Opponent Cover
-- ============================================================

local function makeOpponentCover(direction)

	local data =
		coverData[direction]


	if not data then
		return
	end


	local tag =
		'opponentHoldCover' .. direction


	makeAnimatedLuaSprite(
		tag,
		data.image,
		0,
		0
	)


	addAnimationByPrefix(
		tag,
		'hold',
		data.hold,
		24,
		true
	)


	setObjectCamera(
		tag,
		'hud'
	)


	setProperty(
		tag .. '.visible',
		false
	)


	-- Avoid flashing when created
	setProperty(
		tag .. '.alpha',
		0
	)


	addLuaSprite(
		tag,
		true
	)


	opponentCovers[direction] = tag

	opponentActive[direction] = false

	opponentEndTimers[direction] = nil

end


-- ============================================================
-- Create All Opponent Covers
-- ============================================================

function onCreatePost()

	if not enableHoldCover then
		return
	end


	for direction = 0, 3 do

		makeOpponentCover(direction)

	end


	updateAllShowcaseAlpha()

end


-- ============================================================
-- Update Opponent Cover Position
--
-- Opponent Strum Position
-- + Base Offset
-- + Shared Offset
-- ============================================================

local function updateCoverPosition(direction)

	local tag =
		opponentCovers[direction]


	if not tag then
		return
	end


	local strum =
		'opponentStrums.members[' .. direction .. ']'


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
-- Start Opponent Hold
--
-- Opponent only uses Hold animation.
-- No Start / End animation.
-- ============================================================

local function startCover(
	direction,
	sustainLength
)

	local tag =
		opponentCovers[direction]


	if not tag then
		return
	end


	local oldTimer =
		opponentEndTimers[direction]


	if oldTimer then
		cancelTimer(oldTimer)
	end


	local timerName =
		'opponentHoldCoverEnd' .. direction


	opponentEndTimers[direction] =
		timerName


	updateCoverPosition(direction)

	updateShowcaseAlpha(direction)


	setProperty(
		tag .. '.visible',
		true
	)


	playAnim(
		tag,
		'hold',
		true
	)


	opponentActive[direction] = true


	if sustainLength and sustainLength > 0 then

		runTimer(
			timerName,
			sustainLength / 1000
		)

	end

end


-- ============================================================
-- End Opponent Hold
-- ============================================================

local function endCover(direction)

	local tag =
		opponentCovers[direction]


	if not tag then
		return
	end


	if not opponentActive[direction] then
		return
	end


	opponentActive[direction] = false

	opponentEndTimers[direction] = nil


	setProperty(
		tag .. '.visible',
		false
	)

end


-- ============================================================
-- Opponent Note Hit
-- ============================================================

function opponentNoteHit(
	id,
	direction,
	noteType,
	isSustainNote
)

	if not enableHoldCover then
		return
	end


	-- Sustain ticks do not restart cover
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


	-- Update alpha continuously
	updateAllShowcaseAlpha()


	for direction = 0, 3 do

		local tag =
			opponentCovers[direction]


		if tag and opponentActive[direction] then

			updateCoverPosition(direction)


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
-- Timer
-- ============================================================

function onTimerCompleted(tag)

	if not enableHoldCover then
		return
	end


	for direction = 0, 3 do

		if tag == opponentEndTimers[direction] then

			endCover(direction)

			return

		end

	end

end


-- ============================================================
-- Opponent Miss
-- ============================================================

function opponentNoteMiss(
	id,
	direction,
	noteType,
	isSustainNote
)

	if not enableHoldCover then
		return
	end


	if opponentActive[direction] then


		local oldTimer =
			opponentEndTimers[direction]


		if oldTimer then
			cancelTimer(oldTimer)
		end


		opponentEndTimers[direction] = nil


		endCover(direction)

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
			opponentEndTimers[direction]


		if timerName then
			cancelTimer(timerName)
		end


		local tag =
			opponentCovers[direction]


		if tag then

			setProperty(
				tag .. '.alpha',
				0
			)


			setProperty(
				tag .. '.visible',
				false
			)

		end

	end

end