--[[
    BetterAuras - Configuration Panel

    This module creates and manages the main configuration panel UI.
    It includes sliders, dropdowns, and checkboxes for all settings.

    @file ConfigPanel.lua
    @author Zidious
    @version 1.0.1
]]

local ADDON_NAME, namespace = ...

--------------------------------------------------------------------------------
-- Module Setup
--------------------------------------------------------------------------------

namespace.UI = namespace.UI or {}
local ConfigPanel = {}
namespace.UI.ConfigPanel = ConfigPanel

-- Module references
local BetterAuras = namespace.BetterAuras
local Constants = namespace.Constants
local Database = namespace.Database
local Preview = namespace.UI.Preview
local ControlWidgets = namespace.UI.ControlWidgets
local ProfileDialogs = namespace.UI.ProfileDialogs
local ProfileSelector = namespace.UI.ProfileSelector
local ConfigControls = namespace.UI.ConfigControls

--------------------------------------------------------------------------------
-- Local State
--------------------------------------------------------------------------------

local mainPanel
local scrollChild
local pendingSettings = {}

-- UI element storage
local sliders = {}
local dropdowns = {}

-- Anchor display name mapping
local ANCHOR_DISPLAY_NAMES = {
    [Constants.ANCHOR_TOP_LEFT] = "Top Left",
    [Constants.ANCHOR_TOP_RIGHT] = "Top Right",
    [Constants.ANCHOR_BOTTOM_LEFT] = "Bottom Left",
    [Constants.ANCHOR_BOTTOM_RIGHT] = "Bottom Right"
}

--------------------------------------------------------------------------------
-- Pending Settings Management
--------------------------------------------------------------------------------

local function getPendingValue(key)
    if pendingSettings[key] ~= nil then
        return pendingSettings[key]
    end
    return Database:Get(key)
end

local function setPendingValue(key, value)
    pendingSettings[key] = value
end

local function initializePendingSettings()
    pendingSettings = {}
    local db = Database:GetAll()
    for key, _ in pairs(db) do
        pendingSettings[key] = Database:Get(key)
    end
end

local function savePendingSettings()
    for key, value in pairs(pendingSettings) do
        Database:Set(key, value)
    end
end

local function discardPendingSettings()
    pendingSettings = {}
end

local function refreshPreview()
    Preview:Update(pendingSettings)
end

--------------------------------------------------------------------------------
-- Widget Creation Helpers
--------------------------------------------------------------------------------

local function createDropdown(name, label, yOffset, key, options)
    local onChangeCallback = function(value, text)
        setPendingValue(key, value)
        UIDropDownMenu_SetText(dropdowns[key], text)
        refreshPreview()
    end
    return ControlWidgets.createDropdown(scrollChild, name, label, yOffset, getPendingValue(key), options,
        onChangeCallback)
end

local function createSlider(name, min, max, step, label, xOffset, yOffset, key)
    local onChangeCallback = function(value)
        setPendingValue(key, value)
        refreshPreview()
    end
    return ControlWidgets.createSlider(scrollChild, name, min, max, step, label, xOffset, yOffset, onChangeCallback)
end

--------------------------------------------------------------------------------
-- Panel Creation
--------------------------------------------------------------------------------

function ConfigPanel:Create()
    -- Main panel frame
    mainPanel = CreateFrame("Frame", "BetterAurasConfigPanel", UIParent, "BackdropTemplate")
    mainPanel:SetSize(Constants.CONFIG_PANEL_WIDTH, Constants.CONFIG_PANEL_HEIGHT)
    mainPanel:SetPoint("CENTER")
    mainPanel:SetFrameStrata("DIALOG")
    mainPanel:SetMovable(true)
    mainPanel:EnableMouse(true)
    mainPanel:RegisterForDrag("LeftButton")
    mainPanel:SetScript("OnDragStart", mainPanel.StartMoving)
    mainPanel:SetScript("OnDragStop", mainPanel.StopMovingOrSizing)
    mainPanel:SetBackdrop(Constants.BACKDROP_DIALOG)
    mainPanel:Hide()

    -- Register frame to close on ESC key press
    tinsert(UISpecialFrames, "BetterAurasConfigPanel")

    -- Close button
    local closeButton = CreateFrame("Button", nil, mainPanel, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", mainPanel, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function()
        mainPanel:Hide()
    end)

    -- Scroll frame for left side content
    local scrollFrame = CreateFrame("ScrollFrame", nil, mainPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", mainPanel, "TOPLEFT", 20, -80)
    scrollFrame:SetSize(Constants.SCROLL_CONTENT_WIDTH, 460)
    scrollFrame:SetPoint("BOTTOM", mainPanel, "BOTTOM", -200, 60)

    scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(Constants.SCROLL_CONTENT_WIDTH, 1)
    scrollFrame:SetScrollChild(scrollChild)

    -- Title
    local title = mainPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("TOP", mainPanel, "TOP", 0, -25)
    title:SetText(Constants.ADDON_NAME)

    local subtitle = mainPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -5)
    subtitle:SetText("Customize party frame auras")

    local helpText = mainPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    helpText:SetPoint("TOP", subtitle, "BOTTOM", 0, -3)
    helpText:SetText("Use " .. Constants.SLASH_COMMAND_SHORT .. " to toggle this window")
    helpText:SetTextColor(0.7, 0.7, 0.7, 1)

    -- Create preview panel
    Preview:Create(mainPanel)

    -- Initialize profile dialogs
    ProfileDialogs:Initialize(function()
        initializePendingSettings()
        ConfigPanel:RefreshControls()
        ProfileSelector:Update()
        refreshPreview()

        -- Refresh all party/raid frames with new profile settings
        if BetterAuras and type(BetterAuras.UpdateAllFrames) == "function" then
            BetterAuras:UpdateAllFrames()
        else
            print(Constants.COLOR_ERROR .. Constants.ADDON_NAME .. ": " ..
                Constants.MSG_FUNCTION_NOT_FOUND .. Constants.COLOR_RESET)
        end
    end)

    -- Create profile selector
    ProfileSelector:Create(mainPanel, function()
        initializePendingSettings()
        ConfigPanel:RefreshControls()
        ProfileSelector:Update()
        refreshPreview()

        -- Refresh all party/raid frames with new profile settings
        if BetterAuras and type(BetterAuras.UpdateAllFrames) == "function" then
            BetterAuras:UpdateAllFrames()
        else
            print(Constants.COLOR_ERROR .. Constants.ADDON_NAME .. ": " ..
                Constants.MSG_FUNCTION_NOT_FOUND .. Constants.COLOR_RESET)
        end
    end)

    -- Create all UI controls
    ConfigPanel:CreateControls()

    -- Create buttons
    ConfigPanel:CreateButtons()

    -- Set scroll child height to encompass all content
    scrollChild:SetHeight(690)

    -- OnShow handler
    mainPanel:SetScript("OnShow", function()
        initializePendingSettings()
        ConfigPanel:RefreshControls()
        ProfileSelector:Update()
        Preview:Refresh()
    end)

    -- OnHide handler
    mainPanel:SetScript("OnHide", function()
        discardPendingSettings()
    end)

    return mainPanel
