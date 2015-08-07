local addon, ns = ...
local cfg = {}
local barConfig = {}
local filterConfig = {}

-- 总开关
cfg.enable = true

-- spellbar设置
--位置

barConfig.position = {
    x = 0,
    y = -180,
}

barConfig.relative = {
    frame = UIParent,
    anchor = "CENTER",
}

barConfig.anchor = "CENTER"

barConfig.perRow = nil

-- 图标大小
barConfig.button = {
    height = 36,
    width = 36,
    margin = 4,
}



--过滤器的设置
-- 记录位置
filterConfig.track = {
    Dungeon = true,
    Raid = true,
    Scenario = true,
    None = true,
}

filterConfig.show = {
    Dungeon = nil,
    Raid = nil,
    Scenario = nil,
    None = nil,
}

filterConfig.save = {
    Dungeon = nil,
    Raid = nil,
    Scenario = nil,
    None = nil,
}

-- 如果没有设置，则跟随track的设置
for k, v in pairs(filterConfig.track) do
    if filterConfig.show[k] == nil then
        filterConfig.show[k] = v
    end
    if filterConfig.save[k] == nil then
        filterConfig.save[k] = v
    end
end


cfg.barConfig = barConfig
cfg.filterConfig = filterConfig
ns.cfg = cfg