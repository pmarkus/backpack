
-- Create addon with Ace and desired embeds
Backpack = LibStub("AceAddon-3.0"):NewAddon("Backpack", "AceConsole-3.0", "AceEvent-3.0")

function Backpack:OnInitialize()
    -- Register bag update events
    Backpack:RegisterEvent("BAG_UPDATE")

    -- Register chat commands
    Backpack:RegisterChatCommand("backpack", "ProcessChatCommand")

    -- Set up tables for the standard bags
    Backpack.BlizzardBags = {}
    Backpack.BagsHidden = false
    local bags = Backpack.BlizzardBags
    for x = 0, NUM_BAG_SLOTS do
        -- create a dummy bag frame to act as host for the item slot frames,
        -- ContainerFrameItemButtonTemplate expects this,
        -- we dont have to modify it too much that way
        local bag = CreateFrame('Frame', "DummyBag"..x, UIParent)
        bag:SetFrameStrata("MEDIUM")
        -- set a static size to use for now
        bag:SetWidth(160)
        bag:SetHeight(400)
        -- anchor it to the left side, 10 units of padding
        bag:SetPoint('LEFT', x*160 + 10, 0)
        -- set the containerID so that the itemslot frames get the correct data
        -- for UseContainerItem etc.
        bag:SetID(x)

        -- create tables for the slots of this bag
        bags[x] = bag
        bag.Slots = {}
        bag.numSlots = GetContainerNumSlots(x)

        for y = 1, bag.numSlots do
            -- create a frame for the itemslot, based on the standard blizzard
            -- template so that we can let that do the protected stuff
            local f = CreateFrame("Button", "TestSlot_"..x.."_"..y, bag,
                                        "ContainerFrameItemButtonTemplate")
            bag.Slots[y] = f

            -- set the slotID that the template expects
            f:SetID(y)

            -- clear all anchor points so that none are left from the template
            f:ClearAllPoints()

            -- position the slots starting from the top left, 4 per row
            if (y == 1) then
                f:SetPoint("TOPLEFT", "DummyBag"..x, "TOPLEFT", 0, 0);
            else
                if (mod((y-1), 4) == 0) then
                    f:SetPoint("TOPLEFT", "TestSlot_"..x.."_"..(y-4),
                                                        "BOTTOMLEFT", 0, 0)
                else
                    f:SetPoint("TOPLEFT", "TestSlot_"..x.."_"..(y-1),
                                                        "TOPRIGHT", 0, 0)
                end
            end

            -- update the slot with info from the actual slot in the game
            Backpack:UpdateItemSlot(x, y)

            -- the template starts hidden so we need to show it
            f:Show()
        end
    end
end

function Backpack:OnEnable()
    -- Called when the addon is enabled
end

function Backpack:OnDisable()
    -- Called when the addon is disabled
end

-- Updates itemslot data for the bag contents
function Backpack:BAG_UPDATE(eventName, ...)
    local bagID = ...
    -- grab the bag dummy frame to access its slots
    local bag = Backpack.BlizzardBags[bagID]

    -- as this event can be called before our addon has the proper tables set up
    -- we simply ignore it if we arent ready
    if (bag ~= nil) then
        for y = 1, bag.numSlots do
            Backpack:UpdateItemSlot(bagID, y)
        end
    end
end

-- Updates itemslot data for the specified slot (bagID, slotID)
function Backpack:UpdateItemSlot(bag, slot)
    -- fetch the button frame for this slot
    local button = Backpack.BlizzardBags[bag].Slots[slot]

    -- poll the game for info about the item in this slot,
    -- if there is anything there
    local texture, itemCount, locked, quality, readable, lootable, itemLink
                                            = GetContainerItemInfo(bag, slot)
    button.hasItem = itemLink
    button.readable = readable
    SetItemButtonTexture(button, texture)
    SetItemButtonCount(button, itemCount)
    SetItemButtonDesaturated(button, locked)
end

-- Toggles showing the bags
function Backpack:ToggleBags()
    for index, bag in pairs(Backpack.BlizzardBags) do
        if (Backpack.BagsHidden == true) then
            bag:Show()
        else
            bag:Hide()
        end
    end
    Backpack.BagsHidden = not Backpack.BagsHidden
end

function Backpack:ProcessChatCommand(input)
    if (input == "show") then
        -- force the setting so that the toggle will behave as desired
        Backpack.BagsHidden = true
        Backpack:ToggleBags()
    elseif (input == "hide") then
        -- force the setting so that the toggle will behave as desired
        Backpack.BagsHidden = false
        Backpack:ToggleBags()
    elseif (input == 'toggle') then
        Backpack:ToggleBags()
    else
        Backpack:Print("Backpack: Unknown command '" .. input .. "'")
    end
end
