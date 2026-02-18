--[[
    BetterAuras - Slash Commands

    This module handles slash command registration and processing.

    @file SlashCommands.lua
    @author Zidious
    @version 1.0.2
]]

local ADDON_NAME, namespace = ...

-- Get module references
local Constants = namespace.Constants
local ConfigPanel = namespace.UI.ConfigPanel

--------------------------------------------------------------------------------
-- Slash Command Registration
--------------------------------------------------------------------------------

-- Register slash commands
SLASH_BETTERAURAS1 = Constants.SLASH_COMMAND_PRIMARY
SLASH_BETTERAURAS2 = Constants.SLASH_COMMAND_SHORT

--[[
    Slash command handler.

    @param msg string The command arguments
]]
SlashCmdList["BETTERAURAS"] = function(msg)
    -- Trim whitespace
    msg = strtrim(msg or ""):lower()

    -- Toggle config panel
    if msg == "" or msg == "config" or msg == "options" then
        ConfigPanel:Toggle()
    elseif msg == "show" then
        ConfigPanel:Show()
    elseif msg == "hide" then
        ConfigPanel:Hide()
    elseif msg == "help" then
        print(Constants.COLOR_ADDON_PREFIX .. Constants.ADDON_NAME .. Constants.COLOR_RESET)
        print("Available commands:")
        print("  " .. Constants.SLASH_COMMAND_SHORT .. " - Toggle configuration panel")
        print("  " .. Constants.SLASH_COMMAND_SHORT .. " show - Show configuration panel")
        print("  " .. Constants.SLASH_COMMAND_SHORT .. " hide - Hide configuration panel")
        print("  " .. Constants.SLASH_COMMAND_SHORT .. " help - Show this help message")
    else
        -- Unknown command, just toggle the panel
        ConfigPanel:Toggle()
    end
end

return true
