var lastPlayState:Dynamic = null;

function onUpdatePost(elapsed:Float):Void {
    var cls = Type.resolveClass("games.PlayState");
    if (cls == null) return;

    if (getModSetting("holdCover") != true) return;

    var ps = Reflect.field(cls, "instance");

    if (ps == null) {
        lastPlayState = null;
        return;
    }

    if (ps == lastPlayState) return;

    var group = Reflect.field(ps, "noteGroup");
    var sustain = Reflect.field(ps, "sustainLayer");
    var strum = Reflect.field(ps, "strumLineNotes");

    if (group == null || sustain == null || strum == null)
        return;

    group.remove(sustain, false);

    // 重新获取判定线索引，避免移除对象后索引偏移
    var strumIndex = group.members.indexOf(strum);
    if (strumIndex < 0) return;

    group.insert(strumIndex + 1, sustain);

    lastPlayState = ps;

    trace("[Unsent] Sustain layer moved above strumLineNotes.");
}