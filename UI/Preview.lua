--[[
    BetterAuras - Preview Panel

    This module creates and manages the preview panel that shows
    a sample party frame with buffs and debuffs.

    @file Preview.lua
    @author Zidious
    @version 1.0.1
]]

local ADDON_NAME, namespace = ...

-- Ensure namespace exists
namespace.UI = namespace.UI or {}
local Preview = {}
namespace.UI.Preview = Preview

-- Get module references
local Constants = namespace.Constants
local Database = namespace.Database

-- Local variables
local previewFrame
local previewBuffs = {}
local previewDebuffs = {}
local roleIcon
local nameText

--------------------------------------------------------------------------------
-- Role Icon Functions
--------------------------------------------------------------------------------

--[[
    Updates the role icon based on player's current specialization.
]]
local function updateRoleIcon()
    if not roleIcon then
        return
    end

    -- Get current spec
    local specIndex = GetSpecialization()
    if not specIndex then
        -- Default to DPS icon if no spec
        roleIcon:SetAtlas(Constants.ROLE_ICON_DPS)
        roleIcon:Show()
        return
    end

    -- Get the role for this spec
    local role = GetSpecializationRole(specIndex)

    if role == Constants.ROLE_TANK then
        roleIcon:SetAtlas(Constants.ROLE_ICON_TANK)
        roleIcon:Show()
    elseif role == Constants.ROLE_HEALER then
        roleIcon:SetAtlas(Constants.ROLE_ICON_HEALER)
        roleIcon:Show()
    elseif role == Constants.ROLE_DAMAGER then
        roleIcon:SetAtlas(Constants.ROLE_ICON_DPS)
        roleIcon:Show()
    else
        roleIcon:Hide()
    end
end

--------------------------------------------------------------------------------
-- Preview Icon Creation
--------------------------------------------------------------------------------

--[[
    Creates a single preview aura frame.

    @param parent table The parent frame
    @param iconTexture number The texture ID for the icon
    @param stackCount number The stack count to display (0 for none)
    @param borderColor table RGB color for the border {r, g, b}
    @return table The created aura frame
]]
local function createPreviewAuraFrame(parent, iconTexture, stackCount, borderColor)
    local auraFrame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    auraFrame:SetBackdrop(Constants.BACKDROP_AURA)
    auraFrame:SetBackdropColor(0, 0, 0, 0.8)
    auraFrame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, 1)

    local icon = auraFrame:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", auraFrame, "TOPLEFT", 2, -2)
    icon:SetPoint("BOTTOMRIGHT", auraFrame, "BOTTOMRIGHT", -2, 2)
    icon:SetTexture(iconTexture)
    icon:SetTexCoord(Constants.ICON_TEX_COORD_LEFT, Constants.ICON_TEX_COORD_RIGHT,
        Constants.ICON_TEX_COORD_TOP, Constants.ICON_TEX_COORD_BOTTOM)

    -- Add a subtle glow/highlight overlay
    local highlight = auraFrame:CreateTexture(nil, "OVERLAY")
    highlight:SetAllPoints(icon)
    highlight:SetTexture(Constants.TEXTURE_WHITE)
    highlight:SetGradient("VERTICAL",
        CreateColor(1, 1, 1, 0.2),
        CreateColor(1, 1, 1, 0.0))
    highlight:SetBlendMode("ADD")

    local stackText = auraFrame:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    stackText:SetPoint(Constants.ANCHOR_BOTTOM_RIGHT, auraFrame, Constants.ANCHOR_BOTTOM_RIGHT, -1, 1)
    stackText:SetText(stackCount > 0 and tostring(stackCount) or "")
    stackText:SetTextColor(1, 1, 1, 1)
    stackText:SetFont(stackText:GetFont(), 12, Constants.FONT_OUTLINE)

    auraFrame.icon = icon
    auraFrame.highlight = highlight
    auraFrame.stackText = stackText

    return auraFrame
end

--[[
    Creates all preview icons (buffs and debuffs).
]]
local function createPreviewIcons()
    -- Green border for buffs
    local buffBorderColor = { r = 0.2, g = 0.8, b = 0.2 }

    -- Red border for debuffs
    local debuffBorderColor = { r = 0.9, g = 0.1, b = 0.1 }

    -- Create buff frames
    for i = 1, 3 do
        local buffFrame = createPreviewAuraFrame(previewFrame, Constants.PREVIEW_BUFF_ICONS[i],
            Constants.PREVIEW_BUFF_STACKS[i], buffBorderColor)
        table.insert(previewBuffs, buffFrame)
    end

    -- Create debuff frames
    for i = 1, 3 do
        local debuffFrame = createPreviewAuraFrame(previewFrame, Constants.PREVIEW_DEBUFF_ICONS[i],
            Constants.PREVIEW_DEBUFF_STACKS[i], debuffBorderColor)
        table.insert(previewDebuffs, debuffFrame)
    end
end

--------------------------------------------------------------------------------
-- Preview Update Functions
--------------------------------------------------------------------------------

