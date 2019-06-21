ATTACHMENT_SIGHT = 1
ATTACHMENT_BARREL = 2
ATTACHMENT_LASER = 3
ATTACHMENT_MAGAZINE = 4
ATTACHMENT_GRIP = 5

local attItems = {}

attItems.att_trit = {
    name = "Тритиевая подсветка",
    desc = "Для улучшение стандартных целика и мушки на Beretta 92FS",
    slot = ATTACHMENT_SIGHT,
    attSearch = {
        "bg_tritium92fs",
    }
}
attItems.att_rdot = {
    name = "Красный точечный прицел",
    desc = "Отображающий красную точку в центре",
    slot = ATTACHMENT_SIGHT,
    attSearch = {
        "md_aimpoint",
        "md_microt1",
    }
}
attItems.att_holo = {
    name = "Голографический прицел",
    desc = "Отображает изображение с целью оказания помощи в прицеливании",
    slot = ATTACHMENT_SIGHT,
    attSearch = {
        "md_kobra",
        "md_cobram2",
        "md_eotech",
        "md_rmr",
    }
}
attItems.att_scope4 = {
    name = "Оптика 4x",
    desc = "Позволяет нацеливаться на цели средней дальности",
    slot = ATTACHMENT_SIGHT,
    attSearch = {
        "md_schmidt_shortdot",
        "md_acog",
    }
}
attItems.att_scope8 = {
    name = "Оптика 8x",
    desc = "Позволяет нацеливаться на цели дальней дальности",
    slot = ATTACHMENT_SIGHT,
    attSearch = {
        "md_pso1",
        "bg_sg1scope",
        "md_nightforce_nxs",
    }
}
attItems.att_muzsup = {
    name = "Глушитель",
    desc = "Уменьшает звук выстрела",
    slot = ATTACHMENT_BARREL,
    attSearch = {
        "md_saker",
        "md_tundra9mm",
        "md_pbs1",
    },
}
attItems.att_exmag = {
    name = "Увеличенный магазин",
    desc = "Магазин, который имеет большую емкость",
    slot = ATTACHMENT_MAGAZINE,
    attSearch = {
        "bg_ak74rpkmag",
        "bg_ar1560rndmag",
        "bg_mp530rndmag",
        "bg_makarov_extmag",
        "bg_asval_30rnd",
        "bg_g18_30rd_mag"
    }
}
attItems.att_foregrip = {
    name = "Рукоятка",
    desc = "Позволяет прицеливаться более точно",
    slot = ATTACHMENT_GRIP,
    attSearch = {
        "md_foregrip",
    }
}
attItems.att_laser = {
    name = "Лазерный прицел",
    desc = "Показывает, на что вы нацеливаетесь",
    slot = ATTACHMENT_LASER,
    attSearch = {
        "md_anpeq15",
        "md_insight_x2",
    }
}
attItems.att_bipod = {
    name = "Сошка",
    desc = "Позволяет прицеливаться более точно",
    slot = ATTACHMENT_GRIP,
    attSearch = {
        "bg_bipod",
        "md_bipod",
    }
}

local function attachment(item, data, combine)
    local client = item.player
    local char = client:GetCharacter()
    local inv = char:GetInventory()
    local items = inv:GetItems()

    local target = data

    -- This is the only way, ffagot
    for k, invItem in pairs(items) do
        if (data) then
            if (invItem:GetID() == data) then
                target = invItem

                break
            end
        else
            if (invItem.isWeapon and invItem.isCW) then
                target = invItem

                break
            end
        end
    end

    if (!target) then
        client:NotifyLocalized("noWeapon")

        return false
    else
        local class = target.class
        local SWEP = weapons.Get(class)

        if (target.isCW) then
            -- Insert Weapon Filter here if you just want to create weapon specific shit. 
            local atts = SWEP.Attachments
            local mods = target:GetData("mod", {})
            
            if (atts) then		                                
                -- Is the Weapon Slot Filled?
                if (mods[item.slot]) then
                    client:NotifyLocalized("alreadyAttached")

                    return false
                end

                local pokemon

                for atcat, data in pairs(atts) do
                    if (pokemon) then
                        break
                    end
                    
                    for k, name in pairs(data.atts) do
                        if (pokemon) then
                            break
                        end

                        for _, doAtt in pairs(item.attSearch) do
                            if (name == doAtt) then
                                pokemon = doAtt
                                break
                            end
                        end
                    end
                end

                if (!pokemon) then
                    client:NotifyLocalized("cantAttached")

                    return false
                end

                mods[item.slot] = {item.uniqueID, pokemon, item.name}
                target:SetData("mod", mods)
                local wepon = client:GetActiveWeapon()

                -- If you're holding right weapon, just mod it out.
                if (IsValid(wepon) and wepon:GetClass() == target.class) then
                    wepon:attachSpecificAttachment(pokemon)
                end
                
				-- Yeah let them know you did something with your dildo
				--client:EmitSound("cw/holster4.wav")
				client:EmitSound("volmos/mzone/interface/inv_attach_addon.ogg")

                return true
            else
                client:NotifyLocalized("notCW")
            end
        end
    end

    client:NotifyLocalized("noWeapon")
    return false
end

for className, v in pairs(attItems) do
			local ITEM = ix.item.Register(className, nil, nil, nil, true)
			ITEM.name = v.name or className
			ITEM.description = v.desc
			ITEM.price = 300
			ITEM.model = "models/Items/BoxSRounds.mdl"
			ITEM.width = 1
			ITEM.height = 1
			ITEM.isAttachment = true
			ITEM.category = "Attachments"
            ITEM.attSearch = v.attSearch
            ITEM.slot = v.slot

			ITEM.functions.use = {
                name = "Установить",
                tip = "useTip",
                icon = "icon16/wrench.png",
                isMulti = true,
                multiOptions = function(item, client)
                    local targets = {}
                    local char = client:GetCharacter()
                    
                    if (char) then
                        local inv = char:GetInventory()

                        if (inv) then
                            local items = inv:GetItems()

                            for k, v in pairs(items) do
                                if (v.isWeapon and v.isCW) then
                                    table.insert(targets, {
                                        name = L( v.name ),
                                        data = { v:GetID() },
                                    })
                                else
                                    continue
                                end
                            end
                        end
                    end

                    return targets
                end,
                OnCanRun = function(item)
                    local client = item.player
                    return !IsValid(item.entity) and IsValid(client) and item.invID == client:GetCharacter():GetInventory():GetID()
                end,
                OnRun = function(item, data)
                    return attachment(item, data[1], false)
				end,
			}

            --[[ITEM.functions.combine = {
                OnCanRun = function(item, data)
                    local targetItem = ix.item.instances[data]
                    
                    if (data and targetItem) then
                        if (!IsValid(item.entity) and targetItem.isWeapon and targetItem.isCW) then
                            return true
                        else
                            return false
                        end
                    end
                end,
                OnRun = function(item, data)
                    return attachment(item, data, true)
                end,
            }]]
end