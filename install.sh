#!/usr/bin/env bash
# Install skills from this repo into an agent skills directory.
#
#   ./install.sh               link mode (default): symlink each skill dir
#   ./install.sh --copy        copy mode: real directory copies
#   ./install.sh --force       replace targets that differ from the repo
#   ./install.sh --uninstall   remove symlinks owned by this repo
#
# Link mode makes `git pull` the deployment: pulled changes are live at the
# next session start, and an edit made through a symlink is an edit to this
# repo's working copy — `git status` here reveals live edits before a push.
# Copy mode needs a re-run after every pull, and live edits drift invisibly;
# prefer link mode. Existing real dirs that differ from the repo are never
# clobbered without --force (a differing dir usually means local edits).
#
# Override the destination for testing: SKILLS_DEST=/tmp/sandbox ./install.sh
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
DEST="${SKILLS_DEST:-$HOME/.agents/skills}"
MODE=link
FORCE=0
UNINSTALL=0
for arg in "$@"; do
  case "$arg" in
    --copy)       MODE=copy ;;
    --force)      FORCE=1 ;;
    --uninstall)  UNINSTALL=1 ;;
    -h|--help)    sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)            echo "unknown argument: $arg (see --help)" >&2; exit 2 ;;
  esac
done

linked=0; copied=0; already=0; replaced=0; warned=0; removed=0; kept_foreign=0

if [ "$UNINSTALL" -eq 0 ]; then
  mkdir -p "$DEST"
fi

for d in "$REPO"/*/; do
  src="${d%/}"
  [ -f "$src/SKILL.md" ] || continue
  name="$(basename "$src")"
  target="$DEST/$name"

  if [ "$UNINSTALL" -eq 1 ]; then
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$src" ]; then
      rm "$target"; removed=$((removed + 1))
    elif [ -e "$target" ]; then
      kept_foreign=$((kept_foreign + 1))
      echo "  keep  $name (not a symlink to this repo — not touching)"
    fi
    continue
  fi

  if [ "$MODE" = link ]; then
    if [ -L "$target" ]; then
      if [ "$(readlink "$target")" = "$src" ]; then
        already=$((already + 1))
      else
        warned=$((warned + 1))
        echo "  WARN  $name: symlink points elsewhere ($(readlink "$target")) — skipping"
      fi
      continue
    fi
    if [ -d "$target" ]; then
      if diff -r --brief "$target" "$src" >/dev/null 2>&1 || [ "$FORCE" -eq 1 ]; then
        rm -rf "$target"; ln -s "$src" "$target"; replaced=$((replaced + 1))
      else
        warned=$((warned + 1))
        echo "  WARN  $name: real dir differs from repo (local edits?) — skipping (use --force)"
      fi
      continue
    fi
    ln -s "$src" "$target"; linked=$((linked + 1))
  else
    if [ -L "$target" ]; then
      rm "$target"; cp -a "$src" "$target"; copied=$((copied + 1)); continue
    fi
    if [ -d "$target" ]; then
      if diff -r --brief "$target" "$src" >/dev/null 2>&1; then
        already=$((already + 1))
      elif [ "$FORCE" -eq 1 ]; then
        rm -rf "$target"; cp -a "$src" "$target"; copied=$((copied + 1))
      else
        warned=$((warned + 1))
        echo "  WARN  $name: existing dir differs from repo — skipping (use --force)"
      fi
      continue
    fi
    cp -a "$src" "$target"; copied=$((copied + 1))
  fi
done

if [ "$UNINSTALL" -eq 1 ]; then
  echo "uninstall: removed=$removed kept_foreign=$kept_foreign"
else
  echo "$MODE mode -> $DEST: linked=$linked copied=$copied already_ok=$already replaced=$replaced warned=$warned"
fi
