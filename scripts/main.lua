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

local function getSetting(key,default)
    if getModSetting then
        local success,val = pcall(function()
            return getModSetting(key)
        end)
        if success and val ~= nil then
            return val
        end
    end
    return default
end

local function getNoReset()
    local success,value = pcall(function()
        return getPropertyFromClass('ClientPrefs','data.noReset')
    end)
    if success and value ~= nil then
        return value
    end
    return false
end

local function devPrint(text)
    if disableCheckVer or not hideDevPrint then
        if debugPrint then
            debugPrint("[Unsent's toolbox] "..text,"WHITE")
        else
            print("[Unsent's toolbox] "..text)
        end
    end
end

local function devError(text)
    if disableCheckVer or not hideDevError then
        local message="[Unsent's toolbox] "..text
        if debugPrint then
            debugPrint(message,"RED")
        else
            print(message)
        end
    end
end

local function devWarn(text)
    if disableCheckVer or not hideDevError then
        local message="[Unsent's toolbox] "..text
        if debugPrint then
            debugPrint(message,"YELLOW")
        else
            print(message)
        end
    end
end

local function isNovaFlare()
    local success,result=pcall(function()
        local opponent=getProperty('cpuControlled_opponent')
        return opponent~=nil
    end)
    return success and result
end

local function setSoftPauseText(state)
    setProperty('softPauseText.visible',state)
end

