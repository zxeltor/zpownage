---- Main config settings
-- The max number of seconds to display a kill achievement on the screen
local _zp_const_waitForAchievmentToCompleteInSeconds = 3.0
-- The base folder for our audio files
local _zp_const_audioFileBaseFolder = "Interface\\AddOns\\ZPownage\\Audio\\";

---- Runtime variables
-- The player GUI used to track kills from the combat logs
local _zp_playerGUID
-- A flag used to track debug logging
local _zp_isDebugMode = false;
-- The number of consecutive kills with a death. Is reset after player death.
local _zp_numberOfPlayerKillsBeforeDeath = 0
-- The number of consecutive kills to be considerd for multi kill processing.
local _zp_numberOfConsectutiveMultiKills = 0
-- The max number of seconds between consecutive kills for a new kill to be considered for multi kill processing.
local _zp_maxSecondsBetweenConsecutiveKillsForMultiKill = 4
-- Used to determine if recent consective kills can be considered for multi kill processing.
local _zp_timeElapsedInSecondsSinceLastKill = 0
-- Used to determine if the achievment window is open of not. This is used to block/delay new achievments while 
-- an existing one is still being displayed.
local _zp_isAchievementBeingDisplayed = false;

local _zp_isAddonSettingsFrameAdded = false;

-- A table used to to keep track of units the player has attacked
local _zp_table_inCombatWith = {}
-- A table used as an achievement queue for processing. This guarentees we process achievments in the order they occured.
local _zp_table_achievmentQueue = {}

-- Our achievements enum table, or a table used like an enum. The is a list of available player achievements
local _zp_ACHIEVEMENT_TYPE = {
    DEAD = 1, DOMINATING = 2, DOUBLE = 3, FIRSTBLOOD = 4, FLAWLESS = 5, GODLIKE = 6, HOLYSHIT = 7, KILLSPREE = 8, LUDICROUS = 9,
    MEGA = 10, MONSTER = 11, MULTI = 12, PREP4BATTLE = 13, RAMPAGE = 14, TRIPPLE = 15, ULTRA = 16, UNREAL = 17, UNSTOPPABLE = 18,
    WICKED = 19
}

-- A table of audio file path strings
local _zp_table_achievementAudioFilePath = {
    [_zp_ACHIEVEMENT_TYPE.DEAD] = _zp_const_audioFileBaseFolder .. "pacmandies.mp3",
    [_zp_ACHIEVEMENT_TYPE.DOMINATING] = _zp_const_audioFileBaseFolder .. "dominating.mp3",
    [_zp_ACHIEVEMENT_TYPE.DOUBLE] = _zp_const_audioFileBaseFolder .. "doublekill.mp3",
    [_zp_ACHIEVEMENT_TYPE.FIRSTBLOOD] = _zp_const_audioFileBaseFolder .. "firstblood.mp3",
    [_zp_ACHIEVEMENT_TYPE.FLAWLESS] = _zp_const_audioFileBaseFolder .. "flawlessvictory.mp3",
    [_zp_ACHIEVEMENT_TYPE.GODLIKE] = _zp_const_audioFileBaseFolder .. "godlike.mp3",
    [_zp_ACHIEVEMENT_TYPE.HOLYSHIT] = _zp_const_audioFileBaseFolder .. "holyshit.mp3",
    [_zp_ACHIEVEMENT_TYPE.KILLSPREE] = _zp_const_audioFileBaseFolder .. "killingspree.mp3",
    [_zp_ACHIEVEMENT_TYPE.LUDICROUS] = _zp_const_audioFileBaseFolder .. "ludicrouskill.mp3",
    [_zp_ACHIEVEMENT_TYPE.MEGA] = _zp_const_audioFileBaseFolder .. "megakill.mp3",
    [_zp_ACHIEVEMENT_TYPE.MONSTER] = _zp_const_audioFileBaseFolder .. "monsterkill.mp3",
    [_zp_ACHIEVEMENT_TYPE.MULTI] = _zp_const_audioFileBaseFolder .. "multikill.mp3",
    [_zp_ACHIEVEMENT_TYPE.PREP4BATTLE] = _zp_const_audioFileBaseFolder .. "prepareforbattle.mp3",
    [_zp_ACHIEVEMENT_TYPE.RAMPAGE] = _zp_const_audioFileBaseFolder .. "rampage.mp3",
    [_zp_ACHIEVEMENT_TYPE.TRIPPLE] = _zp_const_audioFileBaseFolder .. "triplekill.mp3",
    [_zp_ACHIEVEMENT_TYPE.ULTRA] = _zp_const_audioFileBaseFolder .. "ultrakill.mp3",
    [_zp_ACHIEVEMENT_TYPE.UNREAL] = _zp_const_audioFileBaseFolder .. "unreal.mp3",
    [_zp_ACHIEVEMENT_TYPE.UNSTOPPABLE] = _zp_const_audioFileBaseFolder .. "unstoppable.mp3",
    [_zp_ACHIEVEMENT_TYPE.WICKED] = _zp_const_audioFileBaseFolder .. "wickedsick.mp3"
}

