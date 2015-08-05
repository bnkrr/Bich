-- class(table) Bich
local addon, ns = ...

BichDB = BichDB or {}

local Bich = {}

function Bich:getCreatureIdByGuid(guid)
    local utype, _, server, instance, zone, id, suid = strsplit("-", guid)
    if utype == "Creature" then
        return tonumber(id)
    else
        return -1
    end
end

function Bich:getZone()
--GetCurrentMapAreaID()得到map area ID
--GetRealZoneText()得到真实名字
--GetZoneText()得到名字（在地城中会有问题）
--GetMapNameByID(mapId)从mapid得到地图名字
    return 0
end


function Bich:addSpell(zone, unitid, spellid)
    if BichDB[zone] == nil then
        BichDB[zone] = {}
    end
    if BichDB[zone][unitid] == nil then
        BichDB[zone][unitid] = {}
    end
    if BichDB[zone][unitid].spells == nil then
        BichDB[zone][unitid].spells = {}
    end
    BichDB[zone][unitid].spells[spellid] = true
end

function Bich:setName(zone, unitid, name)
    if BichDB[zone] == nil then
        BichDB[zone] = {}
    end
    if BichDB[zone][unitid] == nil then
        BichDB[zone][unitid] = {}
    end
    BichDB[zone][unitid].name = name
end

function Bich:getAllInfo(zone, unitid)
    return BichDB[zone] and BichDB[zone][unitid] or {}
end

ns.Bich = Bich