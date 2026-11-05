--================================================
-- Unsent's ToolBox - Advanced Debug Mode
-- TEST BUILD
--================================================
--================================================
-- Safe Setting
--================================================
local temp_psychVersion = version
local temp_disableCheckVer = getModSetting("disableCheckVer") if temp_disableCheckVer == nil then temp_disableCheckVer = false end
local success,result =
	pcall(function()
		local opponent =
			getProperty(
				'cpuControlled_opponent'
			)
		return opponent ~= nil
	end)
temp_isNFE = success and result


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

local languages = safeReadJson("data/language.json") or {["###GloBal_Language"]={Language_ReadError="Language Setting Read ERROR! 语言设置加载错误！"},English={Language_Name="English (Read Language File ERROR!)",Language_Current="Current Language",Enable="Enable",Disable="Disable",Enabled="Enabled",Disabled="Disabled",ModSetting_ReadError="ERROR: Failed to read Toolbox Mod Setting: {1} (Value is Nil),Will Use Default Value : {2}",FakeBotplay_ON="Fake Botplay: ON",FakeBotplay_OFF="Fake Botplay: OFF",Botplay_ON="Botplay: ON",Botplay_OFF="Botplay: OFF",Practice_ON="Practice Mode: ON",Practice_OFF="Practice Mode: OFF",SoftPause_ON="Soft Pause: ON",SoftPause_OFF="Soft Pause: OFF",SoftPause_Enable="Soft Pause: Enabled",SoftPause_Text="SOFT PAUSE\nPress {1} to Exit Soft Pause",SoftResume_Error="Soft Resume Error: {1}",SoftPause_Timeout="Soft Pause initialization timed out after 3 seconds!",Advanced_Debug="Advanced Debug Mode",AD_Playback_Rate="PlayBack Rate",AD_Scroll_Speed="Scroll Speed",AD_Practice="Practice Mode",AD_Botplay="Botplay",AD_BPM="BPM",AD_Song_Start="Song Start",AD_Difficulty="Difficulty",Playback_Info="Playback Rate {1} : {2} | Scroll Speed : {3} | Song Speed : {4}",Scroll_Info="Scroll Speed {1} : {2} | Playback Rate : {3} | Song Speed : {4}",Playback_Reset="Playback Rate RESET : {1} | Scroll Speed : {2} | Song Speed : {3}",Scroll_Reset="Scroll Speed RESET : {1} | Playback Rate : {2} | Song Speed : {3}",Health_Reset="Health RESET : 50%",Health_Info="Health {1} : {2}",Warning_Version="WARNING: Engine Version Check Disabled!",Warning_Debug="Debug output cannot be disabled while this option is enabled.",Error_Engine="ERROR: NovaFlare Engine required!",Error_Stop="Unsent's ToolBox stopped.",Developer_Loaded="Unsent's ToolBox Loaded",Warning_NoReset="WARNING: No Reset is disabled!",Warning_EnableNoReset="Please enable No Reset before using \"Reset Property\"!",Botplay_Disable="Please turn OFF Botplay first!",Toolbox_Print_ON="Toolbox Print: ON"}}
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

local function getLang(key, ...)
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

local function advGetSetting(isGlobal,key, default)
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

local advancedDebugMode = false
local advancedDebugTimer = 0
local advancedDebugCreated = false
local advancedDebugLastState = {}

--================================================
-- Safe Property
--================================================

local function advGetProperty(name, default)
    local ok, value = pcall(function()
        return getProperty(name)
    end)

    if ok and value ~= nil then
        return value
    end

    return default
end

--================================================
-- Safe Class Property
--================================================

local function advGetPropertyFromClass(className, propertyName, default)
    local ok, value = pcall(function()
        return getPropertyFromClass(
            className,
            propertyName
        )
    end)

    if ok and value ~= nil then
        return value
    end

    return default
end

--================================================
-- HScript Trace
--================================================

local function advTrace(text)
    pcall(function()
        runHaxeCode(
            "trace("
            .. string.format("%q", tostring(text))
            .. ");"
        )
    end)
end

--================================================
-- Advanced Debug Output
--================================================

function unsentAdvancedDebugLog(message)
    if not advancedDebugMode then
        return
    end

    local text =
        "[Unsent's toolbox][Advanced Debug] "
        .. tostring(message or "")

    if debugPrint then
        pcall(function()
            debugPrint(
                text,
                "WHITE"
            )
        end)
    end

    advTrace(text)
end

--================================================
-- Time Format
--================================================

