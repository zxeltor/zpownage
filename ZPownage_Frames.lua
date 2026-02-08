---- Define various UI frames used by this addon.
-- This frame is used to process events fired off by the game. It's never displayed to the user.

ZPownage_Settings_UPanel_ID = 0;

function ZPownage_CreateEventFrame()
    local _zp_frame_event = CreateFrame("Frame", "_zpEventFrame")
    _zp_frame_event:Hide()
    return _zp_frame_event
end

function ZPownage_CreateAchievementFrame()
   -- The achievement frame. It's used to flash achievement messages to the screen.
    local _zp_frame_achievementMessage = CreateFrame("Frame", "_zpAchievementFrame", UIParent)
    _zp_frame_achievementMessage:SetFrameStrata("BACKGROUND")
    _zp_frame_achievementMessage:SetWidth(256)
    _zp_frame_achievementMessage:SetHeight(64)
    _zp_frame_achievementMessage:SetPoint("CENTER", 0, 250)
    
    -- Adding 4 background font strings (offset from the main font srting) using the same text as the main font string. This provide a background/border effect.
    local _zp_frame_message_fontStringMessageBackground = _zp_frame_achievementMessage:CreateFontString("_zp_frame_message_fontStringMessageBackground", "OVERLAY", "GameFontNormal")
    _zp_frame_message_fontStringMessageBackground:SetTextHeight(36)
    _zp_frame_message_fontStringMessageBackground:SetTextColor(0, 0, 0, 1)
    _zp_frame_message_fontStringMessageBackground:SetPoint("CENTER", 3, 3)
    
    local _zp_frame_message_fontStringMessageBackground2 = _zp_frame_achievementMessage:CreateFontString("_zp_frame_message_fontStringMessageBackground2", "OVERLAY", "GameFontNormal")
    _zp_frame_message_fontStringMessageBackground2:SetTextHeight(36)
    _zp_frame_message_fontStringMessageBackground2:SetTextColor(0, 0, 0, 1)
    _zp_frame_message_fontStringMessageBackground2:SetPoint("CENTER", 3, -3)
    
    local _zp_frame_message_fontStringMessageBackground3 = _zp_frame_achievementMessage:CreateFontString("_zp_frame_message_fontStringMessageBackground3", "OVERLAY", "GameFontNormal")
    _zp_frame_message_fontStringMessageBackground3:SetTextHeight(36)
    _zp_frame_message_fontStringMessageBackground3:SetTextColor(0, 0, 0, 1)
    _zp_frame_message_fontStringMessageBackground3:SetPoint("CENTER", -3, 3)
    
    local _zp_frame_message_fontStringMessageBackground4 = _zp_frame_achievementMessage:CreateFontString("_zp_frame_message_fontStringMessageBackground4", "OVERLAY", "GameFontNormal")
    _zp_frame_message_fontStringMessageBackground4:SetTextHeight(36)
    _zp_frame_message_fontStringMessageBackground4:SetTextColor(0, 0, 0, 1)
    _zp_frame_message_fontStringMessageBackground4:SetPoint("CENTER", -3, -3)
    
    -- The main font string to display our achievement text
    local _zp_frame_message_fontStringMessage = _zp_frame_achievementMessage:CreateFontString("_zp_frame_message_fontStringMessage", "OVERLAY", "GameFontNormal")
    _zp_frame_message_fontStringMessage:SetTextHeight(36)
    _zp_frame_message_fontStringMessage:SetTextColor(0, 1, 0, 1)
    _zp_frame_message_fontStringMessage:SetPoint("CENTER", 0, 0)
    _zp_frame_message_fontStringMessage:SetText("ZPownage Achievement Message")
    _zp_frame_achievementMessage:Hide()

    return _zp_frame_achievementMessage,
        function(message)
            _zp_frame_message_fontStringMessageBackground:SetText(message)
            _zp_frame_message_fontStringMessageBackground2:SetText(message)
            _zp_frame_message_fontStringMessageBackground3:SetText(message)
            _zp_frame_message_fontStringMessageBackground4:SetText(message)
            _zp_frame_message_fontStringMessage:SetText(message)
        end
