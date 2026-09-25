-- ============================================================
-- Unsent's Toolbox NF Ver
-- Language System
-- ============================================================

local lang = {}

local language = nil

if getModSetting then
	language = getModSetting("language")
end

if language == nil then
	language = "English"
end


if language == "中文" then

	lang.Language_Name = "中文"
	lang.Language_Current = "当前语言:"
	
	lang.FakeBotplay_ON = "Botplay文字：显示"
	lang.FakeBotplay_OFF = "Botplay文字：隐藏"
	lang.Botplay_ON = "Botplay：开启"
	lang.Botplay_OFF = "Botplay：关闭"

	lang.Practice_ON = "练习模式：开启"
	lang.Practice_OFF = "练习模式：关闭"


	lang.SoftPause_ON = "已进入软暂停"
	lang.SoftPause_OFF = "已退出软暂停"
	lang.SoftPause_Enable = "软暂停：已启用"
	lang.SoftPause_Text = "当前处于软暂停\n按{1}退出软暂停"

	lang.SoftResume_Error =
		"尝试退出软暂停错误：{1}"

	lang.SoftPause_Timeout =
		"软暂停初始化超时（3秒）"


	lang.Playback_Info =
		"播放倍率 {1} : {2} | 滚动速度 : {3} | 最终速度 : {4}"

	lang.Scroll_Info =
		"滚动速度 {1} : {2} | 播放倍率 : {3} | 最终速度 : {4}"

	lang.Playback_Reset =
		"播放倍率重置 : {1} | 滚动速度 : {2} | 最终速度 : {3}"

	lang.Scroll_Reset =
		"滚动速度重置 : {1} | 播放倍率 : {2} | 最终速度 : {3}"


	lang.Health_Reset =
		"血量重置 : 50%"

	lang.Health_Info =
		"血量{1} : {2}"


	lang.Warning_Version =
		"警告：引擎版本检测已关闭"

	lang.Warning_Debug =
		"此选项启用时无法关闭工具箱输出"

	lang.Error_Engine =
		"错误：当前运行环境不是NovaFlare Engine！"

	lang.Error_Stop =
		"Unsent's ToolBox 已停止"


	lang.Developer_Loaded =
		"Unsent's ToolBox 已加载"


	lang.Warning_NoReset =
		"警告：No Reset 未开启"

	lang.Warning_EnableNoReset =
		'请开启 No Reset 或更改键位后再尝试使用重置功能'


	lang.Botplay_TurnOff =
		"请先关闭 Botplay"


	lang.Toolbox_Print_ON =
		"工具箱输出：开启"
		

elseif language == "English" then

	lang.Language_Name = "English"
	lang.Language_Current = "Current Language:"

	lang.FakeBotplay_ON =
		"Fake Botplay: ON"

	lang.FakeBotplay_OFF =
		"Fake Botplay: OFF"

	lang.Botplay_ON =
		"Botplay: ON"

	lang.Botplay_OFF =
		"Botplay: OFF"

	lang.Practice_ON =
		"Practice Mode: Enabled"

	lang.Practice_OFF =
		"Practice Mode: Disabled"


	lang.SoftPause_ON =
		"Soft Pause: ON"

	lang.SoftPause_OFF =
		"Soft Pause: OFF"

	lang.SoftPause_Enable =
		"Soft Pause: Enabled"
	lang.SoftPause_Text = 
		"SOFT PAUSE\nPress {1} to Exit Soft Pause"

	lang.SoftResume_Error =
		"Soft Resume Error: {1}"

	lang.SoftPause_Timeout =
		"Soft Pause initialization timed out after 3 seconds!"


	lang.Playback_Info =
		"Playback Rate {1} : {2} | Scroll Speed : {3} | Song Speed : {4}"

	lang.Scroll_Info =
		"Scroll Speed {1} : {2} | Playback Rate : {3} | Song Speed : {4}"


	lang.Playback_Reset =
		"Playback Rate RESET : {1} | Scroll Speed : {2} | Song Speed : {3}"

	lang.Scroll_Reset =
		"Scroll Speed RESET : {1} | Playback Rate : {2} | Song Speed : {3}"


	lang.Health_Reset =
		"Health RESET : 50%"

	lang.Health_Info =
		"Health {1} : {2}"


	lang.Warning_Version =
		"WARNING: Engine Version Check Disabled!"

	lang.Warning_Debug =
		"Debug output cannot be disabled while this option is enabled."


	lang.Error_Engine =
		"ERROR: NovaFlare Engine required!"

	lang.Error_Stop =
		"Unsent's ToolBox stopped."


	lang.Developer_Loaded =
		"Unsent's ToolBox Loaded"


	lang.Warning_NoReset =
		"WARNING: No Reset is disabled!"

	lang.Warning_EnableNoReset =
		'Please enable No Reset before using "Reset Property"!'


	lang.Botplay_TurnOff =
		"Please turn OFF Botplay first!"


	lang.Toolbox_Print_ON =
		"Toolbox Print: ON"

end


return lang