--[[
    Updates the preview panel to reflect current settings.

    @param pendingSettings table Optional table of pending (unsaved) settings
]]
function Preview:Update(pendingSettings)
    -- Helper to get value from pending settings or database
    local function GetValue(key)
        if pendingSettings and pendingSettings[key] ~= nil then
            return pendingSettings[key]
        end
        return Database:Get(key)
    end

    local buffSize = GetValue("buffSize")
    local debuffSize = GetValue("debuffSize")
    local buffSpacing = GetValue("buffSpacing")
    local debuffSpacing = GetValue("debuffSpacing")
    local buffAnchor = GetValue("buffAnchor")
    local debuffAnchor = GetValue("debuffAnchor")
    local buffPaddingTop = GetValue("buffPaddingTop")
    local buffPaddingRight = GetValue("buffPaddingRight")
    local buffPaddingBottom = GetValue("buffPaddingBottom")
    local buffPaddingLeft = GetValue("buffPaddingLeft")
    local debuffPaddingTop = GetValue("debuffPaddingTop")
    local debuffPaddingRight = GetValue("debuffPaddingRight")
    local debuffPaddingBottom = GetValue("debuffPaddingBottom")
    local debuffPaddingLeft = GetValue("debuffPaddingLeft")
    local buffStackFontSize = GetValue("buffStackFontSize")
    local buffStackOffsetX = GetValue("buffStackOffsetX")
    local buffStackOffsetY = GetValue("buffStackOffsetY")
    local debuffStackFontSize = GetValue("debuffStackFontSize")
    local debuffStackOffsetX = GetValue("debuffStackOffsetX")
    local debuffStackOffsetY = GetValue("debuffStackOffsetY")

    -- Update buffs
    for i, buffFrame in ipairs(previewBuffs) do
        buffFrame:SetSize(buffSize, buffSize)
        buffFrame:ClearAllPoints()

        if i == 1 then
            -- Position first buff based on anchor with padding
            if buffAnchor == Constants.ANCHOR_TOP_RIGHT then
                buffFrame:SetPoint(Constants.ANCHOR_TOP_RIGHT, previewFrame, Constants.ANCHOR_TOP_RIGHT,
                    -buffPaddingRight, -buffPaddingTop)
            elseif buffAnchor == Constants.ANCHOR_TOP_LEFT then
                buffFrame:SetPoint(Constants.ANCHOR_TOP_LEFT, previewFrame, Constants.ANCHOR_TOP_LEFT,
                    buffPaddingLeft, -buffPaddingTop)
            elseif buffAnchor == Constants.ANCHOR_BOTTOM_RIGHT then
                buffFrame:SetPoint(Constants.ANCHOR_BOTTOM_RIGHT, previewFrame, Constants.ANCHOR_BOTTOM_RIGHT,
                    -buffPaddingRight, buffPaddingBottom)
            elseif buffAnchor == Constants.ANCHOR_BOTTOM_LEFT then
                buffFrame:SetPoint(Constants.ANCHOR_BOTTOM_LEFT, previewFrame, Constants.ANCHOR_BOTTOM_LEFT,
                    buffPaddingLeft, buffPaddingBottom)
            end
        else
            -- Position subsequent buffs based on anchor
            if buffAnchor == Constants.ANCHOR_TOP_RIGHT or buffAnchor == Constants.ANCHOR_BOTTOM_RIGHT then
                buffFrame:SetPoint("RIGHT", previewBuffs[i - 1], "LEFT", -buffSpacing, 0)
            else
                buffFrame:SetPoint("LEFT", previewBuffs[i - 1], "RIGHT", buffSpacing, 0)
            end
        end

        -- Update stack text font and position
        if buffFrame.stackText then
            buffFrame.stackText:ClearAllPoints()
            buffFrame.stackText:SetPoint(Constants.ANCHOR_BOTTOM_RIGHT, buffFrame, Constants.ANCHOR_BOTTOM_RIGHT,
                buffStackOffsetX, buffStackOffsetY)
            buffFrame.stackText:SetFont(buffFrame.stackText:GetFont(), buffStackFontSize, Constants.FONT_OUTLINE)
        end
        buffFrame:Show()
    end

    -- Update debuffs
    for i, debuffFrame in ipairs(previewDebuffs) do
        debuffFrame:SetSize(debuffSize, debuffSize)
        debuffFrame:ClearAllPoints()

        if i == 1 then
            -- Position first debuff based on anchor with padding
            local verticalOffset = buffSize + buffSpacing

            if debuffAnchor == Constants.ANCHOR_TOP_RIGHT then
                debuffFrame:SetPoint(Constants.ANCHOR_TOP_RIGHT, previewFrame, Constants.ANCHOR_TOP_RIGHT,
                    -debuffPaddingRight, -(debuffPaddingTop + verticalOffset))
            elseif debuffAnchor == Constants.ANCHOR_TOP_LEFT then
                debuffFrame:SetPoint(Constants.ANCHOR_TOP_LEFT, previewFrame, Constants.ANCHOR_TOP_LEFT,
                    debuffPaddingLeft, -(debuffPaddingTop + verticalOffset))
            elseif debuffAnchor == Constants.ANCHOR_BOTTOM_RIGHT then
                debuffFrame:SetPoint(Constants.ANCHOR_BOTTOM_RIGHT, previewFrame, Constants.ANCHOR_BOTTOM_RIGHT,
                    -debuffPaddingRight, debuffPaddingBottom)
            elseif debuffAnchor == Constants.ANCHOR_BOTTOM_LEFT then
                debuffFrame:SetPoint(Constants.ANCHOR_BOTTOM_LEFT, previewFrame, Constants.ANCHOR_BOTTOM_LEFT,
                    debuffPaddingLeft, debuffPaddingBottom)
            end
        else
            -- Position subsequent debuffs based on anchor
            if debuffAnchor == Constants.ANCHOR_TOP_RIGHT or debuffAnchor == Constants.ANCHOR_BOTTOM_RIGHT then
                debuffFrame:SetPoint("RIGHT", previewDebuffs[i - 1], "LEFT", -debuffSpacing, 0)
            else
                debuffFrame:SetPoint("LEFT", previewDebuffs[i - 1], "RIGHT", debuffSpacing, 0)
            end
        end

        -- Update stack text font and position
        if debuffFrame.stackText then
            debuffFrame.stackText:ClearAllPoints()
            debuffFrame.stackText:SetPoint(Constants.ANCHOR_BOTTOM_RIGHT, debuffFrame, Constants.ANCHOR_BOTTOM_RIGHT,
                debuffStackOffsetX, debuffStackOffsetY)
            debuffFrame.stackText:SetFont(debuffFrame.stackText:GetFont(), debuffStackFontSize,
                Constants.FONT_OUTLINE)
        end
        debuffFrame:Show()
    end
