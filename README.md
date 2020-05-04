# Helix-Plugins
Plugins for Helix writed or rewrited by me.


Door's Saves - saves purchased by players doors. Protected for lua-reload.

Perma Class - makes players classes permanent.

IX CW Support - ported from NS CW Support plugin.  
[NetStream](https://github.com/NebulousCloud/helix-hl2rp/blob/master/schema/libs/thirdparty/sh_netstream2.lua) is required!  
This plugin also using Russian language, but you can easily translate to English, by using [original plugin](https://github.com/rebel1324/BlackTea-Nutscript-Plugins/tree/master/cwsupport).  
Holstering is working not properly!!!

TFA Support - written by me plugin that add full support for TFA weapons pack.  
  
What that plugin does:  
1) Generates items (weapons. ammo, attachments);  
2) Add ability to use attachments in inventory like items (equip to weapons);  
3) Automatically changes and registering ammo and ammo types;  
4) Shows in description what attachments are have the weapon, ammo type and magazine capacity;  
5) Allows to edit weapons parameters without editing the original weapon.
  
Before use, edit the sound on those lines:
135, 229, 297, 342
  
"sh_tfa_ammo.lua" - Here you can add ammo ( and new ammo types ).  
"sh_tfa_weps.lua" - Here you can edit weapon parameters.  
"sh_tfa_attach.lua" - Here you can add attachments.

You can select: auto-generate all weapons but blacklisted or auto-generate only that weapons that described in `sh_tfa_weps.lua` file.
For that, just edit "PLUGIN.DoAutoCreation" option in "sh_tfa_support.lua" file.
