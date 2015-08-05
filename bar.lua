local addon, ns = ...
local cfg = ns.cfg


local BichBar = CreateFrame("Frame", "BichSpellBar", UIParent)

function BichBar:addButton(spellid,i)

    local button = CreateFrame("Button", "BichSpellButton_"..tostring(i), self)
    local _, _, img = GetSpellInfo(spellid)
    
    button:SetWidth(32)
    button:SetHeight(32)
    button:SetPoint("CENTER", self, "CENTER", 34*(i-1), 0)
    
    button.spellIcon = button:CreateTexture(nil, "ARTWORK")
    button.spellIcon:SetAllPoints(button)
    button.spellIcon:SetTexture(img)
    --button.spellImage:Show()
    button:Show()
    return button
end

function BichBar:createBar(spells)
    
    self:SetWidth(200)
    self:SetHeight(36)
    self:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    
    self.buttons = {}
    
    for spellid, _ in pairs(spells) do
        local button = self:addButton(spellid, #self.buttons+1)
        table.insert(self.buttons, button)
    end

    -- self:Show()
    -- for i, button in ipairs(self.buttons) do
        -- button:Show()
    -- end
end

ns.BichBar = BichBar