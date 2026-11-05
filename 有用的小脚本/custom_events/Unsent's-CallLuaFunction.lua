function onEvent(name, v1, v2)
    if name == "Unsent's-CallLuaFunction" then
        local funcName, output = parseValue1(v1)
        local args = parseArgs(v2)
        local result = callFunction(funcName, args)
        if output and result ~= nil then
            debugPrint("Unsent's-CallLuaFunction: On Lua Function : "..tostring(funcName).."-> " .. tostring(result))
        end
    end
end

function parseValue1(v1)
    if not v1 or v1 == '' then return nil, false end
    local ok, tbl = pcall(function() return load('return ' .. v1)() end)
    if ok and type(tbl) == 'table' then
        return tbl[1], tbl[2] == true
    end
    return v1, false
end

function parseArgs(v2)
    if not v2 or v2 == '' then return {} end
    local ok, tbl = pcall(function() return load('return ' .. v2)() end)
    if ok and type(tbl) == 'table' then
        return tbl
    end
    return {}
end

function callFunction(funcName, args)
    if not funcName then return nil end
    local func = _G[funcName]
    if type(func) ~= 'function' then
        debugPrint("Unsent's-CallLuaFunction: Function Not Exist : " .. tostring(funcName))
        return nil
    end
    local ok, result = pcall(func, table.unpack(args))
    if not ok then
        debugPrint("Unsent's-CallLuaFunction: ERROR On Lua Function : "..tostring(funcName).."-> " .. tostring(result))
        return nil
    end
    return result
end