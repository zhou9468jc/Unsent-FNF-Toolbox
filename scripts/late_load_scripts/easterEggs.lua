--==================================================
-- Unsent's Toolbox
-- Easter Eggs
--==================================================

--==================================================
-- 老祖宗 GPT 之手搓 JSON 解析器
--==================================================

local JSON_NULL = setmetatable({}, {__tostring = function() return "JSON_NULL" end})
local function parseJson(str) if type(str) ~= "string" then return nil end local pos,len=1,#str local function skip() while pos<=len and str:sub(pos,pos):match("%s") do pos=pos+1 end end local parseValue local function parseString() pos=pos+1 local out={} while pos<=len do local c=str:sub(pos,pos) pos=pos+1 if c=='"' then return table.concat(out) elseif c=="\\" then local e=str:sub(pos,pos) pos=pos+1 local escapes={['"']='"',["\\"]="\\",["/"]="/",b="\b",f="\f",n="\n",r="\r",t="\t"} if escapes[e] then out[#out+1]=escapes[e] elseif e=="u" then local h=str:sub(pos,pos+3) if not h:match("^%x%x%x%x$") then error("Invalid Unicode") end pos=pos+4 local cp=tonumber(h,16) if cp>=0xD800 and cp<=0xDBFF then if str:sub(pos,pos+1)~="\\u" then error("Invalid surrogate") end local l=str:sub(pos+2,pos+5) if not l:match("^%x%x%x%x$") then error("Invalid surrogate") end local lp=tonumber(l,16) if lp<0xDC00 or lp>0xDFFF then error("Invalid surrogate") end cp=0x10000+(cp-0xD800)*0x400+lp-0xDC00 pos=pos+6 elseif cp>=0xDC00 and cp<=0xDFFF then error("Unexpected low surrogate") end if cp<0x80 then out[#out+1]=string.char(cp) elseif cp<0x800 then out[#out+1]=string.char(0xC0+math.floor(cp/64),0x80+cp%64) elseif cp<0x10000 then out[#out+1]=string.char(0xE0+math.floor(cp/4096),0x80+math.floor(cp/64)%64,0x80+cp%64) else out[#out+1]=string.char(0xF0+math.floor(cp/262144),0x80+math.floor(cp/4096)%64,0x80+math.floor(cp/64)%64,0x80+cp%64) end else error("Invalid escape") end else if c:byte()<32 then error("Invalid control character") end out[#out+1]=c end end error("Unterminated string") end local function parseNumber() local start=pos if str:sub(pos,pos)=="-" then pos=pos+1 end local c=str:sub(pos,pos) if c=="0" then pos=pos+1 if str:sub(pos,pos):match("%d") then error("Leading zero") end else if not c:match("[1-9]") then error("Invalid number") end while str:sub(pos,pos):match("%d") do pos=pos+1 end end if str:sub(pos,pos)=="." then pos=pos+1 if not str:sub(pos,pos):match("%d") then error("Invalid fraction") end while str:sub(pos,pos):match("%d") do pos=pos+1 end end c=str:sub(pos,pos) if c=="e" or c=="E" then pos=pos+1 c=str:sub(pos,pos) if c=="+" or c=="-" then pos=pos+1 end if not str:sub(pos,pos):match("%d") then error("Invalid exponent") end while str:sub(pos,pos):match("%d") do pos=pos+1 end end local n=tonumber(str:sub(start,pos-1)) if n==nil then error("Invalid number") end return n end local function parseArray() pos=pos+1 skip() local arr={} if str:sub(pos,pos)=="]" then pos=pos+1 return arr end while true do arr[#arr+1]=parseValue() skip() local c=str:sub(pos,pos) if c=="]" then pos=pos+1 return arr elseif c~="," then error("Expected ',' or ']'") end pos=pos+1 skip() end end local function parseObject() pos=pos+1 skip() local obj={} if str:sub(pos,pos)=="}" then pos=pos+1 return obj end while true do if str:sub(pos,pos)~='"' then error("Expected object key") end local key=parseString() skip() if str:sub(pos,pos)~=":" then error("Expected ':'") end pos=pos+1 skip() obj[key]=parseValue() skip() local c=str:sub(pos,pos) if c=="}" then pos=pos+1 return obj elseif c~="," then error("Expected ',' or '}'") end pos=pos+1 skip() end end parseValue=function() skip() local c=str:sub(pos,pos) if c=='"' then return parseString() elseif c=="{" then return parseObject() elseif c=="[" then return parseArray() elseif c=="-" or c:match("%d") then return parseNumber() end for _,v in ipairs({{"true",true},{"false",false},{"null",JSON_NULL}}) do if str:sub(pos,pos+#v[1]-1)==v[1] then pos=pos+#v[1] return v[2] end end error("Unexpected token at position "..pos) end local ok,result=pcall(function() local v=parseValue() skip() if pos<=len then error("Trailing content") end return v end) if ok then return result end return nil end

