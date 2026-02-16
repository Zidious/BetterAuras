--[[
    BetterAuras - Default Settings

    This file contains all default configuration values for the addon.
    These defaults are used when initializing the database or resetting settings.

    @file Defaults.lua
    @author Zidious
    @version 1.0.1
]]

local ADDON_NAME, namespace = ...

-- Ensure namespace exists
namespace.Defaults = namespace.Defaults or {}
local Defaults = namespace.Defaults
local Constants = namespace.Constants

--------------------------------------------------------------------------------
-- Default Configuration Values
--------------------------------------------------------------------------------

-- Default profile settings
Defaults.profile = {
    -- Buff settings
    buffSize = 20,
    buffSpacing = 2,
    buffPaddingTop = 4,
    buffPaddingRight = 4,
    buffPaddingBottom = 10,
    buffPaddingLeft = 4,
    buffStackFontSize = 12,
    buffStackOffsetX = -1,
    buffStackOffsetY = 1,
    buffAnchor = Constants.ANCHOR_TOP_RIGHT,

    -- Debuff settings
    debuffSize = 26,
    debuffSpacing = 2,
    debuffPaddingTop = 4,
    debuffPaddingRight = 4,
    debuffPaddingBottom = 10,
    debuffPaddingLeft = 4,
    debuffStackFontSize = 12,
    debuffStackOffsetX = -1,
    debuffStackOffsetY = 1,
    debuffAnchor = Constants.ANCHOR_TOP_RIGHT,
}

-- Default database structure (with profiles support)
Defaults.database = {
    -- Version tracking
    version = "1.0.1",

    -- Profile storage
    profiles = {
        ["Default"] = Defaults.profile,
    },

    -- Character -> Profile mapping
    profileKeys = {
        -- ["CharacterName-RealmName"] = "Default"
    },
}

return Defaults
