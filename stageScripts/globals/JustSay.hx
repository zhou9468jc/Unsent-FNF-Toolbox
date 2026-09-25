import flixel.text.FlxText;
import general.backend.language.Language;

var changed = false;
var errorReported = false;
var debugReported = false;

function debug(message:String) {
	trace("[Unsent's JustSay] " + message);
}

function reportError(message:String) {
	if (errorReported) return;

	errorReported = true;
	trace("[Unsent's JustSay] ERROR: " + message);
}

function onUpdatePost(elapsed) {
	if (changed) return;
	if (FlxG.state == null) return;
	if (!Std.isOfType(FlxG.state, LoadingState)) return;

	var state = cast(FlxG.state, LoadingState);

	if (!debugReported) {
		debugReported = true;
		debug("LoadingState detected.");
		debug("Members: " + state.members.length);
	}

	var justSayText:FlxText = null;

	for (obj in state.members) {
		if (obj == null) continue;
		if (!Std.isOfType(obj, FlxText)) continue;

		var text = cast(obj, FlxText);

		debug(
			"FlxText found: " +
			"x=" + text.x +
			", y=" + text.y +
			", width=" + text.width +
			", text=\"" + text.text + "\""
		);

		// LoadingState.hx 中 JustSay 的特征：
		// x = 10
		// width = FlxG.width
		if (Math.abs(text.x - 10) < 1 &&
			Math.abs(text.width - FlxG.width) < 1) {

			justSayText = text;
			debug("Possible JustSay FlxText found.");
			break;
		}
	}

	if (justSayText == null) {
		reportError("JustSay FlxText not found by position.");
		return;
	}

	debug("Original JustSay text: \"" + justSayText.text + "\"");
	debug("JustSay position: x=" + justSayText.x + ", y=" + justSayText.y);
	debug("JustSay width: " + justSayText.width);

	var justSayLang:String = null;

	try {
		debug("Calling Language.get(\"justsayLang\", \"main\")...");

		justSayLang = Language.get(
			"justsayLang",
			"main"
		);

		debug("Language.get result: " + justSayLang);
	} catch (e:Dynamic) {
		reportError("Failed to get justsayLang: " + e);
		return;
	}

	if (justSayLang == null || justSayLang.length == 0) {
		reportError("justsayLang is empty.");
		return;
	}

	var filename =
		"language/JustSay/JustSay-" +
		justSayLang +
		".txt";

	debug("Target file: " + filename);

	var content:String = null;

	try {
		debug("Calling Paths.getTextFromFile...");

		content = Paths.getTextFromFile(filename);
	} catch (e:Dynamic) {
		reportError(
			"Failed to read " +
			filename +
			": " +
			e
		);
		return;
	}

	if (content == null) {
		reportError(
			"Paths.getTextFromFile returned null: " +
			filename
		);
		return;
	}

	if (content.length == 0) {
		reportError(
			"File is empty: " +
			filename
		);
		return;
	}

	debug("File loaded successfully.");
	debug("Raw content length: " + content.length);

	var lines = content.split("\n");
	var validLines:Array<String> = [];

	for (line in lines) {
		line = StringTools.trim(line);

		if (line.length > 0)
			validLines.push(line);
	}

	debug("Total raw lines: " + lines.length);
	debug("Valid lines: " + validLines.length);

	if (validLines.length == 0) {
		reportError(
			"No valid lines found in: " +
			filename
		);
		return;
	}

	var index:Int = 0;

	try {
		index = FlxG.random.int(
			0,
			validLines.length - 1
		);

		debug("Random index: " + index);
		debug("Selected line: " + validLines[index]);
	} catch (e:Dynamic) {
		reportError(
			"Failed to select JustSay line: " +
			e
		);
		return;
	}

	try {
		justSayText.text =
			"Tags: " +
			validLines[index];

		changed = true;

		debug("JustSay text replaced successfully.");
		debug("Final text: " + justSayText.text);
	} catch (e:Dynamic) {
		reportError(
			"Failed to replace JustSay text: " +
			e
		);
	}
}

function onStateSwitch() {
	changed = false;
	errorReported = false;
	debugReported = false;
}