#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
dst=/usr/share/plymouth/themes/miyamoto
font_src="$here/../miyamoto.lock/.config/omarchy/plugins/miyamoto.lock/theme/font/Outfit-Black.ttf"
font_dst=/usr/share/fonts/Outfit-Black.ttf

if (( EUID != 0 )); then
  echo "This installer must run as root (pkexec \"$here/install.sh\")." >&2
  exit 1
fi

if [[ ! -f $here/miyamoto.plymouth || ! -f $here/miyamoto.script ]]; then
  echo "Theme files missing in $here" >&2
  exit 1
fi

if ! compgen -G "$here/assets/*.png" >/dev/null; then
  echo "No assets in $here/assets — run ./build-assets.sh as your user first." >&2
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

if ! fc-match -f '%{family}\n' "Outfit:style=Black" | grep -qi outfit; then
  echo "Outfit:style=Black is not resolvable by fontconfig; prompt text will fall back." >&2
fi

plymouth-set-default-theme miyamoto

if command -v limine-mkinitcpio >/dev/null; then
  limine-mkinitcpio
else
  mkinitcpio -P
fi

echo "Installed Plymouth theme 'miyamoto'. Reboot to see it."
