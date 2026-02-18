--[[
    BetterAuras - Settings Integration

    This module integrates the addon with WoW's built-in settings panel.

    @file SettingsIntegration.lua
    @author Zidious
    @version 1.0.2
]]

local ADDON_NAME, namespace = ...

-- Get module references
local Constants = namespace.Constants
local ConfigPanel = namespace.UI.ConfigPanel

--------------------------------------------------------------------------------
-- Settings Panel Setup
--------------------------------------------------------------------------------

-- Create settings panel for WoW interface options
local settingsPanel = CreateFrame("Frame")
settingsPanel.name = Constants.ADDON_NAME

-- Register with WoW settings system
local category = Settings.RegisterCanvasLayoutCategory(settingsPanel, settingsPanel.name)
Settings.RegisterAddOnCategory(category)

--------------------------------------------------------------------------------
-- Settings Panel UI Elements
--------------------------------------------------------------------------------

-- Add title
local settingsTitle = settingsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
settingsTitle:SetPoint("TOPLEFT", 16, -16)
settingsTitle:SetText(Constants.ADDON_NAME)

-- Add description
local settingsDesc = settingsPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
settingsDesc:SetPoint("TOPLEFT", settingsTitle, "BOTTOMLEFT", 0, -8)
settingsDesc:SetText("Customize party frame auras")

-- Add button to open custom window
local openButton = CreateFrame("Button", nil, settingsPanel, "UIPanelButtonTemplate")
openButton:SetSize(200, 30)
openButton:SetPoint("TOPLEFT", settingsDesc, "BOTTOMLEFT", 0, -20)
openButton:SetText("Open Configuration")
openButton:SetScript("OnClick", function()
    ConfigPanel:Show()
end)

-- Add help text
local buttonHelp = settingsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
buttonHelp:SetPoint("TOPLEFT", openButton, "BOTTOMLEFT", 0, -10)
buttonHelp:SetText("You can also use " .. Constants.SLASH_COMMAND_SHORT ..
    " to open the configuration window")
buttonHelp:SetTextColor(0.7, 0.7, 0.7, 1)

return settingsPanel
