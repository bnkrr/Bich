local addon, ns = ...
local cfg = ns.cfg

-- class(table) Bich
Bich = {}

function Bich:getCreatureIdByGuid(guid)
    local utype, _, server, instance, zone, id, suid = strsplit("-", guid)
    if utype == "Creature" then
        return tonumber(id)
    else
        return -1
    end
end

function Bich:getSpellIdByEvent()
end

function Bich:addSpell(id, spellid)
end

function Bich:getAllSpell()
end


local function initAddon()
--初始化
    DEFAULT_CHAT_FRAME:AddMessage("Bich reloaded", 255, 255, 255)
end

local function handlerAddonLoaded(name)
    if name == "Bich" then
        initAddon()
    end
end

local function handlerTargetChanged(caurse)
--更新显示信息
end

local function handlerCombatLog(timeStamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, 
                                sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
--存储新信息
    if event == "SPELL_HEAL" or event == "SPELL_CAST_START" or event == "SPELL_CAST_SUCCESS" then
        local spellid = select(1,...)
        local unitid = Bich:getCreatureIdByGuid(sourceGUID)
        if unitid ~= -1 then
            DEFAULT_CHAT_FRAME:AddMessage(sourceName .. " spell: " .. GetSpellLink(spellid), 255, 255, 255)
        end
    end
end

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