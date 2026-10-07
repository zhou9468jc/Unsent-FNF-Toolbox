-- ============================================================
-- Double Press Ghost Trail
--
-- Original code is not mine.
-- MoveX / MoveY modification by Unsent.
--
-- NFE 1.2.2
-- ============================================================

local gfRows, bfRows, ddRows, exRows = {}, {}, {}, {}
local enableGhost = getModSetting("characterGhostTrail")

if enableGhost == nil then
	enableGhost = true
end


-- ============================================================
-- Get Character Icon Color
-- ============================================================

local function getIconColor(chr)
	local color = getProperty(chr .. ".healthColorArray")

	if type(color) ~= "table" then
		return getColorFromHex("FFFFFF")
	end

	return getColorFromHex(string.format(
		"%.2x%.2x%.2x",
		math.min((color[1] or 255) + 50, 255),
		math.min((color[2] or 255) + 50, 255),
		math.min((color[3] or 255) + 50, 255)
	))
end


-- ============================================================
-- Get Current Animation Prefix
--
-- Does NOT use animation.frameName.
--
-- NFE animationsArray:
-- anim = animation name
-- name = spritesheet prefix
-- ============================================================

local function getAnimationPrefix(chr)
	local animName = getProperty(chr .. ".animation.curAnim.name")

	if not animName then
		return nil
	end

	local animations = getProperty(chr .. ".animationsArray")

	if type(animations) ~= "table" then
		return nil
	end

	for _, data in pairs(animations) do
		if type(data) == "table" then
			if data.anim == animName then
				return data.name
			end
		end
	end

	return nil
end


-- ============================================================
-- Get Direction From Animation
-- ============================================================

local function getAnimationDirection(animName)
	if not animName then
		return nil
	end

	local name = string.lower(animName)

	if name:find("up") then
		return "up"
	elseif name:find("down") then
		return "down"
	elseif name:find("left") then
		return "left"
	elseif name:find("right") then
		return "right"
	end

	return nil
end


-- ============================================================
-- Create Ghost
-- ============================================================

local function ghostTrail(c, d)
	if not enableGhost or not d or not d[1] then
		return
	end

	local ghost = c .. "Ghost"
	local group = c == "extra" and "dad" or c
	local imageFile = getProperty(c .. ".imageFile")

	if not imageFile then
		return
	end

	makeAnimatedLuaSprite(
		ghost,
		imageFile,
		getProperty(c .. ".x"),
		getProperty(c .. ".y")
	)

	addAnimationByPrefix(
		ghost,
		"idle",
		d[1],
		24,
		false
	)

	setProperty(
		ghost .. ".antialiasing",
		getProperty(c .. ".antialiasing")
	)

	setProperty(
		ghost .. ".offset.x",
		d[2]
	)

	setProperty(
		ghost .. ".offset.y",
		d[3]
	)

	scaleObject(
		ghost,
		getProperty(c .. ".scale.x"),
		getProperty(c .. ".scale.y"),
		false
	)

	setProperty(
		ghost .. ".flipX",
		getProperty(c .. ".flipX")
	)

	setProperty(
		ghost .. ".flipY",
		getProperty(c .. ".flipY")
	)

	setProperty(
		ghost .. ".visible",
		getProperty(c .. ".visible")
	)

	setProperty(
		ghost .. ".color",
		getIconColor(c)
	)

	setProperty(
		ghost .. ".alpha",
		0.8 * getProperty(c .. ".alpha")
	)

	setBlendMode(
		ghost,
		"hardlight"
	)

	addLuaSprite(ghost)

	playAnim(
		ghost,
		"idle",
		true
	)

	setObjectOrder(
		ghost,
		getObjectOrder(group .. "Group") - 0.1
	)


	-- ========================================================
	-- Movement
	-- ========================================================

	local dirMap = {
		["up"] = {0, -45},
		["down"] = {0, 45},
		["right"] = {45, 0},
		["left"] = {-45, 0}
	}

	local moveX = getProperty(ghost .. ".x")
	local moveY = getProperty(ghost .. ".y")

	local direction = getAnimationDirection(d[1])

	if direction then
		local offset = dirMap[direction]

		moveX = moveX + offset[1]
		moveY = moveY + offset[2]
	end


	-- ========================================================
	-- Fade Out
	-- ========================================================

	startTween(
		ghost,
		ghost,
		{
			alpha = 0,
			x = moveX,
			y = moveY
		},
		0.75,
		{
			onComplete = "destroyGhost"
		}
	)
