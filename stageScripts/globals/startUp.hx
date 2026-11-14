import flixel.FlxG;

var UTB_WELCOME_SAVE_KEY:String = "utbWelcomeSeen";
var UTB_LOCAL_PACK:String = "mods/Unsent's toolbox NF Ver/pack.json";
var UTB_REMOTE_PACK:String = "https://zhou9468jc.github.io/Unsent-FNF-Toolbox/pack.json";

// 当前脚本周期是否已经处理过第一次进入主菜单
var UTB_MainMenuIntercepted:Bool = false;

// 临时状态共享
function UTB_SetValue(key:String, value:Dynamic):Void {
    Reflect.setField(FlxG.save.data, key, value);
}

function UTB_GetValue(key:String):Dynamic {
    return Reflect.field(FlxG.save.data, key);
}

// 读取版本号
function UTB_ReadVersion(data:Dynamic):String {
    if (data == null) return "0.0";
    var version = Reflect.field(data, "UTB_version");
    return version == null ? "0.0" : StringTools.trim(Std.string(version));
}

// 解析版本号，支持 hotfix / hf 后缀
function UTB_ParseVersion(version:String):Dynamic {
    version = StringTools.trim(version).toLowerCase();

    var parts = version.split("-");
    var numbers:Array<Int> = [];

    for (part in parts[0].split(".")) {
        var number = Std.parseInt(part);
        numbers.push(number == null ? 0 : number);
    }

    var suffix = parts.length > 1 ? parts[1] : "";
    var hotfix = false;
    var hotfixNumber = 0;

    if (suffix.indexOf("hotfix") == 0 || suffix.indexOf("hf") == 0) {
        hotfix = true;

        var prefix = suffix.indexOf("hotfix") == 0 ? "hotfix" : "hf";
        var numberText = suffix.substr(prefix.length);

        hotfixNumber = numberText == ""
            ? 1
            : (Std.parseInt(numberText) == null ? 1 : Std.parseInt(numberText));
    }

    return {
        numbers: numbers,
        hotfix: hotfix,
        hotfixNumber: hotfixNumber
    };
}

// 比较版本号
// 返回 1：a 更新
// 返回 -1：b 更新
// 返回 0：版本相同
function UTB_CompareVersion(a:String, b:String):Int {
    var va = UTB_ParseVersion(a);
    var vb = UTB_ParseVersion(b);

    var length = Std.int(Math.max(va.numbers.length, vb.numbers.length));

    for (i in 0...length) {
        var av = i < va.numbers.length ? va.numbers[i] : 0;
        var bv = i < vb.numbers.length ? vb.numbers[i] : 0;

        if (av > bv) return 1;
        if (av < bv) return -1;
    }

    // 同一基础版本：Hotfix 高于普通版本
    if (va.hotfix != vb.hotfix)
        return va.hotfix ? 1 : -1;

    // 比较 Hotfix 序号
    if (va.hotfixNumber > vb.hotfixNumber) return 1;
    if (va.hotfixNumber < vb.hotfixNumber) return -1;

    return 0;
}

function UTB_IsNewer(remote:String, local:String):Bool {
    return UTB_CompareVersion(remote, local) > 0;
}

// 解析 JSON
function UTB_ParseJSON(content:String):Dynamic {
    var jsonClass = Type.resolveClass("haxe.Json");
    if (jsonClass == null) throw "haxe.Json unavailable";

    return Reflect.callMethod(
        jsonClass,
        Reflect.field(jsonClass, "parse"),
        [content]
    );
}

// 读取本地 pack.json
function UTB_ReadLocalVersion():Void {
    try {
        var fileClass = Type.resolveClass("sys.io.File");
        if (fileClass == null) throw "sys.io.File unavailable";

        var content = Reflect.callMethod(
            fileClass,
            Reflect.field(fileClass, "getContent"),
            [UTB_LOCAL_PACK]
        );

        var data = UTB_ParseJSON(Std.string(content));
        var version = UTB_ReadVersion(data);

        UTB_SetValue("__utbLocalVersion", version);
        trace("[UTB] Local version: " + version);
    } catch (e:Dynamic) {
        trace("[UTB] Cannot read local pack.json: " + e);
        UTB_SetValue("__utbLocalVersion", "0.0");
    }
}

