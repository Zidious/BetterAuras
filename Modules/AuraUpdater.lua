--[[
    BetterAuras - Aura Updater

    This module handles updating aura layouts on party and raid frames.
    It includes functions to update individual auras and refresh all frames.

    @file AuraUpdater.lua
    @author Zidious
    @version 1.0.2
]]

local ADDON_NAME, namespace = ...

-- Ensure BetterAuras global exists
BetterAuras = BetterAuras or {}

-- Get addon reference
local BetterAuras = BetterAuras
namespace.BetterAuras = BetterAuras

-- Get module references
local Constants = namespace.Constants
local Database = namespace.Database

--------------------------------------------------------------------------------
-- Aura Layout Functions
--------------------------------------------------------------------------------

--[[
    Updates all party and raid frames.
    Applies custom aura positioning to all visible party/raid frames.

    @return number Number of frames refreshed
]]
function BetterAuras:UpdateAllFrames()
    if InCombatLockdown() then
        return 0
    end

    local framesRefreshed = 0
    local frames = {}

    -- Gather all party/raid frames
    if CompactRaidFrameContainer then
        for _, frame in pairs({ CompactRaidFrameContainer:GetChildren() }) do
            if frame and frame.unit and not frame.unit:match("^nameplate") then
                table.insert(frames, frame)
            end
        end
    end

    -- CompactPartyFrame frames (including player)
    local playerFrame = _G[Constants.COMPACT_PARTY_FRAME_PLAYER]
    if playerFrame and playerFrame:IsShown() then
        table.insert(frames, playerFrame)
    end

    for i = 1, 4 do
        local compactFrame = _G[Constants.COMPACT_PARTY_FRAME_MEMBER_PREFIX .. i]
        if compactFrame and compactFrame:IsShown() then
            table.insert(frames, compactFrame)
        end
    end

    -- Apply custom anchoring to all frames
    for _, frame in ipairs(frames) do
        BetterAuras:ApplyCustomAnchoring(frame)
        framesRefreshed = framesRefreshed + 1
    end

    return framesRefreshed
end

return BetterAuras
