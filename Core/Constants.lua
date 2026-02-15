--[[
    BetterAuras - Constants

    This file contains all constant values used throughout the addon.
    Following Lua best practices, all magic strings and values are defined here
    to ensure maintainability and avoid duplication.

    @file Constants.lua
    @author Zidious
    @version 1.0.0
]]

local ADDON_NAME, namespace = ...

-- Ensure namespace exists
namespace.Constants = namespace.Constants or {}
local Constants = namespace.Constants

--------------------------------------------------------------------------------
-- Addon Information
--------------------------------------------------------------------------------

Constants.ADDON_NAME = "BetterAuras"
Constants.DB_NAME = "BetterAurasDB"

--------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------

Constants.SLASH_COMMAND_PRIMARY = "/betterauras"
Constants.SLASH_COMMAND_SHORT = "/ba"

--------------------------------------------------------------------------------
-- Color Codes
--------------------------------------------------------------------------------

Constants.COLOR_ADDON_PREFIX = "|cFF00CCFF" -- Cyan for addon name
Constants.COLOR_SUCCESS = "|cFF00FF00"      -- Green for success messages
Constants.COLOR_ERROR = "|cFFFF0000"        -- Red for error messages
Constants.COLOR_WARNING = "|cFFFFAA00"      -- Orange for warnings
Constants.COLOR_HIGHLIGHT = "|cFFFFD700"    -- Gold for highlighted values
Constants.COLOR_RESET = "|r"                -- Reset color

--------------------------------------------------------------------------------
-- Anchor Points
--------------------------------------------------------------------------------

Constants.ANCHOR_TOP_LEFT = "TOPLEFT"
Constants.ANCHOR_TOP_RIGHT = "TOPRIGHT"
Constants.ANCHOR_BOTTOM_LEFT = "BOTTOMLEFT"
Constants.ANCHOR_BOTTOM_RIGHT = "BOTTOMRIGHT"

-- Anchor options for UI dropdowns
Constants.ANCHOR_OPTIONS = {
    { text = "Top Left",     value = Constants.ANCHOR_TOP_LEFT },
    { text = "Top Right",    value = Constants.ANCHOR_TOP_RIGHT },
    { text = "Bottom Left",  value = Constants.ANCHOR_BOTTOM_LEFT },
    { text = "Bottom Right", value = Constants.ANCHOR_BOTTOM_RIGHT }
}

--------------------------------------------------------------------------------
-- Frame Names and Patterns
--------------------------------------------------------------------------------

Constants.PARTY_UNIT_PATTERN = "^party"
Constants.RAID_UNIT_PATTERN = "^raid"
Constants.PLAYER_UNIT = "player"

Constants.BUFF_FRAME_SUFFIX = "Buff"
Constants.DEBUFF_FRAME_SUFFIX = "Debuff"

Constants.PARTY_MEMBER_FRAME_PREFIX = "PartyMemberFrame"
Constants.COMPACT_PARTY_FRAME_PLAYER = "CompactPartyFramePlayer"
Constants.COMPACT_PARTY_FRAME_MEMBER_PREFIX = "CompactPartyFrameMember"

--------------------------------------------------------------------------------
-- UI Element Sizes and Limits
--------------------------------------------------------------------------------

Constants.MAX_AURA_SLOTS = 40        -- Maximum number of aura slots to check
Constants.CONFIG_PANEL_WIDTH = 800   -- Configuration panel width
Constants.CONFIG_PANEL_HEIGHT = 600  -- Configuration panel height
Constants.PREVIEW_FRAME_WIDTH = 320  -- Preview frame width
Constants.PREVIEW_FRAME_HEIGHT = 110 -- Preview frame height
Constants.SCROLL_CONTENT_WIDTH = 340 -- Scroll frame content width

--------------------------------------------------------------------------------
-- Timer Delays
--------------------------------------------------------------------------------

Constants.ANCHOR_UPDATE_DELAY = 0    -- Delay for anchoring updates (seconds)
Constants.FRAME_REFRESH_DELAY = 0.05 -- Delay for frame refresh (seconds)

--------------------------------------------------------------------------------
-- Slider Ranges
--------------------------------------------------------------------------------

Constants.SLIDER_SIZE_MIN = 10
Constants.SLIDER_SIZE_MAX = 40
Constants.SLIDER_SIZE_STEP = 1

Constants.SLIDER_SPACING_MIN = 0
Constants.SLIDER_SPACING_MAX = 10
Constants.SLIDER_SPACING_STEP = 1

Constants.SLIDER_PADDING_MIN = 0
Constants.SLIDER_PADDING_MAX = 20
Constants.SLIDER_PADDING_STEP = 1

