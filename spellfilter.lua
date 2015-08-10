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
    return table.sort(self:raw(spells))
end

ns.BichSpellFilter = BichSpellFilter