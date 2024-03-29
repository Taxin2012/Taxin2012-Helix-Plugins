
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



local PLUGIN = PLUGIN

if TFA == nil then return end

PLUGIN.GunData = {}
ix.util.Include("sh_tfa_weps.lua")

PLUGIN.AttachData = {}
ix.util.Include("sh_tfa_attach.lua")

PLUGIN.AmmoData = {}
ix.util.Include("sh_tfa_ammo.lua")

if CLIENT then
	function PLUGIN:PopulateItemTooltip( tooltip, item )
		if item.Attachments and not table.IsEmpty( item.Attachments ) then
			local text = "Modifications: "

			local mods = item:GetData( "mods", {} )
			local already = {}

			if not table.IsEmpty( mods ) then
				for k, v in next, mods do
					already[ v ] = true
					text = text .. "\n  +" .. ( ( ix.item.list[ v ] and ix.item.list[ v ].name ) or v )
				end
			end

			for k, v in next, item.Attachments do
				if not already[ k ] then
					local att = ix.item.list[ k ]
					if att then
						text = text .. "\n  -" .. att.name
					end
				end
			end

			local row = tooltip:AddRowAfter( "description", "modsList" )
			row:SetText( text )
			row:SetBackgroundColor( derma.GetColor( "Info", tooltip ) )
			row:SizeToContents()
		end
	end
end

function PLUGIN:AssignWeaponItemBase(item, wepArr, wepData)
	wepArr = wepArr or weapons.GetStored(item.class)
	if wepArr == nil then return end

	item.IsTFA = true

	--wepArr.MainBullet.Ricochet = function() return true end
	wepArr.HandleDoor = function() return end
	wepArr.Primary.DefaultClip = 0
	wepArr.ixTFASupport = true

	local primaryMods, secondaryMods = (wepData ~= nil and wepData.Prim) or item.TFAPrimaryMod, (wepData ~= nil and wepData.Sec) or item.TFASecondaryMod

	if primaryMods ~= nil and table.IsEmpty(primaryMods) == false then
		for k, v in next, primaryMods do
			if wepArr.Primary[ k ] ~= nil then
				wepArr.Primary[ k ] = v
			end
		end
	end

	if secondaryMods ~= nil and table.IsEmpty(secondaryMods) == false then
		for k, v in next, secondaryMods do
			if wepArr.Secondary[ k ] ~= nil then
				wepArr.Secondary[ k ] = v
			end
		end
	end

	local atts = {}

	if wepArr.Attachments then
		for k, v in next, wepArr.Attachments do
			if v.atts ~= nil then
				for k2, v2 in next, v.atts do
					table.Merge( atts, { [ v2 ] = true } )
				end
			end
		end
	end

	item.Attachments = atts

	function item:OnEquipWeapon( ply, wep )
		local data = self:GetData( "mods", {} )

		if not table.IsEmpty( data ) then
			timer.Simple( 0.2, function()
				if IsValid( wep ) then
					for k, v in next, data do
						if self.Attachments[ v ] then
							wep:Attach( v )
						end
					end
				end
			end )
		end
	end

	if CLIENT then
		function item:PaintOver(item, w, h)
			local x, y = w - 14, h - 14

			if item:GetData( "equip" ) then
				surface.SetDrawColor( 110, 255, 110, 100 )
				surface.DrawRect( x, y, 8, 8 )

				x = x - 8 * 1.6
			end

			if not table.IsEmpty( item:GetData( "mods", {} ) ) then
				surface.SetDrawColor( 255, 255, 110, 100 )
				surface.DrawRect( x, y, 8, 8 )

				x = x - 8 * 1.6
			end
		end

		local primaryAmmo = wepArr.Primary.Ammo

		if primaryAmmo ~= nil then
			local found = false

			for k, v in next, ix.item.list do
				if v.ammo == primaryAmmo then
					item.tfaSupportAmmoName = v.name
					found = true
					break
				end
			end

			if found == false then
				local ammoItem = ix.item.list[ "ammo_" .. primaryAmmo ]
				item.tfaSupportAmmoName = (ammoItem ~= nil and ammoItem.name) or primaryAmmo
			end
		end

		function item:GetDescription()
			local text = (wepData ~= nil and wepData.Desc ~= nil and wepData.Desc .. "\n\n") or (self.description ~= "" and self.description .. "\n\n") or ""

			local ammoName, clipSize = self.tfaSupportAmmoName, wepArr.Primary.ClipSize

			if ammoName ~= nil and clipSize ~= nil then
				text = text .. "Using ammo: " .. ammoName .. ".\nMagazine capacity: " .. clipSize .. "."
			end

			return text
		end
	end

	function item:OnInstanced()
		if self:GetData( "mods" ) == nil then
			self:SetData( "mods", {} )
		end
	end
	
	item.functions.detach = {
		name = "Dequip",
		tip = "useTip",
		icon = "icon16/wrench.png",
        isMulti = true,
        multiOptions = function( item, client )
            local targets = {}

            for k, v in next, item:GetData( "mods", {} ) do
                table.insert( targets, {
                    name = ( ix.item.list[ v ] and ix.item.list[ v ].name ) or v,
                    data = { k, v },
                } )
            end

            return targets
        end,
		OnCanRun = function( item )			
            return not IsValid( item.entity ) and IsValid( item.player ) and item.invID == item.player:GetCharacter():GetInventory():GetID() and not table.IsEmpty( item:GetData( "mods", {} ) )
		end,
		OnRun = function( item, data )
			if data and data[1] and data[2] then
				local mods = item:GetData( "mods", {} )
				if not mods[ data[1] ] then return false end

				local x, y, id = item.player:GetCharacter():GetInventory():Add( data[2] )
				if not id then
					item.player:NotifyLocalized( "noFit" )
					return false
				end

				mods[ data[1] ] = nil
				item:SetData( "mods", mods )

				item.player:EmitSound( "weapons/crossbow/reload1.wav" )

				local wep = item.player:GetWeapon( item.class )
				if IsValid( wep ) then
					wep:Detach( data[2], true )
				end
			end

			return false
		end,
	}
