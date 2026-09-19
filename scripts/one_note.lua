--================================================
-- OneNote v2.3 Performance Fix
-- Four Player Lanes -> One Lane
-- Any Direction Input
-- Same-Time Chords -> First Note Only
-- Sustain Body -> Hidden
-- Sustain -> Automatically Completed
--================================================

local oneNoteInitialized=false
local oneNoteMergeTolerance=1.0

local noteFixTimer=0
local noteFixInterval=0.1

local oneNoteHiddenTexture='noteSkins/BlindNote'

local oneNoteDebug=false

--================================================
-- Check Setting
--================================================
local function isOneNoteEnabled()
	return getModSetting('oneNote')==true
end

--================================================
-- Debug
--================================================
local function oneNoteLog(text)
	if oneNoteDebug then
		debugPrint('[OneNote] '..text)
	end
end

--================================================
-- Setup Strums
--================================================
local function setupOneNoteStrums()

	runHaxeCode([[
		if(game.playerStrums!=null)
		{
			var pos:Float=
			]]..tostring(getModSetting('arrowPosition') or 0.5)..[[;


			for(i in 0...game.playerStrums.members.length)
			{
				var strum=game.playerStrums.members[i];

				if(strum==null)
					continue;


				if(i==0)
				{
					strum.visible=true;
					strum.alpha=1;
					strum.active=true;

					strum.x=(FlxG.width-strum.width)*pos;
				}
				else
				{
					strum.visible=false;
					strum.alpha=0;
					strum.active=false;
				}
			}
		}
	]])

end


--================================================
-- Block Native Input
--================================================
local function blockNativeInput()

	runHaxeCode([[
		if(game.strumsBlocked!=null)
		{
			for(i in 0...game.strumsBlocked.length)
			{
				game.strumsBlocked[i]=true;
			}
		}
	]])

end


--================================================
-- Hide Sustain
--================================================
local function hideSustain(note)

	return [[
		]]..note..[[.visible=false;
		]]..note..[[.alpha=0;

		if(]]..note..[[.rgbShader!=null)
			]]..note..[[.rgbShader.enabled=false;

		]]..note..[[.shader=null;
	]]
end


--================================================
-- Process Chart
--================================================
local function processChart()

	runHaxeCode([[
		if(game.unspawnNotes==null)
			return;


		var groups=new Map<Int,Array<games.objects.Note>>();


		for(note in game.unspawnNotes)
		{
			if(note==null || !note.mustPress)
				continue;


			note.noteData=0;


			if(note.isSustainNote)
			{
				]]..hideSustain("note")..[[
				continue;
			}


			var key:Int=Std.int(Math.round(note.strumTime));


			if(!groups.exists(key))
				groups.set(key,[]);


			groups.get(key).push(note);
		}



		for(key in groups.keys())
		{
			var list=groups.get(key);


			if(list==null || list.length<=1)
				continue;


			for(i in 1...list.length)
			{
				var note=list[i];


				if(note==null)
					continue;


				note.noteData=0;

				note.blockHit=true;
				note.ignoreNote=true;

				note.visible=false;
				note.alpha=0;
			}
		}

	]])

end

--================================================
-- Fix Spawned Notes
-- Keep One Lane
-- Hide Sustain
--================================================
local function fixSpawnedNotes()

	runHaxeCode([[
		if(game.notes==null)
			return;


		for(note in game.notes)
		{
			if(note==null || !note.mustPress)
				continue;


			// Force One Lane
			note.noteData=0;


			// Hide sustain
			if(note.isSustainNote)
			{
				note.visible=false;
				note.alpha=0;


				if(note.rgbShader!=null)
					note.rgbShader.enabled=false;


				note.shader=null;
			}
		}
	]])

end



