--================================================
-- Unsent's ToolBox - Advanced Debug Mode
-- TEST BUILD
--================================================

local advancedDebugMode = false
local advancedDebugTimer = 0
local advancedDebugCreated = false
local advancedDebugLastState = {}

--================================================
-- Safe Setting
--================================================

local function advGetSetting(key, default)
    if not getModSetting then
        return default
    end

    local ok, value = pcall(function()
        return getModSetting(key)
    end)

    if ok and value ~= nil then
        return value
    end

    return default
end

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
        0.92
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

			setOnScripts('advRealSongLength',len);
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
                    "%.2fx",
                    songSpeed
                ),

            "Song Speed : "
                .. string.format(
                    "%.2fx",
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
        advGetSetting(
            "advancedDebugMode",
            false
        )

    if not advancedDebugMode then
        return
    end

    advCreateHUD()

    advUpdateHUD()

    unsentAdvancedDebugLog(
        "Advanced Debug Mode : ON"
    )

    unsentAdvancedDebugLog(
        "Debug HUD : Created"
    )

    unsentAdvancedDebugLog(
        "Debug Output : debugPrint + trace"
    )

    unsentAdvancedDebugLog(
        "HUD Position : Bottom Left"
    )

    unsentAdvancedDebugLog(
        "HUD Font : consolab.ttf"
    )

    unsentAdvancedDebugLog(
        "Downscroll Safe : ON"
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
        "Song Start : "
        .. songName
    )

    unsentAdvancedDebugLog(
        "Difficulty : "
        .. advDifficulty()
    )

    unsentAdvancedDebugLog(
        "BPM : "
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
        "Botplay",
        advGetProperty(
            "cpuControlled",
            false
        )
    )

    advTrackState(
        "Practice",
        advGetProperty(
            "practiceMode",
            false
        )
    )

    advTrackState(
        "Playback Rate",
        advGetProperty(
            "playbackRate",
            1
        )
    )

    advTrackState(
        "Song Speed",
        advGetProperty(
            "songSpeed",
            1
        )
    )

    advTrackState(
        "BPM",
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
        "Advanced Debug Mode : OFF"
    )
end