end

local _zp_isAddonSettingsFrameAdded = false

-- Function used to add addon settings for Zpownage in the Blizzard addon UI (Interface/Addons)
function ZPownage_CreatePlayerConfigSettingsUI(_zpAddAchievementToQueue, _zpResetPlayer)

    if _zp_isAddonSettingsFrameAdded then return end

    local _zp_panel = CreateFrame( "Frame", "_zp_panel", UIParent);
     -- Register in the Interface Addon Options GUI
    -- Set the name for the Category for the Options Panel
    _zp_panel.name = "ZPownage";

    local _zp_panel_title_fontStringMessageBackground = _zp_panel:CreateFontString("_zp_panel_title_fontStringMessageBackground", "OVERLAY", "GameFontNormal")
    _zp_panel_title_fontStringMessageBackground:SetTextHeight(36)
    _zp_panel_title_fontStringMessageBackground:SetTextColor(0, 0, 0, 1)
    _zp_panel_title_fontStringMessageBackground:SetPoint("TOP", 3, -17)
    _zp_panel_title_fontStringMessageBackground:SetText("ZPownage")

    local _zp_panel_title_fontStringMessageBackground2 = _zp_panel:CreateFontString("_zp_panel_title_fontStringMessageBackground2", "OVERLAY", "GameFontNormal")
    _zp_panel_title_fontStringMessageBackground2:SetTextHeight(36)
    _zp_panel_title_fontStringMessageBackground2:SetTextColor(0, 0, 0, 1)
    _zp_panel_title_fontStringMessageBackground2:SetPoint("TOP", 3, -23)
    _zp_panel_title_fontStringMessageBackground2:SetText("ZPownage")

    local _zp_panel_title_fontStringMessageBackground3 = _zp_panel:CreateFontString("_zp_panel_title_fontStringMessageBackground3", "OVERLAY", "GameFontNormal")
    _zp_panel_title_fontStringMessageBackground3:SetTextHeight(36)
    _zp_panel_title_fontStringMessageBackground3:SetTextColor(0, 0, 0, 1)
    _zp_panel_title_fontStringMessageBackground3:SetPoint("TOP", -3, -17)
    _zp_panel_title_fontStringMessageBackground3:SetText("ZPownage")

    local _zp_panel_title_fontStringMessageBackground4 = _zp_panel:CreateFontString("_zp_panel_title_fontStringMessageBackground4", "OVERLAY", "GameFontNormal")
    _zp_panel_title_fontStringMessageBackground4:SetTextHeight(36)
    _zp_panel_title_fontStringMessageBackground4:SetTextColor(0, 0, 0, 1)
    _zp_panel_title_fontStringMessageBackground4:SetPoint("TOP", -3, -23)
    _zp_panel_title_fontStringMessageBackground4:SetText("ZPownage")

    local _zp_panel_title_fontStringMessage = _zp_panel:CreateFontString("_zp_panel_title_fontStringMessage", "OVERLAY", "GameFontNormal")
    _zp_panel_title_fontStringMessage:SetTextHeight(36)
    _zp_panel_title_fontStringMessage:SetTextColor(0, 1, 0, 1)
    _zp_panel_title_fontStringMessage:SetPoint("TOP", 0, -20)
    _zp_panel_title_fontStringMessage:SetText("ZPownage")

    local _zp_myCheckButtonPvpOnly = CreateFrame("CheckButton", "_zp_myCheckButtonPvpOnly", _zp_panel, "UICheckButtonTemplate")
    _zp_myCheckButtonPvpOnly:SetPoint("TOPLEFT", 10, -50)
    _zp_myCheckButtonPvpOnly:SetChecked(ZPownage_table_playersettings.isProcessPlayerKillsOnly)
    _G[_zp_myCheckButtonPvpOnly:GetName().."Text"]:SetText("Enable Battleground/Arena Only Mode")
    _zp_myCheckButtonPvpOnly:SetScript("OnClick", function(self, button, down)
        ZPownage_TogglePlayerOnlyKillFlag()
    end)

    local _zp_myButtonReset = CreateFrame("Button", "_zp_myButtonReset", _zp_panel, "UIPanelButtonTemplate")
    _zp_myButtonReset:SetPoint("TOPLEFT", 10, -80)
    _zp_myButtonReset:SetSize(80, 34)
    _zp_myButtonReset:SetText("Reset Kills")
    _zp_myButtonReset:SetScript("OnClick", function(self, button, down) _zpResetPlayer() end)

    local _zp_myButtonTest = CreateFrame("Button", "_zp_myButtonTest", _zp_panel, "UIPanelButtonTemplate")
    _zp_myButtonTest:SetPoint("TOPLEFT", 120, -80)
    _zp_myButtonTest:SetSize(50, 34)
    _zp_myButtonTest:SetText("Test")
    _zp_myButtonTest:SetScript("OnClick", function(self, button, down) _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.DOUBLE) end)

    local _zp_panel_fontString_audioGenreLabel = _zp_panel:CreateFontString("_zp_panel_fontString_audioGenreLabel", "OVERLAY", "GameTooltipText")
    _zp_panel_fontString_audioGenreLabel:SetPoint("TOPLEFT", 315, -92)
    if ZPownage_table_playersettings.genreType == ZPownage_ACHIEVEMENT_GENRE_TYPE.UT then
        _zp_panel_fontString_audioGenreLabel:SetText("Unreal Tournament")
    elseif ZPownage_table_playersettings.genreType == ZPownage_ACHIEVEMENT_GENRE_TYPE.DUKE then
        _zp_panel_fontString_audioGenreLabel:SetText("Duke Nukem")
    end

    local _zp_myButtonSwitchGenre = CreateFrame("Button", "_zp_myButtonSwitchGenre", _zp_panel, "UIPanelButtonTemplate")
    _zp_myButtonSwitchGenre:SetPoint("TOPLEFT", 200, -80)
    _zp_myButtonSwitchGenre:SetSize(100, 34)
    _zp_myButtonSwitchGenre:SetText("Switch Audio")
    _zp_myButtonSwitchGenre:SetScript("OnClick", function(self, button, down)
        if ZPownage_table_playersettings.genreType == ZPownage_ACHIEVEMENT_GENRE_TYPE.UT then
            ZPownage_table_playersettings.genreType = ZPownage_ACHIEVEMENT_GENRE_TYPE.DUKE
            _zp_panel_fontString_audioGenreLabel:SetText("Duke Nukem")
        else
            ZPownage_table_playersettings.genreType = ZPownage_ACHIEVEMENT_GENRE_TYPE.UT
            _zp_panel_fontString_audioGenreLabel:SetText("Unreal Tournament")
        end
        _zpAddAchievementToQueue(ZPownage_ACHIEVEMENT_TYPE.KILLSPREE)
    end)

    -- Bragging panel

    local _zp_frame_bragpanel = CreateFrame( "Frame", "_zp_frame_bragpanel", _zp_panel, "InsetFrameTemplate");
    _zp_frame_bragpanel:SetPoint("TOPLEFT", 10, -140)
    _zp_frame_bragpanel:SetSize(100, 40)

    local _zp_panel_bragpanel_title_fontString = _zp_frame_bragpanel:CreateFontString("_zp_panel_bragpanel_title_fontString", "OVERLAY", "GameFontNormal")
    _zp_panel_bragpanel_title_fontString:SetPoint("TOPLEFT", 2, 14)
    _zp_panel_bragpanel_title_fontString:SetText("Auto-Brag: (Multi-Kills only)")

    local _zp_myCheckButtonBragEmote = CreateFrame("CheckButton", "_zp_myCheckButtonBragEmote", _zp_frame_bragpanel, "UICheckButtonTemplate")
    _zp_myCheckButtonBragEmote:SetPoint("TOPLEFT", 10, -4)
    _zp_myCheckButtonBragEmote:SetChecked(ZPownage_table_playersettings.bragEmote)
    _G[_zp_myCheckButtonBragEmote:GetName().."Text"]:SetText("Emote")
    _zp_myCheckButtonBragEmote:SetScript("OnClick", function(self, button, down) 
        _zp_myCheckButtonBragEmote:GetChecked()
        ZPownage_table_playersettings.bragEmote = _zp_myCheckButtonBragEmote:GetChecked()
    end)

    -- Usage panel

    local _zp_frame_usage_panel = CreateFrame( "Frame", "_zp_frame_usage_panel", _zp_panel, "InsetFrameTemplate");
    _zp_frame_usage_panel:SetPoint("TOPLEFT", 10, -205)
    _zp_frame_usage_panel:SetSize(550, 80)

    local _zp_frame_usage_panel_rightcolumn = CreateFrame( "Frame", "_zp_frame_usage_panel_rightcolumn", _zp_frame_usage_panel);
    _zp_frame_usage_panel_rightcolumn:SetPoint("TOPLEFT", 80, 0)
    _zp_frame_usage_panel_rightcolumn:SetSize(520, 80)

    local _zp_panel_usagepanel_title_fontString = _zp_frame_usage_panel:CreateFontString("_zp_panel_usagepanel_title_fontString", "OVERLAY", "GameFontNormal")
    _zp_panel_usagepanel_title_fontString:SetPoint("TOPLEFT", 2, 14)
    _zp_panel_usagepanel_title_fontString:SetText("Slash Commands:")

    local _zp_panel_usage_fontStringLineReset = _zp_frame_usage_panel:CreateFontString("_zp_panel_usage_fontStringLineReset", "OVERLAY", "GameFontNormal")
    _zp_panel_usage_fontStringLineReset:SetPoint("TOPLEFT", 10, -10)
    _zp_panel_usage_fontStringLineReset:SetText('/zp reset')
    local _zp_panel_usage_fontStringLinePvp = _zp_frame_usage_panel:CreateFontString("_zp_panel_usage_fontStringLinePvp", "OVERLAY", "GameFontNormal")
    _zp_panel_usage_fontStringLinePvp:SetPoint("TOPLEFT", 10, -25)
    _zp_panel_usage_fontStringLinePvp:SetText('/zp pvp')
    local _zp_panel_usage_fontStringLineTest = _zp_frame_usage_panel:CreateFontString("_zp_panel_usage_fontStringLineTest", "OVERLAY", "GameFontNormal")
    _zp_panel_usage_fontStringLineTest:SetPoint("TOPLEFT", 10, -40)
    _zp_panel_usage_fontStringLineTest:SetText('/zp test')
    local _zp_panel_usage_fontStringLineUi = _zp_frame_usage_panel:CreateFontString("_zp_panel_usage_fontStringLineUi", "OVERLAY", "GameFontNormal")
    _zp_panel_usage_fontStringLineUi:SetPoint("TOPLEFT", 10, -55)
    _zp_panel_usage_fontStringLineUi:SetText('/zp')

    local _zp_panel_usage_fontStringLineResetDetails = _zp_frame_usage_panel_rightcolumn:CreateFontString("_zp_panel_usage_fontStringLineResetDetails", "OVERLAY", "GameTooltipText")
    _zp_panel_usage_fontStringLineResetDetails:SetPoint("TOPLEFT", 0, -10)
    _zp_panel_usage_fontStringLineResetDetails:SetText('"Reset kill count."')
    local _zp_panel_usage_fontStringLinePvpDetails = _zp_frame_usage_panel_rightcolumn:CreateFontString("_zp_panel_usage_fontStringLinePvpDetails", "OVERLAY", "GameTooltipText")
    _zp_panel_usage_fontStringLinePvpDetails:SetPoint("TOPLEFT", 0, -25)
    _zp_panel_usage_fontStringLinePvpDetails:SetText('"Toggle Arena/Battleground only kill mode. If disabled, it tracks all kills."')
    local _zp_panel_usage_fontStringLineTestDetails = _zp_frame_usage_panel_rightcolumn:CreateFontString("_zp_panel_usage_fontStringLineTestDetails", "OVERLAY", "GameTooltipText")
    _zp_panel_usage_fontStringLineTestDetails:SetPoint("TOPLEFT", 0, -40)
    _zp_panel_usage_fontStringLineTestDetails:SetText('"Test achievement display and audio playback."')
    local _zp_panel_usage_fontStringLineUiDetails = _zp_frame_usage_panel_rightcolumn:CreateFontString("_zp_panel_usage_fontStringLineUiDetails", "OVERLAY", "GameTooltipText")
    _zp_panel_usage_fontStringLineUiDetails:SetPoint("TOPLEFT", 0, -55)
    _zp_panel_usage_fontStringLineUiDetails:SetText('"Show addon settings UI and usage."')

    -- Notes panel

    local _zp_frame_notes_panel = CreateFrame( "Frame", "_zp_frame_notes_panel", _zp_panel, "InsetFrameTemplate");
    _zp_frame_notes_panel:SetPoint("TOPLEFT", 10, -315)
    _zp_frame_notes_panel:SetSize(550, 100)

    local _zp_frame_notes_panel_rightcolumn = CreateFrame( "Frame", "_zp_frame_notes_panel_rightcolumn", _zp_frame_notes_panel);
    _zp_frame_notes_panel_rightcolumn:SetPoint("TOPLEFT", 80, 0)
    _zp_frame_notes_panel_rightcolumn:SetSize(520, 90)

    local _zp_frame_notes_panel_title_fontString = _zp_frame_notes_panel:CreateFontString("_zp_frame_notes_panel_title_fontString", "OVERLAY", "GameFontNormal")
    _zp_frame_notes_panel_title_fontString:SetPoint("TOPLEFT", 2, 14)
    _zp_frame_notes_panel_title_fontString:SetText("Notes:")

    local _zp_panel_notes_fontStringLine1 = _zp_frame_notes_panel:CreateFontString("_zp_panel_notes_fontStringLine1", "OVERLAY", "GameTooltipText")
    _zp_panel_notes_fontStringLine1:SetPoint("TOPLEFT", 10, -10)
    _zp_panel_notes_fontStringLine1:SetText('World of Warcraft: Midnight (v12.+) has brought about several changes to this addon.')
    
    local _zp_panel_notes_fontStringLine2 = _zp_frame_notes_panel:CreateFontString("_zp_panel_notes_fontStringLine2", "OVERLAY", "GameTooltipText")
    _zp_panel_notes_fontStringLine2:SetPoint("TOPLEFT", 10, -30)
    _zp_panel_notes_fontStringLine2:SetText('Due to new combat restrictions placed on the WOW API, this addon can no longer track')

    local _zp_panel_notes_fontStringLine3 = _zp_frame_notes_panel:CreateFontString("_zp_panel_notes_fontStringLine3", "OVERLAY", "GameTooltipText")
    _zp_panel_notes_fontStringLine3:SetPoint("TOPLEFT", 10, -45)
    _zp_panel_notes_fontStringLine3:SetText('kills by individual players, or send messages in chat channels during combat. For the')
    
    local _zp_panel_notes_fontStringLine4 = _zp_frame_notes_panel:CreateFontString("_zp_panel_notes_fontStringLine4", "OVERLAY", "GameTooltipText")
    _zp_panel_notes_fontStringLine4:SetPoint("TOPLEFT", 10, -60)
    _zp_panel_notes_fontStringLine4:SetText('time being, bragging is limited to emotes, and kills are tracked at the party level.')

    local _zp_panel_notes_fontStringLine5 = _zp_frame_notes_panel:CreateFontString("_zp_panel_notes_fontStringLine5", "OVERLAY", "GameTooltipText")
    _zp_panel_notes_fontStringLine5:SetPoint("TOPLEFT", 10, -80)
    _zp_panel_notes_fontStringLine5:SetText('--Zxeltor')
    
    -- Add the panel to the Blizzard Interface/Addons UI

    local category = Settings.RegisterCanvasLayoutCategory(_zp_panel, _zp_panel.name);
    ZPownage_Settings_UPanel_ID = category.ID;
    Settings.RegisterAddOnCategory(category);

    _zp_isAddonSettingsFrameAdded = true
end