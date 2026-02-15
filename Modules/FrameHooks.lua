--[[
    BetterAuras - Frame Hooks

    This module sets up secure hooks into Blizzard's frame system.
    It intercepts buff/debuff updates and aura positioning to apply custom settings.

    @file FrameHooks.lua
    @author Zidious
    @version 1.0.0
]]

local ADDON_NAME, namespace = ...

-- Get addon reference
local BetterAuras = namespace.BetterAuras

-- Get module references
local Constants = namespace.Constants
local Database = namespace.Database

--------------------------------------------------------------------------------
-- Utility Functions
--------------------------------------------------------------------------------

--[[
    Checks if a unit is a party or raid frame.

    @param unit string The unit token to check
    @return boolean True if the unit is a party or raid member
]]
local function isPartyOrRaidUnit(unit)
    if not unit then
        return false
    end

    return unit:match(Constants.PARTY_UNIT_PATTERN) or
        unit:match(Constants.RAID_UNIT_PATTERN) or
        unit == Constants.PLAYER_UNIT
end

--[[
    Checks if a frame is a nameplate frame.

    @param frame table The frame to check
    @return boolean True if the frame is a nameplate
]]
local function isNamePlateFrame(frame)
    if not frame then
        return false
    end

    -- Check the unit token first - nameplates have unit tokens like "nameplate1", "nameplate2", etc.
    if frame.unit and type(frame.unit) == "string" and frame.unit:match("^nameplate") then
        return true
    end

    -- Check if frame has displayedUnit (some nameplate frames use this)
    if frame.displayedUnit and type(frame.displayedUnit) == "string" and frame.displayedUnit:match("^nameplate") then
        return true
    end

    -- Try to get frame name safely with pcall to handle any errors
    local success, frameName = pcall(function()
        return frame.GetName and frame:GetName()
    end)

    if success and frameName and type(frameName) == "string" then
        -- Check if frame name contains "NamePlate"
        return frameName:match("NamePlate") ~= nil
    end

    -- Check parent frame as well
    if frame.GetParent then
        local parentSuccess, parent = pcall(function()
            return frame:GetParent()
        end)

        if parentSuccess and parent then
            local parentNameSuccess, parentName = pcall(function()
                return parent.GetName and parent:GetName()
            end)

            if parentNameSuccess and parentName and type(parentName) == "string" and parentName:match("NamePlate") then
                return true
            end
        end
    end

    return false
end

--------------------------------------------------------------------------------
-- Secure Hooks
--------------------------------------------------------------------------------

--[[
    Hook into CompactUnitFrame_UpdateAuras to apply custom anchoring.
    This is called after Blizzard's aura layout system runs.
]]
hooksecurefunc("CompactUnitFrame_UpdateAuras", function(frame)
    if not frame or InCombatLockdown() then
        return
    end

    -- Explicitly filter out nameplate frames
    if isNamePlateFrame(frame) then
        return
    end

    -- Only apply to party/raid frames, not nameplates
    if not frame.unit then
        return
    end

    local unit = frame.unit

    -- Filter out nameplates - only process party and raid frames (including player)
    if not isPartyOrRaidUnit(unit) then
        return
    end

    -- Ensure frame has a name
    local frameName = frame.GetName and frame:GetName()
    if not frameName then
        return
    end

    -- Apply custom anchoring after Blizzard's layout
    -- Use immediate execution instead of timer to avoid stale frame references
    if not InCombatLockdown() then
        BetterAuras:ApplyCustomAnchoring(frame)
    end
end)

return BetterAuras
