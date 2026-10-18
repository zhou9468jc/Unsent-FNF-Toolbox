local list = {}

function onCreate()
	if list == {} then
		return
	end
	for i = 1, #list do
		local file = list[i]
		local ext = file:match("%.([^%.]+)$")

		if ext == "lua" then
			addLuaScript("extraScript/" .. file, true)
		elseif ext == "hscript" then
			addHScript("extraScript/" .. file, true)
		else
			error("extraScript/" .. file .. " Not Lua or Hscript File!")
		end
	end
end