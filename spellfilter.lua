--[[
Some spells will generate many similar spell effects, with similar spellid, same icon and same description. These spellid should be saved in database but not shown in spell bar. this file implements spellfilter to filter all spell icon in database, and show some of them.

ns.BichSpellFilter
]]

local addon, ns = ...

local BichSpellFilter = {}

function BichSpellFilter:raw(spells)
    spells = spells or {}
    local spellList = {}
    for spellid, _ in pairs(spells) do
        table.insert(spellList, spellid)
    end
    return spellList
end

function BichSpellFilter:sort(spells)
    local spellList = self:raw(spells)
    table.sort(spellList)
    return spellList
end

function BichSpellFilter:delNoCd(spells)   ---delete the spell with same icon and name.
    local spellTable = {}
    for k, v in spells do   -- copy
        spellTable[k] = v
    end
    for spellid, _ in pairs(spellTable) do
        local name, _, icon = GetSpellInfo(spellid)
        -- GetSpellCooldown
        for s2, _ in pairs(spellTable) do
            if spellid ~= s2 then
                local n2, _, i2 = GetSpellInfo(s2)
                if name == n2 and icon == i2 then
                    spellTable[s2] = nil
                end
            end
        end
    end
end

function BichSpellFilter:isSameSpell(spellid1, spellid2)
    local name1, _, icon1 = GetSpellInfo(spellid1)
    local name2, _, icon2 = GetSpellInfo(spellid2)
    if name1 == name2 and icon1 == icon2 then
        return true
    else
        return false
    end
end

ns.BichSpellFilter = BichSpellFilter