local function advFormatTime(ms)
    ms = math.max(
        0,
        tonumber(ms) or 0
    )

    local totalSeconds =
        math.floor(ms / 1000)

    local minutes =
        math.floor(totalSeconds / 60)

    local seconds =
        totalSeconds % 60

    local milliseconds =
        math.floor(ms % 1000)

    return string.format(
        "%02d:%02d.%03d",
        minutes,
        seconds,
        milliseconds
    )
end

--================================================
-- Conductor Song Position
--================================================

local function advGetSongPosition()
    local position =
        advGetPropertyFromClass(
            "Conductor",
            "songPosition",
            nil
        )

    if position ~= nil then
        return tonumber(position) or 0
    end

    return tonumber(
        advGetProperty(
            "songPosition",
            0
        )
    ) or 0
end

--================================================
-- Conductor BPM
--================================================

local function advGetBPM()
    local bpm =
        advGetPropertyFromClass(
            "Conductor",
            "bpm",
            nil
        )

    if bpm ~= nil then
        return tonumber(bpm) or 0
    end

    bpm =
        advGetProperty(
            "curBpm",
            nil
        )

    if bpm ~= nil then
        return tonumber(bpm) or 0
    end

    return tonumber(
        advGetProperty(
            "bpm",
            0
        )
    ) or 0
end

--================================================
-- Difficulty
--================================================

local function advDifficulty()
    if difficultyName ~= nil then
        return tostring(
            difficultyName
        )
    end

    return tostring(
        advGetProperty(
            "storyDifficulty",
            "?"
        )
    )
end

--================================================
-- Boolean Format
--================================================

local function advBool(value)
    if value then
        return "ON"
    end

    return "OFF"
end

--================================================
-- Screen Height
--================================================

local function advGetScreenHeight()
    local screenHeight = 720

    local ok, value = pcall(function()
        return getPropertyFromClass(
            "flixel.FlxG",
            "height"
        )
    end)

    if ok and value ~= nil then
        screenHeight =
            tonumber(value)
            or screenHeight
    end

    return screenHeight
end

--================================================
-- HUD Position
--================================================

local function advUpdateHUDPosition()
    if not advancedDebugCreated then
        return
    end

    local screenHeight =
        advGetScreenHeight()

    local textHeight =
        tonumber(
            advGetProperty(
                "unsentAdvancedDebug.height",
                0
            )
        )
        or 0

    setProperty(
        "unsentAdvancedDebug.x",
        8
    )

    setProperty(
        "unsentAdvancedDebug.y",
        math.max(
            8,
            screenHeight
            - textHeight
            - 8
        )
    )
end

--================================================
-- Create Debug HUD
--================================================

local function advCreateHUD()
    makeLuaText(
        "unsentAdvancedDebug",
        "",
        0,
        8,
        0
    )

    -- Use Consolab font.
    setTextFont(
        "unsentAdvancedDebug",
        "consolab.ttf"
    )

    setTextSize(
        "unsentAdvancedDebug",
        16
    )

    setTextAlignment(
        "unsentAdvancedDebug",
        "left"
    )

    -- Use the HUD/UI camera.
    -- Downscroll will not move this text.
    setObjectCamera(
        "unsentAdvancedDebug",
        "other"
    )

    setProperty(
        "unsentAdvancedDebug.alpha",
        1
    )

    addLuaText(
        "unsentAdvancedDebug",
        true
    )

    advancedDebugCreated = true

    advUpdateHUDPosition()
end

--================================================
-- Update Debug HUD
--================================================

