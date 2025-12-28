# Blobs With Guns: Redux

It's my second game, Blobs with Guns, but with a drastic file size reduction and other minor updates to improve the experience. There are few new features added, and those that are added are very minor additions that were already half implemented in the original. Other quality-of-life refinements, accessibility options, some bug fixes, balancing, level edits, and visual/audio improvements have been made too, however not many code optimisations have been made and no new levels etc have been added. The experience is still closely aligned with the original.

This game creates it's own save file separate to that of the original game, however on first launch, if a save file from the old game's 'update 2' is detected, all data is copied into the new 'redux' save file. This process is basically invisible, but should allow old players to keep their stats etc (although if they were to go back to the original game, it will still load their old, pre-redux save). Game options are saved in a separate, unencrypted file.

In short, this is the original game but finally somewhat optimised and cleaned up just a tad, making it the ideal way to experience the classic Blobs With Guns.

**IMPORTANT NOTE:** This version uses **Godot 3.5.3!** For whatever reason, things break when using older or newer versions so be sure to keep it here. The game uses the GLES3 renderer for some lighting effects however is configured to fallback to GLES2 if necessary (this will break some of the lighting but should still be playable).

**ANOTHER NOTE:** The assets folder has been configured to be ignored by godot so it is not accessible from the editor or included in builds.



## Rough changelog

* Reorganised some folders
* Remove unused files
* Exclude asset creation files from project
* Rewrote credits screen
* Changed some particles
* Reloading logic fixes
* Audio fixes
* Add reverb effect for indoor levels
* Add gun reload and shell sounds
* Balanced guns
* Fixed bullets getting stuck in ricochet walls
* Decrease focus intensity
* Edited level 9
* Edited bossfight (level 10)
* Update music and add additional music
* Fix bullet spawning bug in level 8
* Properly removed the cut level 11
* Changes to level 7 design
* Fix sprite flipping when rotated (so bullets don't get stuck in walls)
* Lower particle effects to help framerates
* Ever so slightly improved level generation and menu
* Many small camera / HUD fixes
* Update level end logic
* Improvements and fixes to speedrun mode
* Updates to level 5 design
* Implement dedicated redux save file
* Lighting fixes and switch to GLES3
* Changes to level 8 design
* Add accessibility options
