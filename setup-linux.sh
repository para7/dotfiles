#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

find "$REPO_DIR" -maxdepth 1 -mindepth 1 -name ".*" | while IFS= read -r src; do
  base="$(basename "$src")"

  case "$base" in
    "."|".."|".git"|".gitconfig"|".gitconfig.common"|".gitconfig.linux"|".gitconfig.windows")
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

gitconfig_src="$REPO_DIR/.gitconfig.linux"
gitconfig_dest="$HOME/.gitconfig"

if [ -L "$gitconfig_dest" ]; then
  rm -f "$gitconfig_dest"
elif [ -e "$gitconfig_dest" ]; then
  echo "Error: real file or directory already exists at $gitconfig_dest" >&2
  exit 1
fi

ln -s "$gitconfig_src" "$gitconfig_dest"
echo "Linked: $gitconfig_dest -> $gitconfig_src"

echo "Done."
