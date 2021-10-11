# ZPownage v1.0.1
A World of Warcraft addon which tracks player kills, and awards the player with Unreal Tournament style achievements.

![ZPownageLogo](https://github.com/zxeltor/zpownage/blob/main/Screenshots/BoomkinDance_400x400.png)

## Overview 
This addon tracks player kills, and awards the player with Unreal Tournament style achievements.  Achievements for multi-kills and killing sprees are displayed to the user as a flash of text in the middle of the screen, along with audio playback of the Unreal Tournament Announcer.

**Note:** This addon is for fun only. This has no affect on your official in game statistics tracked by Blizzard.

## Details 
The addon maintains a list of units attacked by the player while in combat. Each unit killed by the player while in combat is counted as a kill. When the player reaches certain consecutive kill achievements, a message is displayed to the screen, along with an audio file playback from the Unreal Tournament Announcer.

Your consecutive kill count is reset when you enter a new zone, or player death occurs. This puts you back at the bottom of the achievement list.

**Note(s):**
* If you attack a unit, then leave combat with the unit before they die, you won't get credit for the kill.
* Group unit kills don't count towards a players kill count, unless the player actually attacked the killed unit.

## Scoring 

### Killing Sprees
Awards for every 5th kill without dying

* Killing Spree - 5 kills
* Rampage - 10 kills
* Dominating - 15 kills
* Unstoppable - 20 kills
* Godlike - 25 kills
* Wicked Sick - 30+ kills

### Multiple Kills
Awards for building up chains of kills in quick succession (4 seconds apart or less)

* Double Kill - 2 kills
* Multi Kill - 3 kills
* Mega Kill - 4 kills
* Ultra Kill - 5 kills
* Monster Kill - 6 kills
* Ludicrous Kill - 7 kills
* HOLY S**T - 8+ kills

## Slash Commands
* /zp reset "Reset unit kills"
* /zp pvp "Toggle player only kill mode" - By default the addon only tracks player kills. If disabled, it tracks all kills made by the player.
* /zp "Shows the other slash command usage"

## Installation
### Manual Install
Place the folder "ZPownage" and it's contents inside your World of Warcraft addons folder. You'll need to restart World of Warcraft to see the the addon.
### Curseforge via Overwolf
https://www.curseforge.com/wow/addons/zpownage
