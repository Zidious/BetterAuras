--[[
    BetterAuras - Profile Selector

    This module creates and manages the profile selector dropdown.

    @file ProfileSelector.lua
    @author Zidious
    @version 1.0.2
]]

local ADDON_NAME, namespace = ...

--------------------------------------------------------------------------------
-- Module Setup
--------------------------------------------------------------------------------

namespace.UI = namespace.UI or {}
local ProfileSelector = {}
namespace.UI.ProfileSelector = ProfileSelector

-- Module references
local Constants = namespace.Constants
local Database = namespace.Database

-- Local state
local profileDropdown
local onProfileChangeCallback

--------------------------------------------------------------------------------
-- Dropdown Initialization Function
--------------------------------------------------------------------------------

local function initializeDropdown(self, level)
    local profiles = Database:GetProfileList()
    local currentProfile = Database:GetCurrentProfileName()

    for _, profileName in ipairs(profiles) do
        local menuItem = UIDropDownMenu_CreateInfo()
        menuItem.text = profileName
        menuItem.value = profileName
        menuItem.func = function()
            if Database:SetProfile(profileName) then
                UIDropDownMenu_SetText(profileDropdown, profileName)
                if onProfileChangeCallback then
                    onProfileChangeCallback()
                end
                print(Constants.COLOR_SUCCESS .. Constants.ADDON_NAME .. ":" .. Constants.COLOR_RESET ..
                    " Switched to profile: " .. Constants.COLOR_HIGHLIGHT .. profileName .. Constants.COLOR_RESET)
            end
        end
        menuItem.checked = (profileName == currentProfile)
        UIDropDownMenu_AddButton(menuItem, level)
    end

    -- Separator
    local menuItem = UIDropDownMenu_CreateInfo()
    menuItem.text = ""
    menuItem.isTitle = true
    menuItem.notCheckable = true
    UIDropDownMenu_AddButton(menuItem, level)

    -- New Profile
    menuItem = UIDropDownMenu_CreateInfo()
    menuItem.text = "New Profile..."
    menuItem.notCheckable = true
    menuItem.func = function()
        StaticPopup_Show("BETTERAURAS_NEW_PROFILE")
    end
    UIDropDownMenu_AddButton(menuItem, level)

    -- Copy Profile
    menuItem = UIDropDownMenu_CreateInfo()
    menuItem.text = "Copy Profile..."
    menuItem.notCheckable = true
    menuItem.func = function()
        StaticPopup_Show("BETTERAURAS_COPY_PROFILE")
    end
    UIDropDownMenu_AddButton(menuItem, level)

    -- Reset Profile
    menuItem = UIDropDownMenu_CreateInfo()
    menuItem.text = "Reset Profile..."
    menuItem.notCheckable = true
    menuItem.func = function()
        StaticPopup_Show("BETTERAURAS_RESET_PROFILE")
    end
    UIDropDownMenu_AddButton(menuItem, level)

    -- Delete Profile
    if currentProfile ~= "Default" then
        menuItem = UIDropDownMenu_CreateInfo()
        menuItem.text = "Delete Profile..."
        menuItem.notCheckable = true
        menuItem.func = function()
            StaticPopup_Show("BETTERAURAS_DELETE_PROFILE")
        end
        UIDropDownMenu_AddButton(menuItem, level)
    end
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

function ProfileSelector:Create(parentFrame, onChangeCallback)
    onProfileChangeCallback = onChangeCallback

    -- Profile label
    local profileLabel = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    profileLabel:SetPoint("TOPRIGHT", parentFrame, "TOPRIGHT", -150, -30)
    profileLabel:SetText("Profile:")
    profileLabel:SetTextColor(1, 0.82, 0, 1)

    -- Profile dropdown
    profileDropdown = CreateFrame("Frame", "BetterAurasProfileDropdown", parentFrame, "UIDropDownMenuTemplate")
    profileDropdown:SetPoint("TOPRIGHT", parentFrame, "TOPRIGHT", -40, -45)
    UIDropDownMenu_SetWidth(profileDropdown, 120)

    -- Initialize dropdown
    UIDropDownMenu_Initialize(profileDropdown, initializeDropdown)

    -- Set initial text
    UIDropDownMenu_SetText(profileDropdown, Database:GetCurrentProfileName())
end

function ProfileSelector:Update()
    if profileDropdown then
        -- Close any open dropdowns before updating
        CloseDropDownMenus()
        -- Clear the dropdown's cached initialization
        profileDropdown.initialize = nil
        -- Update the displayed text
        UIDropDownMenu_SetText(profileDropdown, Database:GetCurrentProfileName())
        -- Re-initialize with fresh initialization function
        UIDropDownMenu_Initialize(profileDropdown, initializeDropdown)
    end
end

return ProfileSelector