local function advUpdateHUD()
    if not advancedDebugCreated then
        return
    end

    local songPosition =
        advGetSongPosition()

	local songLength =
		tonumber(
			advGetProperty(
				"songLength",
				0
			)
		)
		or 0


	local realSongLength = 0


	pcall(function()
		runHaxeCode([[
			var len:Float = 0;

			if(FlxG.sound.music != null)
			{
				len = FlxG.sound.music.length;
			}

			game.setOnScripts('advRealSongLength',len);
		]])
	end)


	local realSongLength =
		tonumber(
			getPropertyFromClass(
				'flixel.FlxG',
				'sound.music.length'
			)
		)
		or 0

    local health =
        tonumber(
            advGetProperty(
                "health",
                1
            )
        )
        or 1

    local score =
        advGetProperty(
            "songScore",
            advGetProperty(
                "score",
                0
            )
        )

    local misses =
        advGetProperty(
            "songMisses",
            advGetProperty(
                "misses",
                0
            )
        )

    local combo =
        advGetProperty(
            "combo",
            0
        )

    local playbackRate =
        tonumber(
            advGetProperty(
                "playbackRate",
                1
            )
        )
        or 1

    local songSpeed =
        tonumber(
            advGetProperty(
                "songSpeed",
                1
            )
        )
        or 1

    local bpm =
        advGetBPM()

    local songName =
        tostring(
            advGetProperty(
                "songName",
                "Unknown"
            )
        )

    local step =
        tostring(
            curStep or 0
        )

    local beat =
        tostring(
            curBeat or 0
        )

    local section =
        tostring(
            curSection or 0
        )

    local botplay =
        advGetProperty(
            "cpuControlled",
            false
        )

    local practice =
        advGetProperty(
            "practiceMode",
            false
        )

    local healthPercent =
        health * 50

    local text =
        table.concat({
            "[Unsent's ToolBox - Advanced Debug]",

            "Song       : "
                .. songName,

            "Difficulty : "
                .. advDifficulty(),

			"Time       : "
				.. advFormatTime(songPosition)
				.. " / "
				.. advFormatTime(songLength)
				.. " (Real: "
				.. advFormatTime(realSongLength)
				.. ")",
			
            "Step       : "
                .. step,

            "Beat       : "
                .. beat,

            "Section    : "
                .. section,

            "BPM        : "
                .. string.format(
                    "%.2f",
                    bpm
                ),

            "Health     : "
                .. string.format(
                    "%.1f%%",
                    healthPercent
                ),

            "Score      : "
                .. tostring(
                    score
                ),

            "Misses     : "
                .. tostring(
                    misses
                ),

            "Combo      : "
                .. tostring(
                    combo
                ),

            "Playback   : "
                .. string.format(
                    "%.2fx",
                    playbackRate
                ),

            "Scroll     : "
                .. string.format(
                    "%.2f",
                    songSpeed
                ),

            "Song Speed : "
                .. string.format(
                    "%.2f",
                    songSpeed
                ),

            "Botplay    : "
                .. advBool(
                    botplay
                ),

            "Practice   : "
                .. advBool(
                    practice
                )
        }, "\n")

    setTextString(
        "unsentAdvancedDebug",
        text
    )

    advUpdateHUDPosition()
end

--================================================
-- State Tracking
--================================================

local function advTrackState(name, value)
    if not advancedDebugMode then
        return
    end

    value = tostring(value)

    if advancedDebugLastState[name] ~= value then
        if advancedDebugLastState[name] ~= nil then
            unsentAdvancedDebugLog(
                name
                .. " -> "
                .. value
            )
        end

        advancedDebugLastState[name] =
            value
    end
end

--================================================
-- Create
--================================================

function onCreate()
    advancedDebugMode =
        advGetSetting(false,
            "advancedDebugMode",
            false
        )

    if not advancedDebugMode then
        return
    end

    advCreateHUD()

    advUpdateHUD()

    unsentAdvancedDebugLog(
        getLang("Advanced_Debug").." : "..getLang("ON")
    )

end

--================================================
-- Song Start
--================================================

function onSongStart()
    if not advancedDebugMode then
        return
    end

    local songName =
        tostring(
            advGetProperty(
                "songName",
                "Unknown"
            )
        )

    unsentAdvancedDebugLog(
        getLang("AD_Song_Start").." : "
        .. songName
    )

    unsentAdvancedDebugLog(
        getLang("AD_Difficulty").." : "
        .. advDifficulty()
    )

    unsentAdvancedDebugLog(
        getLang("AD_BPM").." : "
        .. string.format(
            "%.2f",
            advGetBPM()
        )
    )
end

--================================================
-- Update
--================================================

function onUpdate(elapsed)
    if not advancedDebugMode then
        return
    end

    advancedDebugTimer =
        advancedDebugTimer
        + elapsed

    if advancedDebugTimer < 0.1 then
        return
    end

    advancedDebugTimer = 0

    advUpdateHUD()

    --================================================
    -- Track Important Runtime States
    --================================================

    advTrackState(
        getLang("AD_Botplay"),
        advGetProperty(
            "cpuControlled",
            false
        )
    )

    advTrackState(
        getLang("AD_Practice"),
        advGetProperty(
            "practiceMode",
            false
        )
    )

    advTrackState(
        getLang("AD_Playback_Rate"),
        advGetProperty(
            "playbackRate",
            1
        )
    )

    advTrackState(
        getLang("AD_Scroll_Speed"),
        advGetProperty(
            "songSpeed",
            1
        )
    )

    advTrackState(
        getLang("AD_BPM"),
        advGetBPM()
    )
end

--================================================
-- Destroy
--================================================

function onDestroy()
    if not advancedDebugMode then
        return
    end

    unsentAdvancedDebugLog(
        getLang("Advanced_Debug").." : "..getLang("OFF")
    )
end