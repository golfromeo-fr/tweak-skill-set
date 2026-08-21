#!/usr/bin/env bash
# Fallback: if an agent ever fails to discover skills through symlinks,
# replace the ~/.agents/skills symlinks with real copies from this repo.
set -euo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.agents/skills"
mkdir -p "$DEST"
for d in "$REPO"/*/; do
  name="$(basename "$d")"
  [ -f "$d/SKILL.md" ] || continue
  if [ -L "$DEST/$name" ]; then
    rm "$DEST/$name"
  fi
  if [ ! -e "$DEST/$name" ]; then
    cp -a "$d" "$DEST/$name"
    echo "copied $name"
  fi
done
echo "done: real copies of all skills now in $DEST"
