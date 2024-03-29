
--
-- Copyright (C) 2020 Taxin2012
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--



--	Writed by Taxin2012
--	https://steamcommunity.com/id/Taxin2012/



--[[
Required Fields:
Slot - string (Can be anything)

Not required Fields:
Name - string, default: A weapon name
Desc - string, default: ""
Model - string, default: A weapon world model
iconCam - table, default: nil
Width - number, default: 1
Height - number, default: 1
Weight - number, default: nil (Helix don't have a weight system by default)
Price - number, default: 300
Prim - table, default: nil
Sec - table, default: nil
BlackList - bool, default: nil
]]--

PLUGIN.GunData[ "tfa_ins2_ak74m" ] = {
	Name = "AK74M",
	Desc = "Description",
	Slot = "primary",
	Model = "path_to_model_of_item",
	iconCam = {
		tpos = Vector( 0, 0, 0 ),
		tang = Angle( 0, 0, 0 ),
		tfov = 0
	},
	Width = 4,
	Height = 2,
	Weight = 3,
	Price = 2000,
	
	--Weapon Parameters
	--Prim == Primary
	Prim = {
		Ammo = "assault",
		Damage = 31,
		KickUp = 0.4,
		KickDown = 0.4,
		KickHorizontal = 0.35,
		Spread = .021,
		IronAccuracy = .01
	},
	
	--Sec == Secondary
	Sec = {},
	
	--Weapon can be Blacklisted and item will be not auto-generated
	BlackList = false
}

--Only "Slot" field is required:
PLUGIN.GunData[ "another_tfa_weapon" ] = {
	Slot = "secondary"
}