-- A table of text strings to display for player achievements.
local _zp_table_achievementDisplayText = {
    [_zp_ACHIEVEMENT_TYPE.DEAD] = "YOU'VE BEEN POWNED!",
    [_zp_ACHIEVEMENT_TYPE.DOMINATING] = "DOMINATING!",
    [_zp_ACHIEVEMENT_TYPE.DOUBLE] = "DOUBLE KILL!",
    [_zp_ACHIEVEMENT_TYPE.FIRSTBLOOD] = "FIRST BLOOD!",
    [_zp_ACHIEVEMENT_TYPE.FLAWLESS] = "FLAWLESS VICTORY!",
    [_zp_ACHIEVEMENT_TYPE.GODLIKE] = "GODLIKE!",
    [_zp_ACHIEVEMENT_TYPE.HOLYSHIT] = "**** HOLY SHIT! ****",
    [_zp_ACHIEVEMENT_TYPE.KILLSPREE] = "KILLING SPREE!",
    [_zp_ACHIEVEMENT_TYPE.LUDICROUS] = "LUDICROUS KILL!",
    [_zp_ACHIEVEMENT_TYPE.MEGA] = "MEGA KILL!",
    [_zp_ACHIEVEMENT_TYPE.MONSTER] = "MONSTER KILL!",
    [_zp_ACHIEVEMENT_TYPE.MULTI] = "MULTI KILL!",
    [_zp_ACHIEVEMENT_TYPE.PREP4BATTLE] = "PREPARE FOR BATTLE!",
    [_zp_ACHIEVEMENT_TYPE.RAMPAGE] = "RAMPAGE!",
    [_zp_ACHIEVEMENT_TYPE.TRIPPLE] = "TRIPLE KILL!",
    [_zp_ACHIEVEMENT_TYPE.ULTRA] = "ULTRA KILL!",
    [_zp_ACHIEVEMENT_TYPE.UNREAL] = "UNREAL!",
    [_zp_ACHIEVEMENT_TYPE.UNSTOPPABLE] = "UNSTOPPABLE!",
    [_zp_ACHIEVEMENT_TYPE.WICKED] = "WICKED SICK!"
}

-- Here we check if our saved variables exist. If not we set defaults.
local function _zpValidateSavedVariables()
    if not _zp_PlayerConfigurableSettingsTable then
        _zp_PlayerConfigurableSettingsTable = {
            isProcessPlayerKillsOnly = true
        }
    end

    if _zp_PlayerConfigurableSettingsTable.isProcessPlayerKillsOnly == nil then
        _zp_PlayerConfigurableSettingsTable.isProcessPlayerKillsOnly = true
    end
end

