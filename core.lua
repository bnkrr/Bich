local addon, ns = ...
local cfg = ns.cfg

local initAddon()
--初始化
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
end

local function onEvent(this, event, ...)
    if cfg.enable then
        if event == "COMBAT_LOG_EVENT_UNFILTERED" then
            handlerCombatLog(...)
        elseif event == "PLAYER_TARGET_CHANGED" then
            handlerTargetChanged(..)
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