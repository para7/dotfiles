#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

find "$REPO_DIR" -maxdepth 1 -mindepth 1 -name ".*" | while IFS= read -r src; do
  base="$(basename "$src")"

  case "$base" in
    "."|".."|".git")
      continue
      ;;
  esac

  dest="$HOME/$base"

  if [ -L "$dest" ]; then
    rm -f "$dest"
  elif [ -e "$dest" ]; then
    echo "Error: real file or directory already exists at $dest" >&2
    exit 1
  fi

  ln -s "$src" "$dest"
  echo "Linked: $dest -> $src"
done
echo "Done."
