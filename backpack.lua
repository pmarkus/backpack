
-- Create addon with Ace and desired embeds
Backpack = LibStub("AceAddon-3.0"):NewAddon("Backpack", "AceConsole-3.0", "AceEvent-3.0")

function Backpack:OnInitialize()

    Backpack:Print("test")
    -- Register bag update events
    Backpack:RegisterEvent("BAG_UPDATE")

    -- Register chat commands
    Backpack:RegisterChatCommand("backpack", "ProcessChatCommand")

    -- Create the icon frame
    local f = CreateFrame("Frame",nil,UIParent)
    f:SetFrameStrata("BACKGROUND")
    f:SetWidth(128) -- Set these to whatever height/width is needed
    f:SetHeight(64) -- for your Texture

    local t = f:CreateTexture(nil,"BACKGROUND")
    t:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Factions.blp")
    t:SetAllPoints(f)
    f.texture = t

    f:SetPoint("CENTER",0,0)

    Backpack.iconFrame = f
end

function Backpack:OnEnable()
    -- Called when the addon is enabled
end

function Backpack:OnDisable()
    -- Called when the addon is disabled
end

function Backpack:BAG_UPDATE(eventName, ...)
    local bagID = ...
    Backpack:Print('Bag ' .. bagID .. ' updated!')
end

function Backpack:ProcessChatCommand(input)
    if (input == "show") then
        Backpack.iconFrame:Show()
    elseif (input == "hide") then
        Backpack.iconFrame:Hide()
    else
        Backpack:Print("Backpack: Unknown command '" .. input .. "'")
    end
end