local function trySoftPause()
    local success=pcall(function()
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

    local musicReady=pcall(function()
        return getProperty('vocals.time')~=nil
    end)

    local timingReady=pcall(function()
        return getProperty('songPosition')~=nil
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
    softPauseWaiting=true
    softPauseTimer=0
    setSoftPauseText(false)
end

local function resumeSoftPause()
    local ok,err=pcall(function()
        runHaxeCode([[
            if(FlxG.sound.music!=null)
                FlxG.sound.music.resume();
            if(game.vocals!=null)
                game.vocals.resume();
            if(game.opponentVocals!=null)
                game.vocals.resume();
            if(game.timing!=null)
                game.timing.resume();
        ]])
    end)

    if ok then
        setSoftPauseText(false)
        devPrint("Soft Pause : OFF")
    else
        devError("Soft Resume Error: "..tostring(err))
    end
end

local function updateSongSpeed()
    state_playbackRateNoScrollSpeed=getModSetting("playbackRateNoScrollSpeed",false)

    setProperty('playbackRate',playbackRateValue)

    if state_playbackRateNoScrollSpeed==true then
        setProperty('songSpeed',scrollSpeedValue)
        return scrollSpeedValue
    else
        local finalSpeed=playbackRateValue*scrollSpeedValue
        setProperty('songSpeed',finalSpeed)
        return finalSpeed
    end
end

local function initializeSpeed()
    if speedInitialized then
        return
    end

    local rate=getProperty('playbackRate')
    local speed=getProperty('songSpeed')

    if rate==nil then
        rate=1
    end

    if speed==nil then
        speed=1
    end

    playbackRateValue=math.max(0.1,rate)
    scrollSpeedValue=math.max(0.1,speed/playbackRateValue)
    defaultScrollSpeed=scrollSpeedValue

    speedInitialized=true
end

local function changePlaybackRate(amount)
    initializeSpeed()

    local newRate=math.max(0.1,playbackRateValue+amount)

    if newRate==playbackRateValue then
        return
    end

    playbackRateValue=newRate

    local finalSpeed=updateSongSpeed()

    local text=amount>0 and "+"..amount or amount

    devPrint(
        "Playback Rate "..text..
        " : "..playbackRateValue..
        " | Scroll Speed : "..scrollSpeedValue..
        " | Song Speed : "..finalSpeed
    )
end

local function changeScrollSpeed(amount)
    initializeSpeed()

    local newSpeed=math.max(0.1,scrollSpeedValue+amount)

    if newSpeed==scrollSpeedValue then
        return
    end

    scrollSpeedValue=newSpeed

    local finalSpeed=updateSongSpeed()

    local text=amount>0 and "+"..amount or amount

    devPrint(
        "Scroll Speed "..text..
        " : "..scrollSpeedValue..
        " | Playback Rate : "..playbackRateValue..
        " | Song Speed : "..finalSpeed
    )
end
local function resetPlaybackRate()
    initializeSpeed()

    playbackRateValue = 1

    local finalSpeed = updateSongSpeed()

    devPrint(
        "Playback Rate RESET : "..playbackRateValue..
        " | Scroll Speed : "..scrollSpeedValue..
        " | Song Speed : "..finalSpeed
    )
end

local function resetScrollSpeed()
    initializeSpeed()

    scrollSpeedValue = defaultScrollSpeed

    local finalSpeed = updateSongSpeed()

    devPrint(
        "Scroll Speed RESET : "..scrollSpeedValue..
        " | Playback Rate : "..playbackRateValue..
        " | Song Speed : "..finalSpeed
    )
end

local function resetHealth()
    setProperty('health',1)

    devPrint(
        "Health RESET : 50%"
    )
end

local function changeHealth(amount)
    local health = getProperty('health') or 1

    health = math.max(0,math.min(2,health + amount))

    setProperty('health',health)

    local changeText

    if amount > 0 then
        changeText = "+"..math.floor(amount * 50).."%"
    else
        changeText = math.floor(amount * 50).."%"
    end

    devPrint(
        "Health "..changeText..
        " : "..math.floor(health * 50).."%"
    )
end

function onCreate()
    developerMode = getSetting("developerMode",false)
    showcaseMode = getSetting('showCaseMode',false)
    hideDevPrint = getSetting("hideDevPrint",false)
    hideDevError = getSetting("hideDevError",false)
    disableCheckVer = getSetting("disableCheckVer",false)
    softPauseEnabled = getSetting("softPause",false)
    disableBotplay = getSetting("disableBotplay",false)

    if showcaseMode then
        return
    end

    if disableCheckVer then
        devWarn("WARNING: Engine Version Check Disabled!")
        devWarn("Debug output cannot be disabled while this option is enabled.")

    elseif not isNovaFlare() then
        devError("ERROR: NovaFlare Engine required!")
        devError("Developer Toolbox stopped.")
        scriptEnabled = false
        return
    end

    if not developerMode then
        return
    end

    scriptEnabled = true

    botActive = getProperty('cpuControlled') or false
    practiceMode = getProperty('practiceMode') or false

    local textY = 500

    local success,downScroll = pcall(function()
        return getPropertyFromClass('ClientPrefs','data.downScroll')
    end)

    if success and downScroll then
        textY = 140
    end

    makeLuaText(
        'softPauseText',
        'SOFT PAUSE\nPress SPACE to Exit Soft Pause',
        1270,
        0,
        textY
    )

    addLuaText('softPauseText',true)

    setTextSize('softPauseText',40)
    setTextAlignment('softPauseText','center')
    setProperty('softPauseText.visible',false)

    devPrint("Developer Mode Loaded")

    if softPauseEnabled then
        devPrint("Soft Pause : Enabled")
    end
end

function onSongStart()
    if not scriptEnabled then
        return
    end

    noResetEnabled = getNoReset()

    if not noResetEnabled then
        devWarn("WARNING: No Reset is disabled!")
        devWarn('Please enable No Reset before using "Reset Property"!')
    end
end
function onUpdate(elapsed)
    if not scriptEnabled then
        return
    end

    keyCooldown = math.max(0,keyCooldown - elapsed)

    if not speedInitialized then
        initializeSpeed()
    end

    -- R：重置功能
    if keyboardPressed('R') and keyCooldown <= 0 then

        -- Ctrl + R：重置 Playback Rate
        if keyboardPressed('CONTROL') then
            resetPlaybackRate()
            keyCooldown = 0.3
            return
        end

        -- Alt + R：Health 50%
        if keyboardPressed('ALT') then
            resetHealth()
            keyCooldown = 0.3
            return
        end

        -- Shift + R：重置 Scroll Speed
        if keyboardPressed('SHIFT') then
            resetScrollSpeed()
            keyCooldown = 0.3
            return
        end
    end


    -- 等待软暂停初始化
    if softPauseWaiting then
        softPauseTimer = softPauseTimer + elapsed

        if keyboardJustPressed('N') and keyboardPressed('CONTROL') and keyCooldown <= 0 then
            changePlaybackRate(
                keyboardPressed('SHIFT') and 0.5 or 0.1
            )
            keyCooldown = 0.1
            return
        end

        if keyboardJustPressed('M') and keyboardPressed('CONTROL') and keyCooldown <= 0 then
            changePlaybackRate(
                keyboardPressed('SHIFT') and -0.5 or -0.1
            )
            keyCooldown = 0.1
            return
        end

        if trySoftPause() then
            softPauseWaiting = false
            softPaused = true
            softPauseTimer = 0
            setSoftPauseText(true)
            devPrint("Soft Pause : ON")

        elseif softPauseTimer >= softPauseTimeout then
            softPauseWaiting = false
            softPaused = false
            softPauseTimer = 0
            setSoftPauseText(false)

            devError("Soft Pause initialization timed out after 3 seconds!")
        end

        return
    end


    -- Ctrl + N：Playback Rate +
    if keyboardJustPressed('N') and keyboardPressed('CONTROL') and keyCooldown <= 0 then

        changePlaybackRate(
            keyboardPressed('SHIFT') and 0.5 or 0.1
        )

        keyCooldown = 0.1
        return
    end


    -- Ctrl + M：Playback Rate -
    if keyboardJustPressed('M') and keyboardPressed('CONTROL') and keyCooldown <= 0 then

        changePlaybackRate(
            keyboardPressed('SHIFT') and -0.5 or -0.1
        )

        keyCooldown = 0.1
        return
    end


    -- 保持软暂停
    if softPauseEnabled and softPaused then
        ensureSoftPause()
    end


    -- SPACE退出软暂停
    if softPauseEnabled and softPaused and keyboardJustPressed('SPACE') and keyCooldown <= 0 then

        softPaused = false
        resumeSoftPause()

        keyCooldown = 0.3
        return
    end


    -- SPACE + H
    if softPauseEnabled and not softPaused and not softPauseWaiting
    and keyboardJustPressed('H')
    and keyboardPressed('SPACE')
    and keyCooldown <= 0 then

        startSoftPause()

        keyCooldown = 0.3
        return
    end


    -- SPACE + G
    if softPauseEnabled and not softPaused and not softPauseWaiting
    and keyboardJustPressed('G')
    and keyboardPressed('SPACE')
    and keyCooldown <= 0 then

        startSoftPause()

        keyCooldown = 0.3
        return
    end


    -- Shift + C Fake Botplay
    if keyboardJustPressed('C')
    and not disableBotplay
    and keyboardPressed('SHIFT')
    and keyCooldown <= 0 then

        botActive = getProperty('cpuControlled') or false

        if botActive then
            devError("Please turn OFF Botplay first!")
            keyCooldown = 0.3
            return
        end

        fakeBotActive = not fakeBotActive

        setProperty('botplayTxt.visible',fakeBotActive)

        if fakeBotActive then
            devPrint("Fake Botplay : ON")
        else
            devPrint("Fake Botplay : OFF")
        end

        keyCooldown = 0.3
        return
    end


    -- C Botplay
    if keyboardJustPressed('C')
    and not disableBotplay
    and not keyboardPressed('SHIFT')
    and keyCooldown <= 0 then

        botActive = not botActive

        setProperty('cpuControlled',botActive)

        local changeBotText = getSetting('showBotText',true)

        if botActive then

            fakeBotActive = false

            if changeBotText then
                setProperty('botplayTxt.visible',true)
            end

            devPrint("Botplay : ON")

        else

            if changeBotText then
                setProperty('botplayTxt.visible',false)
            end

            fakeBotActive = false

            devPrint("Botplay : OFF")
        end

        keyCooldown = 0.3
        return
    end


    -- V Practice Mode
    if keyboardJustPressed('V') and keyCooldown <= 0 then

        practiceMode = not practiceMode

        setProperty('practiceMode',practiceMode)

        if practiceMode then
            devPrint("Practice Mode : ON")
        else
            devPrint("Practice Mode : OFF")
        end

        keyCooldown = 0.3
        return
    end


    -- P 输出开关
    if keyboardJustPressed('P')
    and not disableCheckVer
    and keyCooldown <= 0 then

        hideDevPrint = not hideDevPrint

        if not hideDevPrint then
            devPrint("Toolbox Print : ON")
        else
            for ii = 1,100 do
                debugPrint(" ")
            end
        end

        keyCooldown = 0.3
        return
    end


    -- N Scroll Speed / Health+
    if keyboardJustPressed('N') and keyCooldown <= 0 then

        if keyboardPressed('ALT') then

            changeHealth(
                keyboardPressed('SHIFT') and 0.4 or 0.1
            )

            keyCooldown = 0.1

        else

            changeScrollSpeed(
                keyboardPressed('SHIFT') and 0.5 or 0.1
            )

            keyCooldown = 0.1
        end

        return
    end


    -- M Scroll Speed / Health-
    if keyboardJustPressed('M') and keyCooldown <= 0 then

        if keyboardPressed('ALT') then

            changeHealth(
                keyboardPressed('SHIFT') and -0.4 or -0.1
            )

            keyCooldown = 0.1

        else

            changeScrollSpeed(
                keyboardPressed('SHIFT') and -0.5 or -0.1
            )

            keyCooldown = 0.1
        end

        return
    end
end


function onDestroy()

    if softPaused or softPauseWaiting then

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