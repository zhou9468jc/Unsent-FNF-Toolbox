
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

var UTB_WELCOME_SAVE_KEY:String = "utbWelcomeSeen";
var UTB_REPOSITORY_URL:String = "https://github.com/zhou9468jc/Unsent-FNF-Toolbox/";
var UTB_FONT_PATH:String = Paths.modFolders("fonts/vcr.ttf");
var UTB_LANGUAGE_PATH:String = Paths.modFolders("data/language.json");
var UTB_DEFAULT_UPDATE_DESCRIPTION_KEY:String = "Welcome_Update_DefaultDescription";

var UTB_LanguageData:Dynamic = null;
var currentLanguage:String = "English";
var page:String = "welcome";

var background:FlxSprite;
var panel:FlxSprite;
var titleText:FlxText;
var infoText:FlxText;
var versionText:FlxText;

var selectedIndex:Int = 0;
var selectionPulse:Float = 0;

var button1:FlxSprite;
var button2:FlxSprite;
var button3:FlxSprite;

var button1Text:FlxText;
var button2Text:FlxText;
var button3Text:FlxText;

var button1Lines:Array<FlxSprite> = [];
var button2Lines:Array<FlxSprite> = [];
var button3Lines:Array<FlxSprite> = [];

var buttonColor:Int = 0xFF30394B;
var buttonHoverColor:Int = 0xFF465675;
var borderColor:Int = 0xFF8BD3FF;

// --------------------------------------------------
// Save
// --------------------------------------------------

function getGameValue(key:String):Dynamic {
    return Reflect.field(FlxG.save.data, key);
}

function setGameValue(key:String, value:Dynamic):Void {
    Reflect.setField(FlxG.save.data, key, value);
}

function setNoCheckVer(value:Bool):Void {
    var allSettings = Reflect.field(FlxG.save.data, "modSettings");

    if (allSettings == null) {
        trace("[UTB] Mod settings not found!");
        return;
    }

    var settings = allSettings.get("Unsent's toolbox NF Ver");

    if (settings == null) {
        trace("[UTB] UTB settings not found!");
        return;
    }

    settings.set("noCheckVer", value);
    FlxG.save.flush();

    trace("[UTB] noCheckVer changed: " + value);
}

// --------------------------------------------------
// Language system
// --------------------------------------------------

function loadLanguageData():Void {
    try {
        var fileClass = Type.resolveClass("sys.io.File");
        var jsonClass = Type.resolveClass("haxe.Json");

        if (fileClass == null || jsonClass == null)
            throw "File/Json unavailable";

        var content = Reflect.callMethod(
            fileClass,
            Reflect.field(fileClass, "getContent"),
            [UTB_LANGUAGE_PATH]
        );

        UTB_LanguageData = Reflect.callMethod(
            jsonClass,
            Reflect.field(jsonClass, "parse"),
            [Std.string(content)]
        );

        trace("[UTB] Language file loaded: " + UTB_LANGUAGE_PATH);
    } catch (e:Dynamic) {
        UTB_LanguageData = null;
        trace("[UTB] Cannot load language.json: " + e);
    }
}

function tr(key:String, fallback:String):String {
    if (UTB_LanguageData != null) {
        var languageData = Reflect.field(UTB_LanguageData, currentLanguage);

        if (languageData != null) {
            var value = Reflect.field(languageData, key);

            if (value != null && StringTools.trim(Std.string(value)) != "")
                return Std.string(value);
        }
    }

    return fallback;
}

function trFrom(language:String, key:String, fallback:String):String {
    if (UTB_LanguageData != null) {
        var languageData = Reflect.field(UTB_LanguageData, language);

        if (languageData != null) {
            var value = Reflect.field(languageData, key);

            if (value != null && StringTools.trim(Std.string(value)) != "")
                return Std.string(value);
        }
    }

    return fallback;
}

// --------------------------------------------------
// UI helpers
// --------------------------------------------------

function applyFont(text:FlxText):Void {
    text.font = UTB_FONT_PATH;
}

function createText(x:Float, y:Float, width:Float, size:Int):FlxText {
    var text = new FlxText(x, y, width, "", size);
    text.alignment = "center";
    text.color = FlxColor.WHITE;
    applyFont(text);
    FlxG.state.add(text);
    return text;
}

