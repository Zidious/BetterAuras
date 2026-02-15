--[[
    BetterAuras - Database Management

    This file handles all database operations including initialization,
    copying defaults, profile management, and providing access to configuration values.

    @file Database.lua
    @author Zidious
    @version 1.0.0
]]

local ADDON_NAME, namespace = ...

-- Ensure namespace exists
namespace.Database = namespace.Database or {}
local Database = namespace.Database

-- Get references to modules
local Constants = namespace.Constants
local Defaults = namespace.Defaults

-- Store reference to saved variables
local savedVariables
local currentProfile
local characterKey

--------------------------------------------------------------------------------
-- Utility Functions
--------------------------------------------------------------------------------

--[[
    Recursively copies default values to a destination table.
    Only copies values if they don't already exist in the destination.

    @param src table The source table with default values
    @param dst table The destination table to copy to
    @return table The merged table
]]
local function copyDefaults(source, destination)
    if type(destination) ~= "table" then
        destination = {}
    end

    for key, value in pairs(source) do
        if type(value) == "table" then
            destination[key] = copyDefaults(value, destination[key])
        elseif destination[key] == nil then
            destination[key] = value
        end
    end

    return destination
end

--[[
    Deep copies a table (including nested tables).

    @param orig table The table to copy
    @return table The copied table
]]
local function deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepCopy(orig_key)] = deepCopy(orig_value)
        end
    else
        copy = orig
    end
    return copy
end

--[[
    Gets the character key (CharacterName-RealmName).

    @return string The character key
]]
local function getCharacterKey()
    if not characterKey then
        local name = UnitName("player")
        local realm = GetRealmName()
        characterKey = name .. "-" .. realm
    end
    return characterKey
end

--------------------------------------------------------------------------------
-- Database API
--------------------------------------------------------------------------------

--[[
    Initializes the database with default values and profile support.
    Called once when the addon is loaded.
]]
function Database:Initialize()
    -- Initialize global saved variable if it doesn't exist
    if type(_G[Constants.DB_NAME]) ~= "table" then
        _G[Constants.DB_NAME] = {}
    end

    -- Store reference to the global table
    savedVariables = _G[Constants.DB_NAME]

    -- Initialize database structure
    if not savedVariables.version then
        -- First time initialization - migrate old data or create new
        savedVariables = copyDefaults(Defaults.database, savedVariables)
        _G[Constants.DB_NAME] = savedVariables
    else
        -- Ensure all database structure exists
        savedVariables.profiles = savedVariables.profiles or {}
        savedVariables.profileKeys = savedVariables.profileKeys or {}

        -- Update version if needed
        if savedVariables.version ~= Defaults.database.version then
            print(Constants.COLOR_ADDON_PREFIX .. Constants.ADDON_NAME .. Constants.COLOR_RESET ..
                ": Upgrading database from v" .. (savedVariables.version or "unknown") .. " to v" .. Defaults.database.version)
            savedVariables.version = Defaults.database.version
        end
    end

    -- Ensure Default profile exists
    if not savedVariables.profiles["Default"] then
        savedVariables.profiles["Default"] = deepCopy(Defaults.profile)
    end

    -- Get character key and set current profile
    local charKey = getCharacterKey()
    local profileName = savedVariables.profileKeys[charKey] or "Default"

    -- Ensure the selected profile exists, fall back to Default if not
    if not savedVariables.profiles[profileName] then
        profileName = "Default"
        savedVariables.profileKeys[charKey] = profileName
    end

    currentProfile = savedVariables.profiles[profileName]

    -- Ensure current profile has all default values
    currentProfile = copyDefaults(Defaults.profile, currentProfile)
    savedVariables.profiles[profileName] = currentProfile
end

--[[
    Gets a configuration value from the current profile.

    @param key string The configuration key to retrieve
    @return any The configuration value
]]
function Database:Get(key)
    if not currentProfile then
        Database:Initialize()
    end
    return currentProfile[key]
end

