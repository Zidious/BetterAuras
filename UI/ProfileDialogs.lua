--[[
    BetterAuras - Profile Management Dialogs

    This module handles the StaticPopup dialogs for profile management
    (creating, copying, and deleting profiles).

    @file ProfileDialogs.lua
    @author Zidious
    @version 1.0.2
]]

local ADDON_NAME, namespace = ...

--------------------------------------------------------------------------------
-- Module Setup
--------------------------------------------------------------------------------

namespace.UI = namespace.UI or {}
local ProfileDialogs = {}
namespace.UI.ProfileDialogs = ProfileDialogs

-- Module references
local Constants = namespace.Constants
local Database = namespace.Database

-- Callbacks
local onProfileChange

--------------------------------------------------------------------------------
-- Helper Functions
--------------------------------------------------------------------------------

--[[
    Safely retrieves the editBox from a StaticPopup dialog.
    Tries multiple methods to find the editBox.

    @param dialog table The StaticPopup dialog
    @return table|nil The editBox frame, or nil if not found
]]
local function getDialogEditBox(dialog)
    -- Try direct properties first
    local editBox = dialog.editBox or dialog.wideEditBox
    
    if not editBox then
        -- Try getting it by name
        local dialogName = dialog:GetName()
        if dialogName then
            editBox = _G[dialogName .. "EditBox"] or _G[dialogName .. "WideEditBox"]
        end
    end
    
    return editBox
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

function ProfileDialogs:Initialize(onChangeCallback)
    onProfileChange = onChangeCallback
    self:RegisterDialogs()
end

--------------------------------------------------------------------------------
-- Dialog Registration
--------------------------------------------------------------------------------

function ProfileDialogs:RegisterDialogs()
    -- New Profile Dialog
    StaticPopupDialogs["BETTERAURAS_NEW_PROFILE"] = {
        text = "Enter a name for the new profile:",
        button1 = "Create",
        button2 = "Cancel",
        hasEditBox = 1,
        maxLetters = 48,
        OnShow = function(self)
        end,
        OnAccept = function(self)
            local editBox = getDialogEditBox(self)
            if not editBox then 
                return 
            end

            local profileName = editBox:GetText()
            if profileName and profileName ~= "" then
                local created = Database:CreateProfile(profileName)
                if created then
                    Database:SetProfile(profileName)
                    if onProfileChange then
                        onProfileChange()
                    end
                    print(Constants.COLOR_SUCCESS .. Constants.ADDON_NAME .. ":" .. Constants.COLOR_RESET ..
                        " Created new profile: " .. Constants.COLOR_HIGHLIGHT .. profileName .. Constants.COLOR_RESET)
                else
                    print(Constants.COLOR_ERROR .. Constants.ADDON_NAME .. ":" .. Constants.COLOR_RESET ..
                        " Profile already exists: " .. profileName)
                end
            end
        end,
        EditBoxOnEnterPressed = function(self)
            local parent = self:GetParent()
            if parent then
                StaticPopupDialogs["BETTERAURAS_NEW_PROFILE"].OnAccept(parent)
                parent:Hide()
            end
        end,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide()
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        preferredIndex = 3,
    }

    -- Copy Profile Dialog
    StaticPopupDialogs["BETTERAURAS_COPY_PROFILE"] = {
        text = "Enter a name for the copied profile:",
        button1 = "Copy",
        button2 = "Cancel",
        hasEditBox = 1,
        maxLetters = 48,
        OnShow = function(self)
            C_Timer.After(0.1, function()
                local dialog = StaticPopup_FindVisible("BETTERAURAS_COPY_PROFILE")
                if dialog then
                    local editBox = dialog.editBox or dialog.wideEditBox
                    if editBox then
                        editBox:SetText(Database:GetCurrentProfileName() .. " Copy")
                        editBox:HighlightText()
                    end
                end
            end)
        end,
        OnAccept = function(self)
            local editBox = getDialogEditBox(self)
            if not editBox then return end

            local profileName = editBox:GetText()
            if profileName and profileName ~= "" then
                if Database:CopyProfile(profileName) then
                    Database:SetProfile(profileName)
                    if onProfileChange then
                        onProfileChange()
                    end
                    print(Constants.COLOR_SUCCESS .. Constants.ADDON_NAME .. ":" .. Constants.COLOR_RESET ..
                        " Copied profile to: " .. Constants.COLOR_HIGHLIGHT .. profileName .. Constants.COLOR_RESET)
                else
                    print(Constants.COLOR_ERROR .. Constants.ADDON_NAME .. ":" .. Constants.COLOR_RESET ..
                        " Profile already exists: " .. profileName)
                end
            end
        end,
        EditBoxOnEnterPressed = function(self)
            local parent = self:GetParent()
            if parent then
                StaticPopupDialogs["BETTERAURAS_COPY_PROFILE"].OnAccept(parent)
                parent:Hide()
            end
        end,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide()
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        preferredIndex = 3,
    }

    -- Delete Profile Dialog
    StaticPopupDialogs["BETTERAURAS_DELETE_PROFILE"] = {
        text = "Are you sure you want to delete this profile?",
        button1 = "Delete",
        button2 = "Cancel",
        OnShow = function(self)
            local profileName = Database:GetCurrentProfileName()
            if self.text then
                self.text:SetText("Delete profile '" .. profileName .. "'?\n\nYou will be switched to the Default profile.")
            end
        end,
        OnAccept = function(self)
            local profileName = Database:GetCurrentProfileName()
            if Database:DeleteProfile(profileName) then
                if onProfileChange then
                    onProfileChange()
                end
                print(Constants.COLOR_SUCCESS .. Constants.ADDON_NAME .. ":" .. Constants.COLOR_RESET ..
                    " Deleted profile: " .. Constants.COLOR_HIGHLIGHT .. profileName .. Constants.COLOR_RESET)
            else
                print(Constants.COLOR_ERROR .. Constants.ADDON_NAME .. ":" .. Constants.COLOR_RESET ..
                    " Cannot delete profile: " .. profileName)
            end
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        preferredIndex = 3,
    }

    -- Reset Profile Dialog
    StaticPopupDialogs["BETTERAURAS_RESET_PROFILE"] = {
        text = "Are you sure you want to reset this profile?",
        button1 = "Reset",
        button2 = "Cancel",
        OnShow = function(self)
            local profileName = Database:GetCurrentProfileName()
            if self.text then
                self.text:SetText("Reset profile '" .. profileName .. "' to defaults?\n\nAll current settings will be lost.")
            end
        end,
        OnAccept = function(self)
            local profileName = Database:GetCurrentProfileName()
            Database:ResetToDefaults()
            if onProfileChange then
                onProfileChange()
            end
            print(Constants.COLOR_SUCCESS .. Constants.ADDON_NAME .. ":" .. Constants.COLOR_RESET ..
                " Reset profile: " .. Constants.COLOR_HIGHLIGHT .. profileName .. Constants.COLOR_RESET)
        end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        preferredIndex = 3,
    }
end

return ProfileDialogs
