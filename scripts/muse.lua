-- ============================================================
-- Unsent Custom Song Start / Perfect End Sound
--
-- 功能：
-- 1. 跳过原版 3 / 2 / 1 / Go 音效
-- 2. 播放自定义开始音效
-- 3. 等待 5.968 秒
-- 4. 跳过原版倒计时，继续正常歌曲流程
-- 5. 全曲没有 Miss 时，歌曲结束播放完美音效
--
-- NFE 1.2.x
-- ============================================================


-- ============================================================
-- Settings
-- ============================================================

local startSound = 'sfx_readygo'
local perfectEndSound = 'sfx_full_combo'

local startSoundLength = 5.968
local enable = getModSetting("muse")
if enable == nil then enable = false end
local enableStartSound = enable
local enablePerfectEndSound = enable


-- ============================================================
-- Internal
-- ============================================================

local startSoundStarted = false
local startSoundFinished = false
local hadMiss = false
local perfectSoundPlayed = false


-- ============================================================
-- Create
-- ============================================================

function onCreate()
	if enableStartSound then
		precacheSound(startSound)
	end

	if enablePerfectEndSound then
		precacheSound(perfectEndSound)
	end
end


-- ============================================================
-- Start Countdown
-- ============================================================

function onStartCountdown()
	if startSoundFinished then
		return Function_Continue
	end

	if not startSoundStarted then
		startSoundStarted = true

		if enableStartSound then
			playSound(startSound, 1)
			runTimer('__Unsent_CustomStartCountdown__', startSoundLength)
			return Function_Stop
		end

		startSoundFinished = true
		return Function_Continue
	end

	return Function_Stop
end


-- ============================================================
-- Start Sound Timer
-- ============================================================

function onTimerCompleted(tag)
	if tag ~= '__Unsent_CustomStartCountdown__' then
		return
	end

	if startSoundFinished then
		return
	end

	startSoundFinished = true

	-- 重新进入 NFE 的倒计时流程。
	-- 本脚本此时会直接放行。
	startCountdown()
end


-- ============================================================
-- Detect Miss
-- ============================================================

function noteMiss()
	hadMiss = true
end

function onUpdate()
	if getProperty('songMisses') > 0 then
		hadMiss = true
	end
end


-- ============================================================
-- Song End
-- ============================================================

function onEndSong()
	if enablePerfectEndSound
		and not hadMiss
		and not perfectSoundPlayed then

		perfectSoundPlayed = true
		playSound(perfectEndSound, 1)
	end

	return Function_Continue
end