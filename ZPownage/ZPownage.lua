---- Main config settings
-- The max number of seconds to display a kill achievement on the screen
local _zp_const_waitForAchievmentToCompleteInSeconds = 3.0

---- Runtime variables
-- The player GUI used to track kills from the combat logs
local _zp_playerGUID
-- A flag used to track debug logging
local _zp_isDebugMode = false
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

-- Add create our event and achievement frames
local _zp_frame_event = ZPownage_CreateEventFrame()
local _zp_frame_achievement, _zpSetAchievementText = ZPownage_CreateAchievmentFrame()

-- A function to Reset player kill stats. Called when a player enters a new world zone/instance, or when a player dies.
local function _zpResetPlayer()
    _zp_playerGUID = UnitGUID("player")
    _zp_numberOfPlayerKillsBeforeDeath = 0
    _zp_numberOfConsectutiveMultiKills = 0
    ZPownage_table_incombatwith = {}
    ZPownage_SendMessageToConsole("Player kills have been set to zero")
end

-- Display an achievment message on the screen using the achievement frame, then calls itself using a timer to close itself.
local function _zpSendMessageToScreen(message)
    if message == "" then
        _zp_frame_achievement:Hide()
        _zp_isAchievementBeingDisplayed = false
    else
        _zpSetAchievementText(message)
        _zp_frame_achievement:Show()
        _zp_isAchievementBeingDisplayed = true
        C_Timer.After(_zp_const_waitForAchievmentToCompleteInSeconds, function() _zpSendMessageToScreen("") end)
    end
end

-- Display achievments to the console and the screen using the achievement window.
local function _zpDisplayMessageToConsoleAndScreen(achievementType)
    if achievementType == ZPownage_ACHIEVEMENT_TYPE.DEAD or achievementType == ZPownage_ACHIEVEMENT_TYPE.FIRSTBLOOD then
        -- Display to the console
        ZPownage_SendMessageToConsole(ZPownage_table_achievement_displaytext[achievementType])
    else
        -- Display multi kills to the console
        if achievementType == ZPownage_ACHIEVEMENT_TYPE.DOUBLE or achievementType == ZPownage_ACHIEVEMENT_TYPE.MULTI or
            achievementType == ZPownage_ACHIEVEMENT_TYPE.MEGA or achievementType == ZPownage_ACHIEVEMENT_TYPE.MONSTER or
            achievementType == ZPownage_ACHIEVEMENT_TYPE.ULTRA or achievementType == ZPownage_ACHIEVEMENT_TYPE.LUDICROUS or
            achievementType == ZPownage_ACHIEVEMENT_TYPE.HOLYSHIT then
                ZPownage_SendMessageToConsole("Multi Kill: " .. _zp_numberOfConsectutiveMultiKills+1 .. " kills")
                ZPownage_SendMessageToChat("Multi Kill: " .. _zp_numberOfConsectutiveMultiKills+1 .. " kills")
        else
            -- Display killing sprees to the console
            ZPownage_SendMessageToConsole("Killing Spree: " .. _zp_numberOfPlayerKillsBeforeDeath .. " kills")
        end
    end

    -- Display achievment to the screen using the achievment frame
    _zpSendMessageToScreen(ZPownage_table_achievement_displaytext[achievementType])
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

    if ZPownage_GetTablelength(ZPownage_table_achievment_queue) == 0 then return end

    local achievmentType = ZPownage_RemoveValueFromTableByIndex(ZPownage_table_achievment_queue, 1)
    if achievmentType == nil then return end

    _zpDisplayMessageToConsoleAndScreen(achievmentType)

    local audioFile

    if ZPownage_table_playersettings.genreType == ZPownage_ACHIEVEMENT_GENRE_TYPE.DUKE then
        audioFile = ZPownage_table_achievement_audiofilepath_duke[achievmentType]
    else
        audioFile = ZPownage_table_achievement_audiofilepath_ut[achievmentType]
    end

    local willPlay = PlaySoundFile(audioFile, "SFX")

    if willPlay == false then ZPownage_SendMessageToConsole("Error: Unable to play audio file '" .. audioFile .. "'") end

    if ZPownage_GetTablelength(ZPownage_table_achievment_queue) > 0 then
        C_Timer.After(_zp_const_waitForAchievmentToCompleteInSeconds, function() _zpProcessAchievementQueue() end)
    end
