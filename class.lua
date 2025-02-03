-------------------------------------------------------------------
--- 'Class' system inspired by the 'Matthias Richter' system.   ---
--- ('https://github.com/vrld/hump/blob/master/class.lua')      ---
-------------------------------------------------------------------

return function(...)
    local tTypes    =   {
        ["FORCE_STRING"]    =   FORCE_STRING    or  1,
        ["FORCE_NUMBER"]    =   FORCE_NUMBER    or  2,
        ["FORCE_BOOL"]      =   FORCE_BOOL      or  3,
    }

    local function includeHelper(tClass, tOther, tSeen)
        if tOther == nil then return tClass end
        if type(tOther) ~= 'table' then return tOther end
        if tSeen[tOther] then return tSeen[tOther] end
    
        tSeen[tOther] = tClass
        for k, v in pairs(tOther) do if not tSeen[k] then tClass[k] = includeHelper({}, v, tSeen) end end

        return tClass
    end    

    local function debugInfo(tSelf)
        local tMt = type(tSelf) == "userdata" and getmetatable(tSelf) or tSelf
        assert(tMt, "Object has no metatable!")
    
        local tStr = {
            "==========================",
            "=== DEBUG OBJECT INFO ===",
            "==========================",
            "\nType: " .. (tMt.__type or "Unknown"),
            "\n# Private Data:",
        }

        table.insert(tStr, (tMt.__private and table.concat({table.unpack(tMt.__private, function(k, v) return string.format("  - %s = %s", k, tostring(v)) end)}, "\n") or "  (empty)"))
        table.insert(tStr, "\n# Methods:")
        table.insert(tStr, table.concat((function() local methods = {} for k, v in pairs(tMt) do if type(v) == "function" then table.insert(methods, string.format("  - %s type : %s", k, type(v))) end end return methods end)(), "\n"))
    
        table.insert(tStr, "\n==========================")
        return table.concat(tStr, "\n")
    end
    

    local function accessor(tSelf, tVarName, tName, tIForce, tDefaultValue)
        tSelf["Get" .. tName] = function(tSelf) return tSelf.__private[tVarName] end

        local tSetters = {
            [tTypes["FORCE_STRING"]] = function(tSelf, tV) tSelf.__private[tVarName] = tV ~= nil and tostring(tV) or tDefaultValue end,
            [tTypes["FORCE_NUMBER"]] = function(tSelf, tV) tSelf.__private[tVarName] = tV ~= nil and tonumber(tV) or tDefaultValue end,
            [tTypes["FORCE_BOOL"]] = function(tSelf, tV) tSelf.__private[tVarName] = tV ~= nil and (tV == nil || tV == false || tV == 0 || tV == "0" || tV == "false") and false or true or tDefaultValue end,
        }

        tSelf["Set" .. tName] = tSetters[tIForce] or function(tSelf, tV) tSelf.__private[tVarName] = tV ~= nil and tV or tDefaultValue end
    end

    local function include(tClass, tOther) return includeHelper(tClass, tOther, {}) end
    local function clone(tOther) return setmetatable(include({}, tOther), assert(getmetatable(tOther), "Cannot clone an object without a metatable.")) end
    local function super(tSelf, tMethod, ...) if tSelf.__super and tSelf.__super[tMethod] then return tSelf.__super[tMethod](tSelf, ...) else error("Method " .. tMethod .. " not found in parent class.") end end
    
    local function new(tClass)
        tClass                  =   tClass or {}
        local tInc              =   getmetatable(tClass.__includes) and {tClass.__includes} or tClass.__includes or {}

        for _, tOther in ipairs(tInc) do if type(tOther) == "string" then tOther = _G[tOther] end include(tClass, tOther) end

        tClass.__index          =   tClass
        tClass.__super          =   tClass.__super or nil
        tClass.__type           =   tClass.__type or "Class"

        tClass.__privateMethods =   tClass.__privateMethods or {}

        local tMethodsToHide    =   {
            init        =   tClass.init    or tClass[1] or function() end,
            include     =   tClass.include or include,
            clone       =   tClass.clone   or clone,
            DebugInfos  =   tClass.__privateMethods.DebugInfos or debugInfo,
        }

        for k, v in pairs(tMethodsToHide) do if v then tClass.__privateMethods[k] = v tClass[k] = nil end end

        return setmetatable(tClass, {
            __call = function(tC, ...)
                local tO = setmetatable({}, tC)

                tO.__private        =   {}
                tO.__type           =   tC.__type
                tO.__privateMethods =   tC.__privateMethods

                assert(xpcall(function(...) tO:init(...) end, function(tErr) return "Init Error: " .. tErr end, ...))

                return tO
            end,
            __gc = function(tO) if tO.destroy then pcall(function() tO:destroy() end) end end,
            __index = function(tSelf, tKey)
                if tKey == "__privateMethods" then return nil end
                if tSelf.__privateMethods[tKey] then return function() return tSelf.__privateMethods[tKey](tSelf) end end
                return rawget(tSelf, tKey)
            end,
        })
    end

    local function overloadOperators(tClass)
        assert(type(tClass) == "table", "[CLASS] ...")
        tClass.__add = function(tA, tB)
            assert(tA.__type == tClass.__type, "[CLASS] Attempted to add incompatible types: " .. tA.__type .. " and " .. tB.__type)
            assert(tB.__type == tClass.__type, "[CLASS] Attempted to add incompatible types: " .. tA.__type .. " and " .. tB.__type)
    
            local tResult = {}
    
            for tKey, tValue in pairs(tA.__private) do tResult[tKey] = tValue end
            for tKey, tValue in pairs(tB.__private) do tResult[tKey] = tResult[tKey] or tValue end
    
            for tKey, tValue in pairs(tA.__privateMethods) do tResult[tKey] = tValue end
            for tKey, tValue in pairs(tB.__privateMethods) do tResult[tKey] = tResult[tKey] or tValue end
    
            return setmetatable(tResult, { __type = tA.__type, __privateMethods = tResult.__privateMethods or {} })
        end
    end

    local function registerClass(tName, tPrototype, tParent)
        local tCls  =   new{__includes = {tPrototype, tParent}}

        if tParent then tCls.__super = tParent end
        tCls.__type = tName
        overloadOperators(tCls)

        return tCls
    end

    return setmetatable({
        new                 = new,
        include             = include,
        clone               = clone,
        super               = super,
        registerAccessor    = accessor,
        registerClass       = registerClass,
    }, { __call = function(_, ...) return new(...) end })
end