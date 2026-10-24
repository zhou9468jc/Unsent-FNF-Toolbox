-- ============================================================
-- Unsent's Toolbox NF Ver
-- Main Script
-- ============================================================
-- version check
UnsentToolbox_NFEVersion = nil  --{ 1.2.0(+) / 1.1.8(-) / 1.0.1 / nil }
local temp_psychVersion = version
local temp_disableCheckVer = getModSetting("disableCheckVer") if temp_disableCheckVer == nil then temp_disableCheckVer = false end
if not temp_disableCheckVer then
	local success,result =
		pcall(function()
			local opponent =
				getProperty(
					'cpuControlled_opponent'
				)
			return opponent ~= nil
		end)
	temp_isNFE = success and result

	if temp_isNFE == false then
		UnsentToolbox_NFEVersion = nil
	elseif temp_psychVersion == "0.6.3" then
		UnsentToolbox_NFEVersion = "1.0.1"
	elseif temp_psychVersion == "0.7.3" and not (type(readJson) == "function") then
		UnsentToolbox_NFEVersion = "1.1.8"
	else
		UnsentToolbox_NFEVersion = "1.2.0"
	end

	pcall(runHaxeCode, 'trace("[Unsent\'s Toolbox] Current Version About: ' .. tostring(UnsentToolbox_NFEVersion) .. '");')
end
--==================================================
--老祖宗gpt之手挫json解析器
local JSON_NULL=setmetatable({},{__tostring=function()return"JSON_NULL"end}) local function parseJson(str) if type(str)~="string"then return nil end local pos,len=1,#str local function skip()while pos<=len and str:sub(pos,pos):match("%s")do pos=pos+1 end end local parseValue local function parseString() pos=pos+1 local out={} while pos<=len do local c=str:sub(pos,pos);pos=pos+1 if c=='"'then return table.concat(out) elseif c=="\\"then local e=str:sub(pos,pos);pos=pos+1 local escapes={['"']='"',["\\"]="\\",["/"]="/",b="\b",f="\f",n="\n",r="\r",t="\t"} if escapes[e]then out[#out+1]=escapes[e] elseif e=="u"then local h=str:sub(pos,pos+3);if not h:match("^%x%x%x%x$")then error("Invalid Unicode")end pos=pos+4 local cp=tonumber(h,16) if cp>=0xD800 and cp<=0xDBFF then if str:sub(pos,pos+1)~="\\u"then error("Invalid surrogate")end local l=str:sub(pos+2,pos+5);if not l:match("^%x%x%x%x$")then error("Invalid surrogate")end local lp=tonumber(l,16);if lp<0xDC00 or lp>0xDFFF then error("Invalid surrogate")end cp=0x10000+(cp-0xD800)*0x400+lp-0xDC00;pos=pos+6 elseif cp>=0xDC00 and cp<=0xDFFF then error("Unexpected low surrogate")end if cp<0x80 then out[#out+1]=string.char(cp) elseif cp<0x800 then out[#out+1]=string.char(0xC0+math.floor(cp/64),0x80+cp%64) elseif cp<0x10000 then out[#out+1]=string.char(0xE0+math.floor(cp/4096),0x80+math.floor(cp/64)%64,0x80+cp%64) else out[#out+1]=string.char(0xF0+math.floor(cp/262144),0x80+math.floor(cp/4096)%64,0x80+math.floor(cp/64)%64,0x80+cp%64)end else error("Invalid escape")end else if c:byte()<32 then error("Invalid control character")end;out[#out+1]=c end end error("Unterminated string") end local function parseNumber() local start=pos if str:sub(pos,pos)=="-"then pos=pos+1 end local c=str:sub(pos,pos) if c=="0"then pos=pos+1;if str:sub(pos,pos):match("%d")then error("Leading zero")end else if not c:match("[1-9]")then error("Invalid number")end;while str:sub(pos,pos):match("%d")do pos=pos+1 end end if str:sub(pos,pos)=="."then pos=pos+1;if not str:sub(pos,pos):match("%d")then error("Invalid fraction")end;while str:sub(pos,pos):match("%d")do pos=pos+1 end end c=str:sub(pos,pos) if c=="e"or c=="E"then pos=pos+1;c=str:sub(pos,pos);if c=="+"or c=="-"then pos=pos+1 end;if not str:sub(pos,pos):match("%d")then error("Invalid exponent")end;while str:sub(pos,pos):match("%d")do pos=pos+1 end end local n=tonumber(str:sub(start,pos-1));if n==nil then error("Invalid number")end;return n end local function parseArray() pos=pos+1;skip();local arr={} if str:sub(pos,pos)=="]"then pos=pos+1;return arr end while true do arr[#arr+1]=parseValue();skip();local c=str:sub(pos,pos);if c=="]"then pos=pos+1;return arr elseif c~=","then error("Expected ',' or ']'")end;pos=pos+1;skip()end end local function parseObject() pos=pos+1;skip();local obj={} if str:sub(pos,pos)=="}"then pos=pos+1;return obj end while true do if str:sub(pos,pos)~='"'then error("Expected object key")end local key=parseString();skip() if str:sub(pos,pos)~=":"then error("Expected ':'")end pos=pos+1;skip();obj[key]=parseValue();skip() local c=str:sub(pos,pos);if c=="}"then pos=pos+1;return obj elseif c~=","then error("Expected ',' or '}'")end;pos=pos+1;skip() end end parseValue=function() skip();local c=str:sub(pos,pos) if c=='"'then return parseString()elseif c=="{"then return parseObject()elseif c=="["then return parseArray()elseif c=="-"or c:match("%d")then return parseNumber()end for _,v in ipairs({{"true",true},{"false",false},{"null",JSON_NULL}})do if str:sub(pos,pos+#v[1]-1)==v[1]then pos=pos+#v[1];return v[2]end end error("Unexpected token at position "..pos) end local ok,result=pcall(function()local v=parseValue();skip();if pos<=len then error("Trailing content")end;return v end) if ok then return result end return nil end local function safeReadJson(value) local content=getTextFromFile(value) if content==nil or content==""then return nil end return parseJson(content) end
--==================================================
local function safeReadJson(value)
    if UnsentToolbox_NFEVersion == "1.2.0" then
        local success, result = pcall(readJson, value)
        if success then return result end
        return nil
    end

    local content = getTextFromFile(value)
    if content == nil or content == "" then return nil end
    return parseJson(content)