end

-- Used to add new achievements to the achievement queue table
local function _zpAddAchievementToQueue(achievmentType)
    if achievmentType == nil then return end

    ZPownage_InsertValueIntoTable(ZPownage_table_achievment_queue, achievmentType)

    if ZPownage_GetTablelength(ZPownage_table_achievment_queue) == 1 then
        _zpProcessAchievementQueue()
    end
end

-- Function used to award players with a killing spree achievment.
local function _zpProcessSpree()
    if _zp_numberOfPlayerKillsBeforeDeath >= 30 then
        _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.WICKED)
    elseif _zp_numberOfPlayerKillsBeforeDeath == 25 then
        _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.GODLIKE)
    elseif _zp_numberOfPlayerKillsBeforeDeath == 20 then
        _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.UNSTOPPABLE)
    elseif _zp_numberOfPlayerKillsBeforeDeath == 15 then
        _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.DOMINATING)
    elseif _zp_numberOfPlayerKillsBeforeDeath == 10 then
        _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.RAMPAGE)
    elseif _zp_numberOfPlayerKillsBeforeDeath == 5 then
        _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.KILLSPREE)
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
        _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.HOLYSHIT)
    elseif _zp_numberOfConsectutiveMultiKills == 6 then
        _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.LUDICROUS)
    elseif _zp_numberOfConsectutiveMultiKills == 5 then
        _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.ULTRA)
    elseif _zp_numberOfConsectutiveMultiKills == 4 then
        _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.MONSTER)
    elseif _zp_numberOfConsectutiveMultiKills == 3 then
        _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.MEGA)
    elseif _zp_numberOfConsectutiveMultiKills == 2 then
        _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.MULTI)
    elseif _zp_numberOfConsectutiveMultiKills == 1 then
        _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.DOUBLE)
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
    _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.DEAD)
    _zpResetPlayer()
end

-- A function to Process a fresh play kill
local function _zpProcessKill()

    local timeElapsedInSecondsForCurrentKill = GetTimePreciseSec()
    _zp_numberOfPlayerKillsBeforeDeath = _zp_numberOfPlayerKillsBeforeDeath + 1

    if _zp_numberOfPlayerKillsBeforeDeath == 1 then
        _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.FIRSTBLOOD)
    end

    if _zp_numberOfPlayerKillsBeforeDeath >= 2 then _zpProcessConsecutiveKill(timeElapsedInSecondsForCurrentKill) end
    if math.fmod(_zp_numberOfPlayerKillsBeforeDeath, 5) == 0 then _zpProcessSpree() end

    _zp_timeElapsedInSecondsSinceLastKill = timeElapsedInSecondsForCurrentKill

    if _zp_isDebugMode then
        ZPownage_SendMessageToConsole("CK:" .. _zp_numberOfPlayerKillsBeforeDeath .. "|MK:" .. _zp_numberOfConsectutiveMultiKills)
    end

end

-- A function used to process the current combat log event.
local function _zpProcessCombatLogEvent()
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()

    if subevent == nil then return end

    if subevent == "SWING_DAMAGE" or subevent == "SPELL_DAMAGE" then

        if sourceGUID == _zp_playerGUID and destGUID and ZPownage_TableHasValue(ZPownage_table_incombatwith, destGUID) == false then
            if ZPownage_table_playersettings.isProcessPlayerKillsOnly and string.find(destGUID, "^Player-") == nil then return end
            ZPownage_InsertValueIntoTable(ZPownage_table_incombatwith, destGUID)
        end

    elseif subevent == "UNIT_DIED" then

        if destGUID and ZPownage_TableHasValue(ZPownage_table_incombatwith, destGUID) then
            ZPownage_RemoveValueFromTableByValue(ZPownage_table_incombatwith, destGUID)
            _zpProcessKill()
        end

    end
end

-- Function used to enable/disable debug logging to the console
local function _zpToggleDebugFlag()
    if _zp_isDebugMode then
        _zp_isDebugMode = false
        ZPownage_SendMessageToConsole("DEBUG mode is DISABLED")
    else
        _zp_isDebugMode = true
        ZPownage_SendMessageToConsole("DEBUG mode is ENABLED")
    end
end

-- Function to register our primary events
local function _zpRegisterPrimaryEvents(registerEvents)
    if _zp_isDebugMode then
        if registerEvents then
            ZPownage_SendMessageToConsole("Listening to primary events")
        else
            ZPownage_SendMessageToConsole("No longer listening to primary events")
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
            ZPownage_SendMessageToConsole("Listening to combat log events")
        else
            ZPownage_SendMessageToConsole("No longer listening to combat log events")
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
local function _zpSetFrameEventScript()
    _zp_frame_event:SetScript("OnEvent", function(self, event, ...)
        if(event == nil) then return end

        if event == "PLAYER_ENTERING_WORLD" then
            if _zp_isDebugMode then
                ZPownage_SendMessageToConsole("PLAYER_ENTERING_WORLD fired")
            end
            ZPownage_InitializeSavedVariables()
            _zpRegisterPrimaryEvents(true)
            _zpResetPlayer()
            _zpResetFrames()
            ZPownage_CreatePlayerConfigSettingsUI(_zpAddAchievementToQueue, _zpResetPlayer)
        elseif event == "PLAYER_LEAVING_WORLD" then
            if _zp_isDebugMode then
                ZPownage_SendMessageToConsole("PLAYER_LEAVING_WORLD fired")
            end
            _zpRegisterPrimaryEvents(false)
        elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
            if _zp_isDebugMode then
                ZPownage_SendMessageToConsole("COMBAT_LOG_EVENT_UNFILTERED fired")
            end
            _zpProcessCombatLogEvent()
        elseif event == "PLAYER_REGEN_DISABLED" then
            if _zp_isDebugMode then
                ZPownage_SendMessageToConsole("PLAYER_REGEN_DISABLED fired")
            end
            _zpRegisterCombatLogEvents(true)
        elseif event == "PLAYER_REGEN_ENABLED" then
            if _zp_isDebugMode then
                ZPownage_SendMessageToConsole("PLAYER_REGEN_ENABLED fired")
            end
            _zpRegisterCombatLogEvents(false)
            ZPownage_table_incombatwith = {}
        elseif (event == "PLAYER_DEAD") then
            if _zp_isDebugMode then
                ZPownage_SendMessageToConsole("PLAYER_DEAD fired")
            end
            _zpProcessDeath()
        elseif (event == "PLAYER_ENTERING_BATTLEGROUND") then
            if _zp_isDebugMode then
                ZPownage_SendMessageToConsole("PLAYER_ENTERING_BATTLEGROUND fired")
            end
            _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.PREP4BATTLE)
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
        ZPownage_TogglePlayerOnlyKillFlag()
    elseif msg and msg == "test" then
        _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.DOUBLE)
    else
        ZPownage_SendUsageToConsole()
        -- Open the WOW Interface/Addon UI
        InterfaceOptionsFrame_Show()
        InterfaceOptionsFrame_OpenToCategory("ZPownage")
    end
end

-- Call this guy to tie event handler functio to our event frame
_zpSetFrameEventScript()

-- Register and our main events with our event frame.
_zp_frame_event:RegisterEvent("PLAYER_ENTERING_WORLD")
_zp_frame_event:RegisterEvent("PLAYER_LEAVING_WORLD")
