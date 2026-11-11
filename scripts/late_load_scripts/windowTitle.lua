-- ============================================================
-- Unsent's Toolbox - Dynamic Window Title
-- ============================================================
--==================================================
--老祖宗gpt之手挫json解析器
local JSON_NULL=setmetatable({},{__tostring=function()return"JSON_NULL"end}) local function parseJson(str) if type(str)~="string"then return nil end local pos,len=1,#str local function skip()while pos<=len and str:sub(pos,pos):match("%s")do pos=pos+1 end end local parseValue local function parseString() pos=pos+1 local out={} while pos<=len do local c=str:sub(pos,pos);pos=pos+1 if c=='"'then return table.concat(out) elseif c=="\\"then local e=str:sub(pos,pos);pos=pos+1 local escapes={['"']='"',["\\"]="\\",["/"]="/",b="\b",f="\f",n="\n",r="\r",t="\t"} if escapes[e]then out[#out+1]=escapes[e] elseif e=="u"then local h=str:sub(pos,pos+3);if not h:match("^%x%x%x%x$")then error("Invalid Unicode")end pos=pos+4 local cp=tonumber(h,16) if cp>=0xD800 and cp<=0xDBFF then if str:sub(pos,pos+1)~="\\u"then error("Invalid surrogate")end local l=str:sub(pos+2,pos+5);if not l:match("^%x%x%x%x$")then error("Invalid surrogate")end local lp=tonumber(l,16);if lp<0xDC00 or lp>0xDFFF then error("Invalid surrogate")end cp=0x10000+(cp-0xD800)*0x400+lp-0xDC00;pos=pos+6 elseif cp>=0xDC00 and cp<=0xDFFF then error("Unexpected low surrogate")end if cp<0x80 then out[#out+1]=string.char(cp) elseif cp<0x800 then out[#out+1]=string.char(0xC0+math.floor(cp/64),0x80+cp%64) elseif cp<0x10000 then out[#out+1]=string.char(0xE0+math.floor(cp/4096),0x80+math.floor(cp/64)%64,0x80+cp%64) else out[#out+1]=string.char(0xF0+math.floor(cp/262144),0x80+math.floor(cp/4096)%64,0x80+math.floor(cp/64)%64,0x80+cp%64)end else error("Invalid escape")end else if c:byte()<32 then error("Invalid control character")end;out[#out+1]=c end end error("Unterminated string") end local function parseNumber() local start=pos if str:sub(pos,pos)=="-"then pos=pos+1 end local c=str:sub(pos,pos) if c=="0"then pos=pos+1;if str:sub(pos,pos):match("%d")then error("Leading zero")end else if not c:match("[1-9]")then error("Invalid number")end;while str:sub(pos,pos):match("%d")do pos=pos+1 end end if str:sub(pos,pos)=="."then pos=pos+1;if not str:sub(pos,pos):match("%d")then error("Invalid fraction")end;while str:sub(pos,pos):match("%d")do pos=pos+1 end end c=str:sub(pos,pos) if c=="e"or c=="E"then pos=pos+1;c=str:sub(pos,pos);if c=="+"or c=="-"then pos=pos+1 end;if not str:sub(pos,pos):match("%d")then error("Invalid exponent")end;while str:sub(pos,pos):match("%d")do pos=pos+1 end end local n=tonumber(str:sub(start,pos-1));if n==nil then error("Invalid number")end;return n end local function parseArray() pos=pos+1;skip();local arr={} if str:sub(pos,pos)=="]"then pos=pos+1;return arr end while true do arr[#arr+1]=parseValue();skip();local c=str:sub(pos,pos);if c=="]"then pos=pos+1;return arr elseif c~=","then error("Expected ',' or ']'")end;pos=pos+1;skip()end end local function parseObject() pos=pos+1;skip();local obj={} if str:sub(pos,pos)=="}"then pos=pos+1;return obj end while true do if str:sub(pos,pos)~='"'then error("Expected object key")end local key=parseString();skip() if str:sub(pos,pos)~=":"then error("Expected ':'")end pos=pos+1;skip();obj[key]=parseValue();skip() local c=str:sub(pos,pos);if c=="}"then pos=pos+1;return obj elseif c~=","then error("Expected ',' or '}'")end;pos=pos+1;skip() end end parseValue=function() skip();local c=str:sub(pos,pos) if c=='"'then return parseString()elseif c=="{"then return parseObject()elseif c=="["then return parseArray()elseif c=="-"or c:match("%d")then return parseNumber()end for _,v in ipairs({{"true",true},{"false",false},{"null",JSON_NULL}})do if str:sub(pos,pos+#v[1]-1)==v[1]then pos=pos+#v[1];return v[2]end end error("Unexpected token at position "..pos) end local ok,result=pcall(function()local v=parseValue();skip();if pos<=len then error("Trailing content")end;return v end) if ok then return result end return nil end local function safeReadJson(value) local content=getTextFromFile(value) if content==nil or content==""then return nil end return parseJson(content) end
--==================================================
local function safeReadJson(path)
    if type(readJson) == "function" then
        local success, result = pcall(readJson, path)
        if success and result ~= nil then
            return result
        end
    end

    local content = getTextFromFile(path)
    if content == nil or content == "" then
        return nil
    end

    if type(parseJson) == "function" then
        local success, result = pcall(parseJson, content)
        if success then
            return result
        end
    end

    return nil
