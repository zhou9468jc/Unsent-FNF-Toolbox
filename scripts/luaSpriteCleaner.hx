// ============================================================
// Lua Sprite Cleaner
// 清理 camHUD 上的所有 Lua Sprite
// ============================================================

var cleanerEnabled = true;
var cleanerRemoved = 0;

function clearLuaHudSprites() {
	if (!cleanerEnabled || game == null || game.modchartSprites == null || !getModSetting("cleanShowCase") || !getModSetting("showCaseMode"))
		return;

    var tags = [];
    for (tag in game.modchartSprites.keys())
        tags.push(tag);

    cleanerRemoved = 0;

    for (tag in tags) {
        var spr = game.modchartSprites.get(tag);

        if (spr == null || spr.cameras == null)
            continue;

        if (spr.cameras.indexOf(game.camHUD) == -1)
            continue;

        // 从 State 中移除
        if (spr.alreadyAdded)
            game.remove(spr, true);

        spr.alreadyAdded = false;

        // 销毁 Sprite
        spr.kill();
        spr.destroy();

        // 从 Lua Sprite 注册表中移除
        game.modchartSprites.remove(tag);

        cleanerRemoved++;
    }

    if (cleanerRemoved > 0)
        trace('[Lua Sprite Cleaner] Removed: ' + cleanerRemoved);
}

// 歌曲开始时清理
function onSongStart() {
    clearLuaHudSprites();
}

// 持续监控新创建的 Lua Sprite
function onUpdatePost(elapsed) {
    clearLuaHudSprites();
}