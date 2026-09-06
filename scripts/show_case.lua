--================================================
-- Showcase Mode
-- NovaFlare Engine 1.2.x
--================================================

local showcaseTimer=0
local blindTimer=0

local oldPrefs={}
local oldHitsound=nil
local showcase=false


function onCreatePost()
	updateShowcase()
	if showcase == true then
		runHaxeCode([[
			trace("[Unsent's ToolBox] Now in Showcase Mode!");
		]])
	end
	runHaxeCode([[
		trace("Current Mod Directory: " + Mods.currentModDirectory);
	]])
end


function onUpdate(elapsed)

	showcaseTimer=showcaseTimer+elapsed
	blindTimer=blindTimer+elapsed

	if showcaseTimer>=0.2 then
		showcaseTimer=0
		updateShowcase()
	end

	if showcase then
            debugPrint("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
	end

	if not showcase then
		return
	end

	hideHUD()
	hideNFEUI()
	hideStrums()
	hideNoteSplash()
	hideRating()
	hideCombo()

	enableShowcaseHitsound()
	forceBotplay()
	lockCameraShake()

	if blindTimer>=0.1 then
		blindTimer=0
		applyBlindNotes()
	end

end


--================================================
-- Showcase Check
--================================================

function updateShowcase()

	if getModSetting('showCaseMode') then

		showcase=true
		savePrefs()

	else

		showcase=false
		restorePrefs()
		restoreNormalUI()
		disableShowcaseHitsound()

	end

end


--================================================
-- Save / Disable NFE Settings
--================================================

function savePrefs()

	if oldPrefs.saved then
		return
	end

	oldPrefs.saved=true

	runHaxeCode([[
		game.variables.set(
			"showcase_keyboardViewer",
			ClientPrefs.data.keyboardViewer
		);

		game.variables.set(
			"showcase_judgementCounter",
			ClientPrefs.data.judgementCounter
		);

		game.variables.set(
			"showcase_showRating",
			ClientPrefs.data.showRating
		);

		game.variables.set(
			"showcase_showComboNum",
			ClientPrefs.data.showComboNum
		);

		ClientPrefs.data.keyboardViewer=false;
		ClientPrefs.data.judgementCounter=false;
		ClientPrefs.data.showRating=false;
		ClientPrefs.data.showComboNum=false;
	]])

end


function restorePrefs()

	if not oldPrefs.saved then
		return
	end

	oldPrefs.saved=false

	runHaxeCode([[
		ClientPrefs.data.keyboardViewer =
			game.variables.get("showcase_keyboardViewer");

		ClientPrefs.data.judgementCounter =
			game.variables.get("showcase_judgementCounter");

		ClientPrefs.data.showRating =
			game.variables.get("showcase_showRating");

		ClientPrefs.data.showComboNum =
			game.variables.get("showcase_showComboNum");
	]])

end


--================================================
-- Restore Normal UI
--================================================

function restoreNormalUI()

	if getModSetting('showCaseMode') then
		return
	end

	runHaxeCode([[
		ClientPrefs.data.keyboardViewer=true;
		ClientPrefs.data.judgementCounter=true;
		ClientPrefs.data.showRating=true;
		ClientPrefs.data.showComboNum=true;

		if(game.keyboardViewer!=null)
		{
			game.keyboardViewer.visible=true;
			game.keyboardViewer.exists=true;
		}

		if(game.judgementCounter_S!=null)
		{
			game.judgementCounter_S.visible=true;
			game.judgementCounter_S.exists=true;
		}
	]])

end


--================================================
-- Botplay
--================================================

function forceBotplay()

	runHaxeCode([[
		if(game!=null)
		{
			game.cpuControlled=true;
		}
	]])

end


--================================================
-- Force Good Rating
--================================================

function goodNoteHit(id,data,type,sustain)

	if not showcase then
		return
	end

	runHaxeCode([[
		if(game!=null && game.notes!=null)
		{
			for(note in game.notes)
			{
				if(note!=null && note.mustPress)
				{
					note.rating="good";
				}
			}
		}
	]])

end


--================================================
-- Disable Camera Shake
--================================================

function lockCameraShake()

	runHaxeCode([[
		if(game!=null)
		{
			game.camGame._fxShakeIntensity=0;
			game.camHUD._fxShakeIntensity=0;
		}
	]])

end


--================================================
-- Disable Hitsound
--================================================

function enableShowcaseHitsound()

	if oldHitsound~=nil then
		return
	end

	runHaxeCode([[
		game.variables.set(
			"showcase_oldHitsound",
			ClientPrefs.data.hitsoundVolume
		);

		ClientPrefs.data.hitsoundVolume=0;
	]])

	oldHitsound=true

end


function disableShowcaseHitsound()

	if oldHitsound==nil then
		return
	end

	runHaxeCode([[
		ClientPrefs.data.hitsoundVolume =
			game.variables.get("showcase_oldHitsound");
	]])

	oldHitsound=nil

end


--================================================
-- Hide HUD
--================================================

function hideHUD()

	local list={
		"healthBar",
		"healthBarBG",
		"scoreTxt",
		"timeBar",
		"timeBarBG",
		"timeTxt",
		"iconP1",
		"iconP2"
	}

	for _,v in ipairs(list) do
		if getProperty(v..".visible")~=nil then
			setProperty(v..".visible",false)
		end
	end

end


--================================================
-- Hide Strums
--================================================

function hideStrums()

	for i=0,7 do
		setPropertyFromGroup(
			"strumLineNotes",
			i,
			"visible",
			false
		)
	end

end


--================================================
-- Hide NFE UI
--================================================

function hideNFEUI()

	runHaxeCode([[
		if(game.keyboardViewer!=null)
		{
			game.keyboardViewer.visible=false;
			game.keyboardViewer.exists=false;
		}

		if(game.judgementCounter_S!=null)
		{
			game.judgementCounter_S.visible=false;
			game.judgementCounter_S.exists=false;
		}
	]])

end


--================================================
-- Hide Rating
--================================================

function hideRating()

	runHaxeCode([[
		if(game.ratingTxt!=null)
		{
			game.ratingTxt.visible=false;
			game.ratingTxt.exists=false;
		}
	]])

end


--================================================
-- Hide Combo
--================================================

function hideCombo()

	runHaxeCode([[
		if(game.comboGroup!=null)
		{
			game.comboGroup.visible=false;
		}
	]])

end


--================================================
-- Hide Note Splash
--================================================

function hideNoteSplash()

	runHaxeCode([[
		if(game.grpNoteSplashes!=null)
		{
			game.grpNoteSplashes.visible=false;

			for(splash in game.grpNoteSplashes.members)
			{
				if(splash!=null)
				{
					splash.visible=false;
					splash.exists=false;
					splash.alpha=0;
				}
			}
		}
	]])

end


--================================================
-- Blind Note
--================================================

function applyBlindNotes()

	runHaxeCode([[
		function applyBlind(note:games.objects.Note)
		{
			if(note==null || note.noteData<0)
				return;

			note.texture="noteSkins/BlindNote";

			if(note.rgbShader!=null)
				note.rgbShader.enabled=false;

			note.shader=null;
		}

		if(game.unspawnNotes!=null)
		{
			for(note in game.unspawnNotes)
				applyBlind(note);
		}

		if(game.notes!=null)
		{
			for(note in game.notes)
				applyBlind(note);
		}
	]])

end


--================================================
-- Restore
--================================================

function onDestroy()

	restorePrefs()
	disableShowcaseHitsound()

end