function createButton(x:Float, y:Float, width:Float, height:Float, labelSize:Int):Dynamic {
    var bg = new FlxSprite(x, y);
    bg.makeGraphic(Std.int(width), Std.int(height), buttonColor);
    FlxG.state.add(bg);

    var lines:Array<FlxSprite> = [];

    var top = new FlxSprite(x, y);
    top.makeGraphic(Std.int(width), 2, borderColor);
    lines.push(top);

    var bottom = new FlxSprite(x, y + height - 2);
    bottom.makeGraphic(Std.int(width), 2, borderColor);
    lines.push(bottom);

    var left = new FlxSprite(x, y);
    left.makeGraphic(2, Std.int(height), borderColor);
    lines.push(left);

    var right = new FlxSprite(x + width - 2, y);
    right.makeGraphic(2, Std.int(height), borderColor);
    lines.push(right);

    for (line in lines)
        FlxG.state.add(line);

    var label = createText(
        x,
        y + (height - labelSize) / 2 - 3,
        width,
        labelSize
    );

    return {
        bg: bg,
        text: label,
        lines: lines
    };
}

function setButtonVisible(
    bg:FlxSprite,
    text:FlxText,
    lines:Array<FlxSprite>,
    visible:Bool
):Void {
    bg.visible = visible;
    text.visible = visible;

    for (line in lines)
        line.visible = visible;
}

// --------------------------------------------------
// Create
// --------------------------------------------------

function onCreate() {
    FlxG.mouse.visible = true;

    loadLanguageData();

    var language = getModSetting("language");
    currentLanguage = language == "Chinese" ? "Chinese" : "English";

    background = new FlxSprite().makeGraphic(
        FlxG.width,
        FlxG.height,
        0xFF171B25
    );
    FlxG.state.add(background);

    panel = new FlxSprite(
        FlxG.width / 2 - 380,
        FlxG.height / 2 - 208
    );
    panel.makeGraphic(760, 416, 0xFF222A38);
    FlxG.state.add(panel);

    var panelLines = [
        new FlxSprite(panel.x, panel.y),
        new FlxSprite(panel.x, panel.y + 412),
        new FlxSprite(panel.x, panel.y),
        new FlxSprite(panel.x + 756, panel.y)
    ];

    panelLines[0].makeGraphic(760, 4, borderColor);
    panelLines[1].makeGraphic(760, 4, borderColor);
    panelLines[2].makeGraphic(4, 416, borderColor);
    panelLines[3].makeGraphic(4, 416, borderColor);

    for (line in panelLines)
        FlxG.state.add(line);

    var textX = panel.x + 40;
    var textWidth = 680;

    titleText = createText(textX, panel.y + 42, textWidth, 32);
    infoText = createText(textX, panel.y + 105, textWidth, 18);
    versionText = createText(textX, panel.y + 205, textWidth, 16);

    var b1 = createButton(
        FlxG.width / 2 - 135,
        panel.y + 245,
        270,
        42,
        20
    );

    button1 = b1.bg;
    button1Text = b1.text;
    button1Lines = b1.lines;

    var b2 = createButton(
        FlxG.width / 2 - 135,
        panel.y + 295,
        270,
        42,
        20
    );

    button2 = b2.bg;
    button2Text = b2.text;
    button2Lines = b2.lines;

    var b3 = createButton(
        FlxG.width / 2 - 135,
        panel.y + 345,
        270,
        42,
        20
    );

    button3 = b3.bg;
    button3Text = b3.text;
    button3Lines = b3.lines;

    if (getGameValue(UTB_WELCOME_SAVE_KEY) != true)
        page = "welcome";
    else
        page = "checking";

    updateTexts();

    if (page == "checking")
        checkVersionResult();
}

// --------------------------------------------------
// Language
// --------------------------------------------------

function setLanguage(language:String):Void {
    if (currentLanguage == language)
        return;

    currentLanguage = language;

    var allSettings = Reflect.field(FlxG.save.data, "modSettings");

    if (allSettings != null) {
        var settings = allSettings.get("Unsent's toolbox NF Ver");

        if (settings != null) {
            settings.set("language", language);
            FlxG.save.flush();
            trace("[UTB] Language changed: " + language);
        } else {
            trace("[UTB] Mod settings not found!");
        }
    }

    updateTexts();
}

// --------------------------------------------------
// Text
// --------------------------------------------------

