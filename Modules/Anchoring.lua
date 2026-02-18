--[[
    BetterAuras - Custom Anchoring

    This module handles custom positioning and anchoring of auras.
    It applies user-configured settings for buff and debuff positioning,
    spacing, padding, and stack count display.

    @file Anchoring.lua
    @author Zidious
    @version 1.0.1
]]

local ADDON_NAME, namespace = ...

-- Get addon reference
local BetterAuras = namespace.BetterAuras

-- Get module references
local Constants = namespace.Constants
local Database = namespace.Database

--------------------------------------------------------------------------------
-- Anchoring Functions
--------------------------------------------------------------------------------

--[[
    Applies anchor position to the first aura frame.

    @param auraFrame table The aura frame to position
    @param parentFrame table The parent frame to anchor to
    @param anchor string The anchor point (TOPLEFT, TOPRIGHT, etc.)
    @param paddingTop number Top padding
    @param paddingRight number Right padding
    @param paddingBottom number Bottom padding
    @param paddingLeft number Left padding
]]
local function applyFirstAuraAnchor(auraFrame, parentFrame, anchor, paddingTop, paddingRight, paddingBottom, paddingLeft)
    if anchor == Constants.ANCHOR_TOP_RIGHT then
        auraFrame:SetPoint(Constants.ANCHOR_TOP_RIGHT, parentFrame, Constants.ANCHOR_TOP_RIGHT,
            -paddingRight, -paddingTop)
    elseif anchor == Constants.ANCHOR_TOP_LEFT then
        auraFrame:SetPoint(Constants.ANCHOR_TOP_LEFT, parentFrame, Constants.ANCHOR_TOP_LEFT,
            paddingLeft, -paddingTop)
    elseif anchor == Constants.ANCHOR_BOTTOM_RIGHT then
        auraFrame:SetPoint(Constants.ANCHOR_BOTTOM_RIGHT, parentFrame, Constants.ANCHOR_BOTTOM_RIGHT,
            -paddingRight, paddingBottom)
    elseif anchor == Constants.ANCHOR_BOTTOM_LEFT then
        auraFrame:SetPoint(Constants.ANCHOR_BOTTOM_LEFT, parentFrame, Constants.ANCHOR_BOTTOM_LEFT,
            paddingLeft, paddingBottom)
    end
end

--[[
    Applies positioning for subsequent aura frames relative to the previous one.

    @param auraFrame table The current aura frame to position
    @param previousFrame table The previous aura frame to anchor to
    @param anchor string The anchor point
    @param spacing number The spacing between frames
]]
local function applySubsequentAuraAnchor(auraFrame, previousFrame, anchor, spacing)
    -- Position subsequent auras based on anchor direction
    if anchor == Constants.ANCHOR_TOP_RIGHT or anchor == Constants.ANCHOR_BOTTOM_RIGHT then
        auraFrame:SetPoint("RIGHT", previousFrame, "LEFT", -spacing, 0)
    else
        auraFrame:SetPoint("LEFT", previousFrame, "RIGHT", spacing, 0)
    end
end

--[[
    Updates stack count text positioning and font size.

    @param auraFrame table The aura frame containing the count text
    @param fontSize number The font size to apply
    @param offsetX number X offset from bottom-right
    @param offsetY number Y offset from bottom-right
]]
local function updateStackCount(auraFrame, fontSize, offsetX, offsetY)
    if auraFrame.count then
        auraFrame.count:ClearAllPoints()
        auraFrame.count:SetPoint(Constants.ANCHOR_BOTTOM_RIGHT, auraFrame, Constants.ANCHOR_BOTTOM_RIGHT,
            offsetX, offsetY)
        auraFrame.count:SetFont(auraFrame.count:GetFont(), fontSize, Constants.FONT_OUTLINE)
    end
end

