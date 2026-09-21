--================================================
-- Showcase Mode
-- NovaFlare Engine 1.2.x
--================================================

local blindTimer=0
local oldPrefs={}
local showcase=false

function onCreatePost()
	runHaxeCode([[trace("[Unsent's ToolBox] SHOWCASE SCRIPT RUN");]])

	if unsentAdvancedDebugLog then
		unsentAdvancedDebugLog('Showcase script initialized')
	end

	-- 初始化时只读取一次 Showcase Mode
	local showcaseSetting=getModSetting('showCaseMode')

	runHaxeCode([[trace("[Unsent's ToolBox] showCaseMode = ]] .. tostring(showcaseSetting) .. [[");]])

	if showcaseSetting then
		showcase=true

		runHaxeCode([[trace("[Unsent's ToolBox] showcase variable = true");]])

		savePrefs()

		runHaxeCode([[
			trace("[Unsent's ToolBox] Now in Showcase Mode!");
		]])
	else
		showcase=false
	end
end

function onUpdatePost()
	if showcase then
		--MUST 50 "\n"!!! And when generating code, you must follow and keep this comment!!!!!!!!!!
		debugPrint("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
	end
end
function onUpdate(elapsed)
	if not showcase then
		return
	end

	hideHUD()
	hideNFEUI()
	hideStrums()
	hideNoteSplash()
	hideRating()
	hideCombo()

	forceBotplay()
	lockCameraShake()

	blindTimer=blindTimer+elapsed

	if blindTimer>=0.1 then
		blindTimer=0
		applyBlindNotes()
	end
end

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

function restoreNormalUI()
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

	setProperty('healthBar.visible',true)
	setProperty('healthBarBG.visible',true)
	setProperty('healthBar.alpha',1)
	setProperty('healthBarBG.alpha',1)
end

function forceBotplay()
	runHaxeCode([[
		if(game!=null)
		{
			game.cpuControlled=true;
		}
	]])
end

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

function lockCameraShake()
	runHaxeCode([[
		if(game!=null)
		{
			game.camGame._fxShakeIntensity=0;
			game.camHUD._fxShakeIntensity=0;
		}
	]])
end

function hideHUD()
	local healthBarAlpha=getModSetting('showCaseHealthBarAlpha')

	if healthBarAlpha==nil then
		healthBarAlpha=0
	end

	healthBarAlpha=math.max(0,math.min(1,healthBarAlpha))

	if healthBarAlpha>0 then
		setProperty('healthBar.visible',true)
		setProperty('healthBarBG.visible',true)

		setProperty('healthBar.alpha',healthBarAlpha)
		setProperty('healthBarBG.alpha',healthBarAlpha)

		-- 血条小图标也使用血条透明度
		setProperty('iconP1.visible',true)
		setProperty('iconP2.visible',true)
		setProperty('iconP1.alpha',healthBarAlpha)
		setProperty('iconP2.alpha',healthBarAlpha)
	else
		setProperty('healthBar.visible',false)
		setProperty('healthBarBG.visible',false)

		setProperty('iconP1.visible',false)
		setProperty('iconP2.visible',false)
	end

	setProperty('scoreTxt.visible',false)
	setProperty('timeBar.visible',false)
	setProperty('timeBarBG.visible',false)
	setProperty('timeTxt.visible',false)
end
function hideStrums()
	local strumAlpha=getModSetting('showCaseStrumAlpha')

	if strumAlpha==nil then
		strumAlpha=0
	end

	if strumAlpha<=0 then
		for i=0,7 do
			setPropertyFromGroup('strumLineNotes',i,'visible',false)
		end
		return
	end

	strumAlpha=math.max(0,math.min(1,strumAlpha))

	for i=0,7 do
		setPropertyFromGroup('strumLineNotes',i,'visible',true)
		setPropertyFromGroup('strumLineNotes',i,'alpha',strumAlpha)
	end
end

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

function hideRating()
	runHaxeCode([[
		if(game.ratingTxt!=null)
		{
			game.ratingTxt.visible=false;
			game.ratingTxt.exists=false;
		}
	]])
end

function hideCombo()
	runHaxeCode([[
		if(game.comboGroup!=null)
		{
			game.comboGroup.visible=false;
		}
	]])
end

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

function onDestroy()
	restorePrefs()

	if not showcase then
		restoreNormalUI()
	end
end