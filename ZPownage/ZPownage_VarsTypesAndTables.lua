-- The base folder for our audio files
local _zp_const_audioFileBaseFolder = "Interface\\AddOns\\ZPownage\\Audio\\";

-- A table used to to keep track of units the player has attacked
ZPownage_table_incombatwith = {}
-- A table used as an achievement queue for processing. This guarentees we process achievments in the order they occured.
ZPownage_table_achievment_queue = {}

ZPownage_ACHIEVEMENT_TYPE = {
    DEAD = 1, DOMINATING = 2, DOUBLE = 3, FIRSTBLOOD = 4, GODLIKE = 5, HOLYSHIT = 6, KILLSPREE = 7, LUDICROUS = 8,
    MEGA = 9, MONSTER = 10, MULTI = 11, PREP4BATTLE = 12, RAMPAGE = 13, ULTRA = 14, UNSTOPPABLE = 15,
    WICKED = 16
}

ZPownage_ACHIEVEMENT_GENRE_TYPE = {
    UT = 1, DUKE = 2
}

-- A table of audio file path strings
ZPownage_table_achievement_audiofilepath_duke = {
    [ZPownage_ACHIEVEMENT_TYPE.DEAD] = _zp_const_audioFileBaseFolder .. "Duke\\" .. "DukeDeath.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.DOMINATING] = _zp_const_audioFileBaseFolder .. "Duke\\" .. "ThatsWhatICallReducingHeadCount.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.DOUBLE] = _zp_const_audioFileBaseFolder .. "Duke\\" .. "DoubleYourPleasure.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.FIRSTBLOOD] = _zp_const_audioFileBaseFolder .. "Duke\\" .. "Finally.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.GODLIKE] = _zp_const_audioFileBaseFolder .. "Duke\\" .. "IveGotBallsOfSteel.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.HOLYSHIT] = _zp_const_audioFileBaseFolder .. "Duke\\" .. "HolyShit.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.KILLSPREE] = _zp_const_audioFileBaseFolder .. "Duke\\" .. "ComeGetSome.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.LUDICROUS] = _zp_const_audioFileBaseFolder .. "Duke\\" .. "LetGodSortThemOut.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.MEGA] = _zp_const_audioFileBaseFolder .. "Duke\\" .. "WhatAMess.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.MONSTER] = _zp_const_audioFileBaseFolder .. "Duke\\" .. "IMustBeDreaming.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.MULTI] = _zp_const_audioFileBaseFolder .. "Duke\\" .. "Nasty.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.PREP4BATTLE] = _zp_const_audioFileBaseFolder .. "Duke\\" .. "ItsAssKickingTime.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.RAMPAGE] = _zp_const_audioFileBaseFolder .. "Duke\\" .. "ItsAllInTheReflexes.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.ULTRA] = _zp_const_audioFileBaseFolder .. "Duke\\" .. "RestInPieces.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.UNSTOPPABLE] = _zp_const_audioFileBaseFolder .. "Duke\\" .. "PHDInKickingAss.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.WICKED] = _zp_const_audioFileBaseFolder .. "Duke\\" .. "DamnImGood.mp3"
}

ZPownage_table_achievement_audiofilepath_ut = {
    [ZPownage_ACHIEVEMENT_TYPE.DEAD] = _zp_const_audioFileBaseFolder .. "pacmandies.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.DOMINATING] = _zp_const_audioFileBaseFolder .. "dominating.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.DOUBLE] = _zp_const_audioFileBaseFolder .. "doublekill.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.FIRSTBLOOD] = _zp_const_audioFileBaseFolder .. "firstblood.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.GODLIKE] = _zp_const_audioFileBaseFolder .. "godlike.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.HOLYSHIT] = _zp_const_audioFileBaseFolder .. "holyshit.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.KILLSPREE] = _zp_const_audioFileBaseFolder .. "killingspree.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.LUDICROUS] = _zp_const_audioFileBaseFolder .. "ludicrouskill.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.MEGA] = _zp_const_audioFileBaseFolder .. "megakill.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.MONSTER] = _zp_const_audioFileBaseFolder .. "monsterkill.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.MULTI] = _zp_const_audioFileBaseFolder .. "multikill.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.PREP4BATTLE] = _zp_const_audioFileBaseFolder .. "prepareforbattle.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.RAMPAGE] = _zp_const_audioFileBaseFolder .. "rampage.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.ULTRA] = _zp_const_audioFileBaseFolder .. "ultrakill.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.UNSTOPPABLE] = _zp_const_audioFileBaseFolder .. "unstoppable.mp3",
    [ZPownage_ACHIEVEMENT_TYPE.WICKED] = _zp_const_audioFileBaseFolder .. "wickedsick.mp3"
}

-- A table of text strings to display for player achievements.
ZPownage_table_achievement_displaytext = {
    [ZPownage_ACHIEVEMENT_TYPE.DEAD] = "YOU'VE BEEN POWNED!",
    [ZPownage_ACHIEVEMENT_TYPE.DOMINATING] = "DOMINATING!",
    [ZPownage_ACHIEVEMENT_TYPE.DOUBLE] = "DOUBLE KILL!",
    [ZPownage_ACHIEVEMENT_TYPE.FIRSTBLOOD] = "FIRST BLOOD!",
    [ZPownage_ACHIEVEMENT_TYPE.GODLIKE] = "GODLIKE!",
    [ZPownage_ACHIEVEMENT_TYPE.HOLYSHIT] = "**** HOLY SHIT! ****",
    [ZPownage_ACHIEVEMENT_TYPE.KILLSPREE] = "KILLING SPREE!",
    [ZPownage_ACHIEVEMENT_TYPE.LUDICROUS] = "LUDICROUS KILL!",
    [ZPownage_ACHIEVEMENT_TYPE.MEGA] = "MEGA KILL!",
    [ZPownage_ACHIEVEMENT_TYPE.MONSTER] = "MONSTER KILL!",
    [ZPownage_ACHIEVEMENT_TYPE.MULTI] = "MULTI KILL!",
    [ZPownage_ACHIEVEMENT_TYPE.PREP4BATTLE] = "PREPARE FOR BATTLE!",
    [ZPownage_ACHIEVEMENT_TYPE.RAMPAGE] = "RAMPAGE!",
    [ZPownage_ACHIEVEMENT_TYPE.ULTRA] = "ULTRA KILL!",
    [ZPownage_ACHIEVEMENT_TYPE.UNSTOPPABLE] = "UNSTOPPABLE!",
    [ZPownage_ACHIEVEMENT_TYPE.WICKED] = "WICKED SICK!"
}