--[[
    Processes a set of aura frames (buffs or debuffs) and applies custom positioning.

    @param config table Configuration table with the following keys:
        - frameName: string - The base frame name
        - parentFrame: table - The parent frame
        - auraType: string - Either "Buff" or "Debuff"
        - size: number - The size of each aura frame
        - anchor: string - The anchor point
        - spacing: number - The spacing between frames
        - paddingTop: number - Top padding
        - paddingRight: number - Right padding
        - paddingBottom: number - Bottom padding
        - paddingLeft: number - Left padding
        - stackFontSize: number - Font size for stack count
        - stackOffsetX: number - X offset for stack count
        - stackOffsetY: number - Y offset for stack count
]]
local function processAuraFrames(config)
    -- Validate config
    if not config or not config.parentFrame then
        return
    end

    -- Get aura frames array (always available in Midnight 12.0.0+)
    local auraFrames
    if config.auraType == Constants.BUFF_FRAME_SUFFIX then
        auraFrames = config.parentFrame.buffFrames
    elseif config.auraType == Constants.DEBUFF_FRAME_SUFFIX then
        auraFrames = config.parentFrame.debuffFrames
    end

    if not auraFrames then
        return
    end

    local firstAura = nil
    local previousAuraFrame = nil

    -- Iterate only visible auras
    for _, auraFrame in ipairs(auraFrames) do
        if auraFrame:IsShown() then
            auraFrame:ClearAllPoints()
            auraFrame:SetSize(config.size, config.size)

            if not firstAura then
                applyFirstAuraAnchor(auraFrame, config.parentFrame, config.anchor,
                    config.paddingTop, config.paddingRight, config.paddingBottom, config.paddingLeft)
                firstAura = auraFrame
            else
                applySubsequentAuraAnchor(auraFrame, previousAuraFrame, config.anchor, config.spacing)
            end

            updateStackCount(auraFrame, config.stackFontSize, config.stackOffsetX, config.stackOffsetY)
            previousAuraFrame = auraFrame
        end
    end
end

--[[
    Applies custom anchoring to all auras on a frame.
    This is the main entry point for custom aura positioning.
    Note: Aura frames are not protected, safe to call during combat.

    @param frame table The frame to apply custom anchoring to
]]
function BetterAuras:ApplyCustomAnchoring(frame)
    if not frame or not frame.unit then
        return
    end

    -- Filter nameplates by unit token
    if frame.unit:match("^nameplate") then
        return
    end

    -- Get all configuration values
    local buffSize = Database:Get("buffSize")
    local debuffSize = Database:Get("debuffSize")
    local buffSpacing = Database:Get("buffSpacing")
    local debuffSpacing = Database:Get("debuffSpacing")
    local buffAnchor = Database:Get("buffAnchor")
    local debuffAnchor = Database:Get("debuffAnchor")
    local buffPaddingTop = Database:Get("buffPaddingTop")
    local buffPaddingRight = Database:Get("buffPaddingRight")
    local buffPaddingBottom = Database:Get("buffPaddingBottom")
    local buffPaddingLeft = Database:Get("buffPaddingLeft")
    local debuffPaddingTop = Database:Get("debuffPaddingTop")
    local debuffPaddingRight = Database:Get("debuffPaddingRight")
    local debuffPaddingBottom = Database:Get("debuffPaddingBottom")
    local debuffPaddingLeft = Database:Get("debuffPaddingLeft")
    local buffStackFontSize = Database:Get("buffStackFontSize")
    local buffStackOffsetX = Database:Get("buffStackOffsetX")
    local buffStackOffsetY = Database:Get("buffStackOffsetY")
    local debuffStackFontSize = Database:Get("debuffStackFontSize")
    local debuffStackOffsetX = Database:Get("debuffStackOffsetX")
    local debuffStackOffsetY = Database:Get("debuffStackOffsetY")

    -- Process buff frames
    processAuraFrames({
        parentFrame = frame,
        auraType = Constants.BUFF_FRAME_SUFFIX,
        size = buffSize,
        anchor = buffAnchor,
        spacing = buffSpacing,
        paddingTop = buffPaddingTop,
        paddingRight = buffPaddingRight,
        paddingBottom = buffPaddingBottom,
        paddingLeft = buffPaddingLeft,
        stackFontSize = buffStackFontSize,
        stackOffsetX = buffStackOffsetX,
        stackOffsetY = buffStackOffsetY
    })

    -- Process debuff frames
    processAuraFrames({
        parentFrame = frame,
        auraType = Constants.DEBUFF_FRAME_SUFFIX,
        size = debuffSize,
        anchor = debuffAnchor,
        spacing = debuffSpacing,
        paddingTop = debuffPaddingTop,
        paddingRight = debuffPaddingRight,
        paddingBottom = debuffPaddingBottom,
        paddingLeft = debuffPaddingLeft,
        stackFontSize = debuffStackFontSize,
        stackOffsetX = debuffStackOffsetX,
        stackOffsetY = debuffStackOffsetY
    })
end

return BetterAuras
