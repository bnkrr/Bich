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
        if bcfg.tooltipAnchor == "ANCHOR_NONE" then
            GameTooltip_SetDefaultAnchor(GameTooltip, self)
        else
            GameTooltip:SetOwner(self, bcfg.tooltipAnchor)
        end
        --GameTooltip:SetHyperlink(self.hyperlink)
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

    for i, spellid in ipairs(spells) do
        self.buttonCount = self.buttonCount + 1
        self:addButton(spellid, self.buttonCount)
    end
end


function BichBar:createBarUnit(flag)--"target"
    local unitid = Bich:getCreatureIdByGuid(UnitGUID(flag))
    local zone = Bich:getZone()
    local spells = Bich:getFilteredSpellInfo(zone, unitid, "sort")
    if next(spells) ~= nil then
        local name = UnitName(flag)
        Bich:setUnitName(unitid, name)
        self:createBar(spells)
        --  for debug
        --BichBar:printMobInfoToChat({zone=zone, unitid=unitid, spells=spells})
    end
end

--debug functions


function BichBar:printMobInfoToChat(mobInfo)
    local name = Bich:getUnitName(mobInfo.unitid)
    
    local msg = ""
    for i, spellid in ipairs(spellsort) do
        msg = msg .. GetSpellLink(spellid)
    end

    DEFAULT_CHAT_FRAME:AddMessage(name .. ":" .. msg, 255, 255, 255)
end

function BichBar:printSearchResultToChat(limit)
    limit = limit or #self.searchResult -- no limit by default
    for i, mobInfo in ipairs(self.searchResult) do
        if i <= limit then
            self:printMobInfoToChat(mobInfo)
        end
    end
end

function BichBar:searchAndShow(cmd, param)
    self.searchResult = Bich:search(cmd, param)
    if #self.searchResult > 0 then
        local randomChoosen = self.searchResult[ math.random(1,#self.searchResult) ]
        self:createBar(randomChoosen.spells)
        self:printSearchResultToChat()
    end
end

BichBar:init()
ns.BichBar = BichBar