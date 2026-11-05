-- ============================================================
-- Unsent's Pixel Note Splash
-- ============================================================

-- ============================================================
-- Settings
-- ============================================================
if not (getPropertyFromClass('PlayState', 'isPixelStage') == true and getModSetting("originalHealthBar") == true) then
	close()
end
local function isPixelStage()
    return true
end
local texture = 'pixelUI/noteSplashes/pixelNoteSplash'

local splashAlpha = 0
local enableSystem = true

local pixelScaleX = 4
local pixelScaleY = 4

local pixelOffsetX = -24
local pixelOffsetY = -28

local pixelSpeed = 33
local pixelBlendMode = 'screen'
local pixelAntialiasing = false

local splashes = {}

local pixelSplashAnims = {
	'purple',
	'blue',
	'green',
	'orange'
}

-- ============================================================
-- Disable Original Note Splash
-- ============================================================

local function disableNoteSplash(group, id)
	if not group or id == nil then return end

	pcall(function()
		setPropertyFromGroup(group, id, 'noteSplashData.disabled', true)
	end)
end

local function disableAllNoteSplashes()
	local groups = {'unspawnNotes', 'notes'}

	for _, group in ipairs(groups) do
		local length = getProperty(group .. '.length') or 0

		for i = 0, length - 1 do
			disableNoteSplash(group, i)
		end
	end
end

-- ============================================================
-- Utility
-- ============================================================

local function getRandomAnim(direction)
	local prefix = pixelSplashAnims[direction + 1]
	if not prefix then return nil end

	return prefix .. math.random(1, 3)
end

local function setPixelBlend(name)
	if not luaSpriteExists(name) then return false end

	local success = setBlendMode(name, pixelBlendMode)
	setProperty(name .. '.antialiasing', pixelAntialiasing)

	return success
end

-- ============================================================
-- Create
-- ============================================================

function onCreate()
	if not isPixelStage() then return end
	disableAllNoteSplashes()

	if version >= '0.7' then
		if enableSystem then
			splashAlpha = getPropertyFromClass(
				'backend.ClientPrefs',
				'data.splashAlpha'
			)
		end
	else
		splashAlpha = 0.6
		enableSystem = getPropertyFromClass(
			'ClientPrefs',
			'noteSplashes'
		) == true
	end
end

function onDestroy()
	if not isPixelStage() then return end
	if version >= '0.7' then
		if enableSystem then
			setPropertyFromClass(
				'backend.ClientPrefs',
				'data.splashAlpha',
				splashAlpha
			)
		end
	else
		setPropertyFromClass(
			'ClientPrefs',
			'noteSplashes',
			splashAlpha > 0
		)
	end
end

function onCreatePost()
	if not isPixelStage() then return end
	precacheImage(texture)

	if splashAlpha > 0 and enableSystem then
		makeAnimatedLuaSprite('noteSplashp', texture, 100, 100)
		addLuaSprite('noteSplashp', false)
		setProperty('noteSplashp.alpha', 0.001)
	end

	disableAllNoteSplashes()
end

-- ============================================================
-- Newly Spawned Notes
-- ============================================================

function onSpawnNote(id, data, noteType, isSustainNote, isHurtNote)
	if not isPixelStage() then return end
	disableNoteSplash('notes', id)
end

-- ============================================================
-- Note Hit
-- ============================================================

function goodNoteHit(id, data, noteType, isSustainNote)
	if not isPixelStage() then return end
	if splashAlpha <= 0 or not enableSystem then return end

	local rating = getPropertyFromGroup('notes', id, 'rating')

	if rating == 'sick' or rating == 'marvelous' then
		spawnSplash(data)
	end
end

-- ============================================================
-- Reuse Existing Splash
-- ============================================================

function hasSplash(direction)
	if not isPixelStage() then return end
	for i = 1, #splashes do
		local name = splashes[i][2]

		if splashes[i][1] == direction
			and luaSpriteExists(name)
			and getProperty(name .. '.animation.curAnim.finished') == true then

			local anim = getRandomAnim(direction)
			if not anim then return false end

			playAnim(name, anim, true)

			setProperty(name .. '.visible', true)
			setProperty(name .. '.x', getPropertyFromGroup('playerStrums', direction, 'x'))
			setProperty(name .. '.y', getPropertyFromGroup('playerStrums', direction, 'y'))

			setPixelBlend(name)

			return true
		end
	end

	return false
end

-- ============================================================
-- Spawn Pixel Splash
-- ============================================================

function spawnSplash(direction)
	if hasSplash(direction) then return end

	local name = 'unsentPixelNoteSplash' .. #splashes

	makeAnimatedLuaSprite(
		name,
		texture,
		getPropertyFromGroup('playerStrums', direction, 'x'),
		getPropertyFromGroup('playerStrums', direction, 'y')
	)

	scaleObject(name, pixelScaleX, pixelScaleY)

	for i = 1, 4 do
		for n = 1, 3 do
			local anim = pixelSplashAnims[i] .. n
			addAnimationByPrefix(name, anim, anim, pixelSpeed, false)
		end
	end

	setObjectCamera(name, 'hud')

	-- 插入到原版 Note Splash 所在层级
	if version >= '0.7' then
		runHaxeCode([[
			var obj = game.getLuaObject("]] .. name .. [[");
			if (obj != null && game.noteGroup != null)
				game.noteGroup.insert(
					game.noteGroup.members.indexOf(game.grpNoteSplashes),
					obj
				);
		]])
	else
		runHaxeCode([[
			var obj = game.getLuaObject("]] .. name .. [[");
			if (obj != null)
				game.insert(
					game.members.indexOf(game.grpNoteSplashes),
					obj
				);
		]])
	end

	setPixelBlend(name)

	setProperty(name .. '.offset.x', pixelOffsetX)
	setProperty(name .. '.offset.y', pixelOffsetY)
	setProperty(name .. '.alpha', 1)

	table.insert(splashes, {direction, name})

	local anim = getRandomAnim(direction)
	if anim then
		playAnim(name, anim, true)
	end
end

-- ============================================================
-- Update
-- ============================================================

function onUpdate()
	if not isPixelStage() then return end
	for i = 1, #splashes do
		local name = splashes[i][2]

		if luaSpriteExists(name)
			and getProperty(name .. '.animation.curAnim.finished') == true then

			setProperty(name .. '.visible', false)
		end
	end
end