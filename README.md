# Unsent's Toolbox NF Ver

[🇨🇳 中文](#中文) | [🇺🇸 English](#english)

---

<a id="中文"></a>

# 🇨🇳 中文

**NovaFlare Engine 1.2.x 调试工具箱模组**

作者：**难寄期许 / Unsent**

## 🎉 简介

Unsent's Toolbox 是一款专为 **NovaFlare Engine 1.2.x** 打造的调试工具箱模组，集成了丰富的游戏调试、HUD 自定义、快捷操作及额外玩法功能。除核心调试功能外，还包括但不限于：

- **多语言支持**
- **自定义评级及评级颜色**
- **中英文 HUD 切换**
- **分数文字颜色系统**（固定颜色 / 彩虹 / 跟随评级 / 跟随角色 / 自定义 RGB）
- **中文自动字体与字号适配**
- **颜色平滑渐变**
- **重复命中角色残影**
- **Ghost Tap 检测与计数 HUD**
- **Ghost Tap 惩罚机制**
- **Ghost Tap 红色渐染效果**
- **FC/AP 箭头指示**（金色 / 蓝色 / 青色 / 紫色 / 原色）
- **Soft Pause（软暂停）**
- **四轨合一单轨模式**
- **Miss Limit（失误次数限制，触发 DIE!!! 后结束游戏）**
- **Blind Play（盲打模式：全部隐藏 / 仅隐藏玩家侧）**
- **Quick Command（快捷命令）系统**（Lua / HScript）
- **Showcase（展示）模式**（隐藏 HUD / UI / 评级 / 连击 / 按键特效）
- **Showcase 可配置血条与箭头透明度**
- **Taunt（嘲讽）互动**
- **V-Slice 风格血条平滑效果**
- **玩家 / 对手长按 Cover 效果**

## ⚠️ 重要提醒

- **仅支持 NovaFlare Engine 1.2.x，普通 Psych Engine 无法运行。**

  > （想运行也可以试试 awa ）

- 重置数值功能需要引擎开启 `No Reset` 选项，或更改重置键键位。

  > 不然按了就死……

- 启用模组后，需要打开模组设置中的 `Enable Debug ToolBox` 总开关，快捷键才会生效。

## ⌨️ 快捷键列表

新版（**2.5.1 及以后版本**）可在 `data\key.json` 中自定义快捷键。

| 默认快捷键（新版 2.5.1+） | 快捷键（旧版 2.5 前） | 功能 |
|---|---|---|
| `主键盘 1` | `C` | 开关 BotPlay |
| `Shift` + `主键盘 1` | `Shift + C` | 开关假 BotPlay（仅显示 BotPlay 文字） |
| `主键盘 2` | `V` | 开关练习模式 |
| `Shift` + `主键盘 3/4` / `主键盘 3/4` | `Shift + N/M` / `N/M` | 调整滚动速度 |
| `Ctrl` / `Ctrl + Shift` + `主键盘 3/4` | `Ctrl` / `Ctrl + Shift + N/M` | 调整播放速度 |
| `Ctrl + R` | `Ctrl + R` | 重置播放速度 |
| `Shift + R` | `Shift + R` | 重置滚动速度 |
| `Alt + R` | `Alt + R` | 将血量重置为 50% |
| `Alt` / `Alt + Shift` + `主键盘 3/4` | `Alt` / `Alt + Shift + N/M` | 调整血量 |
| `Space` + `主键盘 6` / 无修饰键 | `Space + H / G` | 进入软暂停 |
| `Space` | `Space` | 退出软暂停 |
| `主键盘 5` | `P` | 开关工具箱调试输出 |

## 📦 安装方法

1. 在 **Releases** 中下载最新版本的 ZIP 压缩包。
2. 解压 ZIP 压缩包。
3. 将解压后的 `Unsent's Toolbox NF Ver` 文件夹放入 NovaFlare Engine 的 `mods` 文件夹。
4. 启动游戏，在模组列表中启用本模组。
5. 进入模组设置，根据需要启用相关功能。

## 📜 License / 许可证

自 **2026 年 9 月 24 日**起，本项目正式采用 **MIT License** 进行授权。

作者：**难寄期许 / Unsent**


# 📃 附录
## 🛠️ 各版本引擎适配表(仅供参考)
> 标记说明：✅ 已确认支持；❌ 已确认不支持；⚠️ 已知存在问题；? 尚未确认。

| 功能标题                   | NovaFlare 1.2.1 | NovaFlare 1.2.0 | NovaFlare 1.1.8 | Psych Engine 1.0.4 |
| ---------------------- | --------------- | --------------- | --------------- | ------------------ |
| 分数文字颜色系统               | ✅               | ✅               | ✅               | ?                  |
| 自定义评级及评级颜色             | ✅               | ✅               | ✅               | ?                  |
| 中英文 HUD 切换             | ✅               | ✅               | ✅               | ?                  |
| 中文字体与字号适配              | ✅               | ✅               | ✅               | ?                  |
| Ghost Tap 检测与计数 HUD    | ✅               | ✅               | ✅               | ?                  |
| Ghost Tap 惩罚机制         | ✅               | ✅               | ✅               | ?                  |
| Ghost Tap 红色渐染效果       | ✅               | ✅               | ✅               | ?                  |
| FC/AP 箭头指示与染色          | ✅               | ✅               | ✅               | ?                  |
| 四轨合一单轨模式               | ✅               | ✅               | ✅               | ?                  |
| 重复命中角色残影               | ✅               | ✅               | ✅               | ?                  |
| Showcase 展示模式          | ✅               | ✅               | ✅               | ?                  |
| 血条平滑效果                 | ✅               | ✅               | ✅               | ?                  |
| 玩家长按 Cover             | ✅               | ✅               | ✅               | ?                  |
| 对手长按 Cover             | ✅               | ✅               | ✅               | ✅                  |
| 像素舞台长按 Cover           | ✅               | ✅               | ✅               | ?                  |
| Taunt 嘲讽互动             | ✅               | ✅               | ✅               | ?                  |
| Miss Limit 失误次数限制      | ✅               | ✅               | ✅               | ✅                  |
| Blind Play 盲打模式        | ✅               | ✅               | ✅               | ✅                  |
| Quick Command 快捷命令系统   | ✅               | ✅               | ?               | ?                  |
| 工具箱快捷键自定义              | ✅               | ✅               | ?               | ?                  |
| 多语言支持                  | ✅               | ✅               | ✅               | ?                  |
| 高级调试 HUD               | ✅               | ✅               | ✅               | ?                  |
| 角色自动替换                 | ✅               | ✅               | ⚠️               | ?                  |
| 禁用 Botplay             | ✅               | ✅               | ✅               | ?                  |
| V-Slice 风格 HUD         | ✅               | ✅               | ✅               | ?                  |
| V-Slice 判定与连击数字        | ✅               | ✅               | ✅               | ?                  |
| 随机 V-Slice Note Splash | ✅              | ✅              | ✅               | ?                  |
| 开发者快捷键系统               | ✅               | ✅               | ✅               | ✅                  |
| 引擎版本检测                 | ✅               | ✅               | ✅               | ✅                  |
| 额外脚本加载器                | ✅               | ✅               | ?               | ?                  |

## 🖼️ 图集（图片来自Unsent's Toolbox在NF1.2.1-HF2实机演示）

<img width="1599" height="849" alt="image" src="https://github.com/user-attachments/assets/6fef71fb-b8dd-4a35-bcbb-a27a2df9a0ba" />

<img width="1599" height="850" alt="image" src="https://github.com/user-attachments/assets/a8c57d99-0bcc-4cfb-beb1-64269b72ae9c" />

<img width="1599" height="850" alt="image" src="https://github.com/user-attachments/assets/33e7252b-c6eb-4e79-bad6-3586bcf28e23" />

<img width="1599" height="850" alt="image" src="https://github.com/user-attachments/assets/1612a8e0-db88-4bc6-a412-fc5563b715b4" />

<img width="1599" height="849" alt="image" src="https://github.com/user-attachments/assets/3e9e9575-1cb6-4cb5-b13b-a7a5c1bb9a50" />

<img width="1599" height="852" alt="image" src="https://github.com/user-attachments/assets/f8c92b88-6bcc-4f6e-aa11-b3a7f709ea60" />


## ⚡ Quick Command 编辑说明

Quick Command（快捷命令）系统允许用户通过自定义 JSON 配置快捷键，并在按下对应按键时执行指定的 Lua 或 HScript 代码。

### 📁 配置文件

在模组的 `data` 文件夹中，有以下两个相关文件：

- **`quickCommand.json`**：正式配置文件，用于设置和执行快捷命令。
- **`quickCommand-example.json`**：示例配置文件，用于参考配置格式和编写自定义命令。

建议先参考 `quickCommand-example.json` 编写命令，再将需要使用的配置填写到 `quickCommand.json` 中。

### 📝 配置格式

以下是一个完整的配置示例：

```json
{
  "enableAll": true,
  "commands": [
    {
      "name": "Test DebugPrint Message",
      "enable": true,
      "key": "F1",
      "type": "lua",
      "code": "debugPrint(\"QuickCommand Test Lua OK\")"
    },
    {
      "name": "Test Trace Message",
      "enable": true,
      "key": "F2",
      "type": "hscript",
      "code": "trace(\"QuickCommand Test Hscript OK\")"
    }
  ]
}
```

### 🔧 字段说明

| 字段 | 类型 | 说明 |
|---|---|---|
| `enableAll` | Boolean | 全局开关。`true` 启用 Quick Command，`false` 禁用全部快捷命令。 |
| `commands` | Array | 快捷命令列表，可以添加多个命令。 |
| `name` | String | 命令名称，用于标识该命令。 |
| `enable` | Boolean | 单条命令的开关。`true` 启用，`false` 禁用。 |
| `key` | String | **Fixel 键位名**，用于指定触发命令的按键，例如 `F1`、`F2`、`K`。请使用引擎支持的键位名称。 |
| `type` | String | 代码类型，使用 `lua` 或 `hscript`。 |
| `code` | String | 需要执行的代码，以字符串形式填写。 |

### ➕ 添加快捷命令

在 `commands` 数组中添加新的对象即可。每个对象代表一条独立的快捷命令。

例如，添加一条按下 `F2` 时输出调试信息的命令：

```json
{
  "name": "Second Command",
  "enable": true,
  "key": "F2",
  "type": "lua",
  "code": "debugPrint(\"F2 Pressed!\")"
}
```

添加后，`commands` 数组可以包含多条命令：

```json
"commands": [
  {
    "name": "Test Message",
    "enable": true,
    "key": "F1",
    "type": "lua",
    "code": "debugPrint(\"QuickCommand Test OK\")"
  },
  {
    "name": "Second Command",
    "enable": true,
    "key": "F2",
    "type": "lua",
    "code": "debugPrint(\"F2 Pressed!\")"
  }
]
```

### 💻 代码类型

- **`lua`**：将 `code` 中的内容作为 Lua 代码执行。
- **`hscript`**：将 `code` 中的内容作为 HScript 代码执行。

请确保代码符合对应语言的语法，并且当前引擎环境支持所使用的函数和 API。

### ⚠️ 注意事项

- `enableAll` 必须为 `true`，并且对应命令的 `enable` 也必须为 `true`，命令才会启用。
- `key` 必须填写引擎能够识别的 Fixel 键位名称。
- JSON 字符串必须使用英文双引号；代码字符串内部的双引号需要使用 `\"` 转义。
- 每条命令之间使用英文逗号 `,` 分隔，最后一条命令后不要添加逗号。
- 修改配置前建议备份原文件，避免 JSON 格式错误导致配置无法读取。
- 请谨慎执行来源不明的 Lua 或 HScript 代码。
> 搞不懂可以让AI写😈

## ⌨️ 工具箱快捷键自定义说明

工具箱支持通过 `data/key.json` 自定义各项功能的快捷键。修改前建议备份原文件，并使用文本编辑器打开。

### 📝 配置模板示例

```json
{
  "comment": {
    "1": "自定义键位一定要填Flixel键位名！",
    "2": "禁用某个键时不要填NONE，填写Disabled即可。"
  },
  "Toggle": {
    "Botplay": "ONE",
    "Practice": "TWO",
    "FakeBotplayModifier": "SHIFT",
    "Reset": "R",
    "Increase": "THREE",
    "Decrease": "FOUR",
    "SoftPause1": "SIX",
    "SoftPause2": "Disabled",
    "Print": "FIVE"
  },
  "Modifier": {
    "SoftPauseModifierAndExit": "SPACE",
    "Control": "CONTROL",
    "Alt": "ALT",
    "Shift": "SHIFT"
  }
}
```

### 🔧 配置字段说明

| 配置项 | 功能 |
|---|---|
| `Toggle.Botplay` | 开关 BotPlay |
| `Toggle.Practice` | 开关练习模式 |
| `Toggle.FakeBotplayModifier` | 假 BotPlay 的修饰键 |
| `Toggle.Reset` | 重置快捷键使用的基础按键 |
| `Toggle.Increase` | 增加数值使用的按键 |
| `Toggle.Decrease` | 减少数值使用的按键 |
| `Toggle.SoftPause1` | 软暂停快捷键之一 |
| `Toggle.SoftPause2` | 软暂停快捷键之二 |
| `Toggle.Print` | 开关工具箱调试输出 |
| `Modifier.SoftPauseModifierAndExit` | 软暂停相关修饰键及退出操作 |

以下这些一般不要改
| 配置项 | 功能 |
|---|---|
| `Modifier.Control` | Ctrl 修饰键 |
| `Modifier.Alt` | Alt 修饰键 |
| `Modifier.Shift` | Shift 修饰键 |

### ⚠️ 注意事项

- **必须使用 Flixel 键位名**，不能随意填写按键名称。
- 禁用某个键时填写 `Disabled`，不要填写 `NONE`或`ANY`，否则可能导致脚本出错。
- 修改 JSON 时请保留原有结构和字段名称，不要删除其他配置项。
- 修改前建议备份 `key.json`，避免格式错误导致配置无法正常读取。
- 更多键位名称请参考 [Flixel 键位名参考](https://chat.deepseek.com/share/h4p75bdyy7mwx7ptux)。


---

[⬆ 返回顶部](#unsents-toolbox-nf-ver)

---

<a id="english"></a>

# 🇺🇸 English

**Developer Toolbox Mod for NovaFlare Engine 1.2.x**

Author: **Unsent / 难寄期许**

## 🎉 Introduction

Unsent's Toolbox is a debugging toolkit mod designed specifically for **NovaFlare Engine 1.2.x**. It provides a wide range of debugging tools, HUD customization options, keyboard shortcuts, and additional gameplay features. Beyond its core debugging functionality, the mod includes, but is not limited to, the following features:

- **Multilingual Support**
- **Custom Ratings and Rating Colors**
- **English / Chinese HUD Switching**
- **Score Text Color System** (Fixed Color / Rainbow / Rating-Based / Character-Based / Custom RGB)
- **Automatic Font and Font Size Adjustment for Chinese Text**
- **Smooth Color Transitions**
- **Character Afterimages on Repeated Hits**
- **Ghost Tap Detection and Counter HUD**
- **Ghost Tap Penalty System**
- **Ghost Tap Red Tint Effect**
- **FC/AP Arrow Indicators** (Gold / Blue / Cyan / Purple / Original Colors)
- **Soft Pause**
- **Four-Lane to Single-Lane Mode**
- **Miss Limit** (Ends the game after triggering DIE!!!)
- **Blind Play** (Hide All / Hide Player Side Only)
- **Quick Command System** (Lua / HScript)
- **Showcase Mode** (Hide HUD / UI / Ratings / Combos / Note Splashes)
- **Configurable Health Bar and Arrow Transparency in Showcase Mode**
- **Taunt Interactions**
- **V-Slice-Style Smooth Health Bar**
- **Player / Opponent Hold Cover Effects**

## ⚠️ Important Notes

- **Only NovaFlare Engine 1.2.x is supported. The standard Psych Engine is not compatible with this mod.**

- The Reset Values feature requires the engine's `No Reset` option to be enabled, or the reset keybind must be changed.

- After enabling the mod, you must turn on the `Enable Debug ToolBox` master switch in the mod settings for keyboard shortcuts to work.

## ⌨️ Keyboard Shortcuts

In **version 2.5.1 and later**, keybinds can be customized in `data\key.json`.

| Default Keybind (v2.5.1+) | Keybind (Before v2.5) | Function |
|---|---|---|
| `Main Keyboard 1` | `C` | Toggle BotPlay |
| `Shift` + `Main Keyboard 1` | `Shift + C` | Toggle Fake BotPlay (BotPlay text only) |
| `Main Keyboard 2` | `V` | Toggle Practice Mode |
| `Shift` + `Main Keyboard 3/4` / `Main Keyboard 3/4` | `Shift + N/M` / `N/M` | Adjust Scroll Speed |
| `Ctrl` / `Ctrl + Shift` + `Main Keyboard 3/4` | `Ctrl` / `Ctrl + Shift + N/M` | Adjust Playback Speed |
| `Ctrl + R` | `Ctrl + R` | Reset Playback Speed |
| `Shift + R` | `Shift + R` | Reset Scroll Speed |
| `Alt + R` | `Alt + R` | Reset Health to 50% |
| `Alt` / `Alt + Shift` + `Main Keyboard 3/4` | `Alt` / `Alt + Shift + N/M` | Adjust Health |
| `Space` + `Main Keyboard 6` / No modifier | `Space + H / G` | Enter Soft Pause |
| `Space` | `Space` | Exit Soft Pause |
| `Main Keyboard 5` | `P` | Toggle Toolbox Debug Output |

## 📦 Installation

1. Download the latest ZIP archive from **Releases**.
2. Extract the ZIP archive.
3. Place the extracted `Unsent's Toolbox NF Ver` folder into the NovaFlare Engine `mods` folder.
4. Launch the game and enable the mod from the mod list.
5. Open the mod settings and enable the features you want to use.

## 📜 License

Starting on **September 24, 2026**, this project is distributed under the **MIT License**.

Author: **Unsent / 难寄期许**

# 📃 Appendix
## 🖼️ Gallery (Images captured from Unsent's Toolbox running in NF 1.2.1-HF2)

<img width="1599" height="849" alt="image" src="https://github.com/user-attachments/assets/6fef71fb-b8dd-4a35-bcbb-a27a2df9a0ba" />

<img width="1599" height="850" alt="image" src="https://github.com/user-attachments/assets/a8c57d99-0bcc-4cfb-beb1-64269b72ae9c" />

<img width="1599" height="850" alt="image" src="https://github.com/user-attachments/assets/33e7252b-c6eb-4e79-bad6-3586bcf28e23" />

<img width="1599" height="850" alt="image" src="https://github.com/user-attachments/assets/1612a8e0-db88-4bc6-a412-fc5563b715b4" />

<img width="1599" height="849" alt="image" src="https://github.com/user-attachments/assets/3e9e9575-1cb6-4cb5-b13b-a7a5c1bb9a50" />

<img width="1599" height="852" alt="image" src="https://github.com/user-attachments/assets/f8c92b88-6bcc-4f6e-aa11-b3a7f709ea60" />

## ⚡ Quick Command Editing Guide

The Quick Command system allows users to configure custom keyboard shortcuts through a JSON file. Pressing the assigned key executes the specified Lua or HScript code.

### 📁 Configuration Files

The mod's `data` folder contains the following two files:

- **`quickCommand.json`**: The main configuration file used to configure and execute Quick Commands.
- **`quickCommand-example.json`**: An example configuration file that demonstrates the configuration format and how to create custom commands.

It is recommended to refer to `quickCommand-example.json` when creating commands, then add the commands you want to use to `quickCommand.json`.

### 📝 Configuration Format

The following is a complete configuration example:

```json
{
  "enableAll": true,
  "commands": [
    {
      "name": "Test DebugPrint Message",
      "enable": true,
      "key": "F1",
      "type": "lua",
      "code": "debugPrint(\"QuickCommand Test Lua OK\")"
    },
    {
      "name": "Test Trace Message",
      "enable": true,
      "key": "F2",
      "type": "hscript",
      "code": "trace(\"QuickCommand Test Hscript OK\")"
    }
  ]
}
```

### 🔧 Field Reference

| Field | Type | Description |
|---|---|---|
| `enableAll` | Boolean | Global switch. Set to `true` to enable Quick Command or `false` to disable all Quick Commands. |
| `commands` | Array | List of Quick Commands. Multiple commands can be added. |
| `name` | String | Command name used to identify the command. |
| `enable` | Boolean | Individual command switch. Set to `true` to enable the command or `false` to disable it. |
| `key` | String | **Fixel key name** used to specify the activation key, such as `F1`, `F2`, or `K`. Use a key name supported by the engine. |
| `type` | String | Code type. Use `lua` or `hscript`. |
| `code` | String | The code to execute, provided as a string. |

### ➕ Adding Quick Commands

Add a new object to the `commands` array. Each object represents an independent Quick Command.

For example, the following command prints a debug message when `F2` is pressed:

```json
{
  "name": "Second Command",
  "enable": true,
  "key": "F2",
  "type": "lua",
  "code": "debugPrint(\"F2 Pressed!\")"
}
```

After adding the command, the `commands` array can contain multiple entries:

```json
"commands": [
  {
    "name": "Test Message",
    "enable": true,
    "key": "F1",
    "type": "lua",
    "code": "debugPrint(\"QuickCommand Test OK\")"
  },
  {
    "name": "Second Command",
    "enable": true,
    "key": "F2",
    "type": "lua",
    "code": "debugPrint(\"F2 Pressed!\")"
  }
]
```

### 💻 Code Types

- **`lua`**: Executes the contents of `code` as Lua code.
- **`hscript`**: Executes the contents of `code` as HScript code.

Make sure your code follows the syntax of the selected language and that the current engine environment supports the functions and APIs you use.

### ⚠️ Notes

- Both `enableAll` and the individual command's `enable` must be set to `true` for the command to work.
- The `key` field must contain a Fixel key name recognized by the engine.
- JSON strings must use English double quotation marks (`"`). Double quotation marks inside code strings must be escaped as `\"`.
- Separate entries with English commas (`,`). Do not add a trailing comma after the last entry.
- Back up the original configuration file before making changes. Invalid JSON may prevent the configuration from being loaded.
- Be careful when executing Lua or HScript code from untrusted sources.

> Can't figure it out? Ask an AI to write it for you. 😈

---

## ⌨️ Toolbox Keybind Customization Guide

The Toolbox supports custom keybinds for various features through `data/key.json`. Before editing, it is recommended to back up the original file and open it in a text editor.

### 📝 Configuration Template

```json
{
  "comment": {
    "1": "Custom keybinds must use Flixel key names!",
    "2": "To disable a keybind, use Disabled instead of NONE."
  },
  "Toggle": {
    "Botplay": "ONE",
    "Practice": "TWO",
    "FakeBotplayModifier": "SHIFT",
    "Reset": "R",
    "Increase": "THREE",
    "Decrease": "FOUR",
    "SoftPause1": "SIX",
    "SoftPause2": "Disabled",
    "Print": "FIVE"
  },
  "Modifier": {
    "SoftPauseModifierAndExit": "SPACE",
    "Control": "CONTROL",
    "Alt": "ALT",
    "Shift": "SHIFT"
  }
}
```

### 🔧 Configuration Field Reference

| Configuration Field | Function |
|---|---|
| `Toggle.Botplay` | Toggles BotPlay. |
| `Toggle.Practice` | Toggles Practice Mode. |
| `Toggle.FakeBotplayModifier` | Modifier key for Fake BotPlay. |
| `Toggle.Reset` | Base key used by reset shortcuts. |
| `Toggle.Increase` | Key used to increase values. |
| `Toggle.Decrease` | Key used to decrease values. |
| `Toggle.SoftPause1` | One of the Soft Pause shortcut keys. |
| `Toggle.SoftPause2` | The other Soft Pause shortcut key. |
| `Toggle.Print` | Toggles Toolbox debug output. |
| `Modifier.SoftPauseModifierAndExit` | Modifier key used for Soft Pause-related shortcuts and exit operations. |

**The following settings generally should not be changed:**

| Configuration Field | Function |
|---|---|
| `Modifier.Control` | Ctrl modifier key. |
| `Modifier.Alt` | Alt modifier key. |
| `Modifier.Shift` | Shift modifier key. |

### ⚠️ Notes

- **You must use Flixel key names.** Arbitrary key names are not supported.
- To disable a keybind, use `Disabled`. Do not use `NONE` or `ANY`, as these values may cause script errors.
- Preserve the original JSON structure and field names. Do not remove other configuration entries.
- Back up `key.json` before editing to avoid configuration errors.
- For more key names, refer to the [Flixel Key Name Reference](https://chat.deepseek.com/share/h4p75bdyy7mwx7ptux).

---

[⬆ Back to top](#unsents-toolbox-nf-ver)

---
