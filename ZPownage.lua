---- Main config settings
-- The max number of seconds to display a kill achievement on the screen
local _zp_const_waitForAchievementToCompleteInSeconds = 3.0

---- Runtime variables
-- The player GUI used to track kills from the combat logs
local _zp_playerGUID
-- A flag used to track debug logging
local _zp_isDebugMode = false
-- The number of consecutive kills with a death. Is reset after player death.
local _zp_numberOfPlayerKillsBeforeDeath = 0
-- The number of consecutive kills to be considered for multi kill processing.
local _zp_numberOfConsecutiveMultiKills = 0
-- The max number of seconds between consecutive kills for a new kill to be considered for multi kill processing.
local _zp_maxSecondsBetweenConsecutiveKillsForMultiKill = 4
-- Used to determine if recent consecutive kills can be considered for multi kill processing.
local _zp_timeElapsedInSecondsSinceLastKill = 0
-- Used to determine if the achievement window is open of not. This is used to block/delay new achievements while 
-- an existing one is still being displayed.
local _zp_isAchievementBeingDisplayed = false;

-- Add create our event and achievement frames
local _zp_frame_event = ZPownage_CreateEventFrame()
local _zp_frame_achievement, _zpSetAchievementText = ZPownage_CreateAchievementFrame()

-- A function to Reset player kill stats. Called when a player enters a new world zone/instance, or when a player dies.
local function _zpResetPlayer()
    _zp_playerGUID = UnitGUID("player")
    _zp_numberOfPlayerKillsBeforeDeath = 0
    _zp_numberOfConsecutiveMultiKills = 0
    ZPownage_SendMessageToConsole("Kills have been set to zero")
end

-- Display an achievement message on the screen using the achievement frame, then calls itself using a timer to close itself.
local function _zpSendMessageToScreen(message)
    if message == "" then
        _zp_frame_achievement:Hide()
        _zp_isAchievementBeingDisplayed = false
    else
        _zpSetAchievementText(message)
        _zp_frame_achievement:Show()
        _zp_isAchievementBeingDisplayed = true
        C_Timer.After(_zp_const_waitForAchievementToCompleteInSeconds, function() _zpSendMessageToScreen("") end)
    end
end

-- Display achievements to the console and the screen using the achievement window.
local function _zpDisplayMessageToConsoleAndScreen(achievementType)
    if _zp_isDebugMode and (achievementType == ZPownage_ACHIEVEMENT_TYPE.DEAD or achievementType == ZPownage_ACHIEVEMENT_TYPE.FIRSTBLOOD) then
        -- Display to the console
        ZPownage_SendMessageToConsole(ZPownage_table_achievement_displaytext[achievementType])
    else
        -- Display multi kills to the console
        if achievementType == ZPownage_ACHIEVEMENT_TYPE.DOUBLE or achievementType == ZPownage_ACHIEVEMENT_TYPE.MULTI or
            achievementType == ZPownage_ACHIEVEMENT_TYPE.MEGA or achievementType == ZPownage_ACHIEVEMENT_TYPE.MONSTER or
            achievementType == ZPownage_ACHIEVEMENT_TYPE.ULTRA or achievementType == ZPownage_ACHIEVEMENT_TYPE.LUDICROUS or
            achievementType == ZPownage_ACHIEVEMENT_TYPE.HOLYSHIT then
                if _zp_isDebugMode then
                    ZPownage_SendMessageToConsole("Multi Kill: " .. _zp_numberOfConsecutiveMultiKills+1 .. " kills")
                end
                ZPownage_SendMessageToChat("Multi Kill: " .. _zp_numberOfConsecutiveMultiKills+1 .. " kills")
        elseif _zp_isDebugMode then
            -- Display killing sprees to the console
            ZPownage_SendMessageToConsole("Killing Spree: " .. _zp_numberOfPlayerKillsBeforeDeath .. " kills")
        end
    end

    -- Display achievement to the screen using the achievement frame
    _zpSendMessageToScreen(ZPownage_table_achievement_displaytext[achievementType])
end

