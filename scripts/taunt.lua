function useInterpreterToGetKeySetting(s) s=getModSetting(s) return({['Disable']='Disable',['A']='A',['B']='B',['C']='C',['D']='D',['E']='E',['F']='F',['G']='G',['H']='H',['I']='I',['J']='J',['K']='K',['L']='L',['M']='M',['N']='N',['O']='O',['P']='P',['Q']='Q',['R']='R',['S']='S',['T']='T',['U']='U',['V']='V',['W']='W',['X']='X',['Y']='Y',['Z']='Z',['1']='ONE',['2']='TWO',['3']='THREE',['4']='FOUR',['5']='FIVE',['6']='SIX',['7']='SEVEN',['8']='EIGHT',['9']='NINE',['0']='ZERO',['`~']='GRAVEACCENT',['-_']='MINUS',['=+']='PLUS',['[{']='LBRACKET',[']}']='RBRACKET',['\\|']='BACKSLASH',[';:']='SEMICOLON',["' \""]='QUOTE',[',<']='COMMA',['.>']='PERIOD',['/?']='SLASH',['Space']='SPACE',['Enter']='ENTER',['Backspace']='BACKSPACE',['Tab']='TAB',['Caps Lock']='CAPSLOCK',['Shift']='SHIFT',['Control']='CONTROL',['Alt']='ALT',['Escape']='ESCAPE',['Insert']='INSERT',['Delete']='DELETE',['Home']='HOME',['End']='END',['Page Up']='PAGEUP',['Page Down']='PAGEDOWN',['Up']='UP',['Down']='DOWN',['Left']='LEFT',['Right']='RIGHT',['F1']='F1',['F2']='F2',['F3']='F3',['F4']='F4',['F5']='F5',['F6']='F6',['F7']='F7',['F8']='F8',['F9']='F9',['F10']='F10',['F11']='F11',['F12']='F12',['NumLock']='NUMLOCK',['NumPad0']='NUMPADZERO',['NumPad1']='NUMPADONE',['NumPad2']='NUMPADTWO',['NumPad3']='NUMPADTHREE',['NumPad4']='NUMPADFOUR',['NumPad5']='NUMPADFIVE',['NumPad6']='NUMPADSIX',['NumPad7']='NUMPADSEVEN',['NumPad8']='NUMPADEIGHT',['NumPad9']='NUMPADNINE',['NumPad.']='NUMPADPERIOD',['NumPad+']='NUMPADPLUS',['NumPad-']='NUMPADMINUS',['NumPad*']='NUMPADMULTIPLY',['NumPad/']='NUMPADSLASH'})[s]or'NONE' end

function onUpdate()
	local taunt=useInterpreterToGetKeySetting("taunt")
	local pressed=false
	if taunt~='Disable' then
		pressed=keyboardJustPressed(taunt)
	end
	if pressed then
		local character=getModSetting('tauntCharacter')
		local duration=getModSetting('tauntDuration')
		local volume=getModSetting('tauntSoundVolume')
		triggerEvent('Hey!',character,tostring(duration))
		if volume>0 then
			playSound('hey',volume)
		end
	end
end