end

function ConfigPanel:CreateControls()
    sliders, dropdowns = ConfigControls:CreateAll(scrollChild, createSlider, createDropdown)
end

--[[
    Creates the Reset and Apply buttons.
]]
function ConfigPanel:CreateButtons()
    -- Reset to Defaults Button
    local resetButton = CreateFrame("Button", nil, mainPanel, "UIPanelButtonTemplate")
    resetButton:SetSize(140, 35)
    resetButton:SetPoint("BOTTOM", mainPanel, "BOTTOM", -75, 20)
    resetButton:SetText("Reset to Defaults")

    resetButton:SetScript("OnClick", function()
        Database:ResetToDefaults()
        initializePendingSettings()
        ConfigPanel:RefreshControls()
        refreshPreview()
        print(Constants.COLOR_SUCCESS .. Constants.ADDON_NAME .. ":" .. Constants.COLOR_RESET ..
            " " .. Constants.MSG_SETTINGS_RESET)
    end)

    -- Apply Button
    local saveButton = CreateFrame("Button", nil, mainPanel, "UIPanelButtonTemplate")
    saveButton:SetSize(140, 35)
    saveButton:SetPoint("BOTTOM", mainPanel, "BOTTOM", 75, 20)
    saveButton:SetText("Apply Changes")

    saveButton:SetScript("OnClick", function()
        if InCombatLockdown() then
            print(Constants.COLOR_ERROR .. Constants.ADDON_NAME .. ": " ..
                Constants.MSG_COMBAT_LOCKDOWN .. Constants.COLOR_RESET)
            return
        end

        savePendingSettings()

        -- Force complete refresh of all party/raid frames
        if BetterAuras and type(BetterAuras.UpdateAllFrames) == "function" then
            local refreshed, auraCount = BetterAuras:UpdateAllFrames()
            if refreshed and refreshed > 0 then
                print(Constants.COLOR_SUCCESS .. Constants.ADDON_NAME .. ":" .. Constants.COLOR_RESET ..
                    " " .. string.format(Constants.MSG_FRAMES_UPDATED,
                        Constants.COLOR_HIGHLIGHT .. auraCount .. Constants.COLOR_RESET,
                        Constants.COLOR_HIGHLIGHT .. refreshed .. Constants.COLOR_RESET))
            else
                print(Constants.COLOR_WARNING .. Constants.ADDON_NAME .. ":" .. Constants.COLOR_RESET ..
                    " " .. Constants.MSG_NO_FRAMES_FOUND)
            end
        else
            print(Constants.COLOR_ERROR .. Constants.ADDON_NAME .. ": " ..
                Constants.MSG_FUNCTION_NOT_FOUND .. Constants.COLOR_RESET)
        end
    end)
end

--[[
    Refreshes all UI control values from the database.
]]
function ConfigPanel:RefreshControls()
    -- Update sliders
    for key, container in pairs(sliders) do
        local value = getPendingValue(key)
        if value and container.slider then
            container.slider:SetValue(value)
        end
    end

    -- Update dropdowns
    if dropdowns.buffAnchor then
        UIDropDownMenu_SetText(dropdowns.buffAnchor,
            ANCHOR_DISPLAY_NAMES[getPendingValue("buffAnchor")] or "Top Right")
    end

    if dropdowns.debuffAnchor then
        UIDropDownMenu_SetText(dropdowns.debuffAnchor,
            ANCHOR_DISPLAY_NAMES[getPendingValue("debuffAnchor")] or "Top Right")
    end
end

--[[
    Shows the configuration panel.
]]
function ConfigPanel:Show()
    if mainPanel then
        mainPanel:Show()
    end
end

--[[
    Hides the configuration panel.
]]
function ConfigPanel:Hide()
    if mainPanel then
        mainPanel:Hide()
    end
end

--[[
    Toggles the configuration panel visibility.
]]
function ConfigPanel:Toggle()
    if mainPanel and mainPanel:IsShown() then
        ConfigPanel:Hide()
    else
        ConfigPanel:Show()
    end
end

return ConfigPanel
