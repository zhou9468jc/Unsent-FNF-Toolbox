from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
from fnmatch import fnmatch

# ============================================================
# Build Configuration
# ============================================================

# Mod source directory
SOURCE_DIR = Path(__file__).resolve().parent

# Output directory
OUTPUT_DIR = SOURCE_DIR / "releases"

# ============================================================
# Exclude Configuration
# ============================================================

# Exclude folders.
#
# Folder names or paths relative to SOURCE_DIR.
#
EXCLUDE_DIRS = {
    ".git",
    "releases",
    "NoBuildFiles",
}

# Exclude specific files.
#
# Paths are relative to SOURCE_DIR.
#
EXCLUDE_FILES = {
    "scripts/KeySettingInterpreter.txt",
    "build_releases_zip.py",
    "README.md",
}

# Exclude files by filename pattern.
#
# Supports:
#     * = any number of characters
#     ? = one character
#
# Examples:
#     "*.nobuild"
#     ".NoBuild_*"
#
EXCLUDE_PATTERNS = {
    "*.nobuild",
    ".NoBuild_*",
}

# ============================================================
# Helper Functions
# ============================================================

def normalize_path(path):
    """Convert a path to a ZIP-friendly relative path."""
    return path.as_posix()


def is_excluded(file_path):
    """Check whether a file should be excluded."""
    relative_path = file_path.relative_to(SOURCE_DIR)
    relative_posix = normalize_path(relative_path)

    # Exact file exclusion
    if relative_posix in EXCLUDE_FILES:
        return True, "excluded file"

    # Filename pattern exclusion
    for pattern in EXCLUDE_PATTERNS:
        if fnmatch(file_path.name, pattern):
            return True, f"excluded by pattern: {pattern}"

    # Directory exclusion
    for part in relative_path.parts[:-1]:
        if part in EXCLUDE_DIRS:
            return True, f"excluded directory: {part}"

    return False, ""


# ============================================================
# Version Input
# ============================================================

def ask_version():
    """Ask the user for the release version."""
    while True:
        version = input("请输入发布版本号: ").strip()

        if not version:
            print("[ERROR] 版本号不能为空。")
            continue

        # Allow users to enter either:
        # 2.4.4
        # v2.4.4
        if version.lower().startswith("v"):
            version = version[1:].strip()

        if not version:
            print("[ERROR] 版本号无效。")
            continue

        print()
        print(f"发布版本: v{version}")

        confirm = input("确认开始构建吗？[Y/N]: ").strip().lower()

        if confirm in ("y", "yes"):
            return version

        if confirm in ("n", "no"):
            print("已取消构建。")
            raise SystemExit(0)

        print("[ERROR] 请输入 Y 或 N。")
        print()


# ============================================================
# Build Release
# ============================================================

def build_release(version):
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    output_name = f"Unsent's Toolbox NF Ver v{version}.zip"
    output_path = OUTPUT_DIR / output_name

    output_relative = normalize_path(
        output_path.relative_to(SOURCE_DIR)
    )

    files_added = 0
    files_excluded = 0
    excluded_list = []

    print()
    print("=" * 60)
    print("Unsent's Toolbox Release Builder")
    print("=" * 60)
    print()
    print(f"Version: v{version}")
    print(f"Source : {SOURCE_DIR}")
    print(f"Output : {output_path}")
    print()

    # Remove previous build with the same version
    if output_path.exists():
        print(f"[INFO] Removing old release: {output_path.name}")
        output_path.unlink()
        print()

    with ZipFile(
        output_path,
        "w",
        compression=ZIP_DEFLATED,
        compresslevel=9
    ) as archive:

        for file_path in SOURCE_DIR.rglob("*"):
            if not file_path.is_file():
                continue

            relative_path = file_path.relative_to(SOURCE_DIR)
            relative_posix = normalize_path(relative_path)

            # Always exclude the output ZIP itself
            if relative_posix == output_relative:
                files_excluded += 1
                excluded_list.append(
                    (relative_posix, "release output")
                )
                continue

            excluded, reason = is_excluded(file_path)

            if excluded:
                files_excluded += 1
                excluded_list.append(
                    (relative_posix, reason)
                )
                continue

            archive.write(
                file_path,
                arcname=relative_posix
            )

            files_added += 1
            print(f"[ADD] {relative_posix}")

    # ========================================================
    # Build Summary
    # ========================================================

    print()
    print("=" * 60)
    print("Build Complete")
    print("=" * 60)
    print(f"Version        : v{version}")
    print(f"Files added    : {files_added}")
    print(f"Files excluded : {files_excluded}")
    print(f"Output         : {output_path}")
    print()

    if excluded_list:
        print("Excluded files:")
        for path, reason in excluded_list:
            print(f"  [SKIP] {path} ({reason})")
        print()

    # ========================================================
    # ZIP Integrity Test
    # ========================================================

    print("Testing ZIP integrity...")

    with ZipFile(output_path, "r") as archive:
        bad_file = archive.testzip()

    if bad_file is None:
        print("[OK] ZIP integrity test passed.")
    else:
        print(f"[ERROR] ZIP integrity test failed: {bad_file}")
        return False

    print()
    print(f"Release ZIP: {output_path}")

    return True


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    try:
        version = ask_version()
        success = build_release(version)

    except Exception as error:
        print()
        print("=" * 60)
        print("BUILD FAILED")
        print("=" * 60)
        print(f"{type(error).__name__}: {error}")
        raise

    if not success:
        raise SystemExit(1)