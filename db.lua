-- class(table) Bich
local addon, ns = ...

BichDB = BichDB or {}

local Bich = {
    instanceType = {
        [0] = "None",
        [1] = "Normal",
        [2] = "Heroic",
        [3] = "10 Player",
        [4] = "25 Player",
        [5] = "10 Player (H)",
        [6] = "25 Player (H)",
        [7] = "Looking for Raid",
        [8] = "Challenge Mode",
        [9] = "40 Player",
        [11] = "Heroic Scenario",
        [12] = "Normal Scenario",
        [14] = "Normal",
        [15] = "Heroic",
        [16] = "Mythic",
        [17] = "Looking for Raid",
        --[18] = "Event",
        --[19] = "Event",
        --[20] = "Event Scenario",
        [23] = "Mythic (Dungeons)",
    }
    
    instanceCategory = {
        [0] = "None",
        [1] = "Dungeon",
        [2] = "Dungeon",
        [3] = "Raid",
        [4] = "Raid",
        [5] = "Raid",
        [6] = "Raid",
        [7] = "Raid",
        [8] = "Dungeon",
        [9] = "Raid",
        [11] = "Scenario",
        [12] = "Scenario",
        [14] = "Raid",
        [15] = "Raid",
        [16] = "Raid",
        [17] = "Raid",
        --[18] = "Event",
        --[19] = "Event",
        --[20] = "Event Scenario",
        [23] = "Dungeon",
    }
}

function Bich:getCreatureIdByGuid(guid)
    local utype, _, server, instance, zone, id, suid = strsplit("-", guid)
    if utype == "Creature" then
        return tonumber(id)
    else
        return -1
    end
end

function Bich:getZone()
    --local mapId = GetCurrentMapAreaID()
    local name, _, difficultyID, _, _, _, _, instanceMapID = GetInstanceInfo()
    local suffix = "0"  --outside
    if difficultyID ~= 0 then   --在地城中
        if self.instanceType[difficultyID] ~= nil then
            suffix = tostring(difficultyID)
        else
            suffix = 'i' --illegal
        end
    end
    return tostring(instanceMapID) .. "_" .. suffix, name
    --返回 mapId 和 map的名称
end
--GetRealZoneText()得到真实名字
--GetZoneText()得到名字（在地城中会有问题）
--GetMapNameByID(mapId)从mapid得到地图名字

-- 检查当前区域是否满足条件
function Bich:checkZone(filter, zone)
    zone = zone or self:getZone()
    local difficultyID = select(2,strsplit("_", zone))
    local category = self.instanceCategory[difficultyID]
    if category == nil then
        return false
    elseif filter[category] == nil then
        return filter["None"] or false
    else
        return filter[category] or false
    end
end

function Bich:addSpellAndSetName(zone, zoneName, unitid, unitName, spellid)
    if BichDB[zone] == nil then
        BichDB[zone] = {}
    end
    if BichDB[zone][unitid] == nil then
        BichDB[zone][unitid] = {}
    end
    if BichDB[zone][unitid].spells == nil then
        BichDB[zone][unitid].spells = {}
    end
    BichDB[zone].name = zoneName
    BichDB[zone][unitid].name = unitName
    BichDB[zone][unitid].spells[spellid] = true
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

function Bich:setZoneName(zone, name)
    if BichDB[zone] == nil then
        BichDB[zone] = {}
    end
    BichDB[zone].name = name
end

function Bich:setCreatureName(zone, unitid, name)
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