end

local Key=safeReadJson("data/keys.json") or {Toggle={Botplay="ONE",Practice="TWO",FakeBotplayModifier="SHIFT",Reset="R",Increase="THREE",Decrease="FOUR",SoftPause1="SIX",SoftPause2="Disabled",Print="FIVE"},Modifier={SoftPauseModifierAndExit="SPACE",Control="CONTROL",Alt="ALT",Shift="SHIFT"}}
Key.Toggle = Key.Toggle or {}
Key.Modifier = Key.Modifier or {}

local languages = safeReadJson("data/language.json") or {["###GloBal_Language"]={Language_ReadError="Language Setting Read ERROR! 语言设置加载错误！"},English={Language_Name="English (Read Language File ERROR!)",Language_Current="Current Language",Enable="Enable",Disable="Disable",Enabled="Enabled",Disabled="Disabled",ModSetting_ReadError="ERROR: Failed to read Toolbox Mod Setting: {1} (Value is Nil),Will Use Default Value : {2}",FakeBotplay_ON="Fake Botplay: ON",FakeBotplay_OFF="Fake Botplay: OFF",Botplay_ON="Botplay: ON",Botplay_OFF="Botplay: OFF",Practice_ON="Practice Mode: ON",Practice_OFF="Practice Mode: OFF",SoftPause_ON="Soft Pause: ON",SoftPause_OFF="Soft Pause: OFF",SoftPause_Enable="Soft Pause: Enabled",SoftPause_Text="SOFT PAUSE\nPress {1} to Exit Soft Pause",SoftResume_Error="Soft Resume Error: {1}",SoftPause_Timeout="Soft Pause initialization timed out after 3 seconds!",Advanced_Debug="Advanced Debug Mode",AD_Playback_Rate="PlayBack Rate",AD_Scroll_Speed="Scroll Speed",AD_Practice="Practice Mode",AD_Botplay="Botplay",AD_BPM="BPM",AD_Song_Start="Song Start",AD_Difficulty="Difficulty",Playback_Info="Playback Rate {1} : {2} | Scroll Speed : {3} | Song Speed : {4}",Scroll_Info="Scroll Speed {1} : {2} | Playback Rate : {3} | Song Speed : {4}",Playback_Reset="Playback Rate RESET : {1} | Scroll Speed : {2} | Song Speed : {3}",Scroll_Reset="Scroll Speed RESET : {1} | Playback Rate : {2} | Song Speed : {3}",Health_Reset="Health RESET : 50%",Health_Info="Health {1} : {2}",Warning_Version="WARNING: Engine Version Check Disabled!",Warning_Debug="Debug output cannot be disabled while this option is enabled.",Error_Engine="ERROR: NovaFlare Engine required!",Error_Stop="Unsent's ToolBox stopped.",Developer_Loaded="Unsent's ToolBox Loaded",Warning_NoReset="WARNING: No Reset is disabled!",Warning_EnableNoReset="Please enable No Reset before using \"Reset Property\"!",Botplay_Disable="Please turn OFF Botplay first!",Toolbox_Print_ON="Toolbox Print: ON"}}
local language = getModSetting("language")

if language == nil then
	local text =
		"[Unsent's ToolBox] Error : "
		..((languages["###GloBal_Language"] or {}).Language_ReadError or "Language_ReadError")
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
if temp_isNFE == false and not temp_disableCheckVer then
	--error("[Unsent's ToolBox]\nIncorrect engine version! PLEASE USE NovaFlare Engine!",0)
	runHaxeCode([[
		FlxG.stage.window.alert(
			"]]..getLang(false,"Incorrect_Engine",tostring(version))..[[",
			"]]..getLang(false,"Incorrect_Engine_Title")..[["
		);
	]])
elseif temp_isNFE and type(readJson) ~= "function" and not temp_disableCheckVer then

	runHaxeCode([[
		FlxG.stage.window.alert(
			"]]..getLang(false,"Version_Too_Old")..[[",
			"]]..getLang(false,"Version_Too_Old_Title")..[["
		);
	]])
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
local enablePauseMus = false

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



--[[local function isNovaFlare()

	local success,result =
		pcall(function()

			local opponent =
				getProperty(
					'cpuControlled_opponent'
				)

			return opponent ~= nil

		end)


	return success and result
end]]--



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
	if temp_isNFE == false then
		developerMode = false
	end
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
    and keyboardPressed(Key.Toggle.FakeBotplayModifier)
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
                getLang(false,"Toolbox_Print_ON")
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