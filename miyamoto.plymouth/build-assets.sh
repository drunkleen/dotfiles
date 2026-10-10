#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
out="$here/assets"
font="${FONT:-$here/../miyamoto.lock/.config/omarchy/plugins/miyamoto.lock/theme/font/Outfit-Black.ttf}"

# Bake at 2x the lock's 768-tall coordinate system (`s = Screen.height/768`),
# so runtime assets are downscaled (crisp) for typical panels.
B=2
PAD=8

WHITE="#ffffff"
RUST="#881d20"
DIM="#666666"
PILL_FILL="#080808"
PILL_BORDER="#1a1a1a"
PILL_INNER="#222222"

# Lock geometry, in `s` units (T = tangential thickness, L = radial length)
INNER_R=320; OUTER_R=480
INNER_LAB_R=285; OUTER_LAB_R=450
INNER_MAJ_L=18; INNER_MAJ_T=2; INNER_MIN_L=10; INNER_MIN_T=1; INNER_FONT=22
OUTER_MAJ_L=13; OUTER_MAJ_T=1.5; OUTER_MIN_L=8; OUTER_MIN_T=1; OUTER_FONT=16
TICK_MAJ_A=0.30; TICK_MIN_A=0.15; LABEL_A=0.25
PILL_W=330; PILL_H=90; PILL_DIV_X=170; PILL_DIV_W=1; PILL_DIV_H=35

mkdir -p "$out"
[[ -f $font ]] || { echo "Font not found: $font" >&2; exit 1; }

scaled() { awk -v v="$1" -v b="$B" 'BEGIN { printf "%d", int(v * b + 0.5) }'; }
pos()    { awk -v c="$1" -v r="$2" -v i="$3" 'BEGIN { pi=3.14159265358979; a=i*6*pi/180; printf "%d %d", c+r*cos(a)+0.5, c+r*sin(a)+0.5 }'; }

# ticks_mvg CENTER R MAJ_L MAJ_T MIN_L MIN_T  (baked pixels)
# Drawn as explicit polygons: MVG translate/rotate accumulate across primitives.
ticks_mvg() {
  awk -v c="$1" -v R="$2" -v majL="$3" -v majT="$4" -v minL="$5" -v minT="$6" '
    function tick(i, hl, wt,  a, ca, sa, tx, ty) {
      a = i * 6 * 3.14159265358979 / 180
      ca = cos(a); sa = sin(a)
      tx = c + R * ca; ty = c + R * sa
      # tangential unit = (-sa, ca); radial unit = (ca, sa)
      printf "polygon %.2f,%.2f %.2f,%.2f %.2f,%.2f %.2f,%.2f\n", \
        tx + wt*sa - hl*ca, ty - wt*ca - hl*sa, \
        tx - wt*sa - hl*ca, ty + wt*ca - hl*sa, \
        tx - wt*sa + hl*ca, ty + wt*ca + hl*sa, \
        tx + wt*sa + hl*ca, ty - wt*ca + hl*sa
    }
    BEGIN {
      printf "stroke none fill \"#ffffff\" fill-opacity 0.15\n"
      for (i = 0; i < 60; i++) { if (i % 5 == 0) continue; tick(i, minL/2, minT/2) }
      printf "fill-opacity 0.30\n"
      for (i = 0; i < 60; i += 5) { tick(i, majL/2, majT/2) }
    }'
}