Constants.SLIDER_FONT_SIZE_MIN = 6
Constants.SLIDER_FONT_SIZE_MAX = 20
Constants.SLIDER_FONT_SIZE_STEP = 1

Constants.SLIDER_OFFSET_MIN = -10
Constants.SLIDER_OFFSET_MAX = 10
Constants.SLIDER_OFFSET_STEP = 1

--------------------------------------------------------------------------------
-- UI Textures and Assets
--------------------------------------------------------------------------------

Constants.TEXTURE_DIALOG_BACKGROUND = "Interface\\DialogFrame\\UI-DialogBox-Background"
Constants.TEXTURE_DIALOG_BORDER = "Interface\\DialogFrame\\UI-DialogBox-Border"
Constants.TEXTURE_CHAT_BACKGROUND = "Interface\\ChatFrame\\ChatFrameBackground"
Constants.TEXTURE_TOOLTIP_BORDER = "Interface\\Tooltips\\UI-Tooltip-Border"
Constants.TEXTURE_WHITE = "Interface\\Buttons\\WHITE8X8"

Constants.ROLE_ICON_TANK = "roleicon-tiny-tank"
Constants.ROLE_ICON_HEALER = "roleicon-tiny-healer"
Constants.ROLE_ICON_DPS = "roleicon-tiny-dps"

--------------------------------------------------------------------------------
-- Preview Icons
--------------------------------------------------------------------------------

-- Buff texture IDs for preview
Constants.PREVIEW_BUFF_ICONS = { 136243, 135987, 237542 }

-- Debuff texture IDs for preview
Constants.PREVIEW_DEBUFF_ICONS = { 136118, 136139, 136145 }

-- Stack counts for preview
Constants.PREVIEW_BUFF_STACKS = { 5, 3, 0 }
Constants.PREVIEW_DEBUFF_STACKS = { 4, 2, 0 }

--------------------------------------------------------------------------------
-- Texture Crop Coordinates
--------------------------------------------------------------------------------

Constants.ICON_TEX_COORD_LEFT = 0.07
Constants.ICON_TEX_COORD_RIGHT = 0.93
Constants.ICON_TEX_COORD_TOP = 0.07
Constants.ICON_TEX_COORD_BOTTOM = 0.93

--------------------------------------------------------------------------------
-- Backdrop Configurations
--------------------------------------------------------------------------------

Constants.BACKDROP_DIALOG = {
    bgFile = Constants.TEXTURE_DIALOG_BACKGROUND,
    edgeFile = Constants.TEXTURE_DIALOG_BORDER,
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
}

Constants.BACKDROP_PREVIEW = {
    bgFile = Constants.TEXTURE_CHAT_BACKGROUND,
    edgeFile = Constants.TEXTURE_TOOLTIP_BORDER,
    tile = true,
    tileSize = 16,
    edgeSize = 14,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
}

Constants.BACKDROP_AURA = {
    bgFile = Constants.TEXTURE_WHITE,
    edgeFile = Constants.TEXTURE_WHITE,
    tile = false,
    edgeSize = 1.5,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
}

--------------------------------------------------------------------------------
-- Role Definitions
--------------------------------------------------------------------------------

Constants.ROLE_TANK = "TANK"
Constants.ROLE_HEALER = "HEALER"
Constants.ROLE_DAMAGER = "DAMAGER"

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

Constants.EVENT_ADDON_LOADED = "ADDON_LOADED"
Constants.EVENT_PLAYER_REGEN_ENABLED = "PLAYER_REGEN_ENABLED"
Constants.EVENT_PLAYER_SPECIALIZATION_CHANGED = "PLAYER_SPECIALIZATION_CHANGED"
Constants.EVENT_PLAYER_ROLES_ASSIGNED = "PLAYER_ROLES_ASSIGNED"

--------------------------------------------------------------------------------
-- Messages
--------------------------------------------------------------------------------

Constants.MSG_COMBAT_LOCKDOWN = "Cannot apply changes while in combat!"
Constants.MSG_SETTINGS_RESET = "Settings reset to defaults!"
Constants.MSG_FRAMES_UPDATED = "Updated %s auras on %s frames!"
Constants.MSG_NO_FRAMES_FOUND = "No party/raid frames found with visible auras."
Constants.MSG_FUNCTION_NOT_FOUND = "UpdateAllFrames function not found! Try reloading the UI."

--------------------------------------------------------------------------------
-- Font Outline Constants
--------------------------------------------------------------------------------

Constants.FONT_OUTLINE = "OUTLINE"

return Constants
