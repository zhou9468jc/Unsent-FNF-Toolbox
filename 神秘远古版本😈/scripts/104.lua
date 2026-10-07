-- ============================================
-- Developer Mode Script
-- Psych Engine 1.0.4
-- ============================================

local botActive = false
local practiceMode = false
local keyCooldown = 0
local scriptEnabled = false

local success, isPE104 = pcall(function()
    return getModSetting("RunOnPE104")
end)

-- Language helper
local function tr(key, ...)
    return getTranslationPhrase(key, ...)
end


-- Developer output control
local function devPrint(text)
    local hide = getModSetting("hideDevPrint") or false

    if not hide then
        debugPrint(text)
    end
end


function onCreate()

    local devMode = getModSetting("developerMode") or false

    if not devMode then
        return
    end

    if not success or not isPE104 then
        return
    end

    scriptEnabled = true

    botActive = getProperty('cpuControlled') or false
    practiceMode = getProperty('practiceMode') or false

    devPrint(tr("unsent_toolbox_loaded"))
    devPrint(tr("unsent_toolbox_version"))

end



function onUpdate(elapsed)

    if not scriptEnabled then
        return
    end

    keyCooldown = math.max(0, keyCooldown - elapsed)



    -- Toggle Botplay
    if keyboardJustPressed('C') and keyCooldown <= 0 then

        botActive = not botActive

        setProperty('cpuControlled', botActive)


        if botActive then
            devPrint(tr("unsent_toolbox_botplay_on"))
        else
            devPrint(tr("unsent_toolbox_botplay_off"))
        end


        keyCooldown = 0.3

    end



    -- Toggle Practice Mode
    if keyboardJustPressed('V') and keyCooldown <= 0 then

        practiceMode = not practiceMode

        setProperty('practiceMode', practiceMode)


        if practiceMode then
            devPrint(tr("unsent_toolbox_practice_on"))
        else
            devPrint(tr("unsent_toolbox_practice_off"))
        end


        keyCooldown = 0.3

    end





    -- Increase Scroll Speed
    if keyboardJustPressed('N') and keyCooldown <= 0 then

        local speed = getProperty('songSpeed') or 1


        if keyboardPressed('SHIFT') then

            speed = speed + 0.5

            devPrint(
                tr("unsent_toolbox_speed_add_big") .. speed
            )

        else

            speed = speed + 0.1

            devPrint(
                tr("unsent_toolbox_speed_add_small") .. speed
            )

        end


        setProperty('songSpeed', speed)

        keyCooldown = 0.1

    end





    -- Reduce Scroll Speed
    if keyboardJustPressed('M') and keyCooldown <= 0 then

        local speed = getProperty('songSpeed') or 1


        if keyboardPressed('SHIFT') then

            speed = speed - 0.5

            if speed < 0.1 then
                speed = 0.1
            end


            devPrint(
                tr("unsent_toolbox_speed_remove_big") .. speed
            )


        else

            speed = speed - 0.1

            if speed < 0.1 then
                speed = 0.1
            end


            devPrint(
                tr("unsent_toolbox_speed_remove_small") .. speed
            )

        end


        setProperty('songSpeed', speed)

        keyCooldown = 0.1

    end

end