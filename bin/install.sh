#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

is_mac=false
is_linux=false

if [[ "$(uname -s)" == "Darwin" ]]; then
  is_mac=true
fi

if [[ "$(uname -s)" == "Linux" ]]; then
  is_linux=true
fi

echo "Installing dotfiles from: $REPO_DIR"
echo "Detected: mac=$is_mac linux=$is_linux"

link () {
  local src="$1"
  local dest="$2"

  # Ensure parent dir exists
  mkdir -p "$(dirname "$dest")"

  # Backup non-symlink existing files
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    local backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
    echo "Backing up existing: $dest -> $backup"
    mv "$dest" "$backup"
  fi

  echo "Linking: $dest -> $src"
  ln -sfn "$src" "$dest"
}

link_tree () {
  local base="$1"
  [[ -d "$base" ]] || return 0

  # Symlink every file under base into $HOME, preserving relative path.
  while IFS= read -r -d '' src; do
    local rel="${src#$base/}"
    local dest="$HOME/$rel"
    link "$src" "$dest"
  done < <(find "$base" -type f -print0)
}

# Common dotfiles (always)
link_tree "$REPO_DIR/home"

# OS overlays (override common if same path exists)
if $is_mac; then
  link_tree "$REPO_DIR/mac/home"
fi

if $is_linux; then
  link_tree "$REPO_DIR/linux/home"
fi

# Permissions hardening for SSH
chmod 700 "$HOME/.ssh" || true
chmod 600 "$HOME/.ssh/config" || true

echo
echo "Done."
echo "Next steps:"
echo "  - Run bin/check.sh to verify symlinks"
echo "  - Run bin/check.sh --audit for a full verification"
echo "  - git config --show-origin -l | head"
