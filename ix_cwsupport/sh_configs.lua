PLUGIN.gunData = {}
PLUGIN.modelCam = {}
PLUGIN.slotCategory = {
	[1] = "secondary",
	[2] = "primary",
	[3] = "primary",
	[4] = "primary",
}

-- I don't want to make them to buy 50 different kind of ammo
PLUGIN.changeAmmo = {
	["7.92x33mm Kurz"] = "ar2",
	["300 AAC Blackout"] = "ar2",
	["5.7x28mm"] = "pistol",
	["7.65x17MM"] = "smg1",
	["7.62x25mm Tokarev"] = "smg1",
	["7.62x25MM"] = "smg1",
	[".50 BMG"] = "ar2",
	["5.56x45mm"] = "ar2",
	["7.62x51mm"] = "ar2",
	["7.62x31mm"] = "ar2",
	["Frag Grenades"] = "grenade",
	["Flash Grenades"] = "grenade",
	["Smoke Grenades"] = "grenade",
	["9x17MM"] = "smg1",
	["9x19MM"] = "smg1",
	["glock_ammo"] = "smg1",
	[".45 ACP"] = "pistol",
	["9x18MM"] = "pistol",
	["9x39MM"] = "ar2",
	[".40 S&W"] = "pistol",
	[".44 Magnum"] = "357",
	[".50 AE"] = "357",
	["5.45x39MM"] = "ar2",
	["5.56x45MM"] = "ar2",
	["5.7x28MM"] = "pistol",
	["7.62x51MM"] = "ar2",
	["7.62x54mmR"] = "ar2",
	["12 Gauge"] = "buckshot",
	["7.62x54R"] = "sniperround",
	[".338 Lapua"] = "sniperround",
	["RPG_Round"] = "rpg_round",
	[".338mm"] = "sniperround",
	["7.62x39MM"] = "ar2",
	["6.8MM"] = "ar2",
	["9x39MM"] = "ar2",
	["9X19MM"] = "smg1",
	["Gauss Ammo"] = "sniperround",
}


--[[
local AMMO_BOX = "models/Items/BoxSRounds.mdl"
local AMMO_CASE = "models/Items/357ammo.mdl"
local AMMO_FLARE = "models/Items/BoxFlares.mdl"
local AMMO_BIGBOX = "models/Items/BoxMRounds.mdl"
local AMMO_BUCKSHOT = "models/Items/BoxBuckshot.mdl"
local AMMO_GREN = "models/Items/AR2_Grenade.mdl"
local AMMO_RPG = "models/spenser/ssk/item/rpg7_grenade.mdl" --"models/weapons/w_missile_closed.mdl"
local AMMO_VOG = "models/spenser/ssk/item/vog_25.mdl" --"models/items/ar2_grenade.mdl"
]]

PLUGIN.ammoInfo = {}
PLUGIN.ammoInfo["pistol"] = {
	name = "pistol",
	amount = 23,
	price = 200,
	model = "models/spenser/ssk/item/9x18_pbp.mdl"
}
PLUGIN.ammoInfo["357"] = {
	name = "357",
	amount = 10,
	price = 350,
	model = "models/spenser/ssk/item/1143x23_hydro.mdl"
}
PLUGIN.ammoInfo["smg1"] = {
	name = "smg1",
	amount = 30,
	price = 400,
	model = "models/spenser/ssk/item/9x19_pbp.mdl"
}
PLUGIN.ammoInfo["ar2"] = {
	name = "ar2",
	amount = 30,
	price = 400,
	model = "models/spenser/ssk/item/545x39_fmj.mdl"
}
PLUGIN.ammoInfo["buckshot"] = {
	name = "buckshot",
	amount = 7,
	price = 300,
	model = "models/spenser/ssk/item/12x70_buck.mdl"
}
PLUGIN.ammoInfo["sniperround"] = {
	name = "sniperround",
	amount = 10,
	price = 500,
	model = "models/spenser/ssk/item/762x54_7h1.mdl",
	iconCam = {
		ang	= Angle(8.4998140335083, 170.05499267578, 0),
		fov	= 2.1218640972135,
		pos	= Vector(281.19021606445, -49.330429077148, 45.772754669189)
	}
}
PLUGIN.ammoInfo["rpg_round"] = {
	name = "rpg_round",
	amount = 1,
	width = 2,
	price = 300,
	model = "models/spenser/ssk/item/rpg7_grenade.mdl" --"models/weapons/w_missile_closed.mdl"
}
--[[PLUGIN.ammoInfo["vog25"] = {
	name = "vog25",
	amount = 1,
	price = 300,
	model = "models/spenser/ssk/item/vog_25.mdl" --"models/items/ar2_grenade.mdl"
}
PLUGIN.ammoInfo["gauss"] = {
	name = "gauss",
	amount = 10,
	price = 300,
	model = "models/stalker/ammo/gauss.mdl" --"models/items/ar2_grenade.mdl"
}]]

ix.util.Include("presets/sh_defcw.lua")
ix.util.Include("presets/sh_new.lua")

