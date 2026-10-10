#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
dst=/usr/share/plymouth/themes/miyamoto
font_src="$here/../miyamoto.lock/.config/omarchy/plugins/miyamoto.lock/theme/font/Outfit-Black.ttf"
font_dst=/usr/share/fonts/Outfit-Black.ttf

if (( EUID != 0 )); then
  echo "Run as root (pkexec)." >&2
  exit 1
fi

install -d -o 0 -g 0 -m 0755 "$dst"
install -o 0 -g 0 -m 0644 "$here/miyamoto.plymouth" "$dst/miyamoto.plymouth"
install -o 0 -g 0 -m 0644 "$here/miyamoto.script" "$dst/miyamoto.script"
for asset in "$here"/assets/*.png; do
  install -o 0 -g 0 -m 0644 "$asset" "$dst/${asset##*/}"
done
install -d -o 0 -g 0 -m 0755 /usr/share/fonts
install -o 0 -g 0 -m 0644 "$font_src" "$font_dst"
fc-cache -f >/dev/null

echo "family: $(fc-match -f '%{family}' 'Outfit:style=Black')"

plymouth-set-default-theme miyamoto
echo "default theme now: $(plymouth-set-default-theme)"
