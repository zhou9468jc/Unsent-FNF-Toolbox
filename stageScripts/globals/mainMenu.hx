import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;

var created = false;

function onUpdatePost(elapsed) {
	if (created) return;
	if (FlxG.state == null) return;
	if (!Std.isOfType(FlxG.state, MainMenuState)) return;

	var menu = cast(FlxG.state, MainMenuState);

	var reference = null;

	for (obj in menu.members) {
		if (obj == null) continue;
		if (!Std.isOfType(obj, FlxText)) continue;

		var t = cast(obj, FlxText);

		if (t.text.indexOf("NovaFlare Engine") >= 0) {
			reference = t;
			break;
		}

		if (t.text.indexOf("Friday Night Funkin") >= 0) {
			reference = t;
			break;
		}
	}

	if (reference == null) return;

	created = true;

	var text = new FlxText(
		12,
		FlxG.height - 64,
		400,
		"Unsent's Toolbox v 2.4.4",
		12
	);

	text.scrollFactor.set();

	text.setFormat(
		reference.font,
		16,
		reference.color,
		"left",
		FlxTextBorderStyle.OUTLINE,
		reference.borderColor
	);

	text.antialiasing = reference.antialiasing;

	menu.add(text);
	text.cameras = [menu.camHUD];
}
function onStateSwitch(){
	created = false;
}