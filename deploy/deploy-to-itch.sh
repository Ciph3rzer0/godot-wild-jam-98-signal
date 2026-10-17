#!/usr/bin/env bash

## AI GENERATED
# Deploy the Godot web export to itch.io using butler.
#
# Lives at: <project>/deploy/deploy-to-itch.sh
#
# One-time setup:
#   - Install butler: https://itch.io/docs/butler/
#   - Run `butler login` (or set BUTLER_API_KEY in CI)
#   - On itch: set Kind of project to HTML, and tick "This file will be
#     played in the browser" on the upload after the first push.
#
# Usage:
#   ./deploy-to-itch.sh                         # zip + push the existing export
#   GODOT=/path/to/godot ./deploy-to-itch.sh    # re-export first, then zip + push

# Stop on the first failing command (-e), on use of unset variables (-u),
# and when any command in a pipeline fails (pipefail).
set -euo pipefail

# itch target in the form user/game:channel.
ITCH_TARGET="ciph3rzer0/signal:web"

ZIP_NAME="signal_game.zip"

# Resolve paths from the script's own location so it works from any cwd.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
EXPORT_DIR="$PROJECT_DIR/webexport"
ZIP_PATH="$EXPORT_DIR/$ZIP_NAME"

# Optional re-export. EXPORT_PRESET must match the preset name in export_presets.cfg.
GODOT="${GODOT:-}"
EXPORT_PRESET="${EXPORT_PRESET:-Web}"

die() { echo "Error: $*" >&2; exit 1; }

# Fail early with a clear message instead of halfway through.
command -v butler >/dev/null 2>&1 || die "butler not found on PATH"

if [[ -n "$GODOT" ]]; then
  echo "Exporting preset '$EXPORT_PRESET'..."
  # Start from an empty directory so files from old builds can't linger.
  rm -rf "$EXPORT_DIR"
  mkdir -p "$EXPORT_DIR"
  # Keep the Godot editor from scanning/importing the exported files.
  touch "$EXPORT_DIR/.gdignore"
  # itch serves index.html from the root of the upload, so export to that name.
  "$GODOT" --headless --path "$PROJECT_DIR" \
    --export-release "$EXPORT_PRESET" "$EXPORT_DIR/index.html"
fi

# Sanity check: without index.html at the root, itch can't launch the game.
[[ -f "$EXPORT_DIR/index.html" ]] \
  || die "no index.html in $EXPORT_DIR (export the Web preset as index.html first)"

# Start fresh: zip -r updates an existing archive instead of replacing it,
# so files deleted from the export would otherwise stay in the zip.
rm -f "$ZIP_PATH"

# Zip the contents of webexport with index.html at the archive root.
# The * glob skips dotfiles (.gdignore), and the old zip is already deleted,
# so the archive can't include itself.
(
  cd "$EXPORT_DIR"
  if command -v zip >/dev/null 2>&1; then
    zip -r -X "$ZIP_NAME" *            # macOS / Linux
  elif [[ -x /c/Windows/System32/tar.exe ]]; then
    # Windows 10+ bsdtar (Git Bash's own tar is GNU tar and can't write zips).
    # -a picks the zip format from the .zip extension.
    /c/Windows/System32/tar.exe -a -c -f "$ZIP_NAME" *
  else
    echo "Error: no zip tool found (install zip, or use Windows 10+ tar.exe)" >&2
    exit 1
  fi
)

# Version label shown on itch: git tag/commit if available, timestamp otherwise.
# --dirty marks builds made with uncommitted changes.
VERSION="$(git -C "$PROJECT_DIR" describe --tags --always --dirty 2>/dev/null \
  || date +%Y%m%d-%H%M)"

echo "Pushing $ZIP_PATH -> $ITCH_TARGET (version $VERSION)"
# butler diffs the zip's contents against the last build and uploads only
# what changed. --if-changed skips the push entirely if nothing did.
butler push "$ZIP_PATH" "$ITCH_TARGET" # --userversion "$VERSION"