---- Functions to simplying table usage
local function _zpTablelength(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

local function _zpTableHasValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

local function _zpTableInsertValue(tab, val)
    table.insert(tab, val)
end

local function _zpTableRemoveIndex(tab, index)
    return table.remove(tab, index)
end

local function _zpTableRemoveValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return table.remove(tab, index)
        end
    end
end

---- Define various UI frames used by this addon.
-- This frame is used to process events fired off by the game. It's never displayed to the user.
local _zp_frame_event = CreateFrame("Frame", "_zpEventFrame")
_zp_frame_event:Hide()

-- The achievment frame. It's used to flash achievement messages to the screen.
local _zp_frame_achievementMessage = CreateFrame("Frame", "_zpAchievmentFrame", UIParent)
_zp_frame_achievementMessage:SetFrameStrata("BACKGROUND")
_zp_frame_achievementMessage:SetWidth(256)
_zp_frame_achievementMessage:SetHeight(64)
_zp_frame_achievementMessage:SetPoint("CENTER", 0, 250)

-- Adding 4 backgroud font strings (offset from the main font srting) using the same text as the main font string. This provide a background/border effect.
local _zp_frame_message_fontStringMessageBackground = _zp_frame_achievementMessage:CreateFontString(_zp_frame_achievementMessage, "OVERLAY", "GameFontNormal")
_zp_frame_message_fontStringMessageBackground:SetTextHeight(36)
_zp_frame_message_fontStringMessageBackground:SetTextColor(0, 0, 0, 1)
_zp_frame_message_fontStringMessageBackground:SetPoint("CENTER", 3, 3)

local _zp_frame_message_fontStringMessageBackground2 = _zp_frame_achievementMessage:CreateFontString(_zp_frame_achievementMessage, "OVERLAY", "GameFontNormal")
_zp_frame_message_fontStringMessageBackground2:SetTextHeight(36)
_zp_frame_message_fontStringMessageBackground2:SetTextColor(0, 0, 0, 1)
_zp_frame_message_fontStringMessageBackground2:SetPoint("CENTER", 3, -3)

local _zp_frame_message_fontStringMessageBackground3 = _zp_frame_achievementMessage:CreateFontString(_zp_frame_achievementMessage, "OVERLAY", "GameFontNormal")
_zp_frame_message_fontStringMessageBackground3:SetTextHeight(36)
_zp_frame_message_fontStringMessageBackground3:SetTextColor(0, 0, 0, 1)
_zp_frame_message_fontStringMessageBackground3:SetPoint("CENTER", -3, 3)

local _zp_frame_message_fontStringMessageBackground4 = _zp_frame_achievementMessage:CreateFontString(_zp_frame_achievementMessage, "OVERLAY", "GameFontNormal")
_zp_frame_message_fontStringMessageBackground4:SetTextHeight(36)
_zp_frame_message_fontStringMessageBackground4:SetTextColor(0, 0, 0, 1)
_zp_frame_message_fontStringMessageBackground4:SetPoint("CENTER", -3, -3)

-- The main font string to display our achievement text
local _zp_frame_message_fontStringMessage = _zp_frame_achievementMessage:CreateFontString(_zp_frame_achievementMessage, "OVERLAY", "GameFontNormal")
_zp_frame_message_fontStringMessage:SetTextHeight(36)
_zp_frame_message_fontStringMessage:SetTextColor(0, 1, 0, 1)
_zp_frame_message_fontStringMessage:SetPoint("CENTER", 0, 0)
_zp_frame_message_fontStringMessage:SetText("ZPownage Achievment Message")
_zp_frame_achievementMessage:Hide()

-- A simple function to send a messages to the console with "ZPownage: " pre-pended to it.
local function _zpSendMessageToConsole(message)
    if message ~= "" then
        print("ZPownage: " .. message)
    end
end

-- A function to Reset player kill stats. Called when a player enters a new world zone/instance, or when a player dies.
local function _zpResetPlayer()
    _zp_playerGUID = UnitGUID("player")
    _zp_numberOfPlayerKillsBeforeDeath = 0
    _zp_numberOfConsectutiveMultiKills = 0
    _zp_table_inCombatWith = {}
    _zpSendMessageToConsole("Player kills have been set to zero")
end

-- Function used to enable/disable pLayer only killing
local function _zpTogglePlayerOnlyKillFlag()
    if _zp_PlayerConfigurableSettingsTable.isProcessPlayerKillsOnly then
        _zp_PlayerConfigurableSettingsTable.isProcessPlayerKillsOnly = false
        _zpSendMessageToConsole("Player only kill mode is DISABLED")
    else
        _zp_PlayerConfigurableSettingsTable.isProcessPlayerKillsOnly = true
        _zpSendMessageToConsole("PVP only kill mode is ENABLED")
    end
end

-- Function used to add addon settings for Zpownage in the Blizzard addon UI (Interface/Addons)
local function _zpAddPlayerConfigSettingsToAddonUI()

    if _zp_isAddonSettingsFrameAdded then return end

    local _zp_panel = CreateFrame( "Frame", "_zpAddonPanel", UIParent);
     -- Register in the Interface Addon Options GUI
    -- Set the name for the Category for the Options Panel
    _zp_panel.name = "ZPownage";

    local _zp_panel_title_fontStringMessageBackground = _zp_panel:CreateFontString(_zp_panel, "OVERLAY", "GameFontNormal")
    _zp_panel_title_fontStringMessageBackground:SetTextHeight(36)
    _zp_panel_title_fontStringMessageBackground:SetTextColor(0, 0, 0, 1)
    _zp_panel_title_fontStringMessageBackground:SetPoint("TOP", 3, -17)
    _zp_panel_title_fontStringMessageBackground:SetText("ZPownage")

    local _zp_panel_title_fontStringMessageBackground2 = _zp_panel:CreateFontString(_zp_panel, "OVERLAY", "GameFontNormal")
    _zp_panel_title_fontStringMessageBackground2:SetTextHeight(36)
    _zp_panel_title_fontStringMessageBackground2:SetTextColor(0, 0, 0, 1)
    _zp_panel_title_fontStringMessageBackground2:SetPoint("TOP", 3, -23)
    _zp_panel_title_fontStringMessageBackground2:SetText("ZPownage")

    local _zp_panel_title_fontStringMessageBackground3 = _zp_panel:CreateFontString(_zp_panel, "OVERLAY", "GameFontNormal")
    _zp_panel_title_fontStringMessageBackground3:SetTextHeight(36)
    _zp_panel_title_fontStringMessageBackground3:SetTextColor(0, 0, 0, 1)
    _zp_panel_title_fontStringMessageBackground3:SetPoint("TOP", -3, -17)
    _zp_panel_title_fontStringMessageBackground3:SetText("ZPownage")

    local _zp_panel_title_fontStringMessageBackground4 = _zp_panel:CreateFontString(_zp_panel, "OVERLAY", "GameFontNormal")
    _zp_panel_title_fontStringMessageBackground4:SetTextHeight(36)
    _zp_panel_title_fontStringMessageBackground4:SetTextColor(0, 0, 0, 1)
    _zp_panel_title_fontStringMessageBackground4:SetPoint("TOP", -3, -23)
    _zp_panel_title_fontStringMessageBackground4:SetText("ZPownage")

    local _zp_panel_title_fontStringMessage = _zp_panel:CreateFontString(_zp_panel, "OVERLAY", "GameFontNormal")
    _zp_panel_title_fontStringMessage:SetTextHeight(36)
    _zp_panel_title_fontStringMessage:SetTextColor(0, 1, 0, 1)
    _zp_panel_title_fontStringMessage:SetPoint("TOP", 0, -20)
    _zp_panel_title_fontStringMessage:SetText("ZPownage")

    local _zp_myCheckButtonPvpOnly = CreateFrame("CheckButton", "_zpPvpOnlyCheckBox", _zp_panel, "UICheckButtonTemplate")
    _zp_myCheckButtonPvpOnly:SetPoint("TOPLEFT", 10, -40)
    _zp_myCheckButtonPvpOnly:SetChecked(_zp_PlayerConfigurableSettingsTable.isProcessPlayerKillsOnly)
    _G[_zp_myCheckButtonPvpOnly:GetName().."Text"]:SetText("Player Only Kill Mode")
    _zp_myCheckButtonPvpOnly:SetScript("OnClick", function(self, button, down)
        _zpTogglePlayerOnlyKillFlag()
    end)

    local _zp_myButtonReset = CreateFrame("Button", "_zpResetButton", _zp_panel, "OptionsButtonTemplate")
    _zp_myButtonReset:SetPoint("TOPLEFT", 10, -80)
    _zp_myButtonReset:SetText("Reset Kills")
    _zp_myButtonReset:SetScript("OnClick", function(self, button, down) _zpResetPlayer() end)

    local _zp_panel_usage_fontStringLine1 = _zp_panel:CreateFontString(_zp_panel, "OVERLAY", "GameTooltipText")
    _zp_panel_usage_fontStringLine1:SetPoint("BOTTOMLEFT", 10, 70)
    _zp_panel_usage_fontStringLine1:SetText("Available Slash Commands:")
    local _zp_panel_usage_fontStringLine2 = _zp_panel:CreateFontString(_zp_panel, "OVERLAY", "GameTooltipText")
    _zp_panel_usage_fontStringLine2:SetPoint("BOTTOMLEFT", 10, 50)
    _zp_panel_usage_fontStringLine2:SetText('/zp reset  "Reset unit kills"')
    local _zp_panel_usage_fontStringLine3 = _zp_panel:CreateFontString(_zp_panel, "OVERLAY", "GameTooltipText")
    _zp_panel_usage_fontStringLine3:SetPoint("BOTTOMLEFT", 10, 35)
    _zp_panel_usage_fontStringLine3:SetText('/zp pvp    "Toggle player only kill mode" - If disabled, it tracks all kills made by the player.')
    local _zp_panel_usage_fontStringLine4 = _zp_panel:CreateFontString(_zp_panel, "OVERLAY", "GameTooltipText")
    _zp_panel_usage_fontStringLine4:SetPoint("BOTTOMLEFT", 10, 20)
    _zp_panel_usage_fontStringLine4:SetText('/zp        "Show addon settings UI"')

    -- Add the panel to the Blizzard Interface/Addons UI
    InterfaceOptions_AddCategory(_zp_panel);

    _zp_isAddonSettingsFrameAdded = true
end

-- Display an achievment message on the screen using the achievement frame, then calls itself using a timer to close itself.
local function _zpSendMessageToScreen(message)
    if message == "" then
        _zp_frame_achievementMessage:Hide()
        _zp_isAchievementBeingDisplayed = false
    else
        _zp_frame_message_fontStringMessageBackground:SetText(message)
        _zp_frame_message_fontStringMessageBackground2:SetText(message)
        _zp_frame_message_fontStringMessageBackground3:SetText(message)
        _zp_frame_message_fontStringMessageBackground4:SetText(message)
        _zp_frame_message_fontStringMessage:SetText(message)
        _zp_frame_achievementMessage:Show()
        _zp_isAchievementBeingDisplayed = true
        C_Timer.After(_zp_const_waitForAchievmentToCompleteInSeconds, function() _zpSendMessageToScreen("") end)
    end
end

-- Display achievments to the console and the screen using the achievement window.
local function _zpDisplayMessageToConsoleAndScreen(achievementType)
    if achievementType == _zp_ACHIEVEMENT_TYPE.DEAD or achievementType == _zp_ACHIEVEMENT_TYPE.FIRSTBLOOD then
        -- Display to the console
        _zpSendMessageToConsole(_zp_table_achievementDisplayText[achievementType])
    else
        -- Display multi kills to the console
        if achievementType == _zp_ACHIEVEMENT_TYPE.DOUBLE or achievementType == _zp_ACHIEVEMENT_TYPE.MULTI or
            achievementType == _zp_ACHIEVEMENT_TYPE.MEGA or achievementType == _zp_ACHIEVEMENT_TYPE.MONSTER or
            achievementType == _zp_ACHIEVEMENT_TYPE.ULTRA or achievementType == _zp_ACHIEVEMENT_TYPE.LUDICROUS or
            achievementType == _zp_ACHIEVEMENT_TYPE.HOLYSHIT then
            _zpSendMessageToConsole("Multi kill: " .. _zp_numberOfConsectutiveMultiKills+1 .. " kills")
        else
            -- Display killing sprees to the console
            _zpSendMessageToConsole("Killing spree: " .. _zp_numberOfPlayerKillsBeforeDeath .. " kills")
        end
    end

    -- Display achievment to the screen using the achievment frame
    _zpSendMessageToScreen(_zp_table_achievementDisplayText[achievementType])
end

-- Function called by an event to reset the achievements frame by closing it.
local function _zpResetFrames()
    _zp_frame_event:Hide()
    _zpSendMessageToScreen("")
end

-- This function processes our achievment queue table
local function _zpProcessAchievementQueue()
    if _zp_isAchievementBeingDisplayed then
        C_Timer.After(_zp_const_waitForAchievmentToCompleteInSeconds, function() _zpProcessAchievementQueue() end)
    end

    if _zpTablelength(_zp_table_achievmentQueue) == 0 then return end

    local achievmentType = _zpTableRemoveIndex(_zp_table_achievmentQueue, 1)
    if achievmentType == nil then return end

    _zpDisplayMessageToConsoleAndScreen(achievmentType)

    local willPlay, soundHandle = PlaySoundFile(_zp_table_achievementAudioFilePath[achievmentType], "SFX")
    if willPlay == false then _zpSendMessageToConsole("Error: Unable to play audio file '" .. _zp_table_achievementAudioFilePath[achievmentType] .. "'") end

    if _zpTablelength(_zp_table_achievmentQueue) > 0 then
        C_Timer.After(_zp_const_waitForAchievmentToCompleteInSeconds, function() _zpProcessAchievementQueue() end)
    end
end

-- Used to add new achievements to the achievement queue table
local function _zpAddAchievementToQueue(achievmentType)
    if achievmentType == nil then return end

    _zpTableInsertValue(_zp_table_achievmentQueue, achievmentType)

    if _zpTablelength(_zp_table_achievmentQueue) == 1 then
        _zpProcessAchievementQueue()
    end
end

-- Function used to award players with a killing spree achievment.
local function _zpProcessSpree()
    if _zp_numberOfPlayerKillsBeforeDeath >= 30 then
        _zpAddAchievementToQueue(_zp_ACHIEVEMENT_TYPE.WICKED)
    elseif _zp_numberOfPlayerKillsBeforeDeath == 25 then
        _zpAddAchievementToQueue(_zp_ACHIEVEMENT_TYPE.GODLIKE)
    elseif _zp_numberOfPlayerKillsBeforeDeath == 20 then
        _zpAddAchievementToQueue(_zp_ACHIEVEMENT_TYPE.UNSTOPPABLE)
    elseif _zp_numberOfPlayerKillsBeforeDeath == 15 then
        _zpAddAchievementToQueue(_zp_ACHIEVEMENT_TYPE.DOMINATING)
    elseif _zp_numberOfPlayerKillsBeforeDeath == 10 then
        _zpAddAchievementToQueue(_zp_ACHIEVEMENT_TYPE.RAMPAGE)
    elseif _zp_numberOfPlayerKillsBeforeDeath == 5 then
        _zpAddAchievementToQueue(_zp_ACHIEVEMENT_TYPE.KILLSPREE)
    end
end

-- Function used to process multikills.
-- Note: This is called by a timer in another method
local function _zpProcessMultiKill(numberOfConsectutiveMultiKills)

    -- These numbers are compared to see if a new multikill achievment is waiting to be processed.
    -- As an example, we do this so to ensure a Monster kill achiement isn't preceeded by announcements
    -- for Mega, Multi, and Double.  We only want the highest achievment to be announced for a single
    -- multikill achievement
    if(numberOfConsectutiveMultiKills ~= _zp_numberOfConsectutiveMultiKills) then return end

    -- Now we can display the achievement to the player
    if _zp_numberOfConsectutiveMultiKills >= 7 then
        _zpAddAchievementToQueue(_zp_ACHIEVEMENT_TYPE.HOLYSHIT)
    elseif _zp_numberOfConsectutiveMultiKills == 6 then
        _zpAddAchievementToQueue(_zp_ACHIEVEMENT_TYPE.LUDICROUS)
    elseif _zp_numberOfConsectutiveMultiKills == 5 then
        _zpAddAchievementToQueue(_zp_ACHIEVEMENT_TYPE.ULTRA)
    elseif _zp_numberOfConsectutiveMultiKills == 4 then
        _zpAddAchievementToQueue(_zp_ACHIEVEMENT_TYPE.MONSTER)
    elseif _zp_numberOfConsectutiveMultiKills == 3 then
        _zpAddAchievementToQueue(_zp_ACHIEVEMENT_TYPE.MEGA)
    elseif _zp_numberOfConsectutiveMultiKills == 2 then
        _zpAddAchievementToQueue(_zp_ACHIEVEMENT_TYPE.MULTI)
    elseif _zp_numberOfConsectutiveMultiKills == 1 then
        _zpAddAchievementToQueue(_zp_ACHIEVEMENT_TYPE.DOUBLE)
    end

    -- Just reseting our multikill counter
    _zp_numberOfConsectutiveMultiKills = 0

end

-- A function to process consective kills. Awards for building up chains of kills in quick succession (4 seconds apart)
local function _zpProcessConsecutiveKill(timeElapsedInSecondsForCurrentKill)
    -- Determine if our new kill is within our timeoue of the previous kill to be considered for multi kill processing
    if timeElapsedInSecondsForCurrentKill - _zp_timeElapsedInSecondsSinceLastKill <= _zp_maxSecondsBetweenConsecutiveKillsForMultiKill then

        -- Increment our multi kill count and use a timer to call our multi kill processing function.
        _zp_numberOfConsectutiveMultiKills = _zp_numberOfConsectutiveMultiKills + 1
        -- We set the timer so the method is called outside the multi kill timeout. This allows a new incoming player kill
        -- inside the multi kill timeout to be considered by the multi kill processing.
        -- Example: If the player gets a double kill, and a second or two later gets a tripple kill (which is inside our multi kill timeout),
        -- we want to announce/display the achievment for the tripple kill instead of the doubel kill.
        C_Timer.After(_zp_const_waitForAchievmentToCompleteInSeconds + 0.1, function() _zpProcessMultiKill(_zp_numberOfConsectutiveMultiKills) end)

    end
end

-- A callback function to handle player death. Reset our player stats and display our player dead achievment :).
local function _zpProcessDeath()
    _zpAddAchievementToQueue(_zp_ACHIEVEMENT_TYPE.DEAD)
    _zpResetPlayer()
