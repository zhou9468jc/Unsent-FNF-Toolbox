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


--================================================
--Blind Play
--Apply When Note Spawn
--================================================

local blindPlayMode='Disable'

function onSpawnNote(index)

	if blindPlayMode=='Disable' then
		return
	end

	local mustPress=getPropertyFromGroup(
		'notes',
		index,
		'mustPress'
	)

	if blindPlayMode=='All' or (blindPlayMode=='Only Player' and mustPress) then

		setPropertyFromGroup(
			'notes',
			index,
			'texture',
			'noteSkins/BlindNote'
		)

		setPropertyFromGroup(
			'notes',
			index,
			'rgbShader.enabled',
			false
		)

		setPropertyFromGroup(
			'notes',
			index,
			'shader',
			nil
		)

	end
end
local function hasPlayerNotes(song)
    if not song or not song.notes then return false end

    for _, section in ipairs(song.notes) do
        local mustHit = section.mustHitSection == true

        for _, note in ipairs(section.sectionNotes or {}) do
            local noteData = tonumber(note[2])

            if noteData then
                local isPlayer = mustHit
                if noteData >= 4 then
                    isPlayer = not isPlayer
                end

                if isPlayer then return true end
            end
        end
    end

    return false
end

local function hasPlayerNotes()
    return runHaxeCode([[
        if (game == null) return false;

        for (note in game.unspawnNotes) {
            if (note.mustPress) return true;
        }

        for (note in game.notes) {
            if (note.mustPress) return true;
        }

        return false;
    ]])
end
function onSongStart()
    if blindPlayMode == 'Disable' then return end

    if not hasPlayerNotes() then
        unlockAchievement('noNote')
    end
end
--================================================
--Hide Debug Prints
--================================================
local HDP_enable = getModSetting("hideDebugPrints")
if HDP_enable == nil then HDP_enable = false end
function HDP_UpdatePost()
	if HDP_enable == true then
		debugPrint("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
	end
end
--================================================
--Main
--================================================

function onCreate()

	blindPlayMode=getModSetting('blindPlay')

	disableBotplayCreate()

end


function onUpdate(elapsed)

	disableBotplayUpdate()
	missLimitUpdate()

end


function onUpdatePost(elapsed)

	HDP_UpdatePost()
end


function onTimerCompleted(tag)

	if tag=='missLimitDeath' then
		missLimitDeath()
	end

end