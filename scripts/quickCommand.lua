-- ============================================================
-- Quick Command System
-- Lua / HScript Shortcut
-- Unsent's Toolbox NF Ver
-- ============================================================

local commands = {}
local loaded = false


local DefaultLang =
{
	QuickCommand_CannotLoadJson = "QuickCommand : Cannot load json",
	QuickCommand_Loaded = "QuickCommand : Loaded {1} commands",
	QuickCommand_RunHaxeUnavailable = "QuickCommand : runHaxeCode unavailable",
	QuickCommand_LuaError = "QuickCommand Lua Error : {1}",
	QuickCommand_LuaRuntimeError = "QuickCommand Lua Runtime Error : {1}",
	QuickCommand_HScriptError = "QuickCommand HScript Error : {1}",
	QuickCommand_UnknownType = "QuickCommand : Unknown type : {1}",
	QuickCommand_Execute = "QuickCommand : Execute : {1}"
}


local function qcPrint(text)

	text = tostring(text)

	debugPrint(text)

	if type(runHaxeCode) == "function" then

		local safe = text
			:gsub("\\","\\\\")
			:gsub("'","\\'")

		pcall(
			runHaxeCode,
			"trace('"..safe.."')"
		)

	end

end



local function safeReadJson(path)

	if type(readJson) == "function" then

		local ok,result = pcall(readJson,path)

		if ok then
			return result
		end

	end

	return nil

end



local languages = safeReadJson("data/language.json") or {}

local language = getModSetting("language")


if language == nil then

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



local function getLang(isGlobal,key,...)

	local source = isGlobal and Global_lang or lang

	local text = source[key]


	if text == nil then

		text = DefaultLang[key]

	end


	if text == nil then

		text = key

	end


	for i,v in ipairs({...}) do

		text = text:gsub(
			"%{"..i.."%}",
			function()
				return tostring(v)
			end
		)

	end


	return text

end





local function loadCommands()

	if loaded then return end


	local data = safeReadJson(
		"data/quickCommand.json"
	)



	if type(data) ~= "table" then

		qcPrint(
			"[Unsent's Toolbox] - "
			..getLang(false,"QuickCommand_CannotLoadJson")
		)

		return

	end



	local enableAll = data.enableAll ~= false

	local list = data.commands or data

	local count = 0



	for _,v in ipairs(list) do


		if enableAll 
		and v.enable ~= false 
		and v.key 
		and v.type 
		and v.code then


			commands[v.key] =
			{
				name = v.name or "Unknown",
				type = v.type,
				code = v.code
			}


			count = count + 1

		end

	end



	loaded = true



	qcPrint(
		"[Unsent's Toolbox] - "
		..getLang(
			false,
			"QuickCommand_Loaded",
			count
		)
	)

end





local function executeLua(code)


	local func,err = load(code)



	if not func then

		qcPrint(
			"[Unsent's Toolbox] - "
			..getLang(
				false,
				"QuickCommand_LuaError",
				err
			)
		)

		return

	end



	local ok,msg = pcall(func)



	if not ok then

		qcPrint(
			"[Unsent's Toolbox] - "
			..getLang(
				false,
				"QuickCommand_LuaRuntimeError",
				msg
			)
		)

	end


end





local function executeHScript(code)


	if type(runHaxeCode) ~= "function" then


		qcPrint(
			"[Unsent's Toolbox] - "
			..getLang(
				false,
				"QuickCommand_RunHaxeUnavailable"
			)
		)


		return

	end



	local ok,msg = pcall(
		runHaxeCode,
		code
	)



	if not ok then

		qcPrint(
			"[Unsent's Toolbox] - "
			..getLang(
				false,
				"QuickCommand_HScriptError",
				msg
			)
		)

	end


end





local function executeCommand(cmd)


	if cmd.type == "lua" then


		executeLua(cmd.code)



	elseif cmd.type == "hscript" then


		executeHScript(cmd.code)



	else


		qcPrint(
			"[Unsent's Toolbox] - "
			..getLang(
				false,
				"QuickCommand_UnknownType",
				cmd.type
			)
		)


	end


end





function onCreate()

	loadCommands()

end





function onUpdate()


	for key,cmd in pairs(commands) do


		if keyboardJustPressed(key) then


			qcPrint(
				"[Unsent's Toolbox] - "
				..getLang(
					false,
					"QuickCommand_Execute",
					cmd.name
				)
			)


			executeCommand(cmd)


		end


	end


end