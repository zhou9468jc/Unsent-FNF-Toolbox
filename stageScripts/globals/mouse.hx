import openfl.Lib;
import openfl.display.Bitmap;
import openfl.text.TextField;
import openfl.text.TextFormat;

// ============================================================
// 状态
// ============================================================

var showMouseCoordinates:Bool = false;
var fixMouseCursorLayer:Bool = false;

var mouseText:TextField = null;
var cursorClone:Bitmap = null;
var lastOriginalCursor:Dynamic = null;
var cloneFailed:Bool = false;

// ============================================================
// Stage
// ============================================================

function getMainStage():Dynamic {
    try {
        if (Lib.current == null) return null;
        return Lib.current.stage;
    } catch (e:Dynamic) {
        return null;
    }
}

// ============================================================
// 坐标显示
// ============================================================

function createMouseText():Void {
    if (mouseText != null) return;

    try {
        var stage:Dynamic = getMainStage();
        if (stage == null) return;

        mouseText = new TextField();
        mouseText.width = 60;
        mouseText.height = 38;
        mouseText.multiline = true;
        mouseText.selectable = false;
        mouseText.mouseEnabled = false;
        mouseText.background = true;
        mouseText.backgroundColor = 0x202020;
        mouseText.alpha = 0.85;
        mouseText.defaultTextFormat = new TextFormat("_sans", 14, 0xFFFFFF, true);

        stage.addChild(mouseText);
    } catch (e:Dynamic) {
        removeMouseText();
        trace("[MouseXY] Create failed: " + e);
    }
}

function removeMouseText():Void {
    try {
        if (mouseText != null && mouseText.parent != null)
            mouseText.parent.removeChild(mouseText);
    } catch (e:Dynamic) {}

    mouseText = null;
}

function updateMouseText():Void {
    try {
        var stage:Dynamic = getMainStage();
        if (stage == null) return;

        if (mouseText == null)
            createMouseText();

        if (mouseText == null) return;

        if (mouseText.parent != stage)
            stage.addChild(mouseText);

        var mx:Int = Std.int(stage.mouseX);
        var my:Int = Std.int(stage.mouseY);

        mouseText.text = "X: " + mx + "\nY: " + my;
        mouseText.x = mx + 16;
        mouseText.y = my + 16;

        var count:Int = stage.numChildren;
        if (count > 0 && stage.getChildIndex(mouseText) != count - 1)
            stage.setChildIndex(mouseText, count - 1);
    } catch (e:Dynamic) {
        trace("[MouseXY] Update failed: " + e);
    }
}

// ============================================================
// 原始指针
// ============================================================

function getOriginalCursor():Dynamic {
    try {
        if (FlxG.mouse == null) return null;
        return Reflect.getProperty(FlxG.mouse, "cursor");
    } catch (e:Dynamic) {
        return null;
    }
}

// ============================================================
// 创建 Stage 顶层副本
// ============================================================

function createCursorClone(original:Dynamic):Void {
    if (cursorClone != null || cloneFailed) return;

    try {
        if (original == null || original.bitmapData == null) return;

        cursorClone = new Bitmap(original.bitmapData);
        cursorClone.smoothing = original.smoothing;

        var stage:Dynamic = getMainStage();
        if (stage == null) {
            cursorClone = null;
            return;
        }

        // 直接放入 Stage，不触碰原始指针的父容器
        stage.addChild(cursorClone);

        lastOriginalCursor = original;
        trace("[MouseFix] Stage cursor clone created");
    } catch (e:Dynamic) {
        cloneFailed = true;
        trace("[MouseFix] Clone creation failed: " + e);
    }
}

// ============================================================
// 删除副本
// ============================================================

function removeCursorClone():Void {
    try {
        if (cursorClone != null && cursorClone.parent != null)
            cursorClone.parent.removeChild(cursorClone);
    } catch (e:Dynamic) {}

    cursorClone = null;
    lastOriginalCursor = null;
    cloneFailed = false;
}

// ============================================================
// 检查可见性
// ============================================================

function isCursorVisible(original:Dynamic):Bool {
    try {
        if (FlxG.mouse == null || FlxG.mouse.visible != true)
            return false;

        var current:Dynamic = original;

        while (current != null) {
            if (Reflect.getProperty(current, "visible") != true)
                return false;

            current = Reflect.getProperty(current, "parent");
        }

        return true;
    } catch (e:Dynamic) {
        return false;
    }
}

// ============================================================
// 更新 Stage 顶层副本
// ============================================================

function updateCursorClone():Void {
    try {
        var original:Dynamic = getOriginalCursor();
        var stage:Dynamic = getMainStage();

        if (original == null || stage == null) {
            if (cursorClone != null)
                cursorClone.visible = false;
            return;
        }

        // 原始指针对象变化时重新创建
        if (lastOriginalCursor != original) {
            removeCursorClone();
            createCursorClone(original);
        } else if (cursorClone == null) {
            createCursorClone(original);
        }

        if (cursorClone == null) return;

        if (original.bitmapData == null) {
            cursorClone.visible = false;
            return;
        }

        if (cursorClone.bitmapData != original.bitmapData)
            cursorClone.bitmapData = original.bitmapData;

        // 同步完整变换矩阵：位置、缩放、旋转及父容器变换
        var matrix:Dynamic = original.transform.concatenatedMatrix;
        cursorClone.transform.matrix = matrix;

        // 同步透明度与平滑设置
        cursorClone.alpha = original.alpha;
        cursorClone.smoothing = original.smoothing;

        // 原始指针隐藏时，副本也隐藏
        cursorClone.visible = isCursorVisible(original);

        // 确保副本始终位于 Stage 最顶层
        if (cursorClone.parent != stage)
            stage.addChild(cursorClone);

        var count:Int = stage.numChildren;
        if (count > 0 && stage.getChildIndex(cursorClone) != count - 1)
            stage.setChildIndex(cursorClone, count - 1);

    } catch (e:Dynamic) {
        trace("[MouseFix] Update failed: " + e);
    }
}

// ============================================================
// 每帧更新
// ============================================================

function onUpdate(elapsed:Float):Void {
    try {
        showMouseCoordinates = getModSetting("mouseXY") == true;
        fixMouseCursorLayer = getModSetting("mouseDisplayFix") == true;
    } catch (e:Dynamic) {
        trace("[MouseSettings] " + e);
    }

    if (showMouseCoordinates)
        updateMouseText();
    else
        removeMouseText();

    if (fixMouseCursorLayer)
        updateCursorClone();
    else
        removeCursorClone();
}

// ============================================================
// 销毁
// ============================================================

function onDestroy():Void {
    removeMouseText();
    removeCursorClone();
}