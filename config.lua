local addon, ns = ...
local cfg = {}
local barConfig = {}
local filterConfig = {}

-- global enable
cfg.enable = true


-- spellbar config
-- spellbar position
barConfig.position = {
    x = 0,
    y = -180,
}

-- spellbar relatives
barConfig.relative = {
    frame = UIParent,
    anchor = "CENTER",
}

barConfig.anchor = "CENTER"

-- set nil to arrange every icon in one row
barConfig.perRow = nil

-- anchor of tooltip of spells. avialable value:
-- ANCHOR_NONE, ANCHOR_CURSOR, ANCHOR_BOTTOMLEFT, ANCHOR_BOTTOMRIGHT, ANCHOR_LEFT, ANCHOR_RIGHT, ANCHOR_TOPLEFT, ANCHOR_TOPRIGHT
barConfig.tooltipAnchor = "ANCHOR_NONE"

-- icon size
barConfig.button = {
    height = 36,
    width = 36,
    margin = 4,
}

-- filter config
-- where to track the mobs' abilities
filterConfig.track = {
    Dungeon = true,
    Raid = true,
    Scenario = true,
    None = true,
}

-- where to show the bar of the mobs' abilities
filterConfig.show = {
    Dungeon = nil,
    Raid = nil,
    Scenario = nil,
    None = nil,
}

-- where to save to local file when player logout
filterConfig.save = {
    Dungeon = nil,
    Raid = nil,
    Scenario = nil,
    None = nil,
}

-- if set nil, filterConfig.show and filterConfig.save will follow filterConfig.track
for k, v in pairs(filterConfig.track) do
    if filterConfig.show[k] == nil then
        filterConfig.show[k] = v
    end
    if filterConfig.save[k] == nil then
        filterConfig.save[k] = v
    end
end

-- do not touch~
cfg.barConfig = barConfig
cfg.filterConfig = filterConfig
ns.cfg = cfg