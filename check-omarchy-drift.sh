#!/usr/bin/env bash
# Scan the shipped omarchy tree for references to packages we deliberately
# strip out in customize_airootfs.sh (limine + friends, since we boot via
# GRUB/syslinux, not Limine). Run after bumping the omarchy package to catch
# new migrations/scripts that assume those packages are present before they
# start throwing errors on real machines.
#
# Usage: ./check-omarchy-drift.sh
# Requires a prior `./build` run (or at least a pacstrap) so
# work/x86_64/airootfs/usr/share/omarchy exists.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMARCHY_DIR="$REPO_DIR/work/x86_64/airootfs/usr/share/omarchy"

# Terms for packages/units removed in customize_airootfs.sh's
# `pacman -Rdd --noconfirm ...` step. Add to this list if that step grows.
STRIPPED_TERMS=(limine)

if [[ ! -d $OMARCHY_DIR ]]; then
  echo "error: $OMARCHY_DIR not found — run ./build first" >&2
  exit 1
fi

status=0

for term in "${STRIPPED_TERMS[@]}"; do
  echo "=== references to '$term' in shipped omarchy files ==="
  matches=$(grep -rln -- "$term" "$OMARCHY_DIR" 2>/dev/null || true)

  if [[ -z $matches ]]; then
    echo "(none)"
    echo
    continue
  fi

  while IFS= read -r file; do
    rel="${file#"$OMARCHY_DIR"/}"
    echo "--- $rel ---"
    grep -n -- "$term" "$file" | sed 's/^/    /'
  done <<<"$matches"
  echo

  status=1
done

if (( status )); then
  echo "Review each hit above: is it guarded (omarchy-cmd-present, a" \
    "config-file existence check) so it's a no-op without the stripped" \
    "package, or does it run unconditionally (a migration is the highest" \
    "risk — those fire on every omarchy-update)? Patch unconditional ones" \
    "in customize_airootfs.sh, following the existing fixes there."
else
  echo "No references found."
fi

exit "$status"
