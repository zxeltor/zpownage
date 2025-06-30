---- Define various UI frames used by this addon.
-- This frame is used to process events fired off by the game. It's never displayed to the user.

function ZPownage_CreateEventFrame()
    local _zp_frame_event = CreateFrame("Frame", "_zpEventFrame")
    _zp_frame_event:Hide()
    return _zp_frame_event
end

function ZPownage_CreateAchievmentFrame()
   -- The achievment frame. It's used to flash achievement messages to the screen.
    local _zp_frame_achievementMessage = CreateFrame("Frame", "_zpAchievmentFrame", UIParent)
    _zp_frame_achievementMessage:SetFrameStrata("BACKGROUND")
    _zp_frame_achievementMessage:SetWidth(256)
    _zp_frame_achievementMessage:SetHeight(64)
    _zp_frame_achievementMessage:SetPoint("CENTER", 0, 250)
    
    -- Adding 4 backgroud font strings (offset from the main font srting) using the same text as the main font string. This provide a background/border effect.
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
    _zp_frame_message_fontStringMessage:SetText("ZPownage Achievment Message")
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
    _G[_zp_myCheckButtonPvpOnly:GetName().."Text"]:SetText("Enable Player Only Kill Mode")
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

    local _zp_frame_bragpanel = CreateFrame( "Frame", "_zp_frame_bragpanel", _zp_panel, "InsetFrameTemplate");
    _zp_frame_bragpanel:SetPoint("TOPLEFT", 10, -140)
    _zp_frame_bragpanel:SetSize(475, 40)

    local _zp_panel_bragpanel_title_fontString = _zp_frame_bragpanel:CreateFontString("_zp_panel_bragpanel_title_fontString", "OVERLAY", "GameFontNormal")
    _zp_panel_bragpanel_title_fontString:SetPoint("TOPLEFT", 2, 14)
    _zp_panel_bragpanel_title_fontString:SetText("Auto-Brag in channels: (Multi-Kills only)")

    local _zp_myCheckButtonBragSay = CreateFrame("CheckButton", "_zp_myCheckButtonBragSay", _zp_frame_bragpanel, "UICheckButtonTemplate")
    _zp_myCheckButtonBragSay:SetPoint("TOPLEFT", 10, -4)
    _zp_myCheckButtonBragSay:SetChecked(ZPownage_table_playersettings.bragSay)
    _G[_zp_myCheckButtonBragSay:GetName().."Text"]:SetText("Emote")
    _zp_myCheckButtonBragSay:SetScript("OnClick", function(self, button, down) 
        _zp_myCheckButtonBragSay:GetChecked()
        ZPownage_table_playersettings.bragSay = _zp_myCheckButtonBragSay:GetChecked()
    end)

    local _zp_myCheckButtonBragParty = CreateFrame("CheckButton", "_zp_myCheckButtonBragParty", _zp_frame_bragpanel, "UICheckButtonTemplate")
    _zp_myCheckButtonBragParty:SetPoint("TOPLEFT", 110, -4)
    _zp_myCheckButtonBragParty:SetChecked(ZPownage_table_playersettings.bragParty)
    _G[_zp_myCheckButtonBragParty:GetName().."Text"]:SetText("Party")
    _zp_myCheckButtonBragParty:SetScript("OnClick", function(self, button, down) 
        ZPownage_table_playersettings.bragParty = _zp_myCheckButtonBragParty:GetChecked()
    end)

    local _zp_myCheckButtonBragRaid = CreateFrame("CheckButton", "_zp_myCheckButtonBragRaid", _zp_frame_bragpanel, "UICheckButtonTemplate")
    _zp_myCheckButtonBragRaid:SetPoint("TOPLEFT", 210, -4)
    _zp_myCheckButtonBragRaid:SetChecked(ZPownage_table_playersettings.bragRaid)
    _G[_zp_myCheckButtonBragRaid:GetName().."Text"]:SetText("Raid")
    _zp_myCheckButtonBragRaid:SetScript("OnClick", function(self, button, down) 
        ZPownage_table_playersettings.bragRaid = _zp_myCheckButtonBragRaid:GetChecked()
    end)

    local _zp_myCheckButtonBragBG = CreateFrame("CheckButton", "_zp_myCheckButtonBragBG", _zp_frame_bragpanel, "UICheckButtonTemplate")
    _zp_myCheckButtonBragBG:SetPoint("TOPLEFT", 310, -4)
    _zp_myCheckButtonBragBG:SetChecked(ZPownage_table_playersettings.bragBG)
    _G[_zp_myCheckButtonBragBG:GetName().."Text"]:SetText("Battleground")
    _zp_myCheckButtonBragBG:SetScript("OnClick", function(self, button, down) 
        ZPownage_table_playersettings.bragBG = _zp_myCheckButtonBragBG:GetChecked()
    end)

    local _zp_frame_usage_panel = CreateFrame( "Frame", "_zp_frame_usage_panel", _zp_panel, "ThinBorderTemplate");
    _zp_frame_usage_panel:SetPoint("TOPLEFT", 10, -205)
    _zp_frame_usage_panel:SetSize(600, 80)

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
    _zp_panel_usage_fontStringLineResetDetails:SetText('"Reset unit kills"')
    local _zp_panel_usage_fontStringLinePvpDetails = _zp_frame_usage_panel_rightcolumn:CreateFontString("_zp_panel_usage_fontStringLinePvpDetails", "OVERLAY", "GameTooltipText")
    _zp_panel_usage_fontStringLinePvpDetails:SetPoint("TOPLEFT", 0, -25)
    _zp_panel_usage_fontStringLinePvpDetails:SetText('"Toggle player only kill mode. If disabled, it tracks all kills made by the player"')
    local _zp_panel_usage_fontStringLineTestDetails = _zp_frame_usage_panel_rightcolumn:CreateFontString("_zp_panel_usage_fontStringLineTestDetails", "OVERLAY", "GameTooltipText")
    _zp_panel_usage_fontStringLineTestDetails:SetPoint("TOPLEFT", 0, -40)
    _zp_panel_usage_fontStringLineTestDetails:SetText('"Test achievment display and audio playback"')
    local _zp_panel_usage_fontStringLineUiDetails = _zp_frame_usage_panel_rightcolumn:CreateFontString("_zp_panel_usage_fontStringLineUiDetails", "OVERLAY", "GameTooltipText")
    _zp_panel_usage_fontStringLineUiDetails:SetPoint("TOPLEFT", 0, -55)
    _zp_panel_usage_fontStringLineUiDetails:SetText('"Show addon settings UI and usage"')

    -- Add the panel to the Blizzard Interface/Addons UI
    local category, layout = Settings.RegisterCanvasLayoutCategory(_zp_panel, _zp_panel.name, _zp_panel.name);
    category.ID = _zp_panel.name;
    Settings.RegisterAddOnCategory(category);

    _zp_isAddonSettingsFrameAdded = true
end