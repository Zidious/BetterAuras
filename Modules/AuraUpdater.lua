--[[
    BetterAuras - Aura Updater

    This module handles updating aura layouts on party and raid frames.
    It includes functions to update individual auras and refresh all frames.

    @file AuraUpdater.lua
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
-- Aura Layout Functions
--------------------------------------------------------------------------------

--[[
    Updates a single aura frame with the specified size.

    @param frameName string The global name of the aura frame
    @param auraSize number The size to apply to the aura frame
    @return boolean True if the frame was updated, false otherwise
]]
local function updateSingleAuraFrame(frameName, auraSize)
    if not frameName then
        return false
    end

    local auraFrame = _G[frameName]

    -- Validate frame exists and is proper table
    if not auraFrame or type(auraFrame) ~= "table" then
        return false
    end

    -- Check if it's a nameplate frame before calling any methods
    local isNamePlate = false
    if auraFrame.GetName then
        local success, actualFrameName = pcall(auraFrame.GetName, auraFrame)
        if success and actualFrameName and type(actualFrameName) == "string" and actualFrameName:match("NamePlate") then
            isNamePlate = true
        end
    end

    -- Only process if not a nameplate and is shown
    if not isNamePlate and auraFrame.IsShown and auraFrame:IsShown() then
        auraFrame:SetSize(auraSize, auraSize)
        if auraFrame.icon then
            auraFrame.icon:SetAllPoints(auraFrame)
        end
        return true
    end

    return false
end

--[[
    Updates the aura layout for a specific frame.
    Iterates through buff and debuff frames and applies custom sizing.

    @param frame table The frame to update
    @return number The number of auras updated
]]
function VividFrames:UpdateAuraLayout(frame)
    if not frame or not frame.unit then
        return 0
    end

    -- Check for nameplate by unit token first (most reliable)
    if frame.unit and type(frame.unit) == "string" and frame.unit:match("^nameplate") then
        return 0
    end

    -- Safely get frame name
    local frameName = frame.GetName and frame:GetName()
    if not frameName then
        return 0
    end

    -- Skip nameplate frames by name
    if frameName:match("NamePlate") then
        return 0
    end

    local buffSize = Database:Get("buffSize")
    local debuffSize = Database:Get("debuffSize")
    local auraUpdateCount = 0

    -- Try to find and update buff/debuff frames through iteration
    for i = 1, Constants.MAX_AURA_SLOTS do
        local buffName = frameName .. Constants.BUFF_FRAME_SUFFIX .. i
        local debuffName = frameName .. Constants.DEBUFF_FRAME_SUFFIX .. i

        -- Update buff frame
        if updateSingleAuraFrame(buffName, buffSize) then
            auraUpdateCount = auraUpdateCount + 1
        end

        -- Update debuff frame
        if updateSingleAuraFrame(debuffName, debuffSize) then
            auraUpdateCount = auraUpdateCount + 1
        end
    end

    return auraUpdateCount
end

--[[
    Updates all party and raid frames.
    Forces a refresh of all visible unit frames.

    @return number Number of frames refreshed
    @return number Total number of auras updated
]]
function BetterAuras:UpdateAllFrames()
    if InCombatLockdown() then
        return 0, 0
    end

    local framesRefreshed = 0
    local totalAurasUpdated = 0
    local unitFramesToUpdate = {}

    -- Check CompactRaidFrameContainer frames
    if CompactRaidFrameContainer then
        for _, frame in pairs({ CompactRaidFrameContainer:GetChildren() }) do
            if frame and frame.unit then
                table.insert(unitFramesToUpdate, frame)
            end
        end
    end

    -- Check individual party frames (PartyMemberFrame1-4)
    for i = 1, 4 do
        local partyFrame = _G[Constants.PARTY_MEMBER_FRAME_PREFIX .. i]
        if partyFrame and partyFrame:IsShown() then
            table.insert(unitFramesToUpdate, partyFrame)
        end
    end

    -- Check CompactPartyFrame frames (including player)
    local playerFrame = _G[Constants.COMPACT_PARTY_FRAME_PLAYER]
    if playerFrame and playerFrame:IsShown() then
        table.insert(unitFramesToUpdate, playerFrame)
    end

    for i = 1, 4 do
        local compactFrame = _G[Constants.COMPACT_PARTY_FRAME_MEMBER_PREFIX .. i]
        if compactFrame and compactFrame:IsShown() then
            table.insert(unitFramesToUpdate, compactFrame)
        end
    end

    -- Force CompactUnitFrame_UpdateAuras on all frames to reposition
    for _, frame in ipairs(unitFramesToUpdate) do
        -- Extra safety check: skip nameplate frames by unit token
        if frame.unit and type(frame.unit) == "string" and frame.unit:match("^nameplate") then
            -- Skip nameplate frames
        else
            -- Also check by frame name
            local frameName = frame.GetName and frame:GetName()
            if frameName and frameName:match("NamePlate") then
                -- Skip this frame
            elseif CompactUnitFrame_UpdateAuras then
                CompactUnitFrame_UpdateAuras(frame)

                -- Apply custom anchoring immediately
                if not InCombatLockdown() then
                    BetterAuras:ApplyCustomAnchoring(frame)
                end

                local aurasUpdated = BetterAuras:UpdateAuraLayout(frame)
                if aurasUpdated and aurasUpdated > 0 then
                    totalAurasUpdated = totalAurasUpdated + aurasUpdated
                    framesRefreshed = framesRefreshed + 1
                end
            end
        end
    end

    return framesRefreshed, totalAurasUpdated
end

return BetterAuras
