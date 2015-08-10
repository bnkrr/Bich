-- only contains database functions, method: class Bich, data: BichDB, BichAddition
local addon, ns = ...
local BichSpellFilter = ns.BichSpellFilter

BichDB = BichDB or {}       -- only store spell info
local BichDBVersion = 1     -- BichAddition save creature id, names, zone names, zone id
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
    },
    
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
    },
}

function Bich:checkVersion()
    if BichAddition == nil or BichAddition.version ~= BichDBVersion then
        BichDB = {}
        BichAddition = { 
            version = BichDBVersion,
            unit = {}, 
            zone = {},
        }
    end
end


function Bich:getCreatureIdByGuid(guid)
    local utype, _, server, instance, zone, id, suid = strsplit("-", guid)
    if utype == "Creature" or utype == "Vehicle" then
        return tonumber(id)
    else
        return -1
    end
end

function Bich:getZone()
    --local mapId = GetCurrentMapAreaID()
    local name, _, difficultyID, _, _, _, _, instanceMapID = GetInstanceInfo()
    local suffix = "0"  --outside
    if difficultyID ~= 0 then   --in instances
        if self.instanceType[difficultyID] ~= nil then
            suffix = tostring(difficultyID)
        else
            suffix = 'i' --illegal
        end
    end
    return tostring(instanceMapID) .. "_" .. suffix, name
    --return mapId and mapName
end

-- check if the mob in this zone should be saved
function Bich:checkZone(filter, zone)
    zone = zone or self:getZone()
    local difficultyID = tonumber(select(2,strsplit("_", zone)))
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
    self:addSpell(zone, unitid, spellid)
    self:setZoneName(zone, zoneName)
    self:setUnitName(unitid, unitName)
end

function Bich:addSpell(zone, unitid, spellid)
    if BichDB[zone] == nil then
        BichDB[zone] = {}
    end
    if BichDB[zone][unitid] == nil then
        BichDB[zone][unitid] = {}
    end
    if BichDB[zone][unitid][spellid] then
        return false
    else
        BichDB[zone][unitid][spellid] = true
        return true
    end
end

function Bich:setZoneName(zone, name)   -- may be different when difficulty differs
    BichAddition.zone[zone] = name
end

function Bich:getZoneName(zone)
    return BichAddition.zone[zone] or "Not Found."
end

function Bich:setUnitName(unitid, name)
    BichAddition.unit[unitid] = name
end

function Bich:getUnitName(unitid)
    return BichAddition.unit[unitid] or "Not Found."
end

function Bich:getAllSpellInfo(zone, unitid)
    return BichDB[zone] and BichDB[zone][unitid] or {}
end

function Bich:getFilteredSpellInfo(zone, unitid, cmd)
    local rawInfo = BichDB[zone] and BichDB[zone][unitid] or {}
    if cmd == "raw" then
        return BichSpellFilter:raw(rawInfo)
    elseif cmd == "sort" then
        return BichSpellFilter:sort(rawInfo)
    else
        return BichSpellFilter:raw(rawInfo)
    end
end


-- search

function Bich:search(cmd, param)
    local condition = nil
    if cmd == "num" or cmd == "number" then
        condition = function (unitid, mobSpells, param)
            local spellNum = #BichSpellFilter:raw(mobSpells)
            return type(mobSpells) == "table" and spellNum > param
        end
    elseif cmd == "mob" or cmd == "creature" or cmd == "unit" then
        condition = function (unitid, mobSpells, param) return unitid == param end
    elseif cmd == "name" then
        condition = function (unitid, mobSpells, param) return self:getUnitName(unitid) == param end
    else
        condition = function (unitid, mobSpells, param) return false end
    end
    
    local result = {}
    for zone, zoneInfo in pairs(BichDB) do
        for unitid, mobSpells in pairs(zoneInfo) do
            if condition(unitid, mobSpells, param) then
                table.insert(result, {zone=zone, unitid=unitid, spells=BichSpellFilter:sort(mobSpells)})
            end
        end
    end
    return result
end
    
ns.Bich = Bich
