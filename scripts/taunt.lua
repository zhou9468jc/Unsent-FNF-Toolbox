function onUpdate()
	local taunt=getModSetting('taunt')
	local pressed=false

	if taunt=='Space' then
		pressed=keyboardJustPressed('SPACE')
	elseif taunt=='Control' then
		pressed=keyboardJustPressed('CONTROL')
	elseif taunt=='Alt' then
		pressed=keyboardJustPressed('ALT')
	elseif taunt=='Shift' then
		pressed=keyboardJustPressed('SHIFT')
	elseif taunt=='G or H' then
		pressed=keyboardJustPressed('G') or keyboardJustPressed('H')
	elseif taunt=='Q or E' then
		pressed=keyboardJustPressed('Q') or keyboardJustPressed('E')
	end

	if pressed then
		local character=getModSetting('tauntCharacter')
		local duration=getModSetting('tauntDuration')
		local volume=getModSetting('tauntSoundVolume')

		triggerEvent('Hey!',character,tostring(duration))

		if volume>0 then
			playSound('hey',volume)
		end
	end
end