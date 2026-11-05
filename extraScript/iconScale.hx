// ============================================================
// Health Icon Beat Scale
// V-Slice-style Beat Bop
// ============================================================

// Settings
var enablePlayer = true;
var enableOpponent = true;

var beatInterval = 4;
var bopScale = 1.2;
var bopDuration = 0.175;

// Recovery timers
var playerTimer = 0.0;
var opponentTimer = 0.0;

// Disable original NFE icon scale recovery
function onCreatePost()
{
    game.updateIconsScale = function(elapsed:Float) {};
}

// Beat bop
function bopIcon(icon:Dynamic, isPlayer:Bool)
{
    if (icon == null) return;

    icon.scale.set(bopScale, bopScale);
    icon.updateHitbox();

    if (isPlayer)
        playerTimer = bopDuration;
    else
        opponentTimer = bopDuration;
}

// Update recovery
function updateIconScale(icon:Dynamic, timer:Float, elapsed:Float, isPlayer:Bool)
{
    if (icon == null || timer <= 0) return;

    timer -= elapsed;

    if (timer <= 0)
    {
        icon.scale.set(1.0, 1.0);
        icon.updateHitbox();

        if (isPlayer)
            playerTimer = 0;
        else
            opponentTimer = 0;

        return;
    }

    var progress = timer / bopDuration;
    var scale = 1.0 + (bopScale - 1.0) * progress * progress;

    icon.scale.set(scale, scale);
    icon.updateHitbox();

    if (isPlayer)
        playerTimer = timer;
    else
        opponentTimer = timer;
}

// Frame update
function onUpdatePost(elapsed:Float)
{
    updateIconScale(game.iconP1, playerTimer, elapsed, true);
    updateIconScale(game.iconP2, opponentTimer, elapsed, false);
}

// Every beat (4 steps)
function onStepHit()
{
    if (beatInterval <= 0 || curStep % beatInterval != 0)
        return;

    if (enablePlayer)
        bopIcon(game.iconP1, true);

    if (enableOpponent)
        bopIcon(game.iconP2, false);
}