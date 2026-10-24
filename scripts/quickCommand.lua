-- ============================================================
-- Quick Command System
-- Lua / HScript Shortcut
-- Unsent's Toolbox NF Ver
-- ============================================================

local commands = {}
local loaded = false


local DefaultLang =
{
	QuickCommand_CannotLoadJson = "QuickCommand : Cannot load json\nQuickCommand : Language Read ERROR!",
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



--==================================================
--老祖宗gpt之手挫json解析器
local JSON_NULL=setmetatable({},{__tostring=function()return"JSON_NULL"end}) local function parseJson(str) if type(str)~="string"then return nil end local pos,len=1,#str local function skip()while pos<=len and str:sub(pos,pos):match("%s")do pos=pos+1 end end local parseValue local function parseString() pos=pos+1 local out={} while pos<=len do local c=str:sub(pos,pos);pos=pos+1 if c=='"'then return table.concat(out) elseif c=="\\"then local e=str:sub(pos,pos);pos=pos+1 local escapes={['"']='"',["\\"]="\\",["/"]="/",b="\b",f="\f",n="\n",r="\r",t="\t"} if escapes[e]then out[#out+1]=escapes[e] elseif e=="u"then local h=str:sub(pos,pos+3);if not h:match("^%x%x%x%x$")then error("Invalid Unicode")end pos=pos+4 local cp=tonumber(h,16) if cp>=0xD800 and cp<=0xDBFF then if str:sub(pos,pos+1)~="\\u"then error("Invalid surrogate")end local l=str:sub(pos+2,pos+5);if not l:match("^%x%x%x%x$")then error("Invalid surrogate")end local lp=tonumber(l,16);if lp<0xDC00 or lp>0xDFFF then error("Invalid surrogate")end cp=0x10000+(cp-0xD800)*0x400+lp-0xDC00;pos=pos+6 elseif cp>=0xDC00 and cp<=0xDFFF then error("Unexpected low surrogate")end if cp<0x80 then out[#out+1]=string.char(cp) elseif cp<0x800 then out[#out+1]=string.char(0xC0+math.floor(cp/64),0x80+cp%64) elseif cp<0x10000 then out[#out+1]=string.char(0xE0+math.floor(cp/4096),0x80+math.floor(cp/64)%64,0x80+cp%64) else out[#out+1]=string.char(0xF0+math.floor(cp/262144),0x80+math.floor(cp/4096)%64,0x80+math.floor(cp/64)%64,0x80+cp%64)end else error("Invalid escape")end else if c:byte()<32 then error("Invalid control character")end;out[#out+1]=c end end error("Unterminated string") end local function parseNumber() local start=pos if str:sub(pos,pos)=="-"then pos=pos+1 end local c=str:sub(pos,pos) if c=="0"then pos=pos+1;if str:sub(pos,pos):match("%d")then error("Leading zero")end else if not c:match("[1-9]")then error("Invalid number")end;while str:sub(pos,pos):match("%d")do pos=pos+1 end end if str:sub(pos,pos)=="."then pos=pos+1;if not str:sub(pos,pos):match("%d")then error("Invalid fraction")end;while str:sub(pos,pos):match("%d")do pos=pos+1 end end c=str:sub(pos,pos) if c=="e"or c=="E"then pos=pos+1;c=str:sub(pos,pos);if c=="+"or c=="-"then pos=pos+1 end;if not str:sub(pos,pos):match("%d")then error("Invalid exponent")end;while str:sub(pos,pos):match("%d")do pos=pos+1 end end local n=tonumber(str:sub(start,pos-1));if n==nil then error("Invalid number")end;return n end local function parseArray() pos=pos+1;skip();local arr={} if str:sub(pos,pos)=="]"then pos=pos+1;return arr end while true do arr[#arr+1]=parseValue();skip();local c=str:sub(pos,pos);if c=="]"then pos=pos+1;return arr elseif c~=","then error("Expected ',' or ']'")end;pos=pos+1;skip()end end local function parseObject() pos=pos+1;skip();local obj={} if str:sub(pos,pos)=="}"then pos=pos+1;return obj end while true do if str:sub(pos,pos)~='"'then error("Expected object key")end local key=parseString();skip() if str:sub(pos,pos)~=":"then error("Expected ':'")end pos=pos+1;skip();obj[key]=parseValue();skip() local c=str:sub(pos,pos);if c=="}"then pos=pos+1;return obj elseif c~=","then error("Expected ',' or '}'")end;pos=pos+1;skip() end end parseValue=function() skip();local c=str:sub(pos,pos) if c=='"'then return parseString()elseif c=="{"then return parseObject()elseif c=="["then return parseArray()elseif c=="-"or c:match("%d")then return parseNumber()end for _,v in ipairs({{"true",true},{"false",false},{"null",JSON_NULL}})do if str:sub(pos,pos+#v[1]-1)==v[1]then pos=pos+#v[1];return v[2]end end error("Unexpected token at position "..pos) end local ok,result=pcall(function()local v=parseValue();skip();if pos<=len then error("Trailing content")end;return v end) if ok then return result end return nil end local function safeReadJson(value) local content=getTextFromFile(value) if content==nil or content==""then return nil end return parseJson(content) end
--==================================================
local function safeReadJson(value)
    if UnsentToolbox_NFEVersion == "1.2.0" then
        local success, result = pcall(readJson, value)
        if success then return result end
        return nil
    end

    local content = getTextFromFile(value)
    if content == nil or content == "" then return nil end
    return parseJson(content)
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