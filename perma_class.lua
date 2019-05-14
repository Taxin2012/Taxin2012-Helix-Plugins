
local PLUGIN = PLUGIN
PLUGIN.name = "Perma Class"
PLUGIN.author = "Taxin2012"
PLUGIN.description = "Makes class permanent."

ix.config.Add( "runClassHook", true, "Should plugin run PlayerJoinedClass hook?", nil, {
	category = "Perma Class"
} )

if SERVER then
	function PLUGIN:PlayerJoinedClass( ply, classInd, prevClass )
		local char = ply:GetCharacter()
		if char then
			char:SetData( "pclass", classInd )
		end
	end

	function PLUGIN:PlayerLoadedCharacter( ply, char, currChar )
		local char = ply:GetCharacter()
		if char then
			local class = currChar:GetData( "pclass" )
			if class then
				local classTable

				for _, v in ipairs( ix.class.list ) do
					if ( ix.util.StringMatches( v.uniqueID, class ) or ix.util.StringMatches( v.name, class ) ) then
						classTable = v
					end
				end

				if classTable then
					local oldClass = char:GetClass()
					local targetPlayer = char:GetPlayer()

					if targetPlayer:Team() == classTable.faction then
						char:SetClass( classTable.index )

						if ix.config.Get( "runClassHook" ) then
							hook.Run( "PlayerJoinedClass", ply, classTable.index, oldClass )
						end
					end
				end
			end
		end
	end
end
