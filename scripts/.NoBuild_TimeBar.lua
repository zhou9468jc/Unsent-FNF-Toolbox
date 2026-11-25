--这是我自己用的 this is only used to myself
function onDestroy()
	setPropertyFromClass(
		'backend.ClientPrefs',
		'data.timeBarType',
		'Time Left'
	)
end
debugPrint(ghostTapping,"cyan")
function onGhostTap(a)
	debugPrint(tostring(a or "nil"),"lime")
end