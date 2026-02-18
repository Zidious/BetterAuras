--[[
    BetterAuras - Frame Hooks (Midnight 12.0.0+)

    This module sets up secure hooks into Blizzard's frame system.
    It intercepts buff/debuff updates and aura positioning to apply custom settings.

    @file FrameHooks.lua
    @author Zidious
    @version 1.0.2
]]

local ADDON_NAME, namespace = ...

-- Get addon reference
local BetterAuras = namespace.BetterAuras

-- Get module references
local Constants = namespace.Constants

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

--------------------------------------------------------------------------------
-- Secure Hooks
--------------------------------------------------------------------------------

--[[
    Hook into CompactUnitFrame_UpdateAuras to apply custom anchoring.
    This is called after Blizzard's aura layout system runs.
    Note: Aura frames are not protected, so we can safely reposition them during combat.
]]
hooksecurefunc("CompactUnitFrame_UpdateAuras", function(frame)
    if not frame or not frame.unit then
        return
    end

    -- Filter nameplates by unit token (reliable in Midnight 12.0.0+)
    if frame.unit:match("^nameplate") then
        return
    end

    -- Only process party and raid frames (including player)
    if not isPartyOrRaidUnit(frame.unit) then
        return
    end

    -- Apply custom anchoring after Blizzard's layout
    BetterAuras:ApplyCustomAnchoring(frame)
end)

return BetterAuras