function updateTexts():Void {
    var zh = currentLanguage == "Chinese";

    if (page == "welcome") {
        titleText.text = tr(
            "Welcome_Title",
            zh ? "欢迎使用 Unsent's Toolbox！" : "Welcome to Unsent's Toolbox!"
        );

        infoText.text = tr(
            "Welcome_Description",
            zh ? "请选择语言，之后可以在设置中更改。" : "Choose your language. You can change it later."
        );

        versionText.text = "";

        var chineseName = trFrom("Chinese", "Language_Name", "简体中文");
        var englishName = trFrom("English", "Language_Name", "English");

        button1Text.text = chineseName;
        button2Text.text = englishName;
        button3Text.text = tr(
            "Welcome_Confirm",
            zh ? "确定 (Enter)" : "Confirm (Enter)"
        );

        setButtonVisible(button1, button1Text, button1Lines, true);
        setButtonVisible(button2, button2Text, button2Lines, true);
        setButtonVisible(button3, button3Text, button3Lines, true);
    }
    else if (page == "checking") {
        titleText.text = tr(
            "Welcome_Checking",
            zh ? "正在检查更新..." : "Checking for updates..."
        );

        infoText.text = tr(
            "Welcome_Checking_Description",
            zh ? "请稍候。" : "Please wait."
        );

        versionText.text = "";

        setButtonVisible(button1, button1Text, button1Lines, false);
        setButtonVisible(button2, button2Text, button2Lines, false);
        setButtonVisible(button3, button3Text, button3Lines, false);
    }
    else if (page == "update") {
        var localVersion = Std.string(getGameValue("__utbLocalVersion"));
        var remoteVersion = Std.string(getGameValue("__utbRemoteVersion"));

        var description = getGameValue(
            currentLanguage == "Chinese"
                ? "__utbRemoteDescriptionChinese"
                : "__utbRemoteDescriptionEnglish"
        );

        if (description == null || StringTools.trim(Std.string(description)) == "") {
            description = tr(
                UTB_DEFAULT_UPDATE_DESCRIPTION_KEY,
                zh
                    ? "检测到 Unsent's Toolbox 有新版本，建议更新以获取最新功能和改进。"
                    : "A new version of Unsent's Toolbox is available. Update to get the latest features and improvements."
            );
        }

        titleText.text = tr(
            "Welcome_Update_Title",
            zh ? "发现新版本！" : "Update Available!"
        );

        infoText.text = Std.string(description);

        var currentLabel = tr(
            "Welcome_Update_Current",
            zh ? "当前版本：{1}" : "Current: {1}"
        );

        var latestLabel = tr(
            "Welcome_Update_Latest",
            zh ? "最新版本：{1}" : "Latest: {1}"
        );

        currentLabel = StringTools.replace(currentLabel, "{1}", localVersion);
        latestLabel = StringTools.replace(latestLabel, "{1}", remoteVersion);

        versionText.text = currentLabel + "    " + latestLabel;

        button1Text.text = tr(
            "Welcome_Update_Button",
            zh ? "更新 (Enter)" : "Update (Enter)"
        );

        button2Text.text = tr(
            "Welcome_Ignore_Button",
            zh ? "忽略 (Escape)" : "Ignore (Escape)"
        );

        button3Text.text = tr(
            "Welcome_NoCheckVer",
            zh ? "不再询问" : "Don't Ask Again"
        );

        setButtonVisible(button1, button1Text, button1Lines, true);
        setButtonVisible(button2, button2Text, button2Lines, true);
        setButtonVisible(button3, button3Text, button3Lines, true);
    }

    updateSelection();
}

// --------------------------------------------------
// Selection
// --------------------------------------------------

function updateSelection():Void {
    var selectedColor:Int = 0xFF465675;
    var idleColor:Int = 0xFF30394B;
    var selectedBorder:Int = 0xFF8BD3FF;
    var idleBorder:Int = 0xFF526176;

    var pulse:Float = 0.92 + Math.sin(selectionPulse * 5) * 0.08;

    var backgrounds = [button1, button2, button3];
    var labels = [button1Text, button2Text, button3Text];
    var borders = [button1Lines, button2Lines, button3Lines];

    for (i in 0...backgrounds.length) {
        var selected = i == selectedIndex && backgrounds[i].visible;

        backgrounds[i].color = selected ? selectedColor : idleColor;
        backgrounds[i].alpha = selected ? pulse : 1;

        labels[i].color = selected ? 0xFFFFFFFF : 0xFFD0D8E6;

        for (line in borders[i]) {
            line.color = selected ? selectedBorder : idleBorder;
            line.alpha = selected ? pulse : 0.75;
        }
    }
}

