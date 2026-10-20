-- ============================================================
-- Unsent's Note Splash
-- Random V-Slice Note Splash Animations
-- ============================================================

local texture = 'noteSplashes/noteSplashes-vslice'
local splashAlpha = 0
local enableSystem = true

local splashes = {}

-- V-Slice 水花动画前缀，%s 会替换为随机编号 1 或 2
local splashAnims = {
	'note impact %s purple',
	'note impact %s blue',
	'note impact %s green',
	'note impact %s red'
}

-- ============================================================
-- Utility
-- ============================================================

local function getRandomAnim(direction)
	local index = direction + 1
	if index < 1 or index > #splashAnims then
		return nil
	end
	return string.format(splashAnims[index], math.random(1, 2))
end

local function getSplashAnim(direction, noteType)
	if noteType == 'FUCK HAXE9' or noteType == 'FUCK HAXE10' then
		return 'vanilla splash 1 red'
	elseif noteType == 'FUCK HAXE8' then
		return 'vanilla splash 1 purple'
	elseif noteType == 'FUCK HAXE7' then
		return 'ParryFX'
	end
	return getRandomAnim(direction)
end

local function playSplash(name, direction, noteType)
	local anim = getSplashAnim(direction, noteType)
	if not anim then return false end

	setProperty(name .. '.x', getPropertyFromGroup('playerStrums', direction, 'x'))
	setProperty(name .. '.y', getPropertyFromGroup('playerStrums', direction, 'y'))
	playAnim(name, anim == 'ParryFX' and 'anim' or anim, true)
	setProperty(name .. '.visible', true)

	return true
end

-- ============================================================
-- Create
-- ============================================================

function onCreate()
	if version >= '0.7' then
		if enableSystem then
			splashAlpha = getPropertyFromClass('backend.ClientPrefs', 'data.splashAlpha')
			setPropertyFromClass('backend.ClientPrefs', 'data.splashAlpha', 0)
		end
	else
		splashAlpha = 0.6
		enableSystem = getPropertyFromClass('ClientPrefs', 'noteSplashes') == true
		setPropertyFromClass('ClientPrefs', 'noteSplashes', false)
	end
end

function onDestroy()
	if version >= '0.7' then
		if enableSystem then
			setPropertyFromClass('backend.ClientPrefs', 'data.splashAlpha', splashAlpha)
		end
	else
		setPropertyFromClass('ClientPrefs', 'noteSplashes', splashAlpha > 0)
	end
end

function onCreatePost()
	precacheImage(texture)

	if splashAlpha > 0 and enableSystem then
		precacheImage('noteSplashes/noteParry')

		makeAnimatedLuaSprite('noteSplashp', texture, 100, 100)
		addLuaSprite('noteSplashp', false)
		setProperty('noteSplashp.alpha', 0.001)

		if songName == 'build-our-freaky-machine' then
			precacheImage('IC_NoteSplash - grey')
		end
	end
end

-- ============================================================
-- Note Hit
-- ============================================================

function goodNoteHit(id, data, noteType, isSustainNote)
	if splashAlpha <= 0 or not enableSystem then return end

	local rating = getPropertyFromGroup('notes', id, 'rating')
	if rating == 'sick' or rating == 'marvelous' then
		spawnSplash(data, noteType)
	end
end

-- ============================================================
-- Reuse Existing Splash
-- ============================================================

function hasSplash(direction, noteType)
	for i = 1, #splashes do
		local splash = splashes[i]
		local name = splash[3]

		if splash[1] == noteType
			and splash[2] == direction
			and luaSpriteExists(name)
			and getProperty(name .. '.animation.curAnim.finished') == true then

			-- 每次复用都重新选择随机动画
			local anim = getSplashAnim(direction, noteType)
			if not anim then return false end

			playAnim(name, anim, true)
			setProperty(name .. '.visible', true)
			setProperty(name .. '.x', getPropertyFromGroup('playerStrums', direction, 'x'))
			setProperty(name .. '.y', getPropertyFromGroup('playerStrums', direction, 'y'))

			return true
		end
	end

	return false
end

-- ============================================================
-- Spawn Splash
-- ============================================================

function spawnSplash(direction, noteType)
	if hasSplash(direction, noteType) then return end

	local name = 'unsentSvsliceNoteSplash' .. #splashes
	local file = texture
	local scaleX = 1
	local scaleY = 1
	local speed = 26
	local offsetX = 85
	local offsetY = 85
	local color = nil

	if noteType == 'FUCK HAXE5' then
		color = '000000'
	elseif noteType == 'FUCK HAXE6' then
		file = 'noteSplashes/noteParry'
		offsetX = 210
		offsetY = 240
		scaleX = 0.8
		scaleY = 0.8
	end

	makeAnimatedLuaSprite(
		name,
		file,
		getPropertyFromGroup('playerStrums', direction, 'x'),
		getPropertyFromGroup('playerStrums', direction, 'y')
	)

	scaleObject(name, scaleX, scaleY)

	-- 注册动画：随机编号 1 和 2 都需要存在于对应 XML 中
	if noteType == 'FUCK HAXE1' or noteType == 'FUCK HAXE2' then
		addAnimationByPrefix(name, 'anim', 'vanilla splash 1 red', speed, false)
	elseif noteType == 'FUCK HAXE3' then
		addAnimationByPrefix(name, 'anim', 'vanilla splash 1 purple', speed, false)
	elseif noteType == 'FUCK HAXE4' then
		addAnimationByPrefix(name, 'anim', 'ParryFX', speed, false)
	else
		for i = 1, 4 do
			for n = 1, 2 do
				local anim = string.format(splashAnims[i], n)
				addAnimationByPrefix(name, anim, anim, speed, false)
			end
		end
	end

	setObjectCamera(name, 'hud')

	if version >= '0.7' then
		runHaxeCode(
			[[
				var obj = game.getLuaObject("]] .. name .. [[");
				if (obj != null && game.noteGroup != null)
					game.noteGroup.insert(game.noteGroup.members.indexOf(game.grpNoteSplashes), obj);
			]]
		)
	else
		runHaxeCode(
			[[
				var obj = game.getLuaObject("]] .. name .. [[");
				if (obj != null)
					game.insert(game.members.indexOf(game.grpNoteSplashes), obj);
			]]
		)
	end

	setProperty(name .. '.offset.x', offsetX)
	setProperty(name .. '.offset.y', offsetY)
	setProperty(name .. '.alpha', 1)

	if color then
		setProperty(name .. '.color', color)
	end

	table.insert(splashes, {noteType, direction, name})

	-- 播放初始动画
	local anim = getSplashAnim(direction, noteType)
	if anim then
		playAnim(name, anim, true)
	end
end

-- ============================================================
-- Update
-- ============================================================

function onUpdate()
	for i = 1, #splashes do
		local name = splashes[i][3]

		if luaSpriteExists(name)
			and getProperty(name .. '.animation.curAnim.finished') == true then
			setProperty(name .. '.visible', false)
		end
	end
end