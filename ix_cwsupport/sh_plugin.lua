PLUGIN.name = "Macro Weapon Register"
PLUGIN.author = "Black Tea (Edited by Taxin2012)"
PLUGIN.description = "Gun Jesus have arrived."

if (!CustomizableWeaponry) then return end

/*
	MODIFICATION TUTORIAL
		- sh_config
		 This file contains ammo structure.
		- sh_languages
		 This file contains language sets for the weapons.
		- cl_cw3d2d
		 This file contains modification for CW 2.0 HUDs
		- sh_attachments
		 This file contains information and of attachment items.
*/

ix.util.Include("sh_configs.lua")
ix.util.Include("sh_languages.lua")
ix.util.Include("cl_cw3d2d.lua")
ix.util.Include("sh_attachments.lua")

function PLUGIN:InitializedPlugins()
	--table.Merge(ix.lang.stored["korean"], self.koreanTranslation)
	table.Merge(ix.lang.stored["english"], self.englishTranslation)
	table.Merge(ix.lang.stored["russian"], self.russianTranslation) -- By Taxin2012

	-- Create Items with Lua
	do
		-- ammunition
		for name, data in pairs(self.ammoInfo) do
			local uniqueID = "ammo_"..name:lower()
			local ammoInfo = data

			local ITEM = ix.item.Register(uniqueID, "base_ammo", nil, nil, true)
			ITEM.name = ammoInfo.name
			ITEM.ammo = name
			ITEM.ammoAmount = ammoInfo.amount or 30
			ITEM.price = ammoInfo.price or 200
			ITEM.model = ammoInfo.model or AMMO_BOX
			ITEM.width = ammoInfo.width or 1
			ITEM.isAmmo = true

			function ITEM:GetDescription()
				return L("cwAmmoDesc", self.ammoAmount)
			end

			ITEM:Hook("drop", function(item)
				item.player:EmitSound("volmos/mzone/interface/inv_drop.ogg", 80) 
			end)
		end

		-- they were ass.
		local assWeapons = {
			["cw_ber_cz75"] = "muzzleflash_6",
			["cw_ber_deagletoast"] = "muzzleflash_6",
			["cw_ber_fnp45"] = "muzzleflash_6",
			["cw_ber_m9"] = "muzzleflash_6",
			["cw_ber_p220"] = "muzzleflash_6",
			["cw_ber_model620"] = "muzzleflash_6",
			["cw_ber_usp"] = "muzzleflash_6",
		}

		for k, v in ipairs(weapons.GetList()) do
			local class = v.ClassName
			local prefix

			if (class:find("cw_")) then
				prefix = "cw_"
			elseif (class:find("ma85_")) then
				prefix = "ma85_"
			end
			
			if (prefix and !class:find("base")) then
				-- Configure Weapon's Variables
				v.CanRicochet = false
				v.isGoodWeapon = true
				v.canPenetrate = function() return false end
				v.canRicochet = function() return false end
				--v.MuzzleEffect = "muzzleflash_ak74" -- lol jk
				v.Primary.DefaultClip = 0

				--[[if v.WMAng and v.WMPos then
					if not v.IsFixed then
						v.WMAng = Vector(4, -8, 0)
					elseif v.IsFixed then
						v.WMPos = Vector(-1, 1.5, -2)
						v.WMAng = Vector(35, -5, -5)
					elseif v.IsFixed2 then
						v.WMAng = Vector(0, 170, 0)
					elseif v.IsFixed3 then
						v.WMPos = Vector(-2, -1, -2.1)
						v.WMAng = Vector(0, -90, 0)
					end
				end]]

				if v.AddSafeMode then
					v.AddSafeMode = false
				end

				if v.Primary.Ammo and self.changeAmmo[ v.Primary.Ammo ] then
					v.Primary.Ammo = self.changeAmmo[ v.Primary.Ammo ]
				end

				v.VelocitySensitivity = 2

				if (v.MaxSpreadInc) then
					if (!v.neat_MaxSpreadInc) then
						v.neat_MaxSpreadInc = v.MaxSpreadInc
					end
					v.MaxSpreadInc = ((v.neat_MaxSpreadInc or v.MaxSpreadInc) or 0.1) * 3 
				end
				
				if (v.SpreadPerShot) then
					if (!v.neat_SpreadPerShot) then
						v.neat_SpreadPerShot  = v.SpreadPerShot or 0.1
					end

					v.SpreadPerShot = (v.neat_SpreadPerShot or v.SpreadPerShot) * 10

					if (v.FireDelay) then
						v.SpreadCooldown = (v.FireDelay or 0)*0.3
					end
					v.AddSpreadSpeed = v.SpreadPerShot*5
				end

				-- lol fuck you 
				function v:detachSpecificAttachment(attachmentName)
					-- since we don't know the category, we'll just have to iterate over all attachments, find the one we want, and attach it there
					for category, data in pairs(self.Attachments) do
						for key, attachment in ipairs(data.atts) do
							if attachment == attachmentName then
								self:detach(category, key - 1, false)
							end
						end
					end
				end

				-- A code to get rid of fucking movement/sway disability.
				function v:getFinalSpread(vel, maxMultiplier)
					maxMultiplier = maxMultiplier or 1
					
					local final = self.BaseCone
					local aiming = self.dt.State == CW_AIMING
					-- take the continuous fire spread into account
					final = final + self.AddSpread
					
					-- and the player's velocity * mobility factor
					
					if aiming then
						-- irl the accuracy of your weapon goes to shit when you start moving even if you aim down the sights, so when aiming, player movement will impact the spread even more than it does during hip fire
						-- but we're gonna clamp it to a maximum of the weapon's hip fire spread, so that even if you aim down the sights and move, your accuracy won't be worse than your hip fire spread
						final = math.min(final + (vel / 10000 * self.VelocitySensitivity) * self.AimMobilitySpreadMod, self.HipSpread)
					else
						final = final + (vel / 10000 * self.VelocitySensitivity)
					end
					
					if self.ShootWhileProne and self:isPlayerProne() then
						final = final + vel / 1000
					end
					
					-- lastly, return the final clamped value
					return math.Clamp(final, 0, 0.09 + self:getMaxSpreadIncrease(maxMultiplier))
				end

				function v:recalculateDamage()
					if not self.Damage_Orig then return end
						
					local mult = hook.Run("GetSchemaCWDamage", self, self.Owner) or 1

					self.Damage = self.Damage_Orig * self.DamageMult * mult
				end

				function v:recalculateRecoil()
					if not self.Recoil_Orig then return end

					local mult = hook.Run("GetSchemaCWRecoil", self, self.Owner) or 1

					self.Recoil = self.Recoil_Orig * self.RecoilMult * mult
				end

				function v:recalculateFirerate()
					if not self.FireDelay_Orig then return end

					local mult = hook.Run("GetSchemaCWFirerate", self, self.Owner) or 1

					self.FireDelay = self.FireDelay_Orig * self.FireDelayMult * mult
				end

				function v:recalculateVelocitySensitivity()
					if not self.VelocitySensitivity_Orig then return end

					local mult = hook.Run("GetSchemaCWVel", self, self.Owner) or 1

					self.VelocitySensitivity = self.VelocitySensitivity_Orig * self.VelocitySensitivityMult * mult
				end

				function v:recalculateAimSpread()
					if not self.AimSpread_Orig then return end

					local mult = hook.Run("GetSchemaCWAimSpread", self, self.Owner) or 1

					self.AimSpread = self.AimSpread_Orig * self.AimSpreadMult * mult
				end

				function v:recalculateHipSpread()
					if not self.HipSpread_Orig then return end

					local mult = hook.Run("GetSchemaCWHipSpread", self, self.Owner) or 1

					self.HipSpread = self.HipSpread_Orig * self.HipSpreadMult * mult
				end

				function v:recalculateDeployTime()
					if not self.DrawSpeed_Orig then return end

					local mult = hook.Run("GetSchemaCWDeployTime", self, self.Owner) or 1

					self.DrawSpeed = self.DrawSpeed_Orig * self.DrawSpeedMult * mult
				end

				function v:recalculateReloadSpeed()
					if not self.ReloadSpeed_Orig then return end

					local mult = hook.Run("GetSchemaCWReloadSpeed", self, self.Owner) or 1

					self.ReloadSpeed = self.ReloadSpeed_Orig * self.ReloadSpeedMult * mult
				end

				function v:recalculateMaxSpreadInc()
					if not self.MaxSpreadInc_Orig then return end

					local mult = hook.Run("GetSchemaCWMaxSpread", self, self.Owner) or 1

					self.MaxSpreadInc = self.MaxSpreadInc_Orig * self.MaxSpreadIncMult * mult
				end

				-- Generate Items
				local uniqueID = string.Replace(class, prefix, ""):lower()
				local dat = self.gunData[prefix .. uniqueID] or {}

				v.Slot = dat.slot or 2
				local ITEM = ix.item.Register(class:lower(), "base_weapons", nil, nil, true)
				ITEM.name = uniqueID
				ITEM.price = dat.price or 4000
				ITEM.exRender = dat.exRender or false
				--ITEM.iconCam = self.modelCam[v.WorldModel:lower()]
				ITEM.class = prefix .. uniqueID
				--ITEM.holsterDrawInfo = dat.holster
				ITEM.isCW = true
				ITEM.DoEquipSnd = true

				--[[if (dat.holster) then
					ITEM.holsterDrawInfo.model = v.WorldModel
				end]]

				if dat.DurCh then
					ITEM.DurCh = dat.DurCh
				end

				ITEM:Hook("drop", function(item)
					item.player:EmitSound("volmos/mzone/interface/inv_drop.ogg", 80) 
				end)

				ITEM.model = v.WorldModel

				local slot = self.slotCategory[v.Slot]
				ITEM.width = dat.width or 1
				ITEM.height = dat.height or 1
				ITEM.weaponCategory = slot or "primary"

				function ITEM:OnEquipWeapon(client, weapon)
				end

				function ITEM:PaintOver(item, w, h)
					local x, y = w - 14, h - 14

					if item:GetData("equip") then
						surface.SetDrawColor(110, 255, 110, 100)
						surface.DrawRect(x, y, 8, 8)

						x = x - 8 * 1.6
					end

					if #item:GetData("mod", {}) > 0 then
						surface.SetDrawColor(255, 255, 110, 100)
						surface.DrawRect(x, y, 8, 8)

						x = x - 8 * 1.6
					end

					if item:GetData( "durability" ) then
						local tex = tostring( item:GetData( "durability" ) )

						surface.SetFont( "ixChatFont" )
						local wi, he = surface.GetTextSize( tex )
						surface.SetTextColor( 255, 255, 255, 255 )
						surface.SetTextPos( w - ( 14 + wi ), 14 )
						surface.DrawText( tex )
					end
				end

				function ITEM:GetDescription()
					if (!self.entity or !IsValid(self.entity)) then
						local text = L("gunInfoDesc", L(v.Primary.Ammo)) .. "\n"

						text = text .. L("gunInfoStat", v.Primary.ClipSize) .. "\n" or "ОШИБКА ПОЛУЧЕНИЯ ИНФОРМАЦИИ\nСообщите разработчикам" .. "\n" --L(self.weaponCategory) v.Damage,

						if self:GetData( "durability" ) then
							if self:GetData( "durability" ) <= 100 then
								text = text .. "Состояние: " .. self:GetData( "durability", 100 ) .. "/100"
							elseif self:GetData( "durability" ) > 100 then
								text = text .. "Состояние: " .. self:GetData( "durability", 1000 ) .. "/1000"
							end
						end

						local mods = self:GetData("mod", {})
						if #mods > 0 then
							local attText = ""
							for _, att1 in pairs(mods) do
								attText = attText .. "\n<color=39, 174, 96>" .. att1[3] or "ERROR" .. "</color>" --L(att1[1] or "ERROR")
							end
							text = text .. "\n\n" .. L("gunInfoAttachments", attText)
						end

						return text
					else
						local text = L("gunInfoDesc", L(v.Primary.Ammo))
						return text
					end
				end

				function ITEM:OnInstanced()
					if ( self:GetData( "durability" ) ) == nil then
						self:SetData( "durability", 100 )
					end
				end
				
				ITEM.functions.use = {
				name = "Снять",
				tip = "useTip",
				icon = "icon16/wrench.png",
	            isMulti = true,
	            multiOptions = function(item, client)
	                local targets = {}

	                for k, v in pairs(item:GetData("mod", {})) do
	                    table.insert(targets, {
	                        name = v[3] or "ERROR", --L(v[1] or "ERROR")
	                        data = { k },
	                    })
	                end

	                return targets
	            end,
				OnCanRun = function(item)
					if #item:GetData("mod", {}) <= 0 then
						return false
					end
					
					local client = item.player
                    return !IsValid(item.entity) and IsValid(client) and item.invID == client:GetCharacter():GetInventory():GetID()
				end,
				OnRun = function(item, data)
							local client = item.player
							if (data) then
								local char = client:GetCharacter()

								if (char) then
									local inv = char:GetInventory()

									if (inv) then
										local mods = item:GetData("mod", {})
										local attData = mods[data[1]]

										if (attData) then
											inv:Add(attData[1])

											
											local wepon = client:GetActiveWeapon()
											if (IsValid(wepon) and wepon:GetClass() == item.class) then
												wepon:detachSpecificAttachment(attData[2])
											end

											mods[data[1]] = nil

											if (table.Count(mods) == 0) then
												item:SetData("mod", nil)
											else
												item:SetData("mod", mods)
											end
											
											-- Yeah let them know you did something with your dildo
											--client:EmitSound("cw/holster4.wav")
											client:EmitSound("volmos/mzone/interface/inv_detach_addon.ogg")
											
										else
											client:NotifyLocalized("notAttachment")
										end
									end
								end
							else
								client:NotifyLocalized("detTarget")
							end

							return false
						end,
				}

				ITEM.functions.Repair = {
					name = "Починить",
					tip = "equipTip",
					icon = "icon16/bullet_wrench.png",
					OnRun = function( item )
						local client = item.player		
						local items = client:GetCharacter():GetInventory()
						local itm = items:HasItem( "weptools" )
						
						if itm then
							if item:GetData( "durability" ) < 100 then
								itm:Remove()
								client:EmitSound("volmos/mzone/interface/inv_restorearm.ogg", 80)
								client:Notify( 'Вы починили предмет "' .. item.name .. '" используя "' .. itm.name .. '"' )
								item:SetData( "durability", math.Clamp( item:GetData( "durability" ) + 10, 1, 100 ) )
							else
								client:Notify("Для такого вида ремонта требуется менее 100% состояния брони")
							end
						else
							client:Notify("У Вас нет расходников для ремонта")
						end		
						
						return false
					end,
					OnCanRun = function(item)
						local client = item.player

						return !IsValid(item.entity) and IsValid(client) and item:GetData("equip") == true and
							hook.Run("CanPlayerUnequipItem", client, item) != false and item.invID == client:GetCharacter():GetInventory():GetID() and ( not client.ixRagdoll or not client.ixRagdoll:IsValid() )
					end
				}

				--HOLSTER_DRAWINFO[ITEM.class] = ITEM.holsterDrawInfo

				-- Register Language name for the gun.
				if (CLIENT) then
					if (ix.lang.stored["russian"]) then --and ix.lang.stored["korean"] ix.lang.stored["english"]
						ITEM.name = v.PrintName 
						
						ix.lang.stored["english"][prefix .. uniqueID] = v.PrintName 
						--ix.lang.stored["korean"][prefix .. uniqueID] = v.PrintName 
						ix.lang.stored["russian"][prefix .. uniqueID] = v.PrintName -- By Taxin2012
					end
				end
			end
		end
	end

	-- Reconfigure Customizable Weaponry in here	
	do	
		-- There is no Customization Keys.
		CustomizableWeaponry.customizationMenuKey = "" -- the key we need to press to toggle the customization menu
		CustomizableWeaponry.canDropWeapon = false
		CustomizableWeaponry.enableWeaponDrops = false
		CustomizableWeaponry.quickGrenade.enabled = false
		CustomizableWeaponry.quickGrenade.canDropLiveGrenadeIfKilled = false
		CustomizableWeaponry.quickGrenade.unthrownGrenadesGiveWeapon = false
		CustomizableWeaponry.physicalBulletsEnabled = false
		CustomizableWeaponry.customizationEnabled = false

		hook.Remove("PlayerInitialSpawn", "CustomizableWeaponry.PlayerInitialSpawn")
		hook.Remove("PlayerSpawn", "CustomizableWeaponry.PlayerSpawn")
		hook.Remove("AllowPlayerPickup", "CustomizableWeaponry.AllowPlayerPickup")

		if (CLIENT) then
			local up = Vector(0, 0, -100)
			local shellMins, shellMaxs = Vector(-0.5, -0.15, -0.5), Vector(0.5, 0.15, 0.5)
			local angleVel = Vector(0, 0, 0)

			function CustomizableWeaponry.shells:finishMaking(pos, ang, velocity, soundTime, removeTime)
				velocity = velocity or up
				velocity.x = velocity.x + math.Rand(-5, 5)
				velocity.y = velocity.y + math.Rand(-5, 5)
				velocity.z = velocity.z + math.Rand(-5, 5)
				
				time = time or 0.5
				removetime = removetime or 5
				
				local t = self._shellTable or CustomizableWeaponry.shells:getShell("mainshell") -- default to the 'mainshell' shell type if there is none defined

				local ent = ClientsideModel(t.m, RENDERGROUP_BOTH) 
				ent:SetPos(pos)
				ent:PhysicsInitBox(shellMins, shellMaxs)
				ent:SetAngles(ang + AngleRand())
				ent:SetModelScale((self.ShellScale*.9 or .7), 0)
				ent:SetMoveType(MOVETYPE_VPHYSICS) 
				ent:SetSolid(SOLID_VPHYSICS) 
				ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				
				local phys = ent:GetPhysicsObject()
				phys:SetMaterial("gmod_silent")
				phys:SetMass(10)
				phys:SetVelocity(velocity)
				
				angleVel.x = math.random(-500, 500)
				angleVel.y = math.random(-500, 500)
				angleVel.z = math.random(-500, 500)
				
				phys:AddAngleVelocity(ang:Right() * 100 + angleVel + VectorRand()*50000)

				timer.Simple(time, function()
					if t.s and IsValid(ent) then
						sound.Play(t.s, ent:GetPos())
					end
				end)
				
				SafeRemoveEntityDelayed(ent, removetime)
			end
		end

		do
			CustomizableWeaponry.callbacks:addNew("finishReload", "nutExperience", function(weapon)
				if (CLIENT) then return end

				local owner = weapon.Owner

				if (IsValid(owner) and owner:IsPlayer()) then
					local char = owner:GetCharacter()

					if (char) then
						if (char:GetAttribute("gunskill", 0) < 5) then
							char:UpdateAttrib("gunskill", 0.003)
						end
					end
				end
			end)

			if (CLIENT) then
				netstream.Hook("nutUpdateWeapon", function(weapon) if (weapon and weapon:IsValid() and weapon.recalculateStats) then weapon:recalculateStats() end end)
			end

			function CustomizableWeaponry:hasAttachment(ply, att, lookIn)		
				return true
			end

			CustomizableWeaponry.callbacks:addNew("deployWeapon", "uploadAttachments", function(weapon)
				if (CLIENT) then return end

				timer.Simple(.1, function()
					if (IsValid(weapon)) then
						if (weapon.recalculateStats) then
							weapon:recalculateStats()
							
							netstream.Start(weapon.Owner, "nutUpdateWeapon", weapon)
						end
					end
				end)

				local class = weapon:GetClass():lower()
				local client = weapon.Owner

				if (!client) then return end
				if (weapon.attLoaded) then return end

				local char = client:GetCharacter()

				if (char) then
					local inv = char:GetInventory()
					local attList = {}

					for k, v in pairs(inv:GetItems()) do
						if (v.isWeapon and v.class == class) then
							local attachments = v:GetData("mod")

							if (attachments) then
								for k, v in pairs(attachments) do
									table.insert(attList, v[2])
								end
							end

							break
						end
					end

					timer.Simple(0.2, function()
						if (IsValid(weapon) and weapon:GetClass() == class and weapon.attachSpecificAttachment) then
							for _, b in ipairs(attList) do
								weapon:attachSpecificAttachment(b)
							end
						end
					end)

					weapon.attLoaded = true
				end
			end)
		end
	end
end

function PLUGIN:GetSchemaCWVel(weapon, client)
	return 10
end

if (SERVER) then
	function PLUGIN:OnCharAttribUpdated(client, character, key, value)
		if (!client) then
			client = (character and character:getPlayer())
		end

		if (client and client:IsValid()) then
			local weapon = client:GetActiveWeapon()

			if (value == "gunskill") then
				if (weapon and weapon:IsValid() and weapon.recalculateStats) then
					weapon:recalculateStats()
					
					netstream.Start(client, "nutUpdateWeapon", weapon)
				end
			end
		end
	end

	function PLUGIN:OnCharAttribBoosted(client, character, attribID, boostID, boostAmount)
		if (!client) then
			client = (character and character:getPlayer())
		end

		if (client and client:IsValid()) then
			local weapon = client:GetActiveWeapon()

			if (value == "gunskill") then
				if (weapon and weapon:IsValid() and weapon.recalculateStats) then
					weapon:recalculateStats()
					
					netstream.Start(client, "nutUpdateWeapon", weapon)
				end
			end
		end
	end
end