end

function PLUGIN:AssignAmmoItemBase(item, description)
	local ammoType = item.ammo

	game.AddAmmoType( {
	    name = ammoType,
	    dmgtype = DMG_BULLET,
	    tracer = TRACER_LINE,
	    plydmg = 0,
	    npcdmg = 0,
	    force = 2000,
	    minsplash = 10,
	    maxsplash = 5
	} )

	ix.ammo.Register(ammoType)

	if CLIENT then
		function item:GetDescription()
			return (description or (self.description ~= "" and self.description) or "") .. "\n\nHaves " .. self.ammoAmount .. " ammo."
		end
	end
end

function PLUGIN:InitializedPlugins()
	for k, v in next, ix.item.list do
		if v.useTFASupport ~= nil then
			if v.base == "base_weapons" then
				self:AssignWeaponItemBase(v)
			elseif v.base == "base_ammo" then
				self:AssignAmmoItemBase(v)
			end
		end
	end

	for k, v in next, self.AmmoData do
		local ITEM = ix.item.Register( "ammo_" .. k, "base_ammo", nil, nil, true )
		ITEM.name = v.Name
		ITEM.ammo = k
		ITEM.ammoAmount = v.Amount or 30
		ITEM.price = v.Price or 200
		ITEM.model = v.Model or "models/Items/BoxSRounds.mdl"

		if v.iconCam then
			ITEM.iconCam = v.iconCam
		end

		ITEM.width = v.Width or 1
		ITEM.height = v.Height or 1
		ITEM.isAmmo = true

		self:AssignAmmoItemBase(ITEM, v.Desc)

		ITEM:Hook( "drop", function(item)
			item.player:EmitSound( "physics/metal/metal_box_footstep1.wav" ) 
		end )
	end

	for k, v in next, weapons.GetList() do
		local class = v.ClassName
		local dat = self.GunData[ class ]
		
		if dat then
			if dat.BlackList then continue end
		else
			if self.DoAutoCreation and ( class:find( "tfa_" ) or class:find( "sw_" ) ) and not class:find( "base" ) then
				dat = {}
			else
				continue
			end
		end

		local orig_wep = weapons.GetStored( class )
		if orig_wep.ixTFASupport ~= nil then continue end

		local ITEM = ix.item.Register( class, "base_weapons", nil, nil, true )

		ITEM.name = dat.Name or orig_wep.PrintName
		ITEM.price = dat.Price or 4000
		ITEM.exRender = dat.exRender or false
		ITEM.class = class
		ITEM.DoEquipSnd = true

		self:AssignWeaponItemBase(ITEM, orig_wep, dat)
		
		if dat.iconCam then
			ITEM.iconCam = dat.iconCam
		end

		if dat.Weight then
			ITEM.Weight = dat.Weight
		end

		if dat.DurCh then
			ITEM.DurCh = dat.DurCh
		end

		ITEM:Hook( "drop", function( item )
			item.player:EmitSound( "physics/metal/metal_box_footstep1.wav" ) 
		end )

		ITEM.model = dat.Model or v.WorldModel

		ITEM.width = dat.Width or 1
		ITEM.height = dat.Height or 1
		ITEM.weaponCategory = dat.Slot or "primary"
	end

	for k, v in next, self.AttachData do
		local ITEM = ix.item.Register( k, nil, nil, nil, true )
		ITEM.name = v.Name
		ITEM.description = v.Desc or ""
		ITEM.price = v.Price or 300
		ITEM.model = v.Model or "models/Items/BoxSRounds.mdl"
		if v.iconCam then
			ITEM.iconCam = v.iconCam
		end
		ITEM.width = v.Width or 1
		ITEM.height = v.Height or 1
		ITEM.isAttachment = true
		ITEM.category = "Attachments"
        ITEM.slot = v.Slot

		ITEM.functions.use = {
			name = "Equip",
			tip = "useTip",
			icon = "icon16/wrench.png",
			isMulti = true,
			multiOptions = function( item, client )
				local targets = {}

				for k, v in next, client:GetCharacter():GetInventory():GetItems() do
					if v.isWeapon and v.IsTFA and v.Attachments and v.Attachments[ item.uniqueID ] then
						table.insert( targets, {
							name = v.name,
							data = { v.id },
						} )
					end
				end

				return targets
			end,
			OnCanRun = function( item )
				local client = item.player
				return !IsValid(item.entity) and IsValid(client) and item.invID == client:GetCharacter():GetInventory():GetID()
			end,
			OnRun = function( item, data )
				if data and data[1] then
					local wep_itm = item.player:GetCharacter():GetInventory():GetItemByID( data[1], true )
					if not wep_itm then return false end

					if not wep_itm.Attachments or not wep_itm.Attachments[ item.uniqueID ] then return false end

					local mods = wep_itm:GetData( "mods", {} )

					if mods[ item.slot ] then
						item.player:Notify( "This type of item is already mounted on the weapon!" )
						return false
					else
						mods[ item.slot ] = item.uniqueID
						wep_itm:SetData( "mods", mods )

						item.player:EmitSound( "weapons/crossbow/reload1.wav" )

						local wep = item.player:GetWeapon( wep_itm.class )
						if IsValid( wep ) then
							wep:Attach( item.uniqueID, true )
						end

						return true
					end
				end

				return false
			end,
		}
	end
end