end

-- A function to Process a fresh play kill
local function _zpProcessKill()

    local timeElapsedInSecondsForCurrentKill = GetTimePreciseSec()
    _zp_numberOfPlayerKillsBeforeDeath = _zp_numberOfPlayerKillsBeforeDeath + 1

    if _zp_numberOfPlayerKillsBeforeDeath == 1 then
        _zpAddAchievementToQueue(_zp_ACHIEVEMENT_TYPE.FIRSTBLOOD)
    end

    if _zp_numberOfPlayerKillsBeforeDeath >= 2 then _zpProcessConsecutiveKill(timeElapsedInSecondsForCurrentKill) end
    if math.fmod(_zp_numberOfPlayerKillsBeforeDeath, 5) == 0 then _zpProcessSpree() end

    _zp_timeElapsedInSecondsSinceLastKill = timeElapsedInSecondsForCurrentKill

    if _zp_isDebugMode then
        _zpSendMessageToConsole("CK:" .. _zp_numberOfPlayerKillsBeforeDeath .. "|MK:" .. _zp_numberOfConsectutiveMultiKills)
    end

end

-- A function used to process the current combat log event.
local function _zpProcessCombatLogEvent()
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()

    if subevent == nil then return end

    if subevent == "SWING_DAMAGE" or subevent == "SPELL_DAMAGE" then

        if sourceGUID == _zp_playerGUID and destGUID and _zpTableHasValue(_zp_table_inCombatWith, destGUID) == false then
            if _zp_PlayerConfigurableSettingsTable.isProcessPlayerKillsOnly and string.find(destGUID, "^Player-") == nil then return end
            _zpTableInsertValue(_zp_table_inCombatWith, destGUID)
        end

    elseif subevent == "UNIT_DIED" then

        if destGUID and _zpTableHasValue(_zp_table_inCombatWith, destGUID) then
            _zpTableRemoveValue(_zp_table_inCombatWith, destGUID)
            _zpProcessKill()
        end

    end