// 异步检查远程版本
function UTB_CheckVersion():Void {
    UTB_SetValue("__utbVersionCheckDone", false);
    UTB_SetValue("__utbUpdateAvailable", false);
    UTB_SetValue("__utbRemoteVersion", "");

    UTB_SetValue("__utbRemoteDescriptionChinese", "");
    UTB_SetValue("__utbRemoteDescriptionEnglish", "");
    UTB_SetValue("__utbRemoteDescription", "");

    UTB_ReadLocalVersion();

    try {
        var loaderClass = Type.resolveClass("openfl.net.URLLoader");
        var requestClass = Type.resolveClass("openfl.net.URLRequest");

        if (loaderClass == null || requestClass == null)
            throw "URLLoader or URLRequest unavailable";

        var loader = Type.createInstance(loaderClass, []);
        var request = Type.createInstance(requestClass, [UTB_REMOTE_PACK]);

        var addEvent = Reflect.field(loader, "addEventListener");
        var load = Reflect.field(loader, "load");

        Reflect.callMethod(loader, addEvent, ["complete", function(event) {
            try {
                var content = Std.string(Reflect.field(loader, "data"));
                var data = UTB_ParseJSON(content);

                var remoteVersion = UTB_ReadVersion(data);
                var localVersion = Std.string(UTB_GetValue("__utbLocalVersion"));

                // 分别读取中英文描述
                var descriptionChinese = Reflect.field(data, "UTB_discription_Chinese");
                var descriptionEnglish = Reflect.field(data, "UTB_discription_English");

                // 兼容旧版 pack.json 的单语言字段
                if (descriptionEnglish == null || StringTools.trim(Std.string(descriptionEnglish)) == "")
                    descriptionEnglish = Reflect.field(data, "UTB_discription");

                if (descriptionChinese == null)
                    descriptionChinese = "";

                if (descriptionEnglish == null)
                    descriptionEnglish = "";

                UTB_SetValue("__utbRemoteDescriptionChinese", Std.string(descriptionChinese));
                UTB_SetValue("__utbRemoteDescriptionEnglish", Std.string(descriptionEnglish));

                // 兼容旧 UI 字段
                UTB_SetValue("__utbRemoteDescription", Std.string(descriptionEnglish));

                UTB_SetValue("__utbRemoteVersion", remoteVersion);
                UTB_SetValue(
                    "__utbUpdateAvailable",
                    UTB_IsNewer(remoteVersion, localVersion)
                );

                trace(
                    "[UTB] Local: " + localVersion +
                    " | Remote: " + remoteVersion +
                    " | Update: " + UTB_GetValue("__utbUpdateAvailable")
                );
            } catch (e:Dynamic) {
                trace("[UTB] Remote pack.json parse failed: " + e);
            }

            UTB_SetValue("__utbVersionCheckDone", true);
        }]);

        Reflect.callMethod(loader, addEvent, ["ioError", function(event) {
            trace("[UTB] Version check IO error: " + event);
            UTB_SetValue("__utbVersionCheckDone", true);
        }]);

        Reflect.callMethod(loader, addEvent, ["securityError", function(event) {
            trace("[UTB] Version check security error: " + event);
            UTB_SetValue("__utbVersionCheckDone", true);
        }]);

        Reflect.callMethod(loader, load, [request]);
    } catch (e:Dynamic) {
        trace("[UTB] Version check failed: " + e);
        UTB_SetValue("__utbVersionCheckDone", true);
    }
}

// 清除欢迎页存档
function UTB_ResetWelcomeSave():Void {
    Reflect.deleteField(FlxG.save.data, UTB_WELCOME_SAVE_KEY);
    FlxG.save.flush();
    trace("[UTB] Welcome save cleared!");
}

// 游戏启动
function onCreate() {
    UTB_CheckVersion();
    //UTB_ResetWelcomeSave(); // 临时执行一次，测试完成后删除这一行
}

// 获取状态类名
function getStateClassName(state:Dynamic):String {
    if (state == null) return "";

    var cls = Type.getClass(state);
    if (cls == null) return "";

    var name = Type.getClassName(cls);
    return name == null ? "" : name.split(".").pop();
}

// 只拦截脚本周期内第一次进入主菜单
function onStateSwitch() {
    if (UTB_MainMenuIntercepted) return;

    var next = FlxG.game._nextState;
    if (next == null) return;

    var cls = Type.getClass(next);
    if (cls == null) return;

    var className = Type.getClassName(cls);
    if (className == null || className.split(".").pop() != "MainMenuState")
        return;

    // 立即标记，后续跳转全部放行
    UTB_MainMenuIntercepted = true;

    var welcomeSeen = Reflect.field(FlxG.save.data, UTB_WELCOME_SAVE_KEY) == true;
    var checking = UTB_GetValue("__utbVersionCheckDone") != true;
    var updateAvailable = UTB_GetValue("__utbUpdateAvailable") == true;

    // 首次欢迎、检查未完成或发现更新时显示界面
    if (!welcomeSeen || checking || updateAvailable) {
        UTB_SetValue("__utbOriginalNextStateClass", className);
        FlxG.game._nextState = new HScriptState("UTB_Welcome");
        trace("[UTB] First MainMenu transition intercepted!");
    }
}