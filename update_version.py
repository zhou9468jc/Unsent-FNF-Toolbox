import json
import re
from pathlib import Path

ROOT = Path(__file__).parent

PACK_FILE = ROOT / "pack.json"
MENU_FILE = ROOT / "stageScripts" / "globals" / "mainMenu.hx"


def get_current_version():
    if not PACK_FILE.exists():
        return "未知"

    try:
        with open(PACK_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)

        desc = data.get("description", "")
        match = re.search(r"Version:\s*([^\n]+)", desc)

        if match:
            return match.group(1).strip()

    except Exception:
        pass

    return "未知"


def update_pack(version, tag):
    if not PACK_FILE.exists():
        print("未找到 pack.json")
        return

    with open(PACK_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)

    desc = data.get("description", "")

    desc = re.sub(
        r"Version:\s*[^\n]+",
        f"Version: {version}",
        desc
    )

    desc = re.sub(
        r"releases/tag/[^\s\"]+",
        f"releases/tag/{tag}",
        desc
    )

    data["description"] = desc

    with open(PACK_FILE, "w", encoding="utf-8") as f:
        json.dump(
            data,
            f,
            ensure_ascii=False,
            indent=4
        )

    print("已更新 pack.json")


def update_main_menu(version):
    if not MENU_FILE.exists():
        print("未找到 mainMenu.hx")
        return

    text = MENU_FILE.read_text(encoding="utf-8")

    text = re.sub(
        r"Unsent's Toolbox v [0-9A-Za-z.\-]+",
        f"Unsent's Toolbox v {version}",
        text
    )

    MENU_FILE.write_text(
        text,
        encoding="utf-8"
    )

    print("已更新 mainMenu.hx")


def main():
    current = get_current_version()

    print("=== Unsent's Toolbox Version Updater ===")
    print(f"当前版本: {current}")
    print()

    version = input("请输入新版本号: ").strip()

    if not version:
        print("版本号不能为空")
        return

    default_tag = "v" + version.lower()

    tag = input(
        f"请输入 GitHub Tag (默认 {default_tag}): "
    ).strip()

    if not tag:
        tag = default_tag

    print()
    print(f"新版本: {version}")
    print(f"Tag: {tag}")
    print()

    update_pack(version, tag)
    update_main_menu(version)

    print()
    print("更新完成!")
    


if __name__ == "__main__":
    main()
    input("按Enter关闭...")