end

-- Function used to enable/disable debug logging to the console
local function _zpToggleDebugFlag()
    if _zp_isDebugMode then
        _zp_isDebugMode = false
        _zpSendMessageToConsole("DEBUG mode is DISABLED")
    else
        _zp_isDebugMode = true
        _zpSendMessageToConsole("DEBUG mode is ENABLED")
    end
end

-- Function used to send console usage information to the console
local function _zpSendUsageToConsole()
    _zpSendMessageToConsole("Usage ..")
    _zpSendMessageToConsole("/zp reset  'Reset unit kills'")
    _zpSendMessageToConsole("/zp pvp    'Toggle Player ONLY kill mode'")
end

-- Function to register our primary events
local function _zpRegisterPrimaryEvents(registerEvents)
    if _zp_isDebugMode then
        if registerEvents then
            _zpSendMessageToConsole("Listening to primary events")
        else
            _zpSendMessageToConsole("No longer listening to primary events")
        end
    end

    if registerEvents then
        if _zp_frame_event:IsEventRegistered("PLAYER_REGEN_DISABLED") == false then
            _zp_frame_event:RegisterEvent("PLAYER_REGEN_DISABLED")
        end

        if _zp_frame_event:IsEventRegistered("PLAYER_REGEN_ENABLED") == false then
            _zp_frame_event:RegisterEvent("PLAYER_REGEN_ENABLED")
        end

        if _zp_frame_event:IsEventRegistered("PLAYER_ENTERING_BATTLEGROUND") == false then
            _zp_frame_event:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
        end

        if _zp_frame_event:IsEventRegistered("PLAYER_DEAD") == false then
            _zp_frame_event:RegisterEvent("PLAYER_DEAD")
        end
    else
        if _zp_frame_event:IsEventRegistered("PLAYER_REGEN_DISABLED") then
            _zp_frame_event:UnregisterEvent("PLAYER_REGEN_DISABLED")
        end

        if _zp_frame_event:IsEventRegistered("PLAYER_REGEN_ENABLED") then
            _zp_frame_event:UnregisterEvent("PLAYER_REGEN_ENABLED")
        end

        if _zp_frame_event:IsEventRegistered("PLAYER_ENTERING_BATTLEGROUND") then
            _zp_frame_event:UnregisterEvent("PLAYER_ENTERING_BATTLEGROUND")
        end

        if _zp_frame_event:IsEventRegistered("PLAYER_DEAD") then
            _zp_frame_event:UnregisterEvent("PLAYER_DEAD")
        end
    end