# draw_ring OUTFILE R LAB_R MAJ_L MAJ_T MIN_L MIN_T FONT_SIZE  (all s units)
draw_ring() {
  local file="$1"
  local R="$(scaled "$2")" labR="$(scaled "$3")"
  local majL="$(scaled "$4")" majT="$(scaled "$5")"
  local minL="$(scaled "$6")" minT="$(scaled "$7")" fsize="$(scaled "$8")"
  local canvas center pad
  pad=$(( majL / 2 + 6 ))
  canvas=$(( 2 * R + 2 * pad )); center=$(( R + pad ))

  magick -size ${canvas}x${canvas} xc:none \
    -draw "$(ticks_mvg "$center" "$R" "$majL" "$majT" "$minL" "$minT")" "$file"

  local tmp; tmp="$(mktemp -d)"
  local i px py lw lh x y
  for (( i = 0; i < 60; i += 5 )); do
    read -r px py <<<"$(pos "$center" "$labR" "$i")"
    magick -background none -font "$font" -pointsize "$fsize" -fill "$WHITE" \
      -gravity center label:"$(printf '%02d' "$i")" "$tmp/l.png"
    magick "$tmp/l.png" -background none -rotate "$(( i * 6 ))" "$tmp/lr.png"
    read -r lw lh < <(identify -format '%w %h\n' "$tmp/lr.png")
    x=$(( px - lw / 2 )); y=$(( py - lh / 2 ))
    magick "$file" \( "$tmp/lr.png" -channel A -evaluate multiply "$LABEL_A" +channel \) \
      -gravity NorthWest -geometry "+${x}+${y}" -composite "$file"
  done
  rm -rf "$tmp"
}

echo ":: rings"
draw_ring "$out/ring_inner.png" "$INNER_R" "$INNER_LAB_R" \
  "$INNER_MAJ_L" "$INNER_MAJ_T" "$INNER_MIN_L" "$INNER_MIN_T" "$INNER_FONT"
draw_ring "$out/ring_outer.png" "$OUTER_R" "$OUTER_LAB_R" \
  "$OUTER_MAJ_L" "$OUTER_MAJ_T" "$OUTER_MIN_L" "$OUTER_MIN_T" "$OUTER_FONT"

# Spotlight hands: the bright 3-o'clock radial tick -> horizontal bar (len x thick)
bar() {
  local file="$1" w="$2" h="$3"
  magick -size ${w}x${h} xc:none -fill "$WHITE" -stroke none \
    -draw "rectangle 0,0 $(( w - 1 )),$(( h - 1 ))" "$file"
}
echo ":: hands"
bar "$out/hand_inner.png" "$(scaled "$INNER_MAJ_L")" "$(scaled "$INNER_MAJ_T")"
bar "$out/hand_outer.png" "$(scaled "$OUTER_MAJ_L")" "$(scaled "$OUTER_MAJ_T")"

echo ":: pill"
PW="$(scaled "$PILL_W")"; PH="$(scaled "$PILL_H")"
DX="$(scaled "$PILL_DIV_X")"; DW="$(scaled "$PILL_DIV_W")"; DH="$(scaled "$PILL_DIV_H")"
DY=$(( (PH - DH) / 2 ))
magick -size ${PW}x${PH} xc:none \
  -stroke "$PILL_BORDER" -strokewidth "$B" -fill "$PILL_FILL" \
  -draw "roundrectangle 1,1 $(( PW - 2 )),$(( PH - 2 )) $(( PH / 2 - 1 )),$(( PH / 2 - 1 ))" \
  -stroke none -fill "$PILL_INNER" \
  -draw "rectangle ${DX},${DY} $(( DX + DW - 1 )),$(( DY + DH - 1 ))" \
  "$out/pill.png"

echo ":: panel text"
magick -background none -font "$font" -fill "$RUST" \
  -pointsize "$(scaled 18)" -kerning "$(scaled 8)" label:"ARCH" -trim +repage \
  "$out/user.png"

echo ":: bullets"
magick -size 64x64 xc:none -fill "$DIM" \
  -draw "$(awk 'BEGIN{pi=3.14159265358979;c=32;ro=15;ri=5;
    for(i=0;i<8;i++){a=i*45*pi/180-pi/2;r=(i%2==0)?ro:ri;
      printf "%s%.2f,%.2f",(i?" ":"polygon "),c+r*cos(a),c+r*sin(a)}}')" \
  "$out/bullet.png"

rm -f "$out"/logo.png "$out"/labels*.png

echo ":: done"
identify -format '%f %wx%h\n' "$out"/*.png
