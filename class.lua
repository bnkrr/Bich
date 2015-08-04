-- class(table) Bich
local addon, ns = ...

local Bich = {
    db = {}
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
    return 0
end


function Bich:addSpell(zone, unitid, spellid)
    if self.db[zone] == nil then
        self.db[zone] = {}
    end
    if self.db[zone][unitid] == nil then
        self.db[zone][unitid] = {}
    end
    if self.db[zone][unitid].spells == nil then
        self.db[zone][unitid].spells = {}
    end
    self.db[zone][unitid].spells[spellid] = true
end

function Bich:setName(zone, unitid, name)
    if self.db[zone] == nil then
        self.db[zone] = {}
    end
    if self.db[zone][unitid] == nil then
        self.db[zone][unitid] = {}
    end
    self.db[zone][unitid].name = name
end

function Bich:getAllInfo(zone, unitid)
    return self.db[zone] and self.db[zone][unitid] or {}
end

ns.Bich = Bich