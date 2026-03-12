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

echo "Dotfiles repo: $REPO_DIR"
echo "Detected: mac=$is_mac linux=$is_linux"
echo

echo "Key symlinks (quick check):"
ls -la \
  ~/.gitconfig \
  ~/.ssh/config \
  ~/.config/git/ignore \
  ~/.aws/config 2>/dev/null || true

echo
echo "Git identity check:"
git config --show-origin user.email 2>/dev/null || echo "  (no git identity found)"

echo
echo "SSH identities:"
ssh -G github.com 2>/dev/null | grep -i identityfile || echo "  (ssh config not found)"

echo
echo "AWS profile:"
echo "  AWS_PROFILE=${AWS_PROFILE:-<unset>}"
if command -v aws >/dev/null 2>&1; then
  echo "  aws version: $(aws --version 2>&1)"
else
  echo "  aws: not installed"
fi

# Full audit: verify every managed file is symlinked into $HOME
if [[ "${1:-}" == "--audit" ]]; then
  echo
  echo "Audit: verifying managed files are symlinked into \$HOME..."

  audit_tree () {
    local base="$1"
    [[ -d "$base" ]] || return 0

    while IFS= read -r -d '' src; do
      local rel="${src#$base/}"
      local dest="$HOME/$rel"

      if [[ ! -L "$dest" ]]; then
        echo "  MISSING SYMLINK: $dest (should -> $src)"
        continue
      fi

      local target
      target="$(readlink "$dest")"
      if [[ "$target" != "$src" ]]; then
        echo "  WRONG TARGET: $dest -> $target (expected $src)"
      fi
    done < <(find "$base" -type f -print0)
  }

  audit_tree "$REPO_DIR/home"
  if $is_mac; then audit_tree "$REPO_DIR/mac/home"; fi
  if $is_linux; then audit_tree "$REPO_DIR/linux/home"; fi

  echo "Audit complete."
fi