end


-- ============================================================
-- Handle Note Hit
-- ============================================================

local function handleNoteHit(
	id,
	n,
	s,
	cName,
	rows,
	cProp
)
	local strumTime
	local animationPrefix

	if n == "No Animation" or n == "Extra sings too" then
		cName = getProperty("extra.curCharacter")

		if not cName then
			return
		end
	end

	if s then
		return
	end

	strumTime =
		cName ..
		getPropertyFromGroup(
			"notes",
			id,
			"strumTime"
		)


	-- ========================================================
	-- Repeated note = create Ghost
	-- ========================================================

	if rows[strumTime] then
		ghostTrail(
			cProp,
			rows[strumTime]
		)
	end


	-- ========================================================
	-- Get current animation prefix
	--
	-- IMPORTANT:
	-- No animation.frameName is used here.
	-- ========================================================

	animationPrefix =
		getAnimationPrefix(cProp)

	if not animationPrefix then
		return
	end


	-- ========================================================
	-- Save animation data
	-- ========================================================

	rows[strumTime] = {
		animationPrefix,
		getProperty(cProp .. ".offset.x"),
		getProperty(cProp .. ".offset.y")
	}

	runTimer(
		cProp .. "str" .. strumTime
	)
end


-- ============================================================
-- Player Note Hit
-- ============================================================

function goodNoteHit(
	id,
	_,
	n,
	s
)
	if n ~= "No Animation"
	and not getPropertyFromGroup(
		"notes",
		id,
		"gfNote"
	) then

		handleNoteHit(
			id,
			n,
			s,
			"boyfriend",
			bfRows,
			"boyfriend"
		)

	elseif getPropertyFromGroup(
		"notes",
		id,
		"gfNote"
	) or n == "GF sings too" then

		handleNoteHit(
			id,
			n,
			s,
			"gf",
			gfRows,
			"gf"
		)

	else

		handleNoteHit(
			id,
			n,
			s,
			"extra",
			exRows,
			"extra"
		)
	end
end


-- ============================================================
-- Opponent Note Hit
-- ============================================================

function opponentNoteHit(
	id,
	_,
	n,
	s
)
	if n ~= "No Animation"
	and not getPropertyFromGroup(
		"notes",
		id,
		"gfNote"
	) then

		handleNoteHit(
			id,
			n,
			s,
			"dad",
			ddRows,
			"dad"
		)

	elseif getPropertyFromGroup(
		"notes",
		id,
		"gfNote"
	) or n == "GF sings too" then

		handleNoteHit(
			id,
			n,
			s,
			"gf",
			gfRows,
			"gf"
		)

	else

		handleNoteHit(
			id,
			n,
			s,
			"extra",
			exRows,
			"exRows"
		)
	end
end


-- ============================================================
-- Timer
-- ============================================================

function onTimerCompleted(t)
	local key = t:sub(6)

	if t:find("bfstr") then
		bfRows[key] = nil

	elseif t:find("ddstr") then
		ddRows[key] = nil

	elseif t:find("exstr") then
		exRows[key] = nil

	elseif t:find("gfstr") then
		gfRows[key] = nil
	end
end


-- ============================================================
-- Ghost Cleanup
-- ============================================================

function destroyGhost(tag)
	removeLuaSprite(
		tag,
		true
	)
end


function onTweenCompleted(t)
	if t:find("Ghost") then
		removeLuaSprite(
			t,
			true
		)
	end
end