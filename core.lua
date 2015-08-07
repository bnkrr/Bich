local addon, ns = ...
local gEnable = ns.cfg.enable
local fcfg = ns.cfg.filterConfig
local Bich = ns.Bich
local BichBar = ns.BichBar

-- initial
local function initAddon()
    DEFAULT_CHAT_FRAME:AddMessage("Bich loaded", 255, 255, 255)
    ns.loaded = true
end

local function handlerAddonLoaded(name)
    if name == "Bich" then
        initAddon()
    end
end

local function createBarTarget()
    local unitid = Bich:getCreatureIdByGuid(UnitGUID("target"))
    local zone = Bich:getZone()
    local info = Bich:getAllInfo(zone, unitid)
    if info.spells ~= nil then
        local name = UnitName("target")
        Bich:setCreatureName(zone, unitid, name)
        BichBar:createBar(info.spells)
        
        -- DEFAULT_CHAT_FRAME:AddMessage(name .. "'s spells:", 255, 255, 255)
        -- local msg = ""
        -- for spellid, _ in pairs(info.spells) do
            -- msg = msg .. GetSpellLink(spellid)
        -- end
        -- DEFAULT_CHAT_FRAME:AddMessage(msg, 255, 255, 255)
    end
end


-- store spell information
local function handlerCombatLog(timeStamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, 
                                sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)

    if not Bich:checkZone(fcfg.track) then
        return
    end
    --local hl = tostring(select(2, ...)) or tostring(select(1, ...))
    --DEFAULT_CHAT_FRAME:AddMessage((sourceName or "None") .. "  " .. (event or "None2") .. "  " .. (hl or "None3"), 255, 255, 255)
    if event == "SPELL_HEAL" or event == "SPELL_CAST_START" or event == "SPELL_CAST_SUCCESS" then
        local spellid = select(1, ...)
        local unitid = Bich:getCreatureIdByGuid(sourceGUID)
        local zone, zoneName = Bich:getZone()
        
        if unitid > 0 then
            local newSpell = Bich:addSpellAndSetName(zone, zoneName, unitid, sourceName, spellid)
            if sourceGUID == UnitGUID("target") and newSpell then
                createBarTarget()
            end
            --DEFAULT_CHAT_FRAME:AddMessage(sourceName .. " spell: " .. GetSpellLink(spellid), 255, 255, 255)
        end
    end
end



-- show spells stored before
local function handlerTargetChanged()
    BichBar:hideAllButtons()
    if UnitGUID("target") == nil or not Bich:checkZone(fcfg.show) then   --当前区域不显示，或者目标不可用
        return
    end
    createBarTarget()
end

-- save BichDB after logout
local function handlerPlayerLogout()
    for zone, _ in pairs(BichDB) do
        if not BichDB:checkZone(fcfg.save, zone) then
            BichDB[zone] = nil
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

SLASH_BICH_GLOBAL1 = "/bichglobal"
SLASH_BICH_GLOBAL2 = "/bi"
SlashCmdList.BICH_GLOBAL = function() _G["Bich"] = Bich   _G["bcfg"] = ns.cfg end

SLASH_BICH_CLEARDB1 = "/clearbichdb"
SLASH_BICH_CLEARDB2 = "/cb"
SlashCmdList.BICH_CLEARDB = function() _G["BichDB"] = {} end
