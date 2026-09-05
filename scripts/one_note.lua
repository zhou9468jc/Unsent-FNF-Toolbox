--================================================
-- OneNote
-- Four Player Lanes -> One Lane
-- Any Direction Input
-- Same-Time Chords -> First Note Only
-- Sustain Body -> Hidden
-- Sustain -> Automatically Completed
--================================================

local oneNoteInitialized=false
local oneNoteMergeTolerance=1.0
local blindNoteTexture='noteSkins/BlindNote'

--================================================
-- Check Setting
--================================================
local function isOneNoteEnabled()
	return getModSetting('oneNote')==true
end

--================================================
-- Setup OneNote Strums
--================================================
local function setupOneNoteStrums()
	runHaxeCode([[
		if (game.playerStrums != null)
		{
			for (i in 0...game.playerStrums.members.length)
			{
				var strum = game.playerStrums.members[i];

				if (strum == null)
					continue;

				if (i == 0)
				{
					strum.visible = true;
					strum.alpha = 1;
					strum.active = true;
					strum.x = (FlxG.width - strum.width) / 2;
				}
				else
				{
					strum.visible = false;
					strum.alpha = 0;
					strum.active = false;
				}
			}
		}
	]])
end

--================================================
-- Block Native Four-Lane Input
--================================================
local function blockNativeInput()
	runHaxeCode([[
		if (game.strumsBlocked != null)
		{
			for (i in 0...game.strumsBlocked.length)
				game.strumsBlocked[i] = true;
		}
	]])
end

--================================================
-- Process Existing Chart
--================================================
local function processChart()
	runHaxeCode([[
		if (game.unspawnNotes == null)
			return;

		var noteGroups = new Map<Int, Array<games.objects.Note>>();

		//================================================
		// Collect all player tap notes.
		//================================================
		for (note in game.unspawnNotes)
		{
			if (note == null || !note.mustPress)
				continue;

			// Hide Sustain body.
			if (note.isSustainNote)
			{
				note.visible = false;
				note.alpha = 0;

				if (note.rgbShader != null)
					note.rgbShader.enabled = false;

				note.shader = null;
				continue;
			}

			var timeKey:Int = Std.int(Math.round(note.strumTime));

			if (!noteGroups.exists(timeKey))
				noteGroups.set(timeKey, []);

			noteGroups.get(timeKey).push(note);
		}

		//================================================
		// Merge simultaneous notes.
		//================================================
		for (timeKey in noteGroups.keys())
		{
			var group = noteGroups.get(timeKey);

			if (group == null || group.length == 0)
				continue;

			// The first arrow remains visible.
			var firstNote:games.objects.Note = group[0];

			for (i in 0...group.length)
			{
				var note = group[i];

				if (note == null)
					continue;

				// Move all player notes to Lane 0.
				note.noteData = 0;

				if (note == firstNote)
				{
					// Keep the first arrow.
					note.visible = true;
					note.alpha = 1;
					note.blockHit = false;
					note.ignoreNote = false;
				}
				else
				{
					// Hide all additional arrows.
					note.texture = ']]..blindNoteTexture..[[';
					note.visible = true;
					note.alpha = 1;
					note.blockHit = true;
					note.ignoreNote = true;

					if (note.rgbShader != null)
						note.rgbShader.enabled = false;

					note.shader = null;
				}
			}
		}

		//================================================
		// Convert all player notes to Lane 0.
		//================================================
		for (note in game.unspawnNotes)
		{
			if (note == null || !note.mustPress)
				continue;

			note.noteData = 0;

			// Sustain body remains hidden.
			if (note.isSustainNote)
			{
				note.visible = false;
				note.alpha = 0;

				if (note.rgbShader != null)
					note.rgbShader.enabled = false;

				note.shader = null;
			}
		}
	]])
end