--==================================================
-- Settings
--==================================================

local disEasterEgg = getModSetting("disableEGS")
if disEasterEgg == true then
    close()
    return
end

local showEasterEgg = false

--==================================================
-- Language System
--==================================================

local function safeReadJson(path)
    if type(readJson) == "function" then
        local success, result = pcall(readJson, path)
        if success and result ~= nil then return result end
    end

    local content = getTextFromFile(path)
    if content == nil or content == "" then return nil end

    local success, result = pcall(parseJson, content)
    if success then return result end
    return nil
end

local languages = safeReadJson("data/language.json") or {
    Easter_Egg_1_a = "A mysterious voice is calling you...",
    Easter_Egg_1_b = "/ɡoʊ tuː ðə tʃɑːrt ˈedɪtər ænd loʊd ðɪs tʃɑːrt/",
    Easter_Egg_1_c = "\"what-fxxk\""
}

local language = getModSetting("language")

if language == nil then
    local text = "[Unsent's ToolBox] Error : "
        .. ((languages["###GloBal_Language"] or {}).Language_ReadError or "Language_ReadError")

    debugPrint(text, "red")

    local message = tostring(text)
        :gsub("\\", "\\\\")
        :gsub("\r", "\\r")
        :gsub("\n", "\\n")
        :gsub("\t", "\\t")
        :gsub('"', '\\"')

    pcall(runHaxeCode, 'trace("' .. message .. '");')
    language = "English"
end

if language == "###GloBal_Language" then language = "English" end

local lang = languages[language] or languages["English"] or {}
local Global_lang = languages["###GloBal_Language"] or {}

local function getLang(isGlobal, key, ...)
    local source = isGlobal and Global_lang or lang
    local text = source[key]

    if text == nil then
        text = isGlobal and ("Global_" .. key) or key
    end

    text = tostring(text)

    for i, v in ipairs({...}) do
        text = text:gsub("%{" .. i .. "%}", function()
            return tostring(v)
        end)
    end

    return text
end

--==================================================
-- Easter Egg 1
-- 神秘的声音
--==================================================

local egg1Enabled = true
local egg1Show = false

local egg1Tags = {
    "EasterEgg_Line1",
    "EasterEgg_Line2",
    "EasterEgg_Line3"
}

local function createEasterEgg1()
    if not egg1Enabled then return end
    if math.random(1, 50) ~= math.random(1, 50) then return end

    egg1Show = true
    showEasterEgg = true

    local texts = {
        getLang(false, "Easter_Egg_1_a"),
        getLang(false, "Easter_Egg_1_b"),
        getLang(false, "Easter_Egg_1_c")
    }

    local centerY = screenHeight / 2
    local lineHeight = 36

    for i = 1, 3 do
        local tag = egg1Tags[i]

        makeLuaText(tag, texts[i], screenWidth, 0,
            centerY + (i - 2) * lineHeight - 18)

        setTextSize(tag, 28)
        setTextAlignment(tag, "center")
        setTextBorder(tag, 1.5, "000000")
        setObjectCamera(tag, "other")
        addLuaText(tag)
    end
end

local function updateEasterEgg1(elapsed)
end

local function startEasterEgg1()
    if not egg1Show then return end
    runTimer("HideEasterEgg1", 5)
end

local function timerEasterEgg1(tag)
    if tag ~= "HideEasterEgg1" then return end

    for _, textTag in ipairs(egg1Tags) do
        removeLuaText(textTag, true)
    end

    egg1Show = false
    showEasterEgg = false
end

--==================================================
-- Easter Egg 2
-- April Fools Chaos
--==================================================

local egg2Enabled = true
local egg2Active = false
local egg2Time = 0

local function createEasterEgg2()
    if not egg2Enabled then return end

    local time = os.date("*t")
    if time.month ~= 4 or time.day ~= 1 then return end

    initLuaShader("AprilFoolsChaos")

    makeLuaSprite("AprilFoolsShader")
    makeGraphic("AprilFoolsShader", screenWidth, screenHeight)
    setSpriteShader("AprilFoolsShader", "AprilFoolsChaos")

    addHaxeLibrary("ShaderFilter", "openfl.filters")

    runHaxeCode([[
        var shader = game.getLuaObject("AprilFoolsShader").shader;
        var filter = new ShaderFilter(shader);

        game.variables.set("AprilFoolsFilter", filter);

        game.camGame.setFilters([filter]);
        game.camHUD.setFilters([filter]);
        game.camOther.setFilters([filter]);
    ]])

    egg2Active = true
end

--==================================================
-- Persistent Shader
--==================================================

