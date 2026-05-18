#!/usr/bin/env bash
#
# bootstrap.sh
#
# Install or update the mobile-build-tc-from-diff skill into a target project.
#
# Copies .claude/skills/mobile-build-tc-from-diff/ from this patch-to-tc
# repository into the target project's .claude/skills/. SHA-256 hash
# comparison is used to skip unchanged files. Safe to re-run.
#
# Usage:
#   ./bootstrap.sh <target-project-path> [--force] [--dry-run]
#
# Options:
#   --force     Skip confirmation prompts and overwrite without asking
#   --dry-run   Show what would be done without making any changes
#
# Examples:
#   ./bootstrap.sh ~/projects/my-unity-project
#   ./bootstrap.sh ~/projects/my-unity-project --dry-run
#   ./bootstrap.sh ~/projects/my-unity-project --force

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SKILL="$SCRIPT_DIR/.claude/skills/mobile-build-tc-from-diff"

# Parse args
TARGET=""
FORCE=0
DRY_RUN=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --force) FORCE=1; shift ;;
        --dry-run) DRY_RUN=1; shift ;;
        --help|-h)
            grep '^#' "$0" | sed 's/^# \{0,1\}//' | head -24
            exit 0
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            if [[ -z "$TARGET" ]]; then
                TARGET="$1"; shift
            else
                echo "Unexpected argument: $1" >&2
                exit 1
            fi
            ;;
    esac
done

if [[ -z "$TARGET" ]]; then
    echo "Usage: $0 <target-project-path> [--force] [--dry-run]" >&2
    exit 1
fi

# Verify source skill exists
if [[ ! -d "$SOURCE_SKILL" ]]; then
    echo "Error: source skill not found at $SOURCE_SKILL" >&2
    echo "Run this script from the patch-to-tc repository root." >&2
    exit 1
fi

# Resolve target
if [[ ! -d "$TARGET" ]]; then
    echo "Error: target project path does not exist: $TARGET" >&2
    exit 1
fi

TARGET="$(cd "$TARGET" && pwd)"
TARGET_SKILL="$TARGET/.claude/skills/mobile-build-tc-from-diff"
SOURCE_ROOT="$(cd "$SCRIPT_DIR" && pwd)"

# Safety: refuse to bootstrap into patch-to-tc itself
if [[ "$SOURCE_ROOT" == "$TARGET" ]]; then
    echo "Error: target is the patch-to-tc repository itself. Specify a different project." >&2
    exit 2
fi

# Safety: target should be a git repository
if [[ ! -d "$TARGET/.git" ]]; then
    echo "Warning: target $TARGET is not a git repository." >&2
    if [[ $FORCE -ne 1 ]]; then
        read -p "Continue anyway? [y/N] " confirm
        [[ "$confirm" != "y" ]] && exit 3
    fi
fi

# Pick a sha256 tool (Linux: sha256sum, macOS: shasum -a 256)
if command -v sha256sum >/dev/null 2>&1; then
    HASH_CMD="sha256sum"
elif command -v shasum >/dev/null 2>&1; then
    HASH_CMD="shasum -a 256"
else
    echo "Error: no sha256 hashing tool found (need sha256sum or shasum)." >&2
    exit 1
fi

hash_file() {
    $HASH_CMD "$1" | awk '{print $1}'
}

# Walk source files
COPIED=0
UPDATED=0
SKIPPED=0

while IFS= read -r -d '' src_file; do
    rel_path="${src_file#$SOURCE_SKILL/}"
    target_file="$TARGET_SKILL/$rel_path"

    src_hash="$(hash_file "$src_file")"

    if [[ -f "$target_file" ]]; then
        tgt_hash="$(hash_file "$target_file")"
        if [[ "$src_hash" == "$tgt_hash" ]]; then
            SKIPPED=$((SKIPPED + 1))
            continue
        fi
        existed=1
    else
        existed=0
    fi

    if [[ $DRY_RUN -eq 1 ]]; then
        if [[ $existed -eq 1 ]]; then
            echo "[dry-run] would update: $rel_path"
            UPDATED=$((UPDATED + 1))
        else
            echo "[dry-run] would copy:   $rel_path"
            COPIED=$((COPIED + 1))
        fi
    else
        mkdir -p "$(dirname "$target_file")"
        cp "$src_file" "$target_file"
        if [[ $existed -eq 1 ]]; then
            UPDATED=$((UPDATED + 1))
        else
            COPIED=$((COPIED + 1))
        fi
    fi
done < <(find "$SOURCE_SKILL" -type f -print0)

echo ""
echo "Bootstrap complete:"
echo "  - $COPIED new file(s)"
echo "  - $UPDATED updated file(s)"
echo "  - $SKIPPED unchanged file(s) skipped"
echo ""
echo "Next step:"
echo "  cd \"$TARGET\""
echo "  claude"
echo "  > /mobile-build-tc-from-diff"
