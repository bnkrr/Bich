local addon, ns = ...
local bcfg = ns.cfg.barConfig


local BichBar = CreateFrame("Frame", "BichSpellBar", UIParent)


function BichBar:init()
    self:SetWidth(200)
    self:SetHeight(50)
    self:SetPoint(bcfg.anchor, bcfg.relative.frame, bcfg.relative.anchor, bcfg.position.x, bcfg.position.y)
    self.buttons = {}
end


function BichBar:hideAllButtons()
    for i, button in ipairs(self.buttons) do
        button:Hide()
    end
end

function BichBar:createAndSetButton(spellid, i)
    local button = self:createButton(i)
    button:setButton(spellid)
    return button
end


function BichBar:createButton(i)
    local button = CreateFrame("Button", "BichSpellButton_"..tostring(i), self)
    local r, c = 0, i-1
    if bcfg.perRow ~= nil then
        r = math.floor((i-1)/bcfg.perRow)
        c = math.fmod(i-1,bcfg.perRow)
    end
    button:SetWidth(bcfg.button.width)
    button:SetHeight(bcfg.button.height)
    button:SetPoint("TOPLEFT", self, "TOPLEFT", 
                      (bcfg.button.width +bcfg.button.margin)*c,--(bcfg.button.width +bcfg.button.margin)*(c-(bcfg.perRow-1)/2),
                     -(bcfg.button.height+bcfg.button.margin)*r
                   )
    button.spellIcon = button:CreateTexture(nil, "ARTWORK")
    button.spellIcon:SetAllPoints(button)
    
    function button:setButton(spellid)
        local _, _, image = GetSpellInfo(spellid)
        self.spellIcon:SetTexture(image)
        --self.hyperlink = GetSpellLink(spellid)
        self.spellid = spellid
        self:Show()
    end
    
    function button:onEnter()
        GameTooltip_SetDefaultAnchor(GameTooltip, self)
        --GameTooltip:SetHyperlink(self.hyperlink)
        GameTooltip:SetSpellByID(self.spellid)
        GameTooltip:Show()
    end
    
    function button:onLeave()
        GameTooltip:FadeOut()
    end
    
    button:SetScript("OnEnter", button.onEnter)
    button:SetScript("OnLeave", button.onLeave)
    return button
end


function BichBar:addButton(spellid,i)
    if i > #self.buttons then
        local button = self:createAndSetButton(spellid, i)
        table.insert(self.buttons, button)
    else
        local button = self.buttons[i]
        button:setButton(spellid)
    end
end



function BichBar:createBar(spells)
    self:hideAllButtons()
    
    local i = 1
    for spellid, _ in pairs(spells) do
        self:addButton(spellid, i)
        i = i + 1
    end
end

BichBar:init()
ns.BichBar = BichBar