--================================================
-- Spawn Note
--================================================
function onSpawnNote(id,noteData,noteType,isSustainNote,strumTime)

	if not oneNoteInitialized or not isOneNoteEnabled() then
		return
	end


	-- Delay processing to fix NFE spawn order
	runHaxeCode([[
		if(game.notes==null)
			return;


		for(note in game.notes)
		{
			if(note==null)
				continue;


			if(!note.mustPress)
				continue;


			if(Math.abs(note.strumTime-]]..strumTime..[[)<0.1)
			{
				note.noteData=0;


				if(note.isSustainNote)
				{
					note.visible=false;
					note.alpha=0;


					if(note.rgbShader!=null)
						note.rgbShader.enabled=false;


					note.shader=null;
				}

				break;
			}
		}
	]])

end



--================================================
-- Hit One Note
--================================================
local function hitOneNote(direction)

	runHaxeCode([[
		if(game.notes==null)
			return;


		var songPos:Float=Conductor.songPosition;

		var target:games.objects.Note=null;



		for(note in game.notes)
		{
			if(note==null)
				continue;


			if(!note.exists || !note.alive)
				continue;


			if(!note.mustPress)
				continue;


			if(note.isSustainNote)
				continue;


			if(note.wasGoodHit)
				continue;


			if(note.blockHit || note.ignoreNote)
				continue;



			var canHit=
				note.strumTime >
				songPos-(Conductor.safeZoneOffset*note.lateHitMult)
				&&
				note.strumTime <
				songPos+(Conductor.safeZoneOffset*note.earlyHitMult);



			if(!canHit)
				continue;



			if(target==null || note.strumTime<target.strumTime)
				target=note;
		}



		if(target==null)
			return;



		var targetTime=target.strumTime;



		// Normal judgement
		game.goodNoteHit(target);



		// Animation
		var anim='singLEFT';


		if(']]..direction..[['=='DOWN')
			anim='singDOWN';
		else if(']]..direction..[['=='UP')
			anim='singUP';
		else if(']]..direction..[['=='RIGHT')
			anim='singRIGHT';



		if(game.boyfriend!=null)
			game.boyfriend.playAnim(anim,true);



		// Complete sustain
		if(target.tail!=null)
		{
			for(tail in target.tail)
			{
				if(tail==null)
					continue;


				tail.canHold=true;
				tail.wasGoodHit=true;

				tail.visible=false;
				tail.alpha=0;
			}
		}



		// Merge same time notes
		for(note in game.notes)
		{
			if(note==null || note==target)
				continue;


			if(!note.mustPress)
				continue;


			if(note.isSustainNote)
				continue;



			if(Math.abs(note.strumTime-targetTime)<=
				]]..oneNoteMergeTolerance..[[)
			{
				note.wasGoodHit=true;
				note.blockHit=true;
				note.ignoreNote=true;

				note.visible=false;
				note.alpha=0;



				if(note.tail!=null)
				{
					for(tail in note.tail)
					{
						if(tail==null)
							continue;


						tail.canHold=true;
						tail.wasGoodHit=true;
						tail.visible=false;
						tail.alpha=0;
					}
				}
			}
		}
	]])

end



--================================================
-- Countdown Started
--================================================
function onCountdownStarted()

	if not isOneNoteEnabled() then
		return
	end


	setupOneNoteStrums()

	processChart()

	blockNativeInput()


	oneNoteInitialized=true


	oneNoteLog('Initialized')

end



--================================================
-- Update
--================================================
function onUpdate(elapsed)

	if not oneNoteInitialized or not isOneNoteEnabled() then
		return
	end



	-- Periodic note fix
	noteFixTimer=noteFixTimer+elapsed


	if noteFixTimer>=noteFixInterval then

		noteFixTimer=0

		fixSpawnedNotes()

	end



	-- Input
	if keyboardJustPressed('LEFT') then

		hitOneNote('LEFT')

	elseif keyboardJustPressed('DOWN') then

		hitOneNote('DOWN')

	elseif keyboardJustPressed('UP') then

		hitOneNote('UP')

	elseif keyboardJustPressed('RIGHT') then

		hitOneNote('RIGHT')

	end

end