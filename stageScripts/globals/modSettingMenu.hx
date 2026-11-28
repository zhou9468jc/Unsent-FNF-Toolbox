import options.base.ModSettingsSubState;
import tjson.TJSON;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

var openingSettings:Bool = false;
var errorVisible:Bool = false;
var loadingOverlay:FlxSprite = null;
var loadingText:FlxText = null;
var overlayParent:Dynamic = null;
var modRoot:String = null;
var modName:String = null;

// ============================================================
// 自动识别模组根目录
// ============================================================


function detectModRoot():Bool {
    modRoot = null;
    modName = null;

    // 方法一：直接读取当前模组目录
    try {
        var folder:String = Mods.currentModDirectory;

        if (folder != null && folder.length > 0) {
            var root:String = Paths.mods() + folder;

            if (FileSystem.exists(root)) {
                modRoot = root;
                modName = folder;
                trace("[UTB Settings] Detected by currentModDirectory: " + modRoot);
                return true;
            }
        }
    } catch (e:Dynamic) {
        trace("[UTB Settings] Current mod detection failed: " + e);
    }

    // 方法二：通过 HScript 实例反射获取
    try {
        var cls = Type.resolveClass("scripts.hscript.HScript");
        var instances = Reflect.field(cls, "instances");

        if (instances != null) {
            for (key in instances.keys()) {
                var instance = instances.get(key);
                var path = Reflect.field(instance, "filePath");
                var folder = Reflect.field(instance, "modFolder");

                if (path == null || folder == null) continue;

                path = Std.string(path);

                var marker = "/stageScripts/";
                var index = path.lastIndexOf(marker);

                if (index < 0) continue;

                var root = path.substr(0, index);

                if (FileSystem.exists(root)) {
                    modRoot = root;
                    modName = Std.string(folder);
                    trace("[UTB Settings] Detected by HScript: " + modRoot);
                    return true;
                }
            }
        }
    } catch (e:Dynamic) {
        trace("[UTB Settings] HScript detection failed: " + e);
    }

    return false;
}
	

// ============================================================
// 显示遮罩
// ============================================================

function showOverlay(message:String) {
    var state = FlxG.state;
    if (state == null) return;

    overlayParent = state;

    loadingOverlay = new FlxSprite();
    loadingOverlay.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    loadingOverlay.alpha = 0.88;
    loadingOverlay.scrollFactor.set();
    state.add(loadingOverlay);

    loadingText = new FlxText(40, 0, FlxG.width - 80, message);
    loadingText.setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, "center");
    loadingText.screenCenter();
    loadingText.scrollFactor.set();
    state.add(loadingText);
}

function hideOverlay() {
    if (overlayParent != null) {
        if (loadingOverlay != null)
            overlayParent.remove(loadingOverlay, true);

        if (loadingText != null)
            overlayParent.remove(loadingText, true);
    }

    loadingOverlay = null;
    loadingText = null;
    overlayParent = null;
}

// ============================================================
// 错误显示
// ============================================================

function showError(message:String) {
    hideOverlay();

    openingSettings = false;
    errorVisible = true;

    trace("[UTB Settings] ERROR: " + message);

    showOverlay(
        "UTB SETTINGS ERROR\n\n" +
        message +
        "\n\nPress ENTER or ESC to close"
    );
}

// ============================================================
// 读取语言
// ============================================================

function getLoadingText():String {
    var fallback = "Loading settings...";

    try {
        var language = getModSetting("language");

        if (language != "Chinese" && language != "English")
            language = "English";

        var languagePath = modRoot + "/data/language.json";

        if (!FileSystem.exists(languagePath))
            return fallback;

        var data = TJSON.parse(File.getContent(languagePath));
        if (data == null) return fallback;

        var group = Reflect.field(data, language);
        if (group == null) return fallback;

        var value = Reflect.field(group, "ModSetting_Loading");

        if (value != null)
            return Std.string(value);

    } catch (e:Dynamic) {
        trace("[UTB Settings] Language error: " + e);
    }

    return fallback;
}

// ============================================================
// 打开设置
// ============================================================

