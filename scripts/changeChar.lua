local enableSystem = getModSetting("2026BfGf")
if enableSystem == nil then
    enableSystem = false
end

-- 是否保存并恢复角色状态
local saveCharacterState = true

local changedBF = false
local changedGF = false
local changedDad = false

local Dboyfriend = ''
local Ddad = ''
local Dgf = ''

local canDis = true
local pendingSync = {}

local function contains(str, keyword)
    return str and str:lower():find(keyword, 1, true) ~= nil
end

-- 保存角色状态
local function getCharacterState(side)
    if not saveCharacterState then
        return nil
    end

    local state = {}
    local properties = {
        'angle',
        'x', 'y',
        'flipX', 'flipY',
        'scale.x', 'scale.y',
        'alpha', 'visible'
    }

    for _, property in ipairs(properties) do
        state[property] = getProperty(side .. '.' .. property)
    end

    return state
end

-- 切换角色
local function changeCharacter(side, newCharacter)
    local state = getCharacterState(side)
    triggerEvent('Change Character', side, newCharacter)

    if saveCharacterState and state then
        pendingSync[side] = state
    end
end

function onCreatePost()
    Dboyfriend = getProperty('boyfriend.curCharacter') or ''
    Ddad = getProperty('dad.curCharacter') or ''
    Dgf = getProperty('gf.curCharacter') or ''
end

function onUpdate()
    -- 按 9 恢复原角色
    if canDis and keyJustPressed('NINE') then
        enableSystem = false

        changeCharacter('bf', Dboyfriend)
        changeCharacter('dad', Ddad)
        changeCharacter('gf', Dgf)

        return
    end

    if not enableSystem then
        return
    end

    local boyfriend = getProperty('boyfriend.curCharacter') or ''
    local dad = getProperty('dad.curCharacter') or ''
    local gf = getProperty('gf.curCharacter') or ''
    local gfLower = gf:lower()

    -- BF
    if contains(boyfriend, 'bf') or contains(boyfriend, 'boyfriend') then
        if boyfriend ~= 'unsent-bf' and boyfriend ~= 'unsent-bf-pixel' then
            if contains(boyfriend, 'pixel') then
                changeCharacter('bf', 'unsent-bf-pixel')
            else
                changeCharacter('bf', 'unsent-bf')
            end
        end

        changedBF = true
    end

    -- GF：角色名以 no 或 hide 开头时不替换
    if not contains(gf, 'pixel')
        and not gfLower:match('^no')
        and not gfLower:match('^hide')
        and (contains(gf, 'gf') or contains(gf, 'girlfriend')) then

        if gf ~= 'unsent-gf' then
            changeCharacter('gf', 'unsent-gf')
        end

        changedGF = true
    end

    -- Dad
    if contains(dad, 'bf') or contains(dad, 'boyfriend') then
        if dad ~= 'unsent-bf-op' and dad ~= 'unsent-bf-pixel-op' then
            if contains(dad, 'pixel') then
                changeCharacter('dad', 'unsent-bf-pixel-op')
            else
                changeCharacter('dad', 'unsent-bf-op')
            end
        end

        changedDad = true
    elseif not contains(dad, 'pixel')
        and not dad:lower():match('^no')
        and not dad:lower():match('^hide')
        and (contains(dad, 'gf') or contains(dad, 'girlfriend')) then

        if dad ~= 'unsent-gf' then
            changeCharacter('dad', 'unsent-gf')
        end

        changedDad = true
    end
end

-- 切换后同步角色状态
function onUpdatePost()
    if not saveCharacterState then
        pendingSync = {}
        return
    end

    for side, state in pairs(pendingSync) do
        for property, value in pairs(state) do
            if value ~= nil then
                setProperty(side .. '.' .. property, value)
            end
        end

        pendingSync[side] = nil
    end
end

function onSongStart()
    canDis = false
end