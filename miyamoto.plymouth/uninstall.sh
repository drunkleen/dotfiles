#!/usr/bin/env bash
set -euo pipefail

if (( EUID != 0 )); then
  echo "This uninstaller must run as root (pkexec \"$0\")." >&2
  exit 1
fi

plymouth-set-default-theme omarchy
rm -rf /usr/share/plymouth/themes/miyamoto
rm -f /usr/share/fonts/Outfit-Black.ttf
fc-cache -f >/dev/null

if command -v limine-mkinitcpio >/dev/null; then
  limine-mkinitcpio
else
  mkinitcpio -P
fi

echo "Restored the default 'omarchy' Plymouth theme."
