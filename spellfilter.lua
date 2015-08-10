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

ns.BichSpellFilter = BichSpellFilter