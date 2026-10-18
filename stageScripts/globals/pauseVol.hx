// Unsent - Random Pause Music + Pause Music Fix
// Target: NovaFlare Engine 1.2.1-HF2
// Path: stageScripts/globals/pauseVol.hx

var pauseSubStateClass = Type.resolveClass("substates.PauseSubState");

var pauseMusicList:Array<String> = [
    "pause/1", "pause/2", "pause/3", "pause/4", "pause/5",
    "pause/6", "pause/7", "pause/8", "pause/9", "pause/10",
    "pause/11", "pause/12", "pause/13", "pause/14", "pause/15",
    "pause/16", "pause/17", "pause/18"
];

var lastPauseMusic:String = null;
var lastMusic:Dynamic = null;
var lastSongName:String = "";
var lastLoggedTime:Float = -1;

var pauseMusicInitialized:Bool = false;
var pauseSelectionLocked:Bool = false;
var pauseKeyWasPressed:Bool = false;
var wasPaused:Bool = false;

// 获取暂停音乐设置
function isPauseMusicEnabled():Bool {
    return getModSetting("pauseMusic") == true;
}

// 获取暂停音乐对象
function getPauseMusic():Dynamic {
    if (pauseSubStateClass == null)
        return null;
    return Reflect.field(pauseSubStateClass, "pauseMusic");
}

// 获取当前曲目名称
function getPauseSongName():String {
    if (pauseSubStateClass == null)
        return "";
    var name = Reflect.field(pauseSubStateClass, "songName");
    return name == null ? "" : Std.string(name);
}

// 随机选曲：排除上一首及编号相邻的歌曲
function selectRandomPauseMusic():String {
    var candidates:Array<String> = [];
    var lastIndex:Int = -1;

    if (lastPauseMusic != null) {
        var slash = lastPauseMusic.lastIndexOf("/");
        var parsed = Std.parseInt(lastPauseMusic.substring(slash + 1));
        if (parsed != null)
            lastIndex = parsed;
    }

    for (music in pauseMusicList) {
        if (music == lastPauseMusic)
            continue;

        var slash = music.lastIndexOf("/");
        var parsed = Std.parseInt(music.substring(slash + 1));

        if (lastIndex >= 0 && parsed != null &&
            Math.abs(parsed - lastIndex) <= 1)
            continue;

        candidates.push(music);
    }

    if (candidates.length == 0) {
        for (music in pauseMusicList) {
            if (music != lastPauseMusic)
                candidates.push(music);
        }
    }

    if (candidates.length == 0)
        return null;

    var selected = candidates[FlxG.random.int(0, candidates.length - 1)];
    lastPauseMusic = selected;
    return selected;
}

// 通过反射获取 PlayState
function getPlayState():Dynamic {
    var playStateClass = Type.resolveClass("games.PlayState");
    if (playStateClass == null)
        return null;
    return Reflect.field(playStateClass, "instance");
}

// 在暂停菜单创建前选曲
function onUpdate(elapsed:Float):Void {
    if (!isPauseMusicEnabled() || pauseSubStateClass == null)
        return;

    try {
        var playState = getPlayState();
        if (playState == null)
            return;

        // 检测是否已打开暂停子状态
        var subState = Reflect.getProperty(playState, "subState");
        var pauseClass = Type.resolveClass("substates.PauseSubState");
        var currentlyPaused = subState != null &&
            pauseClass != null &&
            Std.isOfType(subState, pauseClass);

        // 退出暂停界面后解锁，供下一次暂停使用
        if (wasPaused && !currentlyPaused) {
            pauseSelectionLocked = false;
            pauseMusicInitialized = false;
            pauseKeyWasPressed = false;
            trace("[Unsent] Pause session ended; selection unlocked.");
        }

        wasPaused = currentlyPaused;

        // 已在暂停界面时，不处理暂停键，避免 Enter 或菜单操作重新随机
        if (currentlyPaused)
            return;

        var controls = Reflect.getProperty(playState, "controls");
        if (controls == null)
            return;

        var pausePressed:Bool = Reflect.getProperty(controls, "PAUSE") == true;

        if (!pausePressed) {
            pauseKeyWasPressed = false;
            return;
        }

        if (pauseKeyWasPressed)
            return;

        pauseKeyWasPressed = true;

        if (pauseSelectionLocked)
            return;

        var selected = selectRandomPauseMusic();
        if (selected == null)
            return;

        Reflect.setField(pauseSubStateClass, "songName", selected);
        pauseSelectionLocked = true;
        pauseMusicInitialized = false;

        trace("[Unsent] Selected pause music: " + selected);
    } catch (e:Dynamic) {
        trace("[Unsent] Pause input check failed: " + Std.string(e));
    }
}

// 从头播放当前暂停音乐
function resetPauseMusic(music:Dynamic):Void {
    if (music == null)
        return;

    try {
        music.pause();
        music.time = 0;
        music.play(false, 0);
        music.volume = 0.5;
        trace("[Unsent] Started pause music from 0.");
    } catch (e:Dynamic) {
        trace("[Unsent] Failed to initialize pause music: " + Std.string(e));
    }
}

// 固定音量；每次暂停会话只初始化一次
function onUpdatePost(elapsed:Float):Void {
    if (!isPauseMusicEnabled())
        return;

    var music = getPauseMusic();
    if (music == null)
        return;

    // 不再因为音乐对象被替换而重置播放时间
    if (!pauseMusicInitialized) {
        resetPauseMusic(music);
        pauseMusicInitialized = true;
        lastMusic = music;
        lastSongName = getPauseSongName();
        lastLoggedTime = -1;
    }

    try {
        music.volume = 0.5;
    } catch (e:Dynamic) {
        trace("[Unsent] Could not lock pause music volume.");
    }

    try {
        var currentTime:Float = music.time;
        if (lastLoggedTime < 0 ||
            Math.abs(currentTime - lastLoggedTime) >= 1000)
            lastLoggedTime = currentTime;
    } catch (e:Dynamic) {
        trace("[Unsent] Could not read pause music time.");
    }
}