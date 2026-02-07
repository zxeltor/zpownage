-- Here we check if our saved variables exist. If not we set defaults.
function ZPownage_InitializeSavedVariables()
    if not ZPownage_table_playersettings then
        ZPownage_table_playersettings = {
            isProcessPlayerKillsOnly = true,
            genreType = ZPownage_ACHIEVEMENT_GENRE_TYPE.UT
        }
    end

    if ZPownage_table_playersettings.isProcessPlayerKillsOnly == nil then
        ZPownage_table_playersettings.genreType = true
    end

    if ZPownage_table_playersettings.genreType == nil then
        ZPownage_table_playersettings.genreType = ZPownage_ACHIEVEMENT_GENRE_TYPE.UT
    end

    if ZPownage_table_playersettings.genreType ~= ZPownage_ACHIEVEMENT_GENRE_TYPE.UT 
        and ZPownage_table_playersettings.genreType ~= ZPownage_ACHIEVEMENT_GENRE_TYPE.DUKE then
        
        ZPownage_table_playersettings.genreType = ZPownage_ACHIEVEMENT_GENRE_TYPE.UT
    end

    if ZPownage_table_playersettings.bragSay == nil then
        ZPownage_table_playersettings.bragSay = false
    end

    if ZPownage_table_playersettings.bragParty == nil then
        ZPownage_table_playersettings.bragParty = false
    end

    if ZPownage_table_playersettings.bragRaid == nil then
        ZPownage_table_playersettings.bragRaid = false
    end

    if ZPownage_table_playersettings.bragBG == nil then
        ZPownage_table_playersettings.bragBG = false
    end
end

---- Functions to simplying table usage
function ZPownage_GetTablelength(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

function ZPownage_TableHasValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

function ZPownage_InsertValueIntoTable(tab, val)
    table.insert(tab, val)
end

function ZPownage_RemoveValueFromTableByIndex(tab, index)
    return table.remove(tab, index)
end

function ZPownage_RemoveValueFromTableByValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return table.remove(tab, index)
        end
    end
end

-- A simple function to send a messages to the console with "ZPownage: " pre-pended to it.
function ZPownage_SendMessageToConsole(message)
    if message ~= "" then
        print("ZPownage: " .. message)
    end
end

    -- A function used to send our brag messages
function ZPownage_SendMessageToChat(message)

    local inBG = UnitInBattleground("player")
    local inRaid = UnitInRaid("player")
    local inParty = UnitInParty("player")
    local chatType = nil

    if inBG and ZPownage_table_playersettings.bragBG then
        chatType = "INSTANCE_CHAT"
        message = "I got a " .. message
    elseif inRaid and ZPownage_table_playersettings.bragRaid then
        chatType = "RAID"
        message = "I got a " .. message
    elseif inParty and ZPownage_table_playersettings.bragRaid then
        chatType = "PARTY"
        message = "I got a " .. message
    elseif ZPownage_table_playersettings.bragSay then
        chatType = "EMOTE"
        message = "got a " .. message
    end

    if chatType ~= nil then
        SendChatMessage(message, chatType)
    end
end

-- Function used to enable/disable pLayer only killing
function ZPownage_TogglePlayerOnlyKillFlag()
    if ZPownage_table_playersettings.isProcessPlayerKillsOnly then
        ZPownage_table_playersettings.isProcessPlayerKillsOnly = false
        ZPownage_SendMessageToConsole("Player only kill mode is DISABLED")
    else
        ZPownage_table_playersettings.isProcessPlayerKillsOnly = true
        ZPownage_SendMessageToConsole("PVP only kill mode is ENABLED")
    end
end

-- Function used to send console usage information to the console
function ZPownage_SendUsageToConsole()
    ZPownage_SendMessageToConsole("Usage ..")
    ZPownage_SendMessageToConsole("/zp reset  'Reset unit kills'")
    ZPownage_SendMessageToConsole("/zp pvp    'Toggle Player ONLY kill mode'")
    ZPownage_SendMessageToConsole("/zp test   'Test achievment display and audio playback'")
    ZPownage_SendMessageToConsole("/zp        'Show addon settings UI and usage'")
end