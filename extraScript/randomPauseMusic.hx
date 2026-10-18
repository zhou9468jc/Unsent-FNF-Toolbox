// Unsent - Random Pause Music
// NFE 1.2.1-HF

// 可用的暂停音乐列表
var pauseMusicList:Array<String> = [
    "pause/1", "pause/2", "pause/3", "pause/4", "pause/5",
    "pause/6", "pause/7", "pause/8", "pause/9", "pause/10",
    "pause/11", "pause/12", "pause/13", "pause/14", "pause/15",
    "pause/16", "pause/17", "pause/18"
];

var lastPauseMusic:String = null;
var lastHandledMusic:Dynamic = null;
var pauseSubStateClass = Type.resolveClass("substates.PauseSubState");

// 随机选择暂停音乐，排除上一首及编号相邻的歌曲
function selectRandomPauseMusic():String
{
    var candidates:Array<String> = [];
    var lastIndex:Int = -1;

    if (lastPauseMusic != null)
    {
        var lastSlash = lastPauseMusic.lastIndexOf("/");
        var parsedLast = Std.parseInt(lastPauseMusic.substring(lastSlash + 1));

        if (parsedLast != null)
            lastIndex = parsedLast;
    }

    for (music in pauseMusicList)
    {
        var slash = music.lastIndexOf("/");
        var parsedIndex = Std.parseInt(music.substring(slash + 1));

        if (lastPauseMusic != null)
        {
            if (music == lastPauseMusic)
                continue;

            if (parsedIndex != null && lastIndex >= 0 &&
                Math.abs(parsedIndex - lastIndex) <= 1)
                continue;
        }

        candidates.push(music);
    }

    if (candidates.length == 0)
    {
        trace("[Unsent] No eligible pause music found.");
        return pauseMusicList.length > 0 ? pauseMusicList[0] : null;
    }

    var selected = candidates[FlxG.random.int(0, candidates.length - 1)];
    lastPauseMusic = selected;
    return selected;
}

// 暂停前选择音乐
function onPause()
{
    if (pauseMusicList == null || pauseMusicList.length == 0)
    {
        trace("[Unsent] Pause music list is empty.");
        return;
    }

    var selectedMusic = selectRandomPauseMusic();

    if (selectedMusic == null)
        return;

    if (pauseSubStateClass != null)
        Reflect.setField(pauseSubStateClass, "songName", selectedMusic);

    trace("[Unsent] Selected pause music: " + selectedMusic);
}

// 确保暂停音乐从头开始
var pauseMusicResetFrames:Int = 0;
var pauseMusicResetTarget:Dynamic = null;

function onUpdatePost(elapsed:Float)
{
    if (pauseSubStateClass == null)
        return;

    var music = Reflect.field(pauseSubStateClass, "pauseMusic");

    if (music == null)
    {
        pauseMusicResetTarget = null;
        pauseMusicResetFrames = 0;
        return;
    }

    // 新的暂停音乐对象出现时，开始重置
    if (music != pauseMusicResetTarget)
    {
        pauseMusicResetTarget = music;
        pauseMusicResetFrames = 0;
    }

    // 连续重置数帧，防止引擎初始化时再次设置随机位置
    if (pauseMusicResetFrames < 5)
    {
        music.time = 0;
        pauseMusicResetFrames++;
    }
}