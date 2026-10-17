// Unsent - Pause Music Position Fix
// Target: NovaFlare Engine 1.2.1-HF
// Path: stageScripts/globals/pauseVol.hx
// 功能：尝试让暂停音乐从头播放，并输出调试信息。

var pauseSubStateClass = Type.resolveClass("substates.PauseSubState");

var lastMusic:Dynamic = null;
var lastSongName:String = "";
var lastLoggedTime:Float = -1;
var resetAttempts:Int = 0;
var resetPending:Bool = false;
var resetDone:Bool = false;

var maxResetAttempts:Int = 30;

// 读取暂停音乐对象
function getPauseMusic():Dynamic
{
    if (pauseSubStateClass == null)
        return null;

    return Reflect.field(pauseSubStateClass, "pauseMusic");
}

// 读取当前暂停曲目名称
function getPauseSongName():String
{
    if (pauseSubStateClass == null)
        return "";

    var name = Reflect.field(pauseSubStateClass, "songName");
    return name == null ? "" : Std.string(name);
}

// 尝试重置播放位置
function resetPauseMusic(music:Dynamic):Void
{
    if (music == null)
        return;

    try
    {
        music.time = 0;
        music.pause();
        music.play(false, 0);
        music.time = 0;

        trace("[Unsent] Attempted to restart pause music from 0.");
    }
    catch (e:Dynamic)
    {
        trace("[Unsent] Failed to reset pause music: " + Std.string(e));
    }
}

// 全局更新：暂停菜单打开期间也会执行
function onUpdatePost(elapsed:Float):Void
{
    var music = getPauseMusic();

    if (music == null)
    {
        lastMusic = null;
        lastSongName = "";
        lastLoggedTime = -1;
        resetAttempts = 0;
        resetPending = false;
        resetDone = false;
        return;
    }
	music.volume = 0.5;
    var songName = getPauseSongName();

    // 对象或曲目变化时，准备重置
    if (music != lastMusic || songName != lastSongName)
    {
        lastMusic = music;
        lastSongName = songName;
        lastLoggedTime = -1;
        resetAttempts = 0;
        resetPending = true;
        resetDone = false;

        trace("[Unsent] Detected pause music: " + songName);
    }

    // 暂停音乐初始化期间，多次尝试重置。
    // 如果引擎随后再次覆盖播放位置，就可能仍然无法生效。
    if (resetPending && !resetDone)
    {
        resetPauseMusic(music);
        resetAttempts++;

        if (resetAttempts >= maxResetAttempts)
        {
            resetPending = false;
            resetDone = true;
            trace("[Unsent] Pause music reset attempts finished.");
        }
    }

    // 输出播放位置，方便确认是否从头开始
    try
    {
        var currentTime:Float = music.time;

        if (lastLoggedTime < 0 || Math.abs(currentTime - lastLoggedTime) >= 1000)
        {
            lastLoggedTime = currentTime;
            trace("[Unsent] Pause music time: " + currentTime + " / " + music.length);
        }
    }
    catch (e:Dynamic)
    {
        trace("[Unsent] Could not read pause music time.");
    }
}