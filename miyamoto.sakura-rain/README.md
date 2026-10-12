# miyamoto.sakura-rain

A desktop petal overlay for Omarchy and Hyprland. Sakura petals drift down over
the wallpaper, in 3D depth: near petals are larger, faster and brighter; far
petals are smaller, slower and dimmer. The overlay is a Quickshell config on a
Wayland background layer. It never takes mouse or keyboard input and never
takes focus.

Petals fade out under application windows, so they show only on bare
wallpaper. Fullscreen windows (games, video) pause the effect.

## Requirements

- Omarchy or any Hyprland session with `quickshell` (Omarchy provides it)
- Python 3.11+ (`tomllib`)
- `stow`, and a systemd user session with `graphical-session.target`

## Install

From the repository root:

```bash
scripts/sakura-rain-install
```

This stows the package with `--no-folding` (each file is linked, so
`~/.config/quickshell/` stays a real directory), validates the config, enables
`sakura-rain.service`, and starts it when a Wayland session is present.

Do not add this package to `pkgs` in the root README or to the auto-stow in
`scripts/update-omarchy-customizations`. Those run `stow` with folding, which
can turn `~/.config/quickshell/` into a single symlink on a fresh machine.

## Uninstall

```bash
scripts/sakura-rain-uninstall
```

This stops and disables the service and unlinks the package. Repository files
stay in place, including your `config.toml`.

## Commands

| Command | What it does |
| --- | --- |
| `sakura-rain start` | Start the service |
| `sakura-rain stop` | Stop the service |
| `sakura-rain toggle` | Start if stopped, stop if running (bind this to a key) |
| `sakura-rain restart` | Apply `config.toml` changes (also re-checks the config) |
| `sakura-rain status` | Show service state and the resolved settings |
| `sakura-rain config` | Validate and print the resolved settings as JSON |
| `sakura-rain logs` | Show the last 80 service log lines |
| `sakura-rain run` | Run in the foreground (what the service executes) |

Config changes take effect on `sakura-rain restart`. The overlay does not
reload on save.

Bind `sakura-rain toggle` in your Hyprland config to switch the overlay on and
off from the keyboard.

## Configuration

Two files live in `~/.config/sakura-rain/` (linked from the repo):

- `config.toml`: your settings. Each `[settings]` key is commented out by default.
- `presets.toml`: named presets and colour palettes. Edit freely.

Resolution order for each setting: built-in defaults, then the preset, then
`[settings]` in `config.toml`.

```toml
enabled = true      # false: the service starts and exits without drawing
preset = "sakura"   # zen | sakura | storm | custom

[settings]
petal_count = 25    # 1..200 petals per monitor
```

### Settings

| Key | Range or values | Default | Meaning |
| --- | --- | --- | --- |
| `petal_count` | 1..200 | 25 | Petals per monitor |
| `spawn_rate` | 0..10 | 0.5 | Petals released per second (0 = no respawn) |
| `fall_speed` | `very_slow` 30, `slow` 60, `medium` 100, `fast` 160, or a number 0..300 | `slow` | Fall speed in px/s at 1440 px screen height (scales per monitor) |
| `wind_strength` | 0..3 | 0.15 | Horizontal drift (0 still, 1 strong, 3 gale) |
| `depth_spread` | 0..1 | 0.6 | 3D depth variety (0 flat, 1 wide spread) |
| `rotation_speed` | `off`, `slow` 0.5, `medium` 1, `fast` 2, or a number 0..4 | `slow` | Spin and tumble rate |
| `opacity` | 0..1 | 0.75 | Overall petal opacity |
| `petal_size` | `[min, max]`, 2..120 px | `[12, 28]` | Petal size at the screen plane |
| `fps_limit` | 10..120 (30 or 60 recommended) | 30 | Frame rate of the motion timer |
| `pause_on_fullscreen` | `true` / `false` | `true` | Hide while a window is fullscreen |
| `avoid_windows` | `true` / `false` | `true` | Fade petals out under app windows |
| `click_through` | `true` / `false` | `true` | `false` lets the overlay capture mouse clicks |
| `color_palette` | `dark_red`, `dusty_pink` | `dark_red` | Colour set from `presets.toml` |
| `rendering_layer` | `background`, `bottom`, `top` | `background` | `background` draws under windows; `top` draws over them |

Unknown keys and out-of-range values fail with an error and exit code 2.

Example, a windy evening scene:

```toml
[settings]
fall_speed = "medium"
wind_strength = 1.2
depth_spread = 0.8
```

### Presets

| Preset | Petals | Spawn/s | Fall | Wind | Rotation | Opacity | FPS |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `zen` | 8 | 0.12 | `very_slow` | 0.05 | `slow` | 0.6 | 30 |
| `sakura` | 25 | 0.5 | `slow` | 0.15 | `slow` | 0.75 | 30 |
| `storm` | 60 | 1.2 | `medium` | 0.6 | `medium` | 0.85 | 60 |
| `custom` | none; only defaults and `[settings]` | | | | | | |

### Palettes

Palettes live in `presets.toml` under `[palettes.<name>]`. Each petal shades
from its `base` colour at the stem to its `tip` colour. The `accent` is used on
`accent_chance` of petals.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| No petals visible | Windows cover the wallpaper: switch to an empty workspace, or set `avoid_windows = false` |
| Service not running | `sakura-rain status`, then `sakura-rain logs` |
| Config error after edit | `sakura-rain config` shows the message and the key |
| Petals stop or freeze after lock or lid close | The service restarts itself (`Restart=always`); report it with `sakura-rain logs` |
| Overlay does not start from a terminal | Needs a Wayland session (`WAYLAND_DISPLAY` set) |

## Files

```
~/.local/bin/sakura-rain                         # CLI (Python, stdlib only)
~/.config/sakura-rain/config.toml                # your settings
~/.config/sakura-rain/presets.toml               # presets and palettes
~/.config/quickshell/sakura-rain/                # QML: shell, PetalField, Petal, Settings.js
~/.config/systemd/user/sakura-rain.service       # user service (autostart)
```
