# miyamoto.desktop-aio

An Omarchy shell `service` plugin that draws a Ryoku-style all-in-one ("AIO")
desktop face: a single click-through card on a bottom layer of the desktop —
above the wallpaper, below windows — showing:

- weather (Open-Meteo; configurable city, units, refresh)
- a big weekday, a clock (12/24-hour) and a letter-spaced date
- a live audio spectrum via `cava` reading the PipeWire playback monitor
- an optional now-playing line from MPRIS

Ink and accent follow the current Omarchy theme by default. The surface never
captures input (its layer input region is empty), leaves Omarchy's
shell/bar/Hyprland configuration untouched, and is covered by fullscreen
windows.

This package is deployed as a [GNU Stow](https://www.gnu.org/software/stow/)
package. The plugin itself is a plain Omarchy `service` plugin (kind
`service`), loaded in-process by `omarchy-shell` and enabled through
`~/.config/omarchy/shell.json`. It is not a systemd user service.

## Requirements

- [Omarchy](https://omarchy.org/) (provides `quickshell`, `qt6-svg`)
- `cava` — audio spectrum capture
- `inter-font` — the "Inter Display" face used for text
- `ttf-material-symbols-variable` — the "Material Symbols Rounded" icon face

```bash
sudo pacman -S --needed cava inter-font ttf-material-symbols-variable
```

## Install

From a checked-out copy of the dotfiles repository:

```bash
cd ~/.dotfiles
stow miyamoto.desktop-aio
omarchy plugin enable miyamoto.desktop-aio
omarchy restart shell
```

`stow` links `~/.config/omarchy/plugins/miyamoto.desktop-aio/`; `omarchy plugin
enable` adds the plugin to `~/.config/omarchy/shell.json`; restarting the shell
loads it. (In this repository `shell.json` already declares
`miyamoto.desktop-aio`, so `scripts/miyamoto-bar apply` is enough.)

To remove it:

```bash
omarchy plugin disable miyamoto.desktop-aio
omarchy restart shell
cd ~/.dotfiles && stow --delete miyamoto.desktop-aio
```

## Usage

Everything is driven by
`~/.config/omarchy/plugins/miyamoto.desktop-aio/config.toml`. Quickshell watches
the file, so edits apply live on save — no restart needed.

After enabling, restart the shell (`omarchy restart shell`) so the plugin is
loaded.

### Configuration reference

```toml
# "all", or one/more monitor names (comma-separated), e.g. "DP-2"
monitor = "DP-2"

# anchor: top-left | top-center | top-right
#         center-left | center | center-right
#         bottom-left | bottom-center | bottom-right | free
anchor = "bottom-left"
margin_x = 56          # used unless anchor = "free"
margin_y = 56
x = 0                  # used only when anchor = "free"
y = 0

scale = 0.5            # card scale (design box is 708 x 454)
opacity = 1.0

# Components
show_clock = true
show_date = true
show_weather = true
show_spectrum = true
show_media = true

# Clock
clock24h = true

# Fonts ("Inter Display" + "Material Symbols Rounded" match Ryoku)
font_display = "Inter Display"
font_icon = "Material Symbols Rounded"

# Ink/accent: "" follows the current Omarchy theme; set "#rrggbb" to override
ink = ""
accent = ""

[weather]
city = "Tehran"
refresh_seconds = 900
units = "metric"

[spectrum]
bars = 40
fps = 30
smoothing = 45
sensitivity = 1.0

[media]
max_width = 320
```

### Theming

Ink (text) and accent (spectrum bars) are read from the active Omarchy theme's
`~/.local/state/omarchy/current/theme/colors.toml`, so the widget recolors
automatically when you switch themes. Set `ink` and/or `accent` in
`config.toml` to override either one with a fixed color.

The fonts must be installed system-wide; change `font_display` / `font_icon`
in `config.toml` to use different families.

## Managing the plugin

```bash
omarchy plugin list                  # confirm miyamoto.desktop-aio is enabled
omarchy plugin disable miyamoto.desktop-aio
omarchy plugin enable  miyamoto.desktop-aio
omarchy restart shell                # reload after enabling/disabling
```

## Layout

| File | Purpose |
| --- | --- |
| `manifest.json` | Plugin manifest (kind `service`, entry point `Service.qml`) |
| `Service.qml` | Service entry point; one bottom-layer surface per selected monitor |
| `AioWidget.qml` | The AIO card (weather, weekday, clock, date, media, spectrum) |
| `Config.qml` | Reads and watches `config.toml` |
| `Theme.qml` | Ink/accent resolution from the Omarchy theme |
| `Weather.qml`, `Wmo.js` | Open-Meteo client and WMO code mapping |
| `AudioBars.qml` | `cava` spectrum over the PipeWire monitor |
| `Media.qml`, `Now.qml` | MPRIS now-playing and the shared clock |
| `GlyphIcon.qml`, `Toml.js`, `qmldir` | Icon rendering, TOML parser, module manifest |

## License

GPL-3.0. This widget adapts Ryoku's `AioWidget.qml`, `AudioBars.qml` and
weather code mapping; see
[`NOTICE`](.config/omarchy/plugins/miyamoto.desktop-aio/NOTICE).
