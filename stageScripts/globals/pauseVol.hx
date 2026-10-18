// Unsent - Pause Music Position Fix
// Target: NovaFlare Engine 1.2.1-HF2
// Path: stageScripts/globals/pauseVol.hx
// 功能：读取暂停音乐设置、固定音量，并尝试让暂停音乐从头播放。

var pauseSubStateClass = Type.resolveClass("substates.PauseSubState");

var lastMusic:Dynamic = null;
var lastSongName:String = "";
var lastLoggedTime:Float = -1;
var resetAttempts:Int = 0;
var resetPending:Bool = false;
var resetDone:Bool = false;
var maxResetAttempts:Int = 1;

// 获取暂停音乐设置。
// 每次调用时读取，避免只在 HScript 初始化时读取一次。
// 读取模组设置
function isPauseMusicEnabled():Bool {
    var result:Dynamic = getModSetting("pauseMusic");
    return result == true;
}

// 获取暂停音乐对象
function getPauseMusic():Dynamic {
    if (pauseSubStateClass == null)
        return null;

    return Reflect.field(pauseSubStateClass, "pauseMusic");
}

// 获取当前暂停曲目名称
function getPauseSongName():String {
    if (pauseSubStateClass == null)
        return "";

    var name = Reflect.field(pauseSubStateClass, "songName");
    return name == null ? "" : Std.string(name);
}

// 尝试从头播放暂停音乐
function resetPauseMusic(music:Dynamic):Void {
    if (music == null)
        return;

    try {
        music.pause();
        music.time = 0;
        music.play(false, 0);
        trace("[Unsent] Attempted to restart pause music from 0.");
    } catch (e:Dynamic) {
        trace("[Unsent] Failed to reset pause music: " + Std.string(e));
    }
}

// 暂停菜单更新期间执行
function onUpdatePost(elapsed:Float):Void {
    if (!isPauseMusicEnabled())
        return;

    var music = getPauseMusic();

    if (music == null) {
        lastMusic = null;
        lastSongName = "";
        lastLoggedTime = -1;
        resetAttempts = 0;
        resetPending = false;
        resetDone = false;
        return;
    }

    // 固定暂停音乐音量
    try {
        music.volume = 0.5;
    } catch (e:Dynamic) {
        trace("[Unsent] Could not set pause music volume.");
    }

    var songName = getPauseSongName();

    // 音乐对象或曲目变化时，重新开始重置流程
    if (music != lastMusic || songName != lastSongName) {
        lastMusic = music;
        lastSongName = songName;
        lastLoggedTime = -1;
        resetAttempts = 0;
        resetPending = true;
        resetDone = false;

        trace("[Unsent] Detected pause music: " + songName);
    }

    // 初始化期间最多尝试重置五次
    if (resetPending && !resetDone) {
        resetPauseMusic(music);
        resetAttempts++;

        if (resetAttempts >= maxResetAttempts) {
            resetPending = false;
            resetDone = true;
            trace("[Unsent] Pause music reset attempts finished.");
        }
    }

    // 每隔约一秒输出一次播放位置，方便调试
    try {
        var currentTime:Float = music.time;

        if (lastLoggedTime < 0 || Math.abs(currentTime - lastLoggedTime) >= 1000) {
            lastLoggedTime = currentTime;
            // trace("[Unsent] Pause music time: " + currentTime + " / " + music.length);
        }
    } catch (e:Dynamic) {
        trace("[Unsent] Could not read pause music time.");
    }
}