--[[
    Sets a configuration value in the current profile.

    @param key string The configuration key to set
    @param value any The value to set
]]
function Database:Set(key, value)
    if not currentProfile then
        Database:Initialize()
    end

    currentProfile[key] = value
end

--[[
    Gets the entire current profile table.

    @return table The current profile table
]]
function Database:GetAll()
    if not currentProfile then
        Database:Initialize()
    end
    return currentProfile
end

--[[
    Resets the current profile to default values.
]]
function Database:ResetToDefaults()
    if not currentProfile or not savedVariables then
        Database:Initialize()
    end

    -- Get current profile name
    local profileName = Database:GetCurrentProfileName()

    -- Replace profile with fresh defaults
    savedVariables.profiles[profileName] = deepCopy(Defaults.profile)
    currentProfile = savedVariables.profiles[profileName]
end

--------------------------------------------------------------------------------
-- Profile Management API
--------------------------------------------------------------------------------

--[[
    Gets the name of the current profile.

    @return string The current profile name
]]
function Database:GetCurrentProfileName()
    if not savedVariables then
        Database:Initialize()
    end

    local charKey = getCharacterKey()
    return savedVariables.profileKeys[charKey] or "Default"
end

--[[
    Gets a list of all profile names.

    @return table Array of profile names
]]
function Database:GetProfileList()
    if not savedVariables then
        Database:Initialize()
    end

    local profileNames = {}
    for profileName, _ in pairs(savedVariables.profiles) do
        table.insert(profileNames, profileName)
    end

    -- Sort alphabetically, but keep Default first
    table.sort(profileNames, function(a, b)
        if a == "Default" then return true end
        if b == "Default" then return false end
        return a < b
    end)

    return profileNames
end

--[[
    Switches to a different profile.

    @param profileName string The name of the profile to switch to
    @return boolean True if successful, false if profile doesn't exist
]]
function Database:SetProfile(profileName)
    if not savedVariables then
        Database:Initialize()
    end

    if not savedVariables.profiles[profileName] then
        return false
    end

    -- Update character's profile key
    local charKey = getCharacterKey()
    savedVariables.profileKeys[charKey] = profileName

    -- Switch current profile
    currentProfile = savedVariables.profiles[profileName]

    -- Ensure it has all defaults
    currentProfile = copyDefaults(Defaults.profile, currentProfile)
    savedVariables.profiles[profileName] = currentProfile

    return true
end

--[[
    Creates a new profile with default values.

    @param profileName string The name of the new profile
    @return boolean True if successful, false if profile already exists
]]
function Database:CreateProfile(profileName)
    if not savedVariables then
        Database:Initialize()
    end

    if savedVariables.profiles[profileName] then
        return false
    end

    -- Create new profile with defaults
    savedVariables.profiles[profileName] = deepCopy(Defaults.profile)

    return true
end

--[[
    Copies the current profile to a new profile.

    @param newProfileName string The name of the new profile
    @return boolean True if successful, false if profile already exists
]]
function Database:CopyProfile(newProfileName)
    if not savedVariables then
        Database:Initialize()
    end

    if savedVariables.profiles[newProfileName] then
        return false
    end

    -- Copy current profile
    savedVariables.profiles[newProfileName] = deepCopy(currentProfile)

    return true
end

--[[
    Deletes a profile.

    @param profileName string The name of the profile to delete
    @return boolean True if successful, false if can't delete (Default or doesn't exist)
]]
function Database:DeleteProfile(profileName)
    if not savedVariables then
        Database:Initialize()
    end

    -- Can't delete Default profile
    if profileName == "Default" then
        return false
    end

    if not savedVariables.profiles[profileName] then
        return false
    end

    -- Remove profile
    savedVariables.profiles[profileName] = nil

    -- Update any characters using this profile to use Default
    for charKey, assignedProfileName in pairs(savedVariables.profileKeys) do
        if assignedProfileName == profileName then
            savedVariables.profileKeys[charKey] = "Default"
        end
    end

    -- If current character was using this profile, switch to Default
    if Database:GetCurrentProfileName() == profileName then
        Database:SetProfile("Default")
    end

    return true
end

return Database
