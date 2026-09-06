--================================================
--Disable Botplay
--================================================
function disableBotplayCreate()
	if getModSetting('disableBotplay') then
		setProperty('botplayTxt.text','NO Botplay Mode')
		setProperty('botplayTxt.visible',true)
		setProperty('cpuControlled',false)
	end
end

function disableBotplayUpdate()
	if getModSetting('disableBotplay') then
		setProperty('botplayTxt.text','NO Botplay Mode')
		setProperty('botplayTxt.visible',true)
		if getProperty('cpuControlled') then
			setProperty('cpuControlled',false)
		end
	end
end

--================================================
--Miss Limit
--================================================
local missLimitDying=false

function missLimitUpdate()
	local missLimit=getModSetting('missLimit')
	if missLimit==-1 or missLimitDying then
		return
	end

	if getProperty('songMisses')>missLimit then
		missLimitDying=true

		makeLuaText('missLimitDieText','  DIE!!!  ',0,0,0)
		setTextSize('missLimitDieText',200)
		setTextColor('missLimitDieText','FF0000')
		setTextAlignment('missLimitDieText','center')
		setObjectCamera('missLimitDieText','other')
		addLuaText('missLimitDieText')
		screenCenter('missLimitDieText','xy')

		runTimer('missLimitDeath',1)
	end
end

function missLimitDeath()
	setHealth(0)
end

function updateMissLimitText()
	local missLimit=getModSetting('missLimit')
	if missLimit==-1 or missLimitDying then
		return
	end

	local misses=getProperty('songMisses')
	local text=getProperty('scoreTxt.text')
	local newText=text:gsub('Misses:%s*[^|]*','Misses: '..misses..'/'..missLimit..' ')

	if newText~=text then
		setProperty('scoreTxt.text',newText)
	end
end

--================================================
--Score Text Color
--================================================
local scoreColors={
	White='FFFFFF',Black='000000',
	Red='FF0000',DarkRed='8B0000',
	Green='00FF00',DarkGreen='006400',
	Blue='0000FF',DarkBlue='00008B',
	SkyBlue='87CEEB',DodgerBlue='1E90FF',
	Cyan='00FFFF',Teal='008080',
	Yellow='FFFF00',Gold='FFD700',
	Orange='FFA500',Coral='FF7F50',
	Purple='800080',Violet='EE82EE',
	Pink='FF69B4',HotPink='FF1493',
	Magenta='FF00FF',
	Brown='A52A2A',Chocolate='D2691E',
	Gray='808080',DarkGray='404040',
	LightGray='D3D3D3',Silver='C0C0C0'
}

local scoreColorList={
	'FFFFFF','000000',
	'FF0000','8B0000',
	'00FF00','006400',
	'0000FF','00008B',
	'87CEEB','1E90FF',
	'00FFFF','008080',
	'FFFF00','FFD700',
	'FFA500','FF7F50',
	'800080','EE82EE',
	'FF69B4','FF1493',
	'FF00FF',
	'A52A2A','D2691E',
	'808080','404040',
	'D3D3D3','C0C0C0'
}

local rainbowTime=0

function hexToRGB(hex)
	return tonumber(hex:sub(1,2),16),tonumber(hex:sub(3,4),16),tonumber(hex:sub(5,6),16)
end

function rgbToHex(r,g,b)
	return string.format('%02X%02X%02X',math.floor(r),math.floor(g),math.floor(b))
end

function getRainbowColor(elapsed)
	local rainbowSpeed=getModSetting('rainbowSpeed')
	rainbowTime=rainbowTime+elapsed*rainbowSpeed

	local count=#scoreColorList
	local pos=rainbowTime%count
	local index=math.floor(pos)+1
	local nextIndex=index%count+1
	local t=pos-math.floor(pos)

	local r1,g1,b1=hexToRGB(scoreColorList[index])
	local r2,g2,b2=hexToRGB(scoreColorList[nextIndex])

	return rgbToHex(
		r1+(r2-r1)*t,
		g1+(g2-g1)*t,
		b1+(b2-b1)*t
	)
end

function getScoreTextColor(elapsed)
	local color=getModSetting('scoreTextColor')

	if color=='Rainbow' then
		return getRainbowColor(elapsed or 0)
	elseif color=='Follow Player' then
		local r=getProperty('boyfriend.healthColorArray[0]')
		local g=getProperty('boyfriend.healthColorArray[1]')
		local b=getProperty('boyfriend.healthColorArray[2]')

		if r~=nil and g~=nil and b~=nil then
			return string.format('%02X%02X%02X',r,g,b)
		end
	elseif color=='Follow Op.' then
		local r=getProperty('dad.healthColorArray[0]')
		local g=getProperty('dad.healthColorArray[1]')
		local b=getProperty('dad.healthColorArray[2]')

		if r~=nil and g~=nil and b~=nil then
			return string.format('%02X%02X%02X',r,g,b)
		end
	elseif color=='Custom' then
		local r=getModSetting('textColorR') or 255
		local g=getModSetting('textColorG') or 255
		local b=getModSetting('textColorB') or 255

		return string.format(
			'%02X%02X%02X',
			math.max(0,math.min(255,r)),
			math.max(0,math.min(255,g)),
			math.max(0,math.min(255,b))
		)
	elseif color~='Disable' and scoreColors[color] then
		return scoreColors[color]
	end

	return nil
end

function scoreTextColorCreate()
	local color=getScoreTextColor(0)

	if color then
		setTextColor('scoreTxt',color)
	end
end

function scoreTextColorUpdate(elapsed)
	local color=getScoreTextColor(elapsed)

	if color then
		setTextColor('scoreTxt',color)
	end
end

--================================================
--Blind Play
--================================================
local blindPlayTimer=0

function applyBlindPlay()
	local mode=getModSetting('blindPlay')

	if mode=='Disable' then
		return
	end

	runHaxeCode([[
		function hideBlindNote(note:games.objects.Note)
		{
			if (note == null || note.noteData < 0)
				return;

			var mode = ']]..mode..[[';

			if (mode == 'Only Player' && !note.mustPress)
				return;

			if (mode == 'All' || (mode == 'Only Player' && note.mustPress))
			{
				note.texture = 'noteSkins/BlindNote';

				if (note.rgbShader != null)
					note.rgbShader.enabled = false;

				note.shader = null;
			}
		}

		if (game.unspawnNotes != null)
		{
			for (note in game.unspawnNotes)
				hideBlindNote(note);
		}

		if (game.notes != null)
		{
			for (note in game.notes)
				hideBlindNote(note);
		}
	]])
end

function blindPlayCreate()
	applyBlindPlay()
end

function blindPlayUpdate(elapsed)
	if getModSetting('blindPlay')=='Disable' then
		return
	end

	blindPlayTimer=blindPlayTimer+elapsed

	if blindPlayTimer>=0.1 then
		blindPlayTimer=0
		applyBlindPlay()
	end
end

--================================================
--Main
--================================================
function onCreatePost()
	blindPlayCreate()
end

function onCreate()
	disableBotplayCreate()
	scoreTextColorCreate()
end

function onUpdate(elapsed)
	disableBotplayUpdate()
	missLimitUpdate()
	blindPlayUpdate(elapsed)
end

function onUpdatePost(elapsed)
	updateMissLimitText()
	scoreTextColorUpdate(elapsed)
end

function onTimerCompleted(tag)
	if tag=='missLimitDeath' then
		missLimitDeath()
	end
end