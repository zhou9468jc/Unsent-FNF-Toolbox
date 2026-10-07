local function checkPE104()

    local success, isPE104 = pcall(function()
        return getModSetting("RunOnPE104")
    end)


    if success then

        -- PE 1.0.4 detected
        if isPE104 == true then

            scriptEnabled = false

            return

        else

            debugPrint(
                "Psych Engine 1.0.4 detected, but PE 1.0.4 Mode is disabled"
            )

            debugPrint(
                "Script will stop run..."
            )

        end


    else

        -- PE 0.6.2 does not have getModSetting
        debugPrint(
            "Psych Engine 0.6.2 mode detected"
        )

    end

end



function onCreate()

    checkPE104()

    if not scriptEnabled then
        return
    end


    botActive = getProperty('cpuControlled') or false
    practiceMode = getProperty('practiceMode') or false


    debugPrint(
        "Developer toolbox loaded - Psych Engine 0.6.2"
    )

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


        devPrint(
            'Botplay: ' .. (botActive and 'ON' or 'OFF')
        )


        keyCooldown = 0.3

    end





    -- Toggle Practice Mode
    if keyboardJustPressed('V') and keyCooldown <= 0 then

        practiceMode = not practiceMode

        setProperty('practiceMode', practiceMode)


        devPrint(
            'Practice Mode: ' .. (practiceMode and 'ON' or 'OFF')
        )


        keyCooldown = 0.3

    end





    -- Increase Scroll Speed
    if keyboardJustPressed('N') and keyCooldown <= 0 then

        local speed = getProperty('songSpeed') or 1


        if keyboardPressed('SHIFT') then

            speed = speed + 0.5


            devPrint(
                'Scroll Speed +0.5: ' .. speed
            )


        else

            speed = speed + 0.1


            devPrint(
                'Scroll Speed +0.1: ' .. speed
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
                'Scroll Speed -0.5: ' .. speed
            )


        else

            speed = speed - 0.1


            if speed < 0.1 then
                speed = 0.1
            end


            devPrint(
                'Scroll Speed -0.1: ' .. speed
            )

        end


        setProperty('songSpeed', speed)

        keyCooldown = 0.1

    end

end