function openUTBSettings() {
    var state = FlxG.state;

    if (openingSettings || errorVisible || state == null || state.subState != null)
        return;

    openingSettings = true;

    try {
        showOverlay(getLoadingText());
    } catch (e:Dynamic) {
        showError("Cannot create loading overlay:\n" + e);
        return;
    }

    new FlxTimer().start(0.05, function(timer) {
        loadUTBSettings();
    });
}

// ============================================================
// 加载设置菜单
// ============================================================

function loadUTBSettings() {
    var state = FlxG.state;

    try {
        if (state == null) {
            showError("Game state is unavailable.");
            return;
        }

        // 自动识别模组目录
        if (modRoot == null || !FileSystem.exists(modRoot)) {
            if (!detectModRoot()) {
                showError("Cannot detect mod directory.\nCheck Mods.currentModDirectory and HScript instances.");
                return;
            }
        }

        // 读取设置文件
        var settingsPath = modRoot + "/data/settings.json";

        if (!FileSystem.exists(settingsPath)) {
            showError("Settings file not found:\n" + settingsPath);
            return;
        }

        var settings = TJSON.parse(File.getContent(settingsPath));

        if (settings == null || settings.length == 0) {
            showError("Settings file is empty or invalid.");
            return;
        }

        // 读取模组名称
        modName = modRoot.substr(modRoot.lastIndexOf("/") + 1);

        var packPath = modRoot + "/pack.json";

        if (FileSystem.exists(packPath)) {
            var pack = TJSON.parse(File.getContent(packPath));

            if (pack != null && pack.name != null)
                modName = Std.string(pack.name);
        }

        // 创建原生设置菜单
        var folderName = modRoot.substr(modRoot.lastIndexOf("/") + 1);
        var menu = new ModSettingsSubState(settings, folderName, modName);

        var oldPersistentUpdate = state.persistentUpdate;
        var oldPersistentDraw = state.persistentDraw;
        var oldCloseCallback = menu.closeCallback;

        var parentMobileControls = Reflect.field(state, "mobileControls");
        var parentVirtualPad = Reflect.field(state, "virtualPad");

        var mobileVisible = parentMobileControls != null ? parentMobileControls.visible : false;
        var mobileActive = parentMobileControls != null ? parentMobileControls.active : false;
        var padVisible = parentVirtualPad != null ? parentVirtualPad.visible : false;
        var padActive = parentVirtualPad != null ? parentVirtualPad.active : false;

        // 菜单关闭回调
        menu.closeCallback = function() {
            if (oldCloseCallback != null) {
                try {
                    oldCloseCallback();
                } catch (e:Dynamic) {
                    trace("[UTB Settings] Original close callback error: " + e);
                }
            }

            if (parentMobileControls != null) {
                parentMobileControls.visible = mobileVisible;
                parentMobileControls.active = mobileActive;
            }

            if (parentVirtualPad != null) {
                parentVirtualPad.visible = padVisible;
                parentVirtualPad.active = padActive;
            }

            state.persistentUpdate = oldPersistentUpdate;
            state.persistentDraw = oldPersistentDraw;

            openingSettings = false;
            trace("[UTB Settings] Parent state restored.");
        };

        // 隐藏父状态的移动端控件
        if (parentMobileControls != null) {
            parentMobileControls.visible = false;
            parentMobileControls.active = false;
        }

        if (parentVirtualPad != null) {
            parentVirtualPad.visible = false;
            parentVirtualPad.active = false;
        }

        state.persistentUpdate = false;
        state.persistentDraw = true;

        hideOverlay();
        state.openSubState(menu);

        trace("[UTB Settings] Native settings menu opened.");

    } catch (e:Dynamic) {
        showError("Failed to load settings menu:\n" + e);
    }
}

// ============================================================
// 全局初始化
// ============================================================

function onCreate() {
    if (detectModRoot()) {
        trace("[UTB Settings] Mod root: " + modRoot);
    } else {
        trace("[UTB Settings] Mod root detection failed.");
    }
}

// ============================================================
// 全局更新
// ============================================================

function onUpdate(elapsed:Float) {
    // 错误遮罩关闭
    if (errorVisible) {
        if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.ESCAPE) {
            hideOverlay();
            errorVisible = false;
        }
        return;
    }

    // Shift + F6 打开设置
    if (FlxG.keys.pressed.SHIFT && FlxG.keys.justPressed.F6)
        openUTBSettings();
}