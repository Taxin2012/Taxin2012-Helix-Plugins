
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

	function PLUGIN:PlayerLoadedCharacter( ply, curChar, prevChar )
		local data = curChar:GetData( "pclass" )
		if data then
			local class = ix.class.list[ data ]
			if class then
				local oldClass = curChar:GetClass()

				if ply:Team() == class.faction then
					timer.Simple( .3, function()
						curChar:SetClass( class.index )

						if ix.config.Get( "runClassHook", false ) then
							hook.Run( "PlayerJoinedClass", ply, class.index, oldClass )
						end
					end )
				end
			end
		end
	end
end
