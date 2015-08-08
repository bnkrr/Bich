local addon, ns = ...
local bcfg = ns.cfg.barConfig


local BichBar = CreateFrame("Frame", "BichSpellBar", UIParent)


function BichBar:init()
    self:SetWidth(200)
    self:SetHeight(50)
    self:SetPoint(bcfg.anchor, bcfg.relative.frame, bcfg.relative.anchor, bcfg.position.x, bcfg.position.y)
    self.buttons = {}
    self.buttonCount = 0
end


function BichBar:hideAllButtons()
    self.buttonCount = 0
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
        --GameTooltip_SetDefaultAnchor(GameTooltip, self)
        --GameTooltip:SetHyperlink(self.hyperlink)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
        GameTooltip:SetSpellByID(self.spellid)
        GameTooltip:Show()
    end
    
    function button:onLeave()
        GameTooltip:FadeOut()
    end
    
    
    function button:onClick(buttonType)
        if IsShiftKeyDown() and buttonType == "LeftButton" and ChatFrame1EditBox:IsVisible() then
            ChatFrame1EditBox:Insert(GetSpellLink(self.spellid))
        end
    end
    
    button:SetScript("OnEnter", button.onEnter)
    button:SetScript("OnLeave", button.onLeave)
    button:SetScript("OnMouseDown", button.onClick)
    return button
end

function BichBar:addButton(spellid,i)
    i = i or self.buttonCount+1
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
    
    spellsort = {}
    for spellid, _ in pairs(spells) do
        table.insert(spellsort, spellid)
    end
    table.sort(spellsort)
    for i, spellid in ipairs(spellsort) do
        self.buttonCount = self.buttonCount + 1
        self:addButton(spellid, self.buttonCount)
    end
end

BichBar:init()
ns.BichBar = BichBar