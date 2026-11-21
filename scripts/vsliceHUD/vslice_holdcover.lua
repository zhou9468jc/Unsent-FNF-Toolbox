function onCreatePost()
	if getPropertyFromClass("PlayState","isPixelStage") then
		addLuaScript("extraScript/v-slice_holdCover-pixel.lua",true)
		addLuaScript("extraScript/v-slice_holdCoverOp-pixel.lua",true)
	else
		addLuaScript("extraScript/v-slice_holdCover.lua",true)
		addLuaScript("extraScript/v-slice_holdCoverOp.lua",true)
	end
end