local function updatePersistentShader()
    if not egg2Active then return end
	cameraShake("game", 0.025, 0.35)
	cameraShake("hud", 0.01, 0.2)
    runHaxeCode([[
        var filter = game.variables.get("AprilFoolsFilter");

        if (filter != null) {
            var cameras = [
                game.camGame,
                game.camHUD,
                game.camOther
            ];

            for (camera in cameras) {
                if (camera.filters == null || !camera.filters.contains(filter)) {
                    var filters = camera.filters == null
                        ? []
                        : camera.filters.copy();

                    filters.push(filter);
                    camera.setFilters(filters);
                }
            }
        }
    ]])
end

--==================================================
-- Random Arrow Movement
--==================================================

local arrowMoveEnabled = true
local arrowMoveRadius = 50
local arrowMoveSpeed = 5
local arrowMoveMinDelay = 0
local arrowMoveMaxDelay = 0.2

local arrowData = {}

local function createArrowMovement()
    if not egg2Active or not arrowMoveEnabled then return end

    arrowData = {}

    for i = 0, 7 do
        local x = getPropertyFromGroup("strumLineNotes", i, "x")
        local y = getPropertyFromGroup("strumLineNotes", i, "y")

        arrowData[i] = {
            baseX = x,
            baseY = y,
            targetX = x,
            targetY = y,
            timer = math.random() * arrowMoveMaxDelay
        }
    end
end

local function updateArrowMovement(elapsed)
    if not egg2Active or not arrowMoveEnabled then return end

    for i = 0, 7 do
        local data = arrowData[i]

        if data then
            data.timer = data.timer - elapsed

            if data.timer <= 0 then
                local angle = math.random() * math.pi * 2
                local distance = math.sqrt(math.random()) * arrowMoveRadius

                data.targetX = data.baseX + math.cos(angle) * distance
                data.targetY = data.baseY + math.sin(angle) * distance

                data.timer = arrowMoveMinDelay
                    + math.random() * (arrowMoveMaxDelay - arrowMoveMinDelay)
            end

            local x = getPropertyFromGroup("strumLineNotes", i, "x")
            local y = getPropertyFromGroup("strumLineNotes", i, "y")
            local lerp = 1 - math.exp(-arrowMoveSpeed * elapsed)

            setPropertyFromGroup("strumLineNotes", i, "x",
                x + (data.targetX - x) * lerp)

            setPropertyFromGroup("strumLineNotes", i, "y",
                y + (data.targetY - y) * lerp)
        end
    end
end

local function destroyArrowMovement()
    for i = 0, 7 do
        local data = arrowData[i]

        if data then
            setPropertyFromGroup("strumLineNotes", i, "x", data.baseX)
            setPropertyFromGroup("strumLineNotes", i, "y", data.baseY)
        end
    end

    arrowData = {}
end

--==================================================
-- Random Pitch
--==================================================

local pitchEnabled = false
local pitchMin = 0.75
local pitchMax = 1.25
local pitchMinDelay = 0.5
local pitchMaxDelay = 2.0
local pitchTimer = 0

local function updateRandomPitch(elapsed)
    if not egg2Active or not pitchEnabled then return end

    pitchTimer = pitchTimer - elapsed

    if pitchTimer <= 0 then
        local pitch = pitchMin + math.random() * (pitchMax - pitchMin)

        setProperty("vocals.pitch", pitch)
        setProperty("inst.pitch", pitch)

        pitchTimer = pitchMinDelay
            + math.random() * (pitchMaxDelay - pitchMinDelay)
    end
end

local function updateEasterEgg2(elapsed)
    if not egg2Active then return end

    egg2Time = egg2Time + elapsed
    setShaderFloat("AprilFoolsShader", "iTime", egg2Time)
end

--==================================================
-- Destroy / Restore
--==================================================

local function destroyEasterEgg2()
    if not egg2Active then return end

    runHaxeCode([[
        var filter = game.variables.get("AprilFoolsFilter");

        if (filter != null) {
            if (game.camGame.filters != null) game.camGame.filters.remove(filter);
            if (game.camHUD.filters != null) game.camHUD.filters.remove(filter);
            if (game.camOther.filters != null) game.camOther.filters.remove(filter);
        }

        game.variables.remove("AprilFoolsFilter");
    ]])

    removeLuaSprite("AprilFoolsShader", true)

    egg2Active = false
end

--==================================================
-- Main Events
--==================================================

function onCreate()
    createEasterEgg1()
    createEasterEgg2()
end

function onCreatePost()
    createArrowMovement()
end

function onUpdate(elapsed)
    updateEasterEgg1(elapsed)
    updateEasterEgg2(elapsed)
    updateRandomPitch(elapsed)
    updatePersistentShader()
end

function onUpdatePost(elapsed)
    updateArrowMovement(elapsed)
end

function onSongStart()
    startEasterEgg1()
end

function onTimerCompleted(tag, loops, loopsLeft)
    timerEasterEgg1(tag)
end

function onEndSong()
    destroyArrowMovement()
    destroyEasterEgg2()
end

function onDestroy()
    destroyArrowMovement()
    destroyEasterEgg2()
end