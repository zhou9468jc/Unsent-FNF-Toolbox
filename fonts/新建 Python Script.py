from pathlib import Path
from fontTools import subset, ttLib

# ============================================================
# Unsent's Font Subsetter
# 精简英文、数字、常用符号及 NFE 中文评级 HUD 字符
# ============================================================

INPUT_FONT = Path("vcr.ttf")
OUTPUT_FONT = Path("unsentScoreText.ttf")

# 字体集合中的字体编号：0 或 1 等
FONT_NUMBER = 0

# 保留 ASCII：空格、英文、数字、基本标点
KEEP_UNICODE_RANGES = range(0x0020, 0x007F)

# NFE 中文评级 HUD 需要的中文及额外符号
KEEP_TEXT = (
    "分数失误准确率评级"
    "等级完美全连"
    "NPSMaxScoreMissesAccuracyRank"
    "APFCGREATGOOD"
    "：，。！？（）【】《》"
    "、·…—"
    "％＋－＝"
    "→←↑↓"
)

def main():
    if not INPUT_FONT.is_file():
        print(f"[错误] 找不到字体文件：{INPUT_FONT.resolve()}")
        return

    options = subset.Options()
    options.flavor = None
    options.font_number = FONT_NUMBER
    options.name_IDs = [1, 2, 3, 4, 5, 6]
    options.name_legacy = True
    options.name_languages = ["*"]
    options.notdef_glyph = True
    options.notdef_outline = True
    options.recommended_glyphs = True
    options.layout_features = ["*"]

    try:
        # 加载字体
        font = subset.load_font(str(INPUT_FONT), options)
        subsetter = subset.Subsetter(options=options)

        # 生成需要保留的 Unicode 字符集合
        keep_unicodes = set(KEEP_UNICODE_RANGES)
        keep_unicodes.update(ord(char) for char in KEEP_TEXT)

        subsetter.populate(unicodes=keep_unicodes)
        subsetter.subset(font)
        subset.save_font(font, str(OUTPUT_FONT), options)

        # 输出处理结果
        original_size = INPUT_FONT.stat().st_size
        output_size = OUTPUT_FONT.stat().st_size
        reduction = (
            (1 - output_size / original_size) * 100
            if original_size else 0
        )

        print("\n[完成] 字体精简成功")
        print(f"原字体：{INPUT_FONT.resolve()}")
        print(f"新字体：{OUTPUT_FONT.resolve()}")
        print(f"原大小：{original_size / 1024:.2f} KB")
        print(f"新大小：{output_size / 1024:.2f} KB")
        print(f"体积变化：{reduction:.2f}%")
        print(f"字体编号：{FONT_NUMBER}")

    except ttLib.TTLibFileIsCollectionError as exc:
        print(f"[错误] 字体包含多个字体：{exc}")
        print("请将 FONT_NUMBER 改为 0、1 等有效编号后重试。")
    except Exception as exc:
        print(f"[错误] 字体处理失败：{type(exc).__name__}: {exc}")

if __name__ == "__main__":
    main()