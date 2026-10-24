function onCreate()
	local a = getTextFromFile("data/language.json")
	b = json.decode(a)
	debugPrint(tostring(b))
end