end

-- Function to register combat log events
local function _zpRegisterCombatLogEvents(registerEvents)
    if _zp_isDebugMode then 
        if registerEvents then
            _zpSendMessageToConsole("Listening to combat log events")
        else
            _zpSendMessageToConsole("No longer listening to combat log events")
        end
    end

    if registerEvents then
        if _zp_frame_event:IsEventRegistered("COMBAT_LOG_EVENT_UNFILTERED") == false then
            _zp_frame_event:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        end
    else
        if _zp_frame_event:IsEventRegistered("COMBAT_LOG_EVENT_UNFILTERED") then
            _zp_frame_event:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        end
    end
end

-- Function used to process the events registered to our events frame
local function _zpSetEventScript()
    _zp_frame_event:SetScript("OnEvent", function(self, event, ...)
        if(event == nil) then return end

        if event == "PLAYER_ENTERING_WORLD" then
            if _zp_isDebugMode then
                _zpSendMessageToConsole("PLAYER_ENTERING_WORLD fired")
            end
            _zpValidateSavedVariables()
            _zpRegisterPrimaryEvents(true)
            _zpResetPlayer()
            _zpResetFrames()
            _zpAddPlayerConfigSettingsToAddonUI()
        elseif event == "PLAYER_LEAVING_WORLD" then
            if _zp_isDebugMode then
                _zpSendMessageToConsole("PLAYER_LEAVING_WORLD fired")
            end
            _zpRegisterPrimaryEvents(false)
        elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
            if _zp_isDebugMode then
                _zpSendMessageToConsole("COMBAT_LOG_EVENT_UNFILTERED fired")
            end
            _zpProcessCombatLogEvent()
        elseif event == "PLAYER_REGEN_DISABLED" then
            if _zp_isDebugMode then
                _zpSendMessageToConsole("PLAYER_REGEN_DISABLED fired")
            end
            _zpRegisterCombatLogEvents(true)
        elseif event == "PLAYER_REGEN_ENABLED" then
            if _zp_isDebugMode then
                _zpSendMessageToConsole("PLAYER_REGEN_ENABLED fired")
            end
            _zpRegisterCombatLogEvents(false)
            _zp_table_inCombatWith = {}
        elseif (event == "PLAYER_DEAD") then
            if _zp_isDebugMode then
                _zpSendMessageToConsole("PLAYER_DEAD fired")
            end
            _zpProcessDeath()
        elseif (event == "PLAYER_ENTERING_BATTLEGROUND") then
            if _zp_isDebugMode then
                _zpSendMessageToConsole("PLAYER_ENTERING_BATTLEGROUND fired")
            end
            _zpAddAchievementToQueue(_zp_ACHIEVEMENT_TYPE.PREP4BATTLE)
        end
    end)
end

-- Define console slah commands for the addon
SLASH_ZPOWNAGE1 = "/zp"
SLASH_ZPOWNAGE2 = "/zpownage"

SlashCmdList["ZPOWNAGE"] = function(msg)
    -- If debug or reset is added as a param to our slash command, then reset the addon.
    if msg and msg == "debug" then
        _zpToggleDebugFlag()
    elseif msg and msg == "reset" then
        _zpResetPlayer()
    elseif msg and msg == "pvp" then
        _zpTogglePlayerOnlyKillFlag()
    else
        -- Open the WOW Interface/Addon UI
        InterfaceOptionsFrame_Show()
        InterfaceOptionsFrame_OpenToCategory("ZPownage")
    end
end

-- Call this guy to tie event handler functio to our event frame
_zpSetEventScript()

-- Register and our main events with our event frame.
_zp_frame_event:RegisterEvent("PLAYER_ENTERING_WORLD")
_zp_frame_event:RegisterEvent("PLAYER_LEAVING_WORLD")