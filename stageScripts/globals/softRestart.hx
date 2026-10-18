import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import states.titleState.TitleState;

// ===== 配置 =====

// 长按重启时间，单位：毫秒（ms）
var restartHoldDuration:Float = 3000;

// 进度条外边距
var restartBarMargin:Float = 12;

// 进度条高度与边框宽度
var restartBarHeight:Int = 12;
var restartBarBorder:Int = 2;

// ===== 状态变量 =====
var restartHoldTime:Float = 0;
var restartProgressBar:FlxSprite = null;
var restartProgressBackground:FlxSprite = null;
var restartCamera:FlxCamera = null;

var restarting:Bool = false;
var waitingForTitleRestart:Bool = false;
var createdState:Dynamic = null;

// ===== 创建独立摄像机层级 =====
function createRestartCamera():Void {
	if (restartCamera != null)
		return;

	restartCamera = new FlxCamera();
	restartCamera.bgColor = FlxColor.TRANSPARENT;
	restartCamera.scroll.set(0, 0);
	restartCamera.target = null;

	FlxG.cameras.add(restartCamera, false);
}

// ===== 销毁独立摄像机 =====
function destroyRestartCamera():Void {
	if (restartCamera == null)
		return;

	try {
		FlxG.cameras.remove(restartCamera, true);
	} catch (e:Dynamic) {}

	restartCamera = null;
}

// ===== 获取重启按键 =====
function getRestartKey():String {
	var key:Dynamic = getModSetting("softRestartKey");

	if (key == null)
		return null;

	key = Std.string(key);

	if (key == "" || key == "Disable" || key == "None")
		return null;

	var keyMap:Map<String, String> = [
		"Space" => "SPACE",
		"Enter" => "ENTER",
		"Backspace" => "BACKSPACE",
		"Tab" => "TAB",
		"Escape" => "ESCAPE",
		"Insert" => "INSERT",
		"Delete" => "DELETE",
		"Home" => "HOME",
		"End" => "END",
		"Page Up" => "PAGEUP",
		"Page Down" => "PAGEDOWN",
		"Up" => "UP",
		"Down" => "DOWN",
		"Left" => "LEFT",
		"Right" => "RIGHT",
		"NumPad0" => "NUMPADZERO",
		"NumPad1" => "NUMPADONE",
		"NumPad2" => "NUMPADTWO",
		"NumPad3" => "NUMPADTHREE",
		"NumPad4" => "NUMPADFOUR",
		"NumPad5" => "NUMPADFIVE",
		"NumPad6" => "NUMPADSIX",
		"NumPad7" => "NUMPADSEVEN",
		"NumPad8" => "NUMPADEIGHT",
		"NumPad9" => "NUMPADNINE"
	];

	if (keyMap.exists(key))
		return keyMap.get(key);

	return key.toUpperCase();
}

// ===== 检查按键是否按住 =====
function isRestartKeyHeld(keyName:String):Bool {
	if (keyName == null || keyName == "")
		return false;

	var pressed = Reflect.getProperty(FlxG.keys, "pressed");

	if (pressed == null)
		return false;

	return Reflect.getProperty(pressed, keyName) == true;
}

// ===== 添加对象到当前状态 =====
function addToCurrentState(obj:Dynamic):Void {
	if (FlxG.state == null || obj == null)
		return;

	var addMethod = Reflect.field(FlxG.state, "add");

	if (addMethod != null)
		Reflect.callMethod(FlxG.state, addMethod, [obj]);
}

// ===== 移除显示对象 =====
function removeDisplayObject(obj:Dynamic):Void {
	if (obj == null)
		return;

	try {
		if (FlxG.state != null) {
			var removeMethod = Reflect.field(FlxG.state, "remove");

			if (removeMethod != null)
				Reflect.callMethod(FlxG.state, removeMethod, [obj, false]);
		}
	} catch (e:Dynamic) {}

	try {
		obj.destroy();
	} catch (e:Dynamic) {}
}

