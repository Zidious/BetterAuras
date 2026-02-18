--[[
    BetterAuras - Config Controls Builder

    This module creates all the configuration controls (sliders and dropdowns)
    for buff and debuff settings.

    @file ConfigControls.lua
    @author Zidious
    @version 1.0.2
]]

local ADDON_NAME, namespace = ...

--------------------------------------------------------------------------------
-- Module Setup
--------------------------------------------------------------------------------

namespace.UI = namespace.UI or {}
local ConfigControls = {}
namespace.UI.ConfigControls = ConfigControls

-- Module references
local Constants = namespace.Constants
local ControlWidgets = namespace.UI.ControlWidgets

--------------------------------------------------------------------------------
-- Helper Functions
--------------------------------------------------------------------------------

--[[
    Creates a complete aura settings section with all controls.

    @param parent table The parent frame
    @param auraType string "Buff" or "Debuff"
    @param yOffsets table Y-offsets for each control element
    @param createSliderFunc function Function to create slider widgets
    @param createDropdownFunc function Function to create dropdown widgets
    @return table, table Tables of sliders and dropdowns keyed by setting name
]]
local function createAuraSection(parent, auraType, yOffsets, createSliderFunc, createDropdownFunc)
    local settingPrefix = auraType:lower()
    local sliders = {}
    local dropdowns = {}

    -- Section header
    ControlWidgets.createSectionHeader(parent, auraType .. "s", yOffsets.header)

    -- Anchor dropdown
    dropdowns[settingPrefix .. "Anchor"] = createDropdownFunc(
        "BetterAuras" .. auraType .. "AnchorDropdown",
        "Anchor Position:",
        yOffsets.anchor,
        settingPrefix .. "Anchor",
        Constants.ANCHOR_OPTIONS
    )

    -- Main sliders in 2 columns
    sliders[settingPrefix .. "Size"] = createSliderFunc(
        "BetterAuras" .. auraType .. "SizeSlider",
        Constants.SLIDER_SIZE_MIN, Constants.SLIDER_SIZE_MAX, Constants.SLIDER_SIZE_STEP,
        "Size", 10, yOffsets.size, settingPrefix .. "Size"
    )

    sliders[settingPrefix .. "Spacing"] = createSliderFunc(
        "BetterAuras" .. auraType .. "SpacingSlider",
        Constants.SLIDER_SPACING_MIN, Constants.SLIDER_SPACING_MAX, Constants.SLIDER_SPACING_STEP,
        "Spacing", 175, yOffsets.size, settingPrefix .. "Spacing"
    )

    sliders[settingPrefix .. "PaddingTop"] = createSliderFunc(
        "BetterAuras" .. auraType .. "PaddingTopSlider",
        Constants.SLIDER_PADDING_MIN, Constants.SLIDER_PADDING_MAX, Constants.SLIDER_PADDING_STEP,
        "Padding Top", 10, yOffsets.paddingTop, settingPrefix .. "PaddingTop"
    )

    sliders[settingPrefix .. "PaddingRight"] = createSliderFunc(
        "BetterAuras" .. auraType .. "PaddingRightSlider",
        Constants.SLIDER_PADDING_MIN, Constants.SLIDER_PADDING_MAX, Constants.SLIDER_PADDING_STEP,
        "Padding Right", 175, yOffsets.paddingTop, settingPrefix .. "PaddingRight"
    )

    sliders[settingPrefix .. "PaddingBottom"] = createSliderFunc(
        "BetterAuras" .. auraType .. "PaddingBottomSlider",
        Constants.SLIDER_PADDING_MIN, Constants.SLIDER_PADDING_MAX, Constants.SLIDER_PADDING_STEP,
        "Padding Bottom", 10, yOffsets.paddingBottom, settingPrefix .. "PaddingBottom"
    )

    sliders[settingPrefix .. "PaddingLeft"] = createSliderFunc(
        "BetterAuras" .. auraType .. "PaddingLeftSlider",
        Constants.SLIDER_PADDING_MIN, Constants.SLIDER_PADDING_MAX, Constants.SLIDER_PADDING_STEP,
        "Padding Left", 175, yOffsets.paddingBottom, settingPrefix .. "PaddingLeft"
    )

    -- Stack count subsection
    ControlWidgets.createSubsectionHeader(parent, "Stack Count", yOffsets.stackHeader)

    sliders[settingPrefix .. "StackFontSize"] = createSliderFunc(
        "BetterAuras" .. auraType .. "StackFontSizeSlider",
        Constants.SLIDER_FONT_SIZE_MIN, Constants.SLIDER_FONT_SIZE_MAX, Constants.SLIDER_FONT_SIZE_STEP,
        "Font Size", 10, yOffsets.stackFontSize, settingPrefix .. "StackFontSize"
    )

    sliders[settingPrefix .. "StackOffsetX"] = createSliderFunc(
        "BetterAuras" .. auraType .. "StackOffsetXSlider",
        Constants.SLIDER_OFFSET_MIN, Constants.SLIDER_OFFSET_MAX, Constants.SLIDER_OFFSET_STEP,
        "Offset X", 175, yOffsets.stackFontSize, settingPrefix .. "StackOffsetX"
    )

    sliders[settingPrefix .. "StackOffsetY"] = createSliderFunc(
        "BetterAuras" .. auraType .. "StackOffsetYSlider",
        Constants.SLIDER_OFFSET_MIN, Constants.SLIDER_OFFSET_MAX, Constants.SLIDER_OFFSET_STEP,
        "Offset Y", 10, yOffsets.stackOffsetY, settingPrefix .. "StackOffsetY"
    )

    return sliders, dropdowns
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

function ConfigControls:CreateAll(parent, createSliderFunc, createDropdownFunc)
    local allSliders = {}
    local allDropdowns = {}

    -- Buff Section
    local buffSliders, buffDropdowns = createAuraSection(
        parent,
        "Buff",
        {
            header = -10,
            anchor = -58,
            size = -113,
            paddingTop = -153,
            paddingBottom = -193,
            stackHeader = -233,
            stackFontSize = -260,
            stackOffsetY = -300
        },
        createSliderFunc,
        createDropdownFunc
    )

    -- Debuff Section
    local debuffSliders, debuffDropdowns = createAuraSection(
        parent,
        "Debuff",
        {
            header = -342,
            anchor = -390,
            size = -445,
            paddingTop = -485,
            paddingBottom = -525,
            stackHeader = -565,
            stackFontSize = -592,
            stackOffsetY = -632
        },
        createSliderFunc,
        createDropdownFunc
    )

    -- Merge tables
    for k, v in pairs(buffSliders) do
        allSliders[k] = v
    end
    for k, v in pairs(debuffSliders) do
        allSliders[k] = v
    end
    for k, v in pairs(buffDropdowns) do
        allDropdowns[k] = v
    end
    for k, v in pairs(debuffDropdowns) do
        allDropdowns[k] = v
    end

    return allSliders, allDropdowns
end

return ConfigControls
