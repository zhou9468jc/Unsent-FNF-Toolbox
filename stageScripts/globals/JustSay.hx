import flixel.text.FlxText;
import general.backend.language.Language;

var changed = false;

var failCount = 0;
var maxFail = 5;

var lastRandomIndex = -1;


function debug(msg)
{
	trace("[Unsent's JustSay] " + msg);
}


function onUpdatePost(elapsed)
{
	if (changed)
		return;

	if (FlxG.state == null)
		return;

	if (!Std.isOfType(FlxG.state, LoadingState))
		return;


	var state = FlxG.state;

	var target = null;


	// 查找 LoadingState 的 JustSay 文本
	for (obj in state.members)
	{
		if (obj == null)
			continue;

		if (!Std.isOfType(obj, FlxText))
			continue;


		var text = obj;


		if (Math.abs(text.x - 10) < 1 &&
			Math.abs(text.width - FlxG.width) < 1)
		{
			target = text;
			break;
		}
	}


	if (target == null)
		return;



	var lang = Language.get("justsayLang", "main");


	if (lang == null || lang.length <= 0)
	{
		failCount++;

		if (failCount >= maxFail)
		{
			debug("Language failed, keep original.");
			changed = true;
		}

		return;
	}



	// Lang-PT-BR -> PT-BR
	if (StringTools.startsWith(lang, "Lang-"))
	{
		lang = lang.substr(5);
	}



	var filePath = "JustSay/JustSay-Lang-" + lang + ".txt";


	var content = Paths.getTextFromFile(filePath);



	if (content == null || content.length <= 0)
	{
		failCount++;

		if (failCount >= maxFail)
		{
			debug("JustSay file missing: " + filePath);
			debug("Keep original text.");

			changed = true;
		}

		return;
	}



	var lines = [];


	for (line in content.split("\n"))
	{
		line = StringTools.trim(line);


		// 删除空行和注释
		if (line.length <= 0)
			continue;

		if (StringTools.startsWith(line, "#"))
			continue;


		lines.push(line);
	}



	if (lines.length <= 0)
	{
		debug("No valid JustSay lines.");
		changed = true;
		return;
	}



	// ==========================
	// Enhanced Random System
	// ==========================

	var randomIndex = lastRandomIndex;


	// 防止连续重复
	while (randomIndex == lastRandomIndex && lines.length > 1)
	{
		randomIndex = FlxG.random.int(
			0,
			lines.length - 1
		);
	}


	lastRandomIndex = randomIndex;


	// 加入时间扰动
	var timeSeed = Std.int(Date.now().getTime() % lines.length);


	randomIndex =
		(randomIndex + timeSeed) % lines.length;



	var result = lines[randomIndex];



	target.text = "Tags: " + result;



	debug("Language: " + lang);
	debug("File: " + filePath);
	debug("Line count: " + lines.length);
	debug("Random index: " + randomIndex);
	debug("Selected: " + result);



	changed = true;
}



function onStateSwitch()
{
	changed = false;

	failCount = 0;

	lastRandomIndex = -1;
}