end

--------------------------------------------------------------------------------
-- Preview Panel Creation
--------------------------------------------------------------------------------

--[[
    Creates the preview panel UI element.

    @param parent table The parent frame
    @return table The created preview panel
]]
function Preview:Create(parent)
    local previewBg = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    previewBg:SetSize(360, 200)
    previewBg:SetPoint("TOP", parent, "TOP", 180, -80)
    previewBg:SetBackdrop({
        bgFile = Constants.TEXTURE_CHAT_BACKGROUND,
        edgeFile = Constants.TEXTURE_TOOLTIP_BORDER,
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    previewBg:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    previewBg:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    -- Preview label
    local previewLabel = previewBg:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    previewLabel:SetPoint("TOP", previewBg, "TOP", 0, -10)
    previewLabel:SetText("Preview")

    -- Party Frame Preview
    previewFrame = CreateFrame("Frame", nil, previewBg, "BackdropTemplate")
    previewFrame:SetSize(Constants.PREVIEW_FRAME_WIDTH, Constants.PREVIEW_FRAME_HEIGHT)
    previewFrame:SetPoint("TOP", previewLabel, "BOTTOM", 0, -15)
    previewFrame:SetBackdrop(Constants.BACKDROP_PREVIEW)

    -- Get player class color
    local _, class = UnitClass(Constants.PLAYER_UNIT)
    local classColor = RAID_CLASS_COLORS[class] or { r = 0.0, g = 0.6, b = 0.9 }

    previewFrame:SetBackdropColor(classColor.r * 0.15, classColor.g * 0.15, classColor.b * 0.15, 1)
    previewFrame:SetBackdropBorderColor(classColor.r * 0.7, classColor.g * 0.7, classColor.b * 0.7, 1)

    -- Role icon (small circle in top-left)
    roleIcon = previewFrame:CreateTexture(nil, "OVERLAY")
    roleIcon:SetSize(20, 20)
    roleIcon:SetPoint("TOPLEFT", previewFrame, "TOPLEFT", 4, -4)
    updateRoleIcon()

    -- Character name
    nameText = previewFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("TOPLEFT", roleIcon, "TOPRIGHT", 6, -2)
    nameText:SetText(UnitName(Constants.PLAYER_UNIT) or "Your Name")
    nameText:SetTextColor(1, 1, 1, 1)
    nameText:SetJustifyH("LEFT")

    -- Create preview icons
    createPreviewIcons()

    -- Set up event frame for role updates
    local roleUpdateFrame = CreateFrame("Frame")
    roleUpdateFrame:RegisterEvent(Constants.EVENT_PLAYER_SPECIALIZATION_CHANGED)
    roleUpdateFrame:RegisterEvent(Constants.EVENT_PLAYER_ROLES_ASSIGNED)
    roleUpdateFrame:SetScript("OnEvent", function()
        if parent:IsShown() then
            updateRoleIcon()
        end
    end)

    return previewBg
end

--[[
    Refreshes the preview panel (updates role icon and name).
]]
function Preview:Refresh()
    if nameText then
        nameText:SetText(UnitName(Constants.PLAYER_UNIT) or "Your Name")
    end
    updateRoleIcon()
    Preview:Update()
end

return Preview
