local addon, ns = ...
local cfg = ns.cfg
local Bich = ns.Bich

-- initial
local function initAddon()

    DEFAULT_CHAT_FRAME:AddMessage("Bich reloaded", 255, 255, 255)
end

local function handlerAddonLoaded(name)
    if name == "Bich" then
        initAddon()
    end
end


-- store spell information
local function handlerCombatLog(timeStamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, 
                                sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)

    if event == "SPELL_HEAL" or event == "SPELL_CAST_START" or event == "SPELL_CAST_SUCCESS" then
        local spellid = select(1,...)
        local unitid = Bich:getCreatureIdByGuid(sourceGUID)
        local zone = Bich:getZone()
        Bich:addSpell(zone, unitid, spellid)
        Bich:setName(zone, unitid, sourceName)
        
        
        if unitid ~= -1 then
            DEFAULT_CHAT_FRAME:AddMessage(sourceName .. " spell: " .. GetSpellLink(spellid), 255, 255, 255)
        end
    end
end



-- show spells stored before
local function handlerTargetChanged(cause)
    if UnitGUID("target") == nil then
        return
    end
    local unitid = Bich:getCreatureIdByGuid(UnitGUID("target"))
    local zone = Bich:getZone()
    local info = Bich:getAllInfo(zone, unitid)
    if info.spells ~= nil then
        local name = UnitName("target")
        Bich:setName(zone, unitid, name)
        DEFAULT_CHAT_FRAME:AddMessage(name .. "'s spells:", 255, 255, 255)
        local msg = ""
        for spellid, _ in pairs(info.spells) do
            msg = msg .. GetSpellLink(spellid)
        end
        DEFAULT_CHAT_FRAME:AddMessage(msg, 255, 255, 255)
    end
end

--event handler
local function onEvent(this, event, ...)
    if cfg.enable then
        if event == "COMBAT_LOG_EVENT_UNFILTERED" then
            handlerCombatLog(...)
        elseif event == "PLAYER_TARGET_CHANGED" then
            handlerTargetChanged(...)
        elseif event == "ADDON_LOADED" then
            handlerAddonLoaded(...)
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", onEvent)
frame:Show()