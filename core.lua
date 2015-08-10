local addon, ns = ...
local gEnable = ns.cfg.enable
local fcfg = ns.cfg.filterConfig
local Bich = ns.Bich
local BichBar = ns.BichBar

-- initial
local function initAddon()
    math.randomseed(os.time())
    DEFAULT_CHAT_FRAME:AddMessage("|cff00bfffBich|r loaded", 255, 255, 255)
    Bich:checkVersion() -- check database version
    ns.loaded = true
end

local function handlerAddonLoaded(name)
    if name == "Bich" then
        initAddon()
    end
end


-- store spell information
local function handlerCombatLog(timeStamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, 
                                sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)

    if not Bich:checkZone(fcfg.track) then
        return
    end
    if event == "SPELL_HEAL" or event == "SPELL_CAST_START" or event == "SPELL_CAST_SUCCESS" then
        local spellid = select(1, ...)
        local unitid = Bich:getCreatureIdByGuid(sourceGUID)
        local zone, zoneName = Bich:getZone()
        
        if unitid > 0 then
            local newSpell = Bich:addSpellAndSetName(zone, zoneName, unitid, sourceName, spellid)
            if unitid == Bich:getCreatureIdByGuid(UnitGUID("target")) and newSpell then
                BichBar:createBarUnit("target")
            end
        end
    end
end


-- show spells stored before
local function handlerTargetChanged()
    BichBar:hideAllButtons()
    if UnitGUID("target") == nil or not Bich:checkZone(fcfg.show) then   --target is nil or not shown in this zone
        return
    end
    BichBar:createBarUnit("target")
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
SlashCmdList.BICH_CLEARDB = function() _G["BichDB"] = {} end

SLASH_BICH_SEARCHDB1 = "/bichsearchdb"
SLASH_BICH_SEARCHDB2 = "/bs"

SlashCmdList.BICH_SEARCHDB = function(msg, editbox)
    local cmd, param = msg:match("^(%S*)%s*(.-)$")
    cmd = string.lower(cmd)
    if cmd == "num" or cmd == "number" then
        param = tonumber(param)
    elseif cmd == "mob" or cmd == "creature" or cmd == "unit" then
        param = tonumber(param)
    -- elseif cmd == "name" then
        -- do nothing
    end
    if param ~= nil then
        BichBar:searchAndShow(cmd, param)
    else
        DEFAULT_CHAT_FRAME:AddMessage("Wrong parameters!", 255, 255, 255)
        DEFAULT_CHAT_FRAME:AddMessage("/bs num|unit|name param", 255, 255, 255)
    end
end