// --------------------------------------------------
// Version check result
// --------------------------------------------------

function checkVersionResult():Void {
    if (getGameValue("__utbVersionCheckDone") != true)
        return;

    if (getModSetting("noCheckVer") == true) {
        finishToMainMenu();
        return;
    }

    if (getGameValue("__utbUpdateAvailable") == true) {
        page = "update";
        selectedIndex = 0;
        updateTexts();
    } else {
        finishToMainMenu();
    }
}

// --------------------------------------------------
// State switch
// --------------------------------------------------

function finishWelcome():Void {
    setGameValue(UTB_WELCOME_SAVE_KEY, true);
    FlxG.save.flush();

    if (getGameValue("__utbVersionCheckDone") != true) {
        page = "checking";
        updateTexts();
        return;
    }

    checkVersionResult();
}

function finishToMainMenu():Void {
    var className = getGameValue("__utbOriginalNextStateClass");

    if (className == null) {
        trace("[UTB] Original MainMenuState class is missing!");
        return;
    }

    var menuClass = Type.resolveClass(Std.string(className));

    if (menuClass == null) {
        trace("[UTB] Cannot resolve MainMenuState: " + className);
        return;
    }

    FlxG.switchState(Type.createInstance(menuClass, []));
}

// --------------------------------------------------
// Open repository
// --------------------------------------------------

function openRepository():Void {
    trace("[UTB] Opening repository...");

    var flxGClass = Type.resolveClass("flixel.FlxG");
    var openURL = flxGClass == null ? null : Reflect.field(flxGClass, "openURL");

    if (openURL != null) {
        try {
            Reflect.callMethod(flxGClass, openURL, [UTB_REPOSITORY_URL]);
        } catch (e:Dynamic) {
            trace("[UTB] Failed to open repository: " + Std.string(e));
        }
    } else {
        trace("[UTB] FlxG.openURL is unavailable!");
    }

    finishToMainMenu();
}

// --------------------------------------------------
// Update
// --------------------------------------------------

function onUpdate(elapsed:Float) {
    FlxG.mouse.visible = true;
    selectionPulse += elapsed;

    if (page == "checking") {
        checkVersionResult();
        return;
    }

    var hover1 = button1.visible && FlxG.mouse.overlaps(button1);
    var hover2 = button2.visible && FlxG.mouse.overlaps(button2);
    var hover3 = button3.visible && FlxG.mouse.overlaps(button3);

    if (hover1)
        selectedIndex = 0;
    else if (hover2)
        selectedIndex = 1;
    else if (hover3)
        selectedIndex = 2;

    updateSelection();

    if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.A) {
        selectedIndex = selectedIndex <= 0 ? 2 : selectedIndex - 1;
        updateSelection();
    }

    if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.D) {
        selectedIndex = selectedIndex >= 2 ? 0 : selectedIndex + 1;
        updateSelection();
    }

    if (page == "welcome") {
        if (FlxG.keys.justPressed.ENTER) {
            if (selectedIndex == 0)
                setLanguage("Chinese");
            else if (selectedIndex == 1)
                setLanguage("English");

            finishWelcome();
        }

        if (FlxG.mouse.justPressed) {
            if (hover1) {
                selectedIndex = 0;
                setLanguage("Chinese");
                updateSelection();
            }
            else if (hover2) {
                selectedIndex = 1;
                setLanguage("English");
                updateSelection();
            }
            else if (hover3) {
                selectedIndex = 2;
                updateSelection();
                finishWelcome();
            }
        }
    }
    else if (page == "update") {
        if (FlxG.keys.justPressed.ENTER) {
            if (selectedIndex == 0)
                openRepository();
            else if (selectedIndex == 1)
                finishToMainMenu();
            else if (selectedIndex == 2) {
                setNoCheckVer(true);
                finishToMainMenu();
            }
        }

        if (FlxG.keys.justPressed.ESCAPE)
            finishToMainMenu();

        if (FlxG.mouse.justPressed) {
            if (hover1)
                openRepository();
            else if (hover2)
                finishToMainMenu();
            else if (hover3) {
                setNoCheckVer(true);
                finishToMainMenu();
            }
        }
    }
}