end

-- ============================================================
-- Language
-- ============================================================

local languages = safeReadJson("data/language.json") or {
    English = {
        Window_Title_Paused = "PAUSED",
        Window_Title_Gameover = "GAMEOVER",
        Window_Title_GameStart = "SONGSTART"
    }
}

local language = getModSetting("language") or "English"
local lang = languages[language] or languages.English or {}

local function getLang(isGlobal, key, ...)
    local source = isGlobal and Global_lang or lang
    local value = source and source[key]

    if value == nil then
        value = isGlobal and ("Global_" .. key) or key
    end

    value = tostring(value)

    for i, v in ipairs({...}) do
        value = value:gsub("{" .. i .. "}", function()
            return tostring(v)
        end)
    end

    return value
end

-- ============================================================
-- Window Title
-- ============================================================

local oldTitle = nil
local currentSuffix = nil

local function getWindowTitle()
    return getPropertyFromClass(
        "openfl.Lib",
        "application.window.title"
    )
end

local function setWindowTitle(suffix)
    if oldTitle == nil then
        oldTitle = getWindowTitle()
    end

    if oldTitle == nil then return end
    if currentSuffix == suffix then return end

    currentSuffix = suffix

    if suffix == "Friday Night Funkin'" then
        setPropertyFromClass(
            "openfl.Lib",
            "application.window.title",
            suffix
        )
        return
    end

    setPropertyFromClass(
        "openfl.Lib",
        "application.window.title",
        oldTitle .. suffix
    )
end

-- ============================================================
-- Title State
-- ============================================================

local function setTitle(code, value)
    local suffix = " - Unsent's ToolBox"

    if getModSetting("originalHealthBar") == true then
        suffix = "Friday Night Funkin'"

    elseif code == 1 then
        suffix = suffix .. " - " .. tostring(songName or "")

    elseif code == 2 then
        suffix = suffix .. " - " .. tostring(songName or "")
            .. " - " .. getLang(false, "Window_Title_Paused")

    elseif code == 3 then
        suffix = suffix .. " - " .. tostring(songName or "")
            .. " - " .. getLang(false, "Window_Title_Gameover")

    elseif code == 4 then
        suffix = suffix .. " - " .. tostring(songName or "")
            .. " - " .. getLang(false, "Window_Title_GameStart")

    elseif code == 9 then
        suffix = suffix .. " - " .. tostring(songName or "")
            .. " - " .. tostring(value or "")
    end

    setWindowTitle(suffix)
end

-- ============================================================
-- Game Events
-- ============================================================

function onCreatePost()
    oldTitle = getWindowTitle()
    currentSuffix = nil
    setTitle(1)
end

function onResume()
    setTitle(1)
end

function onPause()
    setTitle(2)
end

function onEndSong()
    setTitle(0)
end

function onGameOver()
    setTitle(3)
end

-- ============================================================
-- Countdown
-- ============================================================

function onCountdownTick(c)
    if c == 0 then
        setTitle(9, "3")
    elseif c == 1 then
        setTitle(9, "2")
    elseif c == 2 then
        setTitle(9, "1")
    elseif c == 3 then
        setTitle(9, "GO!")
    elseif c == 4 then
        setTitle(4)
        runTimer("start", 2)
    end
end

function onTimerCompleted(tag)
    if tag == "start" then
        setTitle(1)
    end
end

-- ============================================================
-- Destroy
-- ============================================================

function onDestroy()
    if oldTitle ~= nil then
        setPropertyFromClass(
            "openfl.Lib",
            "application.window.title",
            oldTitle
        )
    end

    oldTitle = nil
    currentSuffix = nil
end