--================================================
-- Process Already Spawned Notes
--================================================
local function processSpawnedNotes()
	runHaxeCode([[
		if (game.notes == null)
			return;

		for (note in game.notes)
		{
			if (note == null || !note.mustPress)
				continue;

			if (note.isSustainNote)
			{
				note.visible = false;
				note.alpha = 0;

				if (note.rgbShader != null)
					note.rgbShader.enabled = false;

				note.shader = null;

				continue;
			}

			note.noteData = 0;
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

	runHaxeCode([[
		if (game.notes == null)
			return;

		var note = game.notes.members[]]..id..[[];

		if (note == null || !note.mustPress)
			return;

		if (]]..tostring(isSustainNote)..[[)
		{
			// Hide Sustain body.
			note.visible = false;
			note.alpha = 0;

			if (note.rgbShader != null)
				note.rgbShader.enabled = false;

			note.shader = null;

			return;
		}

		// All player notes use Lane 0.
		note.noteData = 0;
	]])
end

--================================================
-- Hit OneNote
--================================================
local function hitOneNote(direction)
	runHaxeCode([[
		if (game.notes == null)
			return;

		var songPos:Float = Conductor.songPosition;
		var target:games.objects.Note = null;

		//================================================
		// Find the earliest visible player Note.
		//================================================
		for (note in game.notes)
		{
			if (note == null)
				continue;

			if (!note.exists || !note.alive)
				continue;

			if (!note.mustPress)
				continue;

			if (note.isSustainNote)
				continue;

			if (note.wasGoodHit)
				continue;

			if (note.blockHit || note.ignoreNote)
				continue;

			if (note.texture == ']]..blindNoteTexture..[[')
				continue;

			var canBeHit:Bool =
				note.strumTime >
					songPos - (Conductor.safeZoneOffset * note.lateHitMult)
				&&
				note.strumTime <
					songPos + (Conductor.safeZoneOffset * note.earlyHitMult);

			if (!canBeHit)
				continue;

			if (target == null || note.strumTime < target.strumTime)
				target = note;
		}

		if (target == null)
			return;

		var targetTime:Float = target.strumTime;

		//================================================
		// Normal Note judgement.
		//================================================
		game.goodNoteHit(target);

		//================================================
		// Play animation based on the actual key.
		//================================================
		var anim:String = 'singLEFT';

		if (']]..direction..[[' == 'DOWN')
			anim = 'singDOWN';
		else if (']]..direction..[[' == 'UP')
			anim = 'singUP';
		else if (']]..direction..[[' == 'RIGHT')
			anim = 'singRIGHT';

		if (game.boyfriend != null)
			game.boyfriend.playAnim(anim,true);

		//================================================
		// Automatically complete Sustain.
		//================================================
		if (target.tail != null)
		{
			for (tailNote in target.tail)
			{
				if (tailNote == null)
					continue;

				if (!tailNote.mustPress)
					continue;

				tailNote.canHold = true;
				tailNote.wasGoodHit = true;
				tailNote.visible = false;
				tailNote.alpha = 0;

				if (tailNote.rgbShader != null)
					tailNote.rgbShader.enabled = false;

				tailNote.shader = null;
			}
		}

		//================================================
		// Automatically process simultaneous arrows.
		//================================================
		for (note in game.notes)
		{
			if (note == null || note == target)
				continue;

			if (!note.exists || !note.alive)
				continue;

			if (!note.mustPress)
				continue;

			if (note.isSustainNote)
				continue;

			if (Math.abs(note.strumTime - targetTime) <= ]]..oneNoteMergeTolerance..[[)
			{
				note.wasGoodHit = true;
				note.blockHit = true;
				note.ignoreNote = true;

				// Automatically complete duplicate Sustain.
				if (note.tail != null)
				{
					for (tailNote in note.tail)
					{
						if (tailNote == null)
							continue;

						tailNote.canHold = true;
						tailNote.wasGoodHit = true;
						tailNote.visible = false;
						tailNote.alpha = 0;
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
	processSpawnedNotes()

	oneNoteInitialized=true
end

--================================================
-- Update
--================================================
function onUpdate(elapsed)
	if not oneNoteInitialized or not isOneNoteEnabled() then
		return
	end

	-- Block NFE's native four-lane input.
	blockNativeInput()

	-- Any direction can hit the OneNote.
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