-- Function called by an event to reset the achievements frame by closing it.
local function _zpResetFrames()
    _zp_frame_event:Hide()
    _zpSendMessageToScreen("")
end

-- This function processes our achievement queue table
local function _zpProcessAchievementQueue()
    if _zp_isAchievementBeingDisplayed then
        C_Timer.After(_zp_const_waitForAchievementToCompleteInSeconds, function() _zpProcessAchievementQueue() end)
    end

    if ZPownage_GetTablelength(ZPownage_table_achievement_queue) == 0 then return end

    local achievementType = ZPownage_RemoveValueFromTableByIndex(ZPownage_table_achievement_queue, 1)
    if achievementType == nil then return end

    _zpDisplayMessageToConsoleAndScreen(achievementType)

    local audioFile

    if ZPownage_table_playersettings.genreType == ZPownage_ACHIEVEMENT_GENRE_TYPE.DUKE then
        audioFile = ZPownage_table_achievement_audiofilepath_duke[achievementType]
    else
        audioFile = ZPownage_table_achievement_audiofilepath_ut[achievementType]
    end

    local willPlay = PlaySoundFile(audioFile, "SFX")

    if willPlay == false then ZPownage_SendMessageToConsole("Error: Unable to play audio file '" .. audioFile .. "'") end

    if ZPownage_GetTablelength(ZPownage_table_achievement_queue) > 0 then
        C_Timer.After(_zp_const_waitForAchievementToCompleteInSeconds, function() _zpProcessAchievementQueue() end)
    end
end

-- Used to add new achievements to the achievement queue table
local function _zpAddAchievementToQueue(achievementType)
    if achievementType == nil then return end

    ZPownage_InsertValueIntoTable(ZPownage_table_achievement_queue, achievementType)

    if ZPownage_GetTablelength(ZPownage_table_achievement_queue) == 1 then
        _zpProcessAchievementQueue()
    end
end

-- Function used to award players with a killing spree achievement.
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
local function _zpProcessMultiKill(numberOfConsecutiveMultiKills)

    -- These numbers are compared to see if a new multikill achievement is waiting to be processed.
    -- As an example, we do this so to ensure a Monster kill achievement isn't preceded by announcements
    -- for Mega, Multi, and Double.  We only want the highest achievement to be announced for a single
    -- multikill achievement
    if(numberOfConsecutiveMultiKills ~= _zp_numberOfConsecutiveMultiKills) then return end

    -- Now we can display the achievement to the player
    if _zp_numberOfConsecutiveMultiKills >= 7 then
        _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.HOLYSHIT)
    elseif _zp_numberOfConsecutiveMultiKills == 6 then
        _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.LUDICROUS)
    elseif _zp_numberOfConsecutiveMultiKills == 5 then
        _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.ULTRA)
    elseif _zp_numberOfConsecutiveMultiKills == 4 then
        _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.MONSTER)
    elseif _zp_numberOfConsecutiveMultiKills == 3 then
        _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.MEGA)
    elseif _zp_numberOfConsecutiveMultiKills == 2 then
        _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.MULTI)
    elseif _zp_numberOfConsecutiveMultiKills == 1 then
        _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.DOUBLE)
    end

    -- Just resetting our multikill counter
    _zp_numberOfConsecutiveMultiKills = 0

end

-- A function to process consecutive kills. Awards for building up chains of kills in quick succession (4 seconds apart)
local function _zpProcessConsecutiveKill(timeElapsedInSecondsForCurrentKill)
    -- Determine if our new kill is within our timeoue of the previous kill to be considered for multi kill processing
    if timeElapsedInSecondsForCurrentKill - _zp_timeElapsedInSecondsSinceLastKill <= _zp_maxSecondsBetweenConsecutiveKillsForMultiKill then

        -- Increment our multi kill count and use a timer to call our multi kill processing function.
        _zp_numberOfConsecutiveMultiKills = _zp_numberOfConsecutiveMultiKills + 1
        -- We set the timer so the method is called outside the multi kill timeout. This allows a new incoming player kill
        -- inside the multi kill timeout to be considered by the multi kill processing.
        -- Example: If the player gets a double kill, and a second or two later gets a triple kill (which is inside our multi kill timeout),
        -- we want to announce/display the achievement for the triple kill instead of the double kill.
        C_Timer.After(_zp_const_waitForAchievementToCompleteInSeconds + 0.1, function() _zpProcessMultiKill(_zp_numberOfConsecutiveMultiKills) end)

    end
end

-- A callback function to handle player death. Reset our player stats and display our player dead achievement :).
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
        ZPownage_SendMessageToConsole("CK:" .. _zp_numberOfPlayerKillsBeforeDeath .. "|MK:" .. _zp_numberOfConsecutiveMultiKills)
    end

end

-- A function used to process the current combat log event.
local function _zpProcessCombatLogEvent(...)

    --[[
     If the player has enabled player only kill mode, then we want to check if the player is in a battleground
     or arena before processing the kill. If the player is not in a battleground or arena, then we want to 
     ignore the kill.
     ]]
    if ZPownage_table_playersettings.isProcessPlayerKillsOnly then
        local name, instanceType = GetInstanceInfo()
        if not (instanceType == "pvp" or instanceType == "arena") then
            return
        end
    end

    local attackerGUID, targetGUID = ...

    --[[
     The above parameters are passed by the PARTY_KILL event. We can use these to determine the source and target of the kill.
     When doing solo content, the parameters seem to work even when in combat. Unfortunately, when in a party and in combat, 
     these parameters become secret, and throw an error when you try to access them. So for now, we are just going to process kills 
     from the PARTY_KILL event without trying to determine the source and target of the kill. This means we will process all kills 
     that the player is involved in, even if they are not the killer.

     issecretvalue(value) and canaccessvalue(value) are used to determine if the parameters passed by the PARTY_KILL event are accessible or not.
     When in combat and in a party, these parameters become secret and throw an error when you try to access them. So, we use these functions to 
     check if we can access the parameters before trying to access them.
    ]]

    -- Using this for testing purposes. I want to see when this param is available.
    if _zp_isDebugMode and canaccessvalue(attackerGUID) and attackerGUID == _zp_playerGUID then
            ZPownage_SendMessageToConsole("Player GUID: " .. tostring(attackerGUID) .. " got the kill!")
    end

    _zpProcessKill()
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
        if _zp_frame_event:IsEventRegistered("PARTY_KILL") == false then
            _zp_frame_event:RegisterEvent("PARTY_KILL")
        end

        if _zp_frame_event:IsEventRegistered("PLAYER_DEAD") == false then
            _zp_frame_event:RegisterEvent("PLAYER_DEAD")
        end
    else
        if _zp_frame_event:IsEventRegistered("PARTY_KILL") then
            _zp_frame_event:UnregisterEvent("PARTY_KILL")
        end

        if _zp_frame_event:IsEventRegistered("PLAYER_DEAD") then
            _zp_frame_event:UnregisterEvent("PLAYER_DEAD")
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
        elseif (event == "PLAYER_ENTERING_BATTLEGROUND") then
            if _zp_isDebugMode then
                ZPownage_SendMessageToConsole("PLAYER_ENTERING_BATTLEGROUND fired")
            end
            _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.PREP4BATTLE)
        elseif (event == "PARTY_KILL") then
            if _zp_isDebugMode then
                ZPownage_SendMessageToConsole("PARTY_KILL fired")
            end
            _zpProcessCombatLogEvent(...)
        elseif (event == "PLAYER_DEAD") then
            if _zp_isDebugMode then
                ZPownage_SendMessageToConsole("PLAYER_DEAD fired")
            end
            _zpProcessDeath()
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
        Settings.OpenToCategory(ZPownage_Settings_UPanel_ID)
    end
end

-- Call this guy to tie event handler function to our event frame
_zpSetFrameEventScript()

-- Register and our main events with our event frame.
_zp_frame_event:RegisterEvent("PLAYER_ENTERING_WORLD")
_zp_frame_event:RegisterEvent("PLAYER_LEAVING_WORLD")
