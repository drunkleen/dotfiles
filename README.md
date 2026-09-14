# My Linux Dotfiles

Personal configuration for my Omarchy desktop and command-line environment, managed with [GNU Stow](https://www.gnu.org/software/stow/).

> [!IMPORTANT]
> The Hyprland configuration in this repository is for **Omarchy only**. It imports Omarchy's Lua bootstrap and default modules from `/usr/share/omarchy`, so it is not a standalone Hyprland configuration and will not work correctly on a plain Hyprland installation.

## Contents

The current working tree contains these Stow packages:

| Package | Installed path | Purpose |
| --- | --- | --- |
| [`fontconfig`](fontconfig) | `~/.config/fontconfig/` | Font-family defaults and fallbacks |
| [`hypr`](hypr) | `~/.config/hypr/` | Omarchy-specific Hyprland Lua configuration |
| [`nvim`](nvim) | `~/.config/nvim/` | Neovim configuration from the `tired.nvim` Git submodule |
| [`omarchy`](omarchy) | `~/.config/omarchy/`, `~/.config/systemd/user/`, `~/.config/gtk-*`, `~/.icons/`, `~/.local/` | Lock screen, desktop clock, plugins, theme, cursor, font, and resume input fix |
| [`terminal`](terminal) | `~/.zshrc`, `~/.gitconfig`, `~/.config/terminal/`, `~/.config/{alacritty,btop,foot,ghostty,kitty,leenfetch,tmux}/` | Zsh setup, shared shell utilities, terminal emulators, btop, Leenfetch, and tmux |
| [`voxtype`](voxtype) | `~/.config/voxtype/` | Whisper-based dictation daemon and hotkey tooling |

Each package mirrors its destination below `$HOME`. The repository's [`.stowrc`](.stowrc) sets the Stow target to `~/` and enables restowing.

The Omarchy plugins are maintained as separate Git submodules:

- [`drunkleen/omarchy.paperwidget`](https://github.com/drunkleen/omarchy.paperwidget) → `omarchy/.config/omarchy/plugins/omarchy.paperwidget`
- [`drunkleen/omarchy.pixlock`](https://github.com/drunkleen/omarchy.pixlock) → `omarchy/.config/omarchy/plugins/omarchy.pixlock`
- [`mrCode/castr-indicator`](https://github.com/mrCode/castr-indicator) → `omarchy/.config/omarchy/plugins/castr.indicator`
- [`thisisgm/omarchy-pods`](https://github.com/thisisgm/omarchy-pods) → `omarchy/.config/omarchy/plugins/io.github.thisisgm.omapods`
- [`huacnlee/omamail`](https://github.com/huacnlee/omamail) → `omarchy/.config/omarchy/plugins/omamail`
- [`stappmus/Omarchy-Spotify`](https://github.com/stappmus/Omarchy-Spotify) → `omarchy/.config/omarchy/plugins/quickshell.spotify`

The [Leenium Omarchy theme](https://github.com/drunkleen/leenium.omarchy) is bundled as a submodule under `omarchy/.config/omarchy/themes/leenium.omarchy`.

## Requirements

The base installation requires:

- [Omarchy](https://omarchy.org/)
- Git
- GNU Stow
- `capitaine-cursors`

The configuration also expects several tools used by the shell setup, including Zsh, Starship, zoxide, fzf, fd, eza, bat, ripgrep, tmux, and Leenfetch. Some helper functions additionally use Docker, `yay`, `jq`, and desktop utilities such as `xdg-open`.

## Installation

Clone the Omarchy branch into `~/dotfiles`:

```bash
git clone --recurse-submodules --branch omarchy git@github.com:drunkleen/my-linux-dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Preview all current packages before linking them:

```bash
stow --no --verbose fontconfig hypr nvim omarchy terminal voxtype
```

Install all current packages:

```bash
stow fontconfig hypr nvim omarchy terminal voxtype
```

If the repository was cloned without `--recurse-submodules`, initialize the Neovim configuration afterward:

```bash
git submodule update --init --recursive
```

Stow does not overwrite existing files. If a target already exists, move it to a backup location first and rerun the command. For example:

```bash
mv ~/.config/hypr ~/.config/hypr.pre-dotfiles
stow hypr
```

## Omarchy Setup

The repository includes a helper for the complete Omarchy customization:

```bash
cd ~/dotfiles
./scripts/setup-omarchy-customizations
```

Run it from an unlocked graphical Omarchy session. It:

1. Stows the `hypr` and `omarchy` packages.
2. Refreshes the user font cache.
3. Reloads the user systemd manager.
4. Enables and starts the fcitx5 resume monitor.
5. Rescans the Omarchy plugin registry.
6. Enables the custom lock screen and desktop clock.
7. Sets `capitaine-cursors` as the Hyprland, GTK, and XCursor default at size 24.

If the Omarchy or Hyprland target files already exist, back them up before running the helper:

```bash
mv ~/.config/hypr ~/.config/hypr.pre-dotfiles
mv ~/.config/omarchy/plugins/omarchy.pixlock ~/.config/omarchy/plugins/omarchy.pixlock.pre-dotfiles 2>/dev/null || true
mv ~/.config/omarchy/plugins/omarchy.paperwidget ~/.config/omarchy/plugins/omarchy.paperwidget.pre-dotfiles 2>/dev/null || true
./scripts/setup-omarchy-customizations
```

### Omarchy-only Hyprland configuration

[`hypr/.config/hypr/hyprland.lua`](hypr/.config/hypr/hyprland.lua) loads:

- Omarchy's bootstrap from `$OMARCHY_PATH` or `/usr/share/omarchy`
- Omarchy's default Hyprland Lua configuration
- personal monitor, input, binding, appearance, and autostart overrides
- Omarchy's dynamic toggles
- custom screen-recording styling

The package also includes `hyprsunset`, XDG desktop portal, recording, and Lua language-server configuration. Do not install this package on a non-Omarchy Hyprland system without rewriting its imports and defaults.

### Lock screen

[`omarchy.pixlock`](omarchy/.config/omarchy/plugins/omarchy.pixlock) is a customized clone of Omarchy's lock plugin. It provides:

- a Stencil Pixel-7 clock and day/date display
- a matching password field and password characters
- automatic FIDO2 security-key detection and unlock through `omarchy-lock-fido2`
- password fallback when no FIDO2 key is present
- automatic password-field focus
- password and fingerprint PAM flows
- layout and focus hardening for suspend and lid-close behavior

Its source repository is [drunkleen/omarchy.pixlock](https://github.com/drunkleen/omarchy.pixlock).

### Desktop clock

[`omarchy.paperwidget`](omarchy/.config/omarchy/plugins/omarchy.paperwidget) displays the matching Stencil Pixel-7 clock and day/date at the bottom-left of the desktop.

Its source repository is [drunkleen/omarchy.paperwidget](https://github.com/drunkleen/omarchy.paperwidget).

### Additional plugins

The `omarchy` package also bundles several third-party plugins as submodules:

- [`castr.indicator`](omarchy/.config/omarchy/plugins/castr.indicator) — cast the screen to an Apple TV or Chromecast from the bar, with a live mirror/extend indicator.
- [`io.github.thisisgm.omapods`](omarchy/.config/omarchy/plugins/io.github.thisisgm.omapods) — AirPods status in the bar: per-pod and case battery, listening mode, adaptive noise level, and ear detection.
- [`omamail`](omarchy/.config/omarchy/plugins/omamail) — a native email client for Gmail, HEY, and any IMAP mailbox.
- [`quickshell.spotify`](omarchy/.config/omarchy/plugins/quickshell.spotify) — Spotify control in Quickshell using about 60 MB of memory instead of the official client's ~950 MB.

These are scanned and enabled through Omarchy's plugin registry; see the setup script or `omarchy-plugin-enable` to activate them.

### Omarchy theme

The [Leenium Omarchy theme](omarchy/.config/omarchy/themes/leenium.omarchy) is a Git submodule providing the Stencil Pixel-7 styling used by the lock screen and desktop clock. Its source repository is [drunkleen/leenium.omarchy](https://github.com/drunkleen/leenium.omarchy).

### Resume input fix

[`omarchy-fcitx5-resume.service`](omarchy/.config/systemd/user/omarchy-fcitx5-resume.service) runs a small D-Bus monitor that restarts Omarchy's managed fcitx5 service after resume. This avoids stale Wayland input grabs that can leave the lock screen unable to accept a password after suspend.

The service uses systemd's `%h` home-directory specifier, so it works without hard-coding a username.

### Stencil Pixel-7 font

The font is stored in [`omarchy/.local/share/fonts/stencil-pixel-7/`](omarchy/.local/share/fonts/stencil-pixel-7). Its original readme is included in the same directory. The font is free for home use; consult that file before commercial use.

After installation, verify the customization by locking once and then performing one suspend/resume cycle. Confirm that the clock renders correctly, the password field is focused, and keyboard input works immediately.

### Cursor theme

The desktop uses the dark `capitaine-cursors` variant at size 24. The setting is applied through the Omarchy Hyprland environment, GTK 3/4 settings, GNOME interface settings, and the standard XCursor fallback. Install it with:

```bash
sudo pacman -S capitaine-cursors
```

## Shell Configuration

The [`terminal`](terminal) package uses a small `.zshrc` that loads modular configuration from `~/.config/terminal/`:

```text
terminal/.config/terminal/
├── shared/
│   ├── aliases.d/
│   ├── functions.d/
│   ├── aliases.sh
│   ├── functions.sh
│   ├── fzf-preview.sh
│   └── theme.sh
├── bash/
│   ├── ble/
│   └── completions/
└── zsh/
    └── init.zsh
```

The shared layer provides navigation and editor aliases, package/AUR helpers, Docker service helpers, project initializers, network utilities, notifications, fzf helpers, and the `shellhelp` command. Zsh adds history, completion, Starship, zoxide, fzf, autosuggestions, syntax highlighting, and Omarchy's environment bootstrap.

Environment-specific values should be based on [`terminal/.env.example`](terminal/.env.example); do not commit private tokens or credentials.

### Terminal emulators and tools

The `terminal` package also configures the terminal emulators and tools it relies on:

- [`alacritty`](terminal/.config/alacritty) — Alacritty configuration.
- [`foot`](terminal/.config/foot) — Foot terminal configuration.
- [`ghostty`](terminal/.config/ghostty) — Ghostty configuration.
- [`kitty`](terminal/.config/kitty) — Kitty configuration: `JetBrainsMono Nerd Font` at size 12, 14&nbsp;px window padding, and clipboard-friendly shortcuts. It includes Omarchy's theming file by default and overrides Omarchy's defaults from `/etc/xdg/kitty/kitty.conf`.
- [`btop`](terminal/.config/btop) — System monitor theme, including a symlinked `current.theme` that follows the active Omarchy theme.
- [`leenfetch`](terminal/.config/leenfetch) — Leenfetch layout, modules, and flags, previously shipped as a separate `leenfetch` package.
- [`tmux`](terminal/.config/tmux) — tmux keybindings, behavior, and theme, previously shipped as a separate `tmux` package.

## Neovim

The [`nvim/.config/nvim`](nvim/.config/nvim) directory is a Git submodule pointing to [drunkleen/tired.nvim](https://github.com/drunkleen/tired.nvim). Keeping it as a submodule allows the Neovim configuration to retain its own history while still being installed through this dotfiles repository.

Install its Stow package with:

```bash
stow nvim
```

Update the submodule to the latest commit from its tracked branch with:

```bash
git submodule update --remote nvim/.config/nvim
```

Review the resulting submodule commit change before committing it in this repository.

## tmux

The `terminal` package ships [`tmux.conf`](terminal/.config/tmux/tmux.conf) and includes:

- `Ctrl+Space` as the primary prefix, with `Ctrl+B` as a secondary prefix
- vi-style copy mode
- direct pane splitting, navigation, and resizing shortcuts
- numbered window shortcuts with `Alt+1` through `Alt+9`
- mouse support, RGB colors, clipboard integration, and extended keys
- a compact top status bar

Reload it after changes with:

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

## voxtype

The [`voxtype`](voxtype) package configures [Voxtype](https://github.com/ThatOneCalculator/voxtype), a Whisper-based dictation daemon. It writes an `idle`/`recording`/`transcribing` state file for external integrations (Waybar, polybar, etc.), records from the system default input device at 16&nbsp;kHz, pauses MPRIS media while recording, and notifies (optionally) on recording/transcription events. The hotkey itself is bound in Hyprland (`Super + Ctrl + X` by default).

## Maintenance

Restow one package after changing it:

```bash
cd ~/dotfiles
stow hypr
```

Restow all current packages:

```bash
stow fontconfig hypr nvim omarchy terminal voxtype
```

Remove a package's links without deleting the repository files:

```bash
stow --delete voxtype
```

Check what Stow would change:

```bash
stow --no --verbose hypr
```

After changing shell files, start a new shell or reload Zsh:

```bash
source ~/.zshrc
```

After changing the bundled font:

```bash
fc-cache -f ~/.local/share/fonts
```

## Notes

- This repository is personal and opinionated; paths, monitor settings, bindings, and service assumptions may need adjustment on another machine.
- The `hypr` package is supported only on Omarchy.
- Omarchy package files under `/usr/share/omarchy` are dependencies, not vendored files; user customizations remain under `~/.config` and `~/.local`.
- The repository-wide files do not currently declare a separate license. The bundled font retains its own usage terms in its included readme.
