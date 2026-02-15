--[[
    BetterAuras - Control Widgets

    This module provides factory functions for creating UI controls
    such as sliders, dropdowns, and section headers.

    @file ControlWidgets.lua
    @author Zidious
    @version 1.0.0
]]

local ADDON_NAME, namespace = ...

--------------------------------------------------------------------------------
-- Module Setup
--------------------------------------------------------------------------------

namespace.UI = namespace.UI or {}
local ControlWidgets = {}
namespace.UI.ControlWidgets = ControlWidgets

-- Module references
local Constants = namespace.Constants

--------------------------------------------------------------------------------
-- Helper Functions
--------------------------------------------------------------------------------

--[[
    Hides the default slider labels (Text, Low, High) for a slider.

    @param sliderName string The name of the slider widget
]]
local function hideDefaultSliderLabels(sliderName)
    local labelsToHide = {
        _G[sliderName .. "Text"],
        _G[sliderName .. "Low"],
        _G[sliderName .. "High"]
    }
    for _, label in ipairs(labelsToHide) do
        if label then
            label:Hide()
        end
    end
end

--------------------------------------------------------------------------------
-- Widget Factories
--------------------------------------------------------------------------------

function ControlWidgets.createDropdown(parent, name, label, yOffset, currentValue, options, onChangeCallback)
    local dropdown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)

    local dropdownLabel = dropdown:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    dropdownLabel:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 20, 0)
    dropdownLabel:SetText(label)

    UIDropDownMenu_SetWidth(dropdown, 160)

    -- Find the text for the current value
    local currentText = options[1].text
    for _, option in ipairs(options) do
        if option.value == currentValue then
            currentText = option.text
            break
        end
    end
    UIDropDownMenu_SetText(dropdown, currentText)

    UIDropDownMenu_Initialize(dropdown, function(self, level)
        for _, option in ipairs(options) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = option.text
            info.value = option.value
            info.func = function()
                onChangeCallback(option.value, option.text)
            end
            info.checked = (currentValue == option.value)
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    return dropdown
end

function ControlWidgets.createSlider(parent, name, min, max, step, label, xOffset, yOffset, onChangeCallback)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(150, 32)
    container:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset)

    -- Label
    local labelText = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelText:SetPoint("TOPLEFT", container, "TOPLEFT", 3, 0)
    labelText:SetText(label)
    labelText:SetTextColor(1, 0.82, 0, 1)

    -- Value display
    local valueText = container:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    valueText:SetPoint("TOPRIGHT", container, "TOPRIGHT", -3, 0)
    valueText:SetText("0")

    -- Slider
    local slider = CreateFrame("Slider", name, container, "OptionsSliderTemplate")
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -18)
    slider:SetWidth(150)
    slider:SetHeight(14)
    slider.value = valueText

    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        self.value:SetText(value)
        onChangeCallback(value)
    end)

    hideDefaultSliderLabels(name)

    container.slider = slider
    return container
end

function ControlWidgets.createSectionHeader(parent, text, yOffset)
    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    header:SetText(text)

    local divider = parent:CreateTexture(nil, "ARTWORK")
    divider:SetHeight(1)
    divider:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -8)
    divider:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 320, -8)
    divider:SetColorTexture(0.25, 0.25, 0.25, 0.8)

    return header
end

function ControlWidgets.createSubsectionHeader(parent, text, yOffset)
    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    header:SetText(text)
    header:SetTextColor(0.8, 0.8, 0.8, 1)

    local divider = parent:CreateTexture(nil, "ARTWORK")
    divider:SetHeight(1)
    divider:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -3)
    divider:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 320, -3)
    divider:SetColorTexture(0.15, 0.15, 0.15, 0.6)

    return header
end

return ControlWidgets