// ===== 清理 UI 和独立层级 =====
function clearRestartUI():Void {
	removeDisplayObject(restartProgressBar);
	removeDisplayObject(restartProgressBackground);

	restartProgressBar = null;
	restartProgressBackground = null;
	createdState = null;

	destroyRestartCamera();
}

// ===== 创建红色进度条与黑色边框 =====
function createRestartProgressBar():Void {
	if (FlxG.state == null)
		return;

	if (restartProgressBar != null && createdState == FlxG.state)
		return;

	clearRestartUI();
	createRestartCamera();

	createdState = FlxG.state;

	var barWidth:Int = Std.int(
		FlxG.width - restartBarMargin * 2
	);

	var innerWidth:Int = barWidth - restartBarBorder * 2;
	var innerHeight:Int = restartBarHeight - restartBarBorder * 2;

	if (barWidth <= 0 || innerWidth <= 0 || innerHeight <= 0)
		return;

	var x:Float = restartBarMargin;
	var y:Float = restartBarMargin;

	// 黑色边框背景
	var background = new FlxSprite(x, y);
	background.makeGraphic(
		barWidth,
		restartBarHeight,
		FlxColor.BLACK
	);
	background.scrollFactor.set(0, 0);
	background.cameras = [restartCamera];
	background.antialiasing = false;

	addToCurrentState(background);
	restartProgressBackground = background;

	// 红色进度条
	var bar = new FlxSprite(
		x + restartBarBorder,
		y + restartBarBorder
	);
	bar.makeGraphic(
		innerWidth,
		innerHeight,
		FlxColor.RED
	);
	bar.scrollFactor.set(0, 0);
	bar.cameras = [restartCamera];
	bar.antialiasing = false;

	addToCurrentState(bar);
	restartProgressBar = bar;
}

// ===== 更新进度条 =====
function updateRestartProgressBar():Void {
	if (restartProgressBar == null)
		return;

	var fullWidth:Int = Std.int(
		FlxG.width
		- restartBarMargin * 2
		- restartBarBorder * 2
	);

	var innerHeight:Int = restartBarHeight - restartBarBorder * 2;

	var progress:Float = 0;

	if (restartHoldDuration > 0)
		progress = restartHoldTime / restartHoldDuration;

	if (progress < 0)
		progress = 0;

	if (progress > 1)
		progress = 1;

	var currentWidth:Int = Std.int(fullWidth * progress);

	restartProgressBar.setGraphicSize(
		currentWidth,
		innerHeight
	);
	restartProgressBar.updateHitbox();

	restartProgressBar.x = restartBarMargin + restartBarBorder;
	restartProgressBar.y = restartBarMargin + restartBarBorder;
}

// ===== 执行软重启 =====
function performSoftRestart():Void {
	if (restarting)
		return;

	restarting = true;
	waitingForTitleRestart = true;

	clearRestartUI();

	TitleState.initialized = false;
	TitleState.closedState = false;

	FlxG.sound.music.fadeOut(0.3);

	FlxG.camera.fade(
		FlxColor.BLACK,
		0.5,
		false,
		FlxG.resetGame,
		false
	);
}

// ===== 每帧更新 =====
function onUpdate(elapsed:Float):Void {
	if (restarting)
		return;

	var keyName:String = getRestartKey();

	if (keyName == null || restartHoldDuration <= 0) {
		restartHoldTime = 0;
		clearRestartUI();
		return;
	}

	if (FlxG.state == null)
		return;

	if (isRestartKeyHeld(keyName)) {
		// elapsed 为秒，转换成毫秒
		restartHoldTime += elapsed * 1000;

		if (restartHoldTime > restartHoldDuration)
			restartHoldTime = restartHoldDuration;

		createRestartProgressBar();
		updateRestartProgressBar();

		if (restartHoldTime >= restartHoldDuration)
			performSoftRestart();
	} else {
		restartHoldTime = 0;
		clearRestartUI();
	}
}

// ===== 状态切换 =====
function onStateSwitch():Void {
	clearRestartUI();
	restartHoldTime = 0;

	if (!waitingForTitleRestart)
		restarting = false;
}