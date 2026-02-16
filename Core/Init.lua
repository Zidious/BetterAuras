--[[
    BetterAuras - Initialization

    This file initializes the addon namespace and sets up the main addon object.
    It handles the ADDON_LOADED event and performs initial setup tasks.

    @file Init.lua
    @author Zidious
    @version 1.0.1
]]

local ADDON_NAME, namespace = ...

-- Create the main addon object
BetterAuras = BetterAuras or {}
namespace.BetterAuras = BetterAuras

-- Store namespace for later access
BetterAuras.namespace = namespace

-- Get references to modules
local Constants = namespace.Constants
local Defaults = namespace.Defaults

--------------------------------------------------------------------------------
-- Addon Event Frame
--------------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent(Constants.EVENT_ADDON_LOADED)
eventFrame:RegisterEvent(Constants.EVENT_PLAYER_REGEN_ENABLED)

--[[
    Event handler for addon initialization and updates.

    @param eventFrame table The event frame
    @param event string The event name
    @param addonName string The addon name (for ADDON_LOADED event)
]]
eventFrame:SetScript("OnEvent", function(eventFrame, event, addonName)
    if event == Constants.EVENT_ADDON_LOADED and addonName == Constants.ADDON_NAME then
        BetterAuras:OnInitialize()
    elseif event == Constants.EVENT_PLAYER_REGEN_ENABLED then
        BetterAuras:OnCombatEnd()
    end
end)

--------------------------------------------------------------------------------
-- Initialization Handler
--------------------------------------------------------------------------------

--[[
    Called when the addon is loaded.
    Initializes the database and performs initial frame updates.
]]
function BetterAuras:OnInitialize()
    -- Initialize database
    if namespace.Database and namespace.Database.Initialize then
        namespace.Database:Initialize()
    end

    -- Create the configuration panel
    if namespace.UI and namespace.UI.ConfigPanel and namespace.UI.ConfigPanel.Create then
        namespace.UI.ConfigPanel:Create()
    end

    -- Perform initial frame update
    if BetterAuras.UpdateAllFrames then
        BetterAuras:UpdateAllFrames()
    end
end

--------------------------------------------------------------------------------
-- Combat End Handler
--------------------------------------------------------------------------------

--[[
    Called when the player leaves combat.
    Updates all frames to ensure auras are properly positioned.
]]
function BetterAuras:OnCombatEnd()
    if BetterAuras.UpdateAllFrames then
        BetterAuras:UpdateAllFrames()
    end
end

return BetterAuras
