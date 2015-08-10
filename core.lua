local addon, ns = ...
local gEnable = ns.cfg.enable
local fcfg = ns.cfg.filterConfig
local Bich = ns.Bich
local BichBar = ns.BichBar

-- some functions
local function printMobInfoToChat(mobInfo)
    local name = Bich:getUnitName(mobInfo.unitid)
    local msg = ""
    for i, spellid in ipairs(mobInfo.spells) do
        msg = msg .. GetSpellLink(spellid)
    end
    
    DEFAULT_CHAT_FRAME:AddMessage(name .. ":" .. msg, 255, 255, 255)
end


local function printSearchResultToChat(resultSet, limit)
    limit = limit or #resultSet -- no limit by default
    for i, mobInfo in ipairs(resultSet) do
        if i <= limit then
            printMobInfoToChat(mobInfo)
        end
    end
end

local function searchAndShow(cmd, param)
    searchResult = Bich:search(cmd, param)
    if #searchResult > 0 then
        local randomChoosen = searchResult[ fastrandom(1,#searchResult) ]
        BichBar:createBar(randomChoosen.spells)
        printSearchResultToChat(searchResult)
        --printSearchResultToChat({randomChoosen})
    end
end




-- initial
local function initAddon()
    Bich:checkVersion() -- check database version
    ns.loaded = true
    DEFAULT_CHAT_FRAME:AddMessage("|cff00f0f0Bich|r loaded", 255, 255, 255)
end

local function handlerAddonLoaded(name)
    if name == "Bich" then
        initAddon()
    end
end

-- get the spells and create bar
local function unitCreateBar(flag)
    local guid = UnitGUID(flag)
    local unitid = Bich:getCreatureIdByGuid(guid)
    local zone = Bich:getZone()
    local spells = Bich:getFilteredSpellInfo(zone, unitid, "sort")
    
    if next(spells) ~= nil then
        local name = UnitName(flag)
        Bich:setUnitName(unitid, name)
        BichBar:createBar(spells)
        --  for debug
        
        -- printMobInfoToChat({zone=zone, unitid=unitid, spells=spells})
    end
end


-- store spell information
local function handlerCombatLog(timeStamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, 
                                sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)

    if not Bich:checkZone(fcfg.track) then
        return
    end
    wwb = {171764,173009,173010}
    local f = false
    for i, v in ipairs(wwb) do
        if v == select(1,...) then
            f = true
        end
    end
    if f == false then
        if select(1,...) ~= nil then
            local l = select(1,...)
            print(sourceName)
            DEFAULT_CHAT_FRAME:AddMessage(event..":"..GetSpellLink(l), 255, 255, 255)
        end
    end
    -- if sourceName == "薇薇安" then
        -- wwa = wwa or {}
        -- local e = event..":"..tostring(select(1, ...))
        -- local f = false
        -- for i, v in ipairs(wwa) do
            -- if v == e then
                -- f = true
            -- end
        -- end
        -- if f == false then
            -- table.insert(wwa, e)
        -- end
        -- DEFAULT_CHAT_FRAME:AddMessage("{", 255, 255, 255)
        -- for i, v in ipairs(wwa) do
            -- DEFAULT_CHAT_FRAME:AddMessage(v, 255, 255, 255)
        -- end
        -- DEFAULT_CHAT_FRAME:AddMessage("}", 255, 255, 255)
        
    -- end
    if event == "SPELL_HEAL" or event == "SPELL_CAST_START" or event == "SPELL_CAST_SUCCESS" then
        local spellid = select(1, ...)
        local unitid = Bich:getCreatureIdByGuid(sourceGUID)
        local zone, zoneName = Bich:getZone()
        if unitid > 0 then
            local newSpell = Bich:addSpellAndSetName(zone, zoneName, unitid, sourceName, spellid)
            local tarGuid = UnitGUID("target")
            if unitid == Bich:getCreatureIdByGuid(tarGuid) and newSpell then
                unitCreateBar("target")
            end
        end
    end
end


-- show spells stored when target changed
local function handlerTargetChanged()
    BichBar:hideAllButtons()
    if UnitGUID("target") == nil or not Bich:checkZone(fcfg.show) then   --target is nil or not shown in this zone
        return
    end
    unitCreateBar("target")
end

-- save BichDB after logout
local function handlerPlayerLogout()
    for zone, _ in pairs(BichDB) do
        if not Bich:checkZone(fcfg.save, zone) then
            BichDB[zone] = nil
        end
    end
    for zone, _ in pairs(BichAddition.zone) do
        if not Bich:checkZone(fcfg.save, zone) then
            BichAddition.zone[zone] = nil
        end
    end
end

--event handler
local frame = CreateFrame("Frame")

function frame:onEvent(event, ...)
    if gEnable then
        if ns.loaded then
            if event == "COMBAT_LOG_EVENT_UNFILTERED" then
                handlerCombatLog(...)
            elseif event == "PLAYER_TARGET_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" then
                handlerTargetChanged()       
            elseif event == "PLAYER_LOGOUT" then
                handlerPlayerLogout()
            end
        elseif event == "ADDON_LOADED" then
            handlerAddonLoaded(...)
        end
    end
end

frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:SetScript("OnEvent", frame.onEvent)


-- slash commands
SLASH_BICH_RELOADER1 = "/rl"
SlashCmdList.BICH_RELOADER = function() ReloadUI() end

SLASH_BICH_CLEARDB1 = "/bichcleardb"
SLASH_BICH_CLEARDB2 = "/bclr"
SlashCmdList.BICH_CLEARDB = function()
    _G["BichDB"] = {}
    _G["BichAddition"].zone = {}
    _G["BichAddition"].unit = {}
end

SLASH_BICH_SEARCHDB1 = "/bichsearchdb"
SLASH_BICH_SEARCHDB2 = "/bs"

SlashCmdList.BICH_SEARCHDB = function(msg, editbox)
    local cmd, param = msg:match("^(%S*)%s*(.-)$")
    cmd = string.lower(cmd)
    if cmd == "num" or cmd == "number" then
        param = tonumber(param)
    elseif cmd == "mob" or cmd == "creature" or cmd == "unit" then
        param = tonumber(param)
    elseif cmd == "name" then
        -- do nothing
    else    -- invalid cmd
        param = nil
    end
    if param ~= nil then
        searchAndShow(cmd, param)
    else
        DEFAULT_CHAT_FRAME:AddMessage("Wrong parameters!", 255, 255, 255)
        DEFAULT_CHAT_FRAME:AddMessage("|cff00f0f0/bs|r num|unit|name  param", 255, 255, 255)
    end
end