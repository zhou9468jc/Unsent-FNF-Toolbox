-- ============================================================
-- Unsent's Toolbox NF Ver
-- Main Script
-- Language Support
-- ============================================================

local Key = readJson("data/keys.json") or {}

Key.Toggle = Key.Toggle or {}
Key.Modifier = Key.Modifier or {}

local languages = readJson("data/language.json") or {}
local language = getModSetting("language")

if language == nil then
	local text =
		"[Unsent's ToolBox] Error : "..(languages["###GloBal_Language"] or {})["Language_ReadError"]
		or "Language_ReadError"
	debugPrint(text,"red")
	local message = tostring(text)
		:gsub("\\", "\\\\")
		:gsub("\r", "\\r")
		:gsub("\n", "\\n")
		:gsub("\t", "\\t")
		:gsub('"', '\\"')

	pcall(runHaxeCode, 'trace("' .. message .. '");')

	language = "English"
end

if language == "###GloBal_Language" then
	language = "English"
end

local lang =
	languages[language]
	or languages["English"]
	or {}

local Global_lang =
	languages["###GloBal_Language"]
	or {}

local function getLang(isGlobal, key, ...)
	local source = isGlobal and Global_lang or lang
	local text = source[key]

	if text == nil then
		text = isGlobal and ("Global_" .. key) or key
	end

	for i, v in ipairs({...}) do
		text = text:gsub("%{" .. i .. "%}", function()
			return tostring(v)
		end)
	end

	return text
end

local function loadLanguage()

	language = getModSetting("language") or "English"

	local languages = readJson(
		"data/language.json"
	)

	if languages == nil then
		return false
	end

	lang =
		languages[language]
		or languages["English"]
		or {}

	languageLoaded = true

	return true
end
local function getSetting(key, default)
	if getModSetting then
		local ok, val = pcall(getModSetting, key)
		if ok and val ~= nil then
			return val
		end
	end

	debugPrint(
		"[Unsent's ToolBox] " ..
		getLang(false, "ModSetting_ReadError", key, default),
		"red"
	)

	return default
end
local function onCreateTestCodes()
	return
end
local function onUpdateTestCodes()
	return
end

local botActive = false
local practiceMode = false
local keyCooldown = 0
local scriptEnabled = false

local developerMode = false
local hideDevPrint = false
local hideDevError = false

local fakeBotActive = false
local disableCheckVer = false

local softPauseEnabled = false
local noResetEnabled = false

local softPaused = false
local softPauseWaiting = false
local softPauseTimer = 0
local softPauseTimeout = 3

local playbackRateValue = 1
local scrollSpeedValue = 1
local defaultScrollSpeed = 1
local speedInitialized = false

local disableBotplay = false
local advancedDebugMode = false
local showcaseMode = false

local function haxeTrace(text)
    local message = tostring(text)

    -- 注意：先转义反斜杠，再转义控制字符，最后转义引号
    message = message
        :gsub("\\", "\\\\")   -- 1. 反斜杠优先
        :gsub("\r", "\\r")    -- 2. 回车
        :gsub("\n", "\\n")    -- 3. 换行
        :gsub("\t", "\\t")    -- 4. 制表
        :gsub('"', '\\"')     -- 5. 双引号

    local code = 'trace("' .. message .. '");'
    pcall(runHaxeCode, code)
end


local function getNoReset()

	local success,value =
		pcall(function()

			return getPropertyFromClass(
				'ClientPrefs',
				'data.noReset'
			)

		end)


	if (success and value == true) or Key.Toggle.Reset ~= "R" then
		return true
	else
		return false
	end

end



local function devPrint(text)

	local message =
		"[Unsent's toolbox] "..text


	if advancedDebugMode then

		if debugPrint then
			debugPrint(
				message,
				"WHITE"
			)
		end


		haxeTrace(message)



	elseif disableCheckVer or not hideDevPrint then


		if debugPrint then
			debugPrint(
				message,
				"WHITE"
			)
		end


		haxeTrace(message)


	end
end
local function devError(text)

	local message =
		"[Unsent's toolbox] "..text


	if advancedDebugMode then

		if debugPrint then
			debugPrint(
				message,
				"RED"
			)
		end


		haxeTrace(message)


	elseif disableCheckVer or not hideDevError then

		if debugPrint then

			debugPrint(
				message,
				"RED"
			)

		else

			haxeTrace(message)

		end

	end
end



local function devWarn(text)

	local message =
		"[Unsent's toolbox] "..text


	if advancedDebugMode then

		if debugPrint then
			debugPrint(
				message,
				"YELLOW"
			)
		end


		haxeTrace(message)


	elseif disableCheckVer or not hideDevError then

		if debugPrint then

			debugPrint(
				message,
				"YELLOW"
			)

		else

			haxeTrace(message)

		end

	end
end



local function isNovaFlare()

	local success,result =
		pcall(function()

			local opponent =
				getProperty(
					'cpuControlled_opponent'
				)

			return opponent ~= nil

		end)


	return success and result
end



local function setSoftPauseText(state)

	setProperty(
		'softPauseText.visible',
		state
	)

end



local function updateSongSpeed()

	local noScroll =
		getSetting(
			"playbackRateNoScrollSpeed",
			false
		)


	setProperty(
		'playbackRate',
		playbackRateValue
	)


	if noScroll then

		setProperty(
			'songSpeed',
			scrollSpeedValue
		)

		return scrollSpeedValue

	else

		local finalSpeed =
			playbackRateValue *
			scrollSpeedValue


		setProperty(
			'songSpeed',
			finalSpeed
		)


		return finalSpeed

	end
end



local function initializeSpeed()

	if speedInitialized then
		return
	end


	local rate =
		getProperty(
			'playbackRate'
		)


	local speed =
		getProperty(
			'songSpeed'
		)


	if rate == nil then
		rate = 1
	end


	if speed == nil then
		speed = 1
	end


	playbackRateValue =
		math.max(
			0.1,
			rate
		)


	scrollSpeedValue =
		math.max(
			0.1,
			speed / playbackRateValue
		)


	defaultScrollSpeed =
		scrollSpeedValue


	speedInitialized = true
end



local function changePlaybackRate(amount)

	initializeSpeed()


	local newRate =
		math.max(
			0.1,
			playbackRateValue + amount
		)


	if newRate == playbackRateValue then
		return
	end


	playbackRateValue =
		newRate


	local finalSpeed =
		updateSongSpeed()


	local text =
		amount > 0
		and "+"..amount
		or amount


	devPrint(
		getLang(false,
			"Playback_Info",
			text,
			playbackRateValue,
			scrollSpeedValue,
			finalSpeed
		)
	)
end



local function changeScrollSpeed(amount)

	initializeSpeed()


	local newSpeed =
		math.max(
			0.1,
			scrollSpeedValue + amount
		)


	if newSpeed == scrollSpeedValue then
		return
	end


	scrollSpeedValue =
		newSpeed


	local finalSpeed =
		updateSongSpeed()


	local text =
		amount > 0
		and "+"..amount
		or amount


	devPrint(
		getLang(false,
			"Scroll_Info",
			text,
			scrollSpeedValue,
			playbackRateValue,
			finalSpeed
		)
	)
end
local function resetPlaybackRate()

	initializeSpeed()

	playbackRateValue = 1


	local finalSpeed =
		updateSongSpeed()


	devPrint(
		getLang(false,
			"Playback_Reset",
			playbackRateValue,
			scrollSpeedValue,
			finalSpeed
		)
	)
end



local function resetScrollSpeed()

	initializeSpeed()


	scrollSpeedValue =
		defaultScrollSpeed


	local finalSpeed =
		updateSongSpeed()


	devPrint(
		getLang(false,
			"Scroll_Reset",
			scrollSpeedValue,
			playbackRateValue,
			finalSpeed
		)
	)
end



local function resetHealth()

	setProperty(
		'health',
		1
	)


	devPrint(
		getLang(false,
			"Health_Reset"
		)
	)
end



local function changeHealth(amount)

	local health =
		getProperty(
			'health'
		)
		or 1


	health =
		math.max(
			0,
			math.min(
				2,
				health + amount
			)
		)


	setProperty(
		'health',
		health
	)


	local changeText


	if amount > 0 then

		changeText =
			"+"..
			math.floor(
				amount * 50
			)
			.."%"

	else

		changeText =
			" "..
			math.floor(
				amount * 50
			)
			.."%"

	end

	local text = math.floor(health * 50).."%"

	devPrint(
		getLang(false,
			"Health_Info",
			changeText,
			text
		)
	)
end



local function trySoftPause()

	local success =
		pcall(function()

			runHaxeCode([[
				if(game.timing!=null)
					game.timing.pause();

				if(FlxG.sound.music!=null)
					FlxG.sound.music.pause();

				if(game.vocals!=null)
					game.vocals.pause();

				if(game.opponentVocals!=null)
					game.opponentVocals.pause();
			]])

		end)


	if not success then
		return false
	end


	local musicReady =
		pcall(function()

			return getProperty(
				'vocals.time'
			) ~= nil

		end)


	local timingReady =
		pcall(function()

			return getProperty(
				'songPosition'
			) ~= nil

		end)


	return musicReady or timingReady
end



local function ensureSoftPause()

	pcall(function()

		runHaxeCode([[
			if(game.timing!=null)
				game.timing.pause();

			if(FlxG.sound.music!=null)
				FlxG.sound.music.pause();

			if(game.vocals!=null)
				game.vocals.pause();

			if(game.opponentVocals!=null)
				game.opponentVocals.pause();
		]])

	end)

end



local function startSoftPause()

	softPauseWaiting = true
	softPauseTimer = 0

	setSoftPauseText(false)

end



local function resumeSoftPause()

	local ok,err =
		pcall(function()

			runHaxeCode([[
				if(FlxG.sound.music!=null)
					FlxG.sound.music.resume();

				if(game.vocals!=null)
					game.vocals.resume();

				if(game.opponentVocals!=null)
					game.opponentVocals.resume();

				if(game.timing!=null)
					game.timing.resume();
			]])

		end)


	if ok then

		setSoftPauseText(false)

		devPrint(
			getLang(false,
				"SoftPause_OFF"
			)
		)

	else

		devError(
			tostring(err)
		)

	end
end
function onCreate()
	onCreateTestCodes()
	setObjectCamera('botplayTxt', 'hud')
	setObjectOrder('botplayTxt',11000)
	devPrint(getLang(false,"Language_Current").." : "..getLang(false,"Language_Name"))
	advancedDebugMode =
		getSetting(
			"advancedDebugMode",
			false
		)

	developerMode =
		getSetting(
			"developerMode",
			false
		)

	showcaseMode =
		getSetting(
			"showCaseMode",
			false
		)

	hideDevPrint =
		getSetting(
			"hideDevPrint",
			false
		)

	hideDevError =
		getSetting(
			"hideDevError",
			false
		)


	if advancedDebugMode then

		hideDevPrint = false
		hideDevError = false

	end


	disableCheckVer =
		getSetting(
			"disableCheckVer",
			false
		)


	softPauseEnabled =
		getSetting(
			"softPause",
			false
		)


	disableBotplay =
		getSetting(
			"disableBotplay",
			false
		)

    originalHealthBar =
        getSetting(
            'originalHealthBar',
            false
        )

	if showcaseMode then
		return
	end



	if disableCheckVer then

		devWarn(
			getLang(false,
				"Warning_Version"
			)
		)

		devWarn(
			getLang(false,
				"Warning_Debug"
			)
		)


	elseif not isNovaFlare() then


		devError(
			getLang(false,
				"Error_Engine"
			)
		)

		devError(
			getLang(false,
				"Error_Stop"
			)
		)


		return

	end



	if not developerMode then
		return
	end



	scriptEnabled = true


	botActive =
		getProperty(
			'cpuControlled'
		)
		or false


	practiceMode =
		getProperty(
			'practiceMode'
		)
		or false



	local textY = 500


	local success,downScroll =
		pcall(function()

			return getPropertyFromClass(
				'ClientPrefs',
				'data.downScroll'
			)

		end)



	if success and downScroll then
		textY = 140
	end



	makeLuaText(
		'softPauseText',
		getLang(false,"SoftPause_Text", Key.Modifier.SoftPauseModifierAndExit),
		1270,
		0,
		textY
	)


	addLuaText(
		'softPauseText',
		true
	)
	
	setObjectCamera(
		'softPauseText',
		'other'
	)

	setObjectOrder(
		'softPauseText',
		90001
	)

	setTextSize(
		'softPauseText',
		40
	)


	setTextAlignment(
		'softPauseText',
		'center'
	)


	setProperty(
		'softPauseText.visible',
		false
	)



	devPrint(
		getLang(false,
			"Developer_Loaded"
		)
	)



	if softPauseEnabled then

		devPrint(
			getLang(false,
				"SoftPause_Enable"
			)
		)

	end

end



function onSongStart()

	if not scriptEnabled then
		return
	end


	noResetEnabled =
		getNoReset()



	if not noResetEnabled then

		devWarn(
			getLang(false,
				"Warning_NoReset"
			)
		)


		devWarn(
			getLang(false,
				"Warning_EnableNoReset"
			)
		)

	end

end

function onUpdate(elapsed)
	onUpdateTestCodes()
    if not scriptEnabled then
        return
    end


    keyCooldown = math.max(
        0,
        keyCooldown - elapsed
    )


    if not speedInitialized then
        initializeSpeed()
    end



    -- Reset

    if keyboardPressed(Key.Toggle.Reset)
    and keyCooldown <= 0 then


        -- Ctrl + R

        if keyboardPressed(Key.Modifier.Control) then

            resetPlaybackRate()

            keyCooldown = 0.3
            return

        end



        -- Alt + R

        if keyboardPressed(Key.Modifier.Alt) then

            resetHealth()

            keyCooldown = 0.3
            return

        end



        -- Shift + R

        if keyboardPressed(Key.Modifier.Shift) then

            resetScrollSpeed()

            keyCooldown = 0.3
            return

        end

    end



    -- Soft Pause waiting

    if softPauseWaiting then


        softPauseTimer =
            softPauseTimer + elapsed



        if keyboardJustPressed(Key.Toggle.Increase)
        and keyboardPressed(Key.Modifier.Control)
        and keyCooldown <= 0 then


            changePlaybackRate(
                keyboardPressed(Key.Modifier.Shift)
                and 0.5
                or 0.1
            )


            keyCooldown = 0.1
            return

        end



        if keyboardJustPressed(Key.Toggle.Decrease)
        and keyboardPressed(Key.Modifier.Control)
        and keyCooldown <= 0 then


            changePlaybackRate(
                keyboardPressed(Key.Modifier.Shift)
                and -0.5
                or -0.1
            )


            keyCooldown = 0.1
            return

        end



        if trySoftPause() then


            softPauseWaiting = false
            softPaused = true
            softPauseTimer = 0


            setSoftPauseText(true)


            devPrint(
                getLang(false,"SoftPause_ON")
            )



        elseif softPauseTimer >= softPauseTimeout then


            softPauseWaiting = false
            softPaused = false
            softPauseTimer = 0


            setSoftPauseText(false)


            devError(
                getLang(false,"SoftPause_Timeout")
            )

        end


        return

    end



    -- Ctrl + N

    if keyboardJustPressed(Key.Toggle.Increase)
    and keyboardPressed(Key.Modifier.Control)
    and keyCooldown <= 0 then


        changePlaybackRate(
            keyboardPressed(Key.Modifier.Shift)
            and 0.5
            or 0.1
        )


        keyCooldown = 0.1
        return

    end



    -- Ctrl + M

    if keyboardJustPressed(Key.Toggle.Decrease)
    and keyboardPressed(Key.Modifier.Control)
    and keyCooldown <= 0 then


        changePlaybackRate(
            keyboardPressed(Key.Modifier.Shift)
            and -0.5
            or -0.1
        )


        keyCooldown = 0.1
        return

    end
    -- 保持 Soft Pause

    if softPauseEnabled
    and softPaused then

        ensureSoftPause()

    end



    -- SPACE退出 Soft Pause

    if softPauseEnabled
    and softPaused
    and keyboardJustPressed(Key.Modifier.SoftPauseModifierAndExit)
    and keyCooldown <= 0 then


        softPaused = false


        resumeSoftPause()


        keyCooldown = 0.3

        return

    end



    -- SPACE + H

    if softPauseEnabled
    and not softPaused
    and not softPauseWaiting
    and keyboardJustPressed(Key.Toggle.SoftPause1)
    and keyboardPressed(Key.Modifier.SoftPauseModifierAndExit)
    and keyCooldown <= 0 then


        startSoftPause()


        keyCooldown = 0.3

        return

    end



    -- SPACE + G

    if softPauseEnabled
    and not softPaused
    and not softPauseWaiting
    and keyboardJustPressed(Key.Toggle.SoftPause2)
    and keyboardPressed(Key.Modifier.SoftPauseModifierAndExit)
    and keyCooldown <= 0 then


        startSoftPause()


        keyCooldown = 0.3

        return

    end



    -- Shift + C Fake Botplay

    if keyboardJustPressed(Key.Toggle.Botplay)
    and not disableBotplay
    and keyboardPressed(Key.Modifier.Shift)
    and keyCooldown <= 0 then


        botActive =
            getProperty('cpuControlled')
            or false



        if botActive then

            devError(
                getLang(false,"Botplay_Disable")
            )


            keyCooldown = 0.3

            return

        end



        fakeBotActive =
            not fakeBotActive



        setProperty(
            'botplayTxt.visible',
            fakeBotActive
        )



        if fakeBotActive then

            devPrint(
                getLang(false,"FakeBotplay_ON")
            )


        else

            devPrint(
                getLang(false,"FakeBotplay_OFF")
            )

        end



        keyCooldown = 0.3

        return

    end



    -- C Botplay

    if keyboardJustPressed(Key.Toggle.Botplay)
    and not disableBotplay
    and not keyboardPressed(Key.Modifier.Shift)
    and keyCooldown <= 0 then


        botActive =
            not botActive



        setProperty(
            'cpuControlled',
            botActive
        )



        local changeBotText =
            getSetting(
                'showBotText',
                true
            )



        if botActive then


            fakeBotActive = false



            if changeBotText
            and not originalHealthBar then

                setProperty(
                    'botplayTxt.visible',
                    true
                )

            end



            devPrint(
                getLang(false,"Botplay_ON")
            )



        else


            if changeBotText then

                setProperty(
                    'botplayTxt.visible',
                    false
                )

            end



            fakeBotActive = false



            devPrint(
                getLang(false,"Botplay_OFF")
            )

        end



        keyCooldown = 0.3

        return

    end



    -- V Practice Mode

    if keyboardJustPressed(Key.Toggle.Practice)
    and keyCooldown <= 0 then


        practiceMode =
            not practiceMode



        setProperty(
            'practiceMode',
            practiceMode
        )



        if practiceMode then

            devPrint(
                getLang(false,"Practice_ON")
            )


        else

            devPrint(
                getLang(false,"Practice_OFF")
            )

        end



        keyCooldown = 0.3

        return

    end
    -- P 输出开关

    if keyboardJustPressed(Key.Toggle.Print)
    and not disableCheckVer
    and keyCooldown <= 0
    and not advancedDebugMode then


        hideDevPrint =
            not hideDevPrint



        if not hideDevPrint then

            devPrint(
                getLang(false,"Print_ON")
            )


        else

            for ii = 1,100 do
                debugPrint(" ")
            end

        end



        keyCooldown = 0.3

        return

    end



    -- N Scroll Speed / Health+

    if keyboardJustPressed(Key.Toggle.Increase)
    and keyCooldown <= 0 then


        if keyboardPressed(Key.Modifier.Alt) then


            changeHealth(
                keyboardPressed(Key.Modifier.Shift)
                and 0.4
                or 0.1
            )


            keyCooldown = 0.1


        else


            changeScrollSpeed(
                keyboardPressed(Key.Modifier.Shift)
                and 0.5
                or 0.1
            )


            keyCooldown = 0.1


        end


        return

    end



    -- M Scroll Speed / Health-

    if keyboardJustPressed(Key.Toggle.Decrease)
    and keyCooldown <= 0 then


        if keyboardPressed(Key.Modifier.Alt) then


            changeHealth(
                keyboardPressed(Key.Modifier.Shift)
                and -0.4
                or -0.1
            )


            keyCooldown = 0.1


        else


            changeScrollSpeed(
                keyboardPressed(Key.Modifier.Shift)
                and -0.5
                or -0.1
            )


            keyCooldown = 0.1


        end


        return

    end

end



function onDestroy()

    if softPaused
    or softPauseWaiting then


        pcall(function()

            runHaxeCode([[
                if(FlxG.sound.music != null)
                    FlxG.sound.music.resume();

                if(game.vocals != null)
                    game.vocals.resume();

                if(game.opponentVocals != null)
                    game.opponentVocals.resume();

                if(game.timing != null)
                    game.timing.resume();
            ]])


        end)



        softPaused = false
        softPauseWaiting = false
        softPauseTimer = 0

    end

end