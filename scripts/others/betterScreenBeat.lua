local enable = getModSetting("betterScreenBeat")
if enable == nil then
	enable = false
end

function onCreate()
	if enable then
		setProperty('camZoomingMult',0)
	end
end

function goodNoteHit(id, direction, noteType, isSustainNote)
	if enable and not isSustainNote then
		setProperty('camZooming', true)
		triggerEvent('Add Camera Zoom', '0.015', '0.015')
	end
end

function noteMiss(id, direction, noteType, isSustainNote)
	if enable and not isSustainNote then
		triggerEvent('Screen Shake', '0,0', '0.1,0.008')
	end
end