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
| [`omarchy`](omarchy) | `~/.config/omarchy/`, `~/.config/systemd/user/`, `~/.config/gtk-*`, `~/.icons/`, `~/.local/` | GTK settings, cursor, Stencil Pixel-7 font, Leenium theme, and resume input fix |
| [`omarchy-bar`](omarchy-bar) | `~/.config/omarchy/plugins/miyamoto.{menu,workspaces}`, `~/.config/omarchy/shell.json` | Cloned top-bar menu and workspace pagination plus the bar/shell config |
| [`omarchy-lock`](omarchy-lock) | `~/.config/omarchy/plugins/miyamoto.lock` | Cloned lock plugin re-skinned with the Ryoku qylock `clockwork/orbital` theme |
| [`omarchy-desktop-widget`](omarchy-desktop-widget) | `~/.config/omarchy-desktop-widget/`, `~/.config/systemd/user/omarchy-desktop-widget.service` | Standalone Ryoku-style AIO desktop widget (weather, clock, date, cava spectrum, now-playing) |
| [`terminal`](terminal) | `~/.zshrc`, `~/.gitconfig`, `~/.config/terminal/`, `~/.config/{alacritty,btop,foot,ghostty,kitty,leenfetch,tmux}/` | Zsh setup, shared shell utilities, terminal emulators, btop, Leenfetch, and tmux |
| [`voxtype`](voxtype) | `~/.config/voxtype/` | Whisper-based dictation daemon and hotkey tooling |

Each package mirrors its destination below `$HOME`. The repository's [`.stowrc`](.stowrc) sets the Stow target to `~/` and enables restowing.

The Omarchy shell customizations are user-owned clones of built-in plugins:

- [`omarchy-bar`](omarchy-bar) holds `miyamoto.menu` (top-bar menu) and `miyamoto.workspaces` (workspace pagination), and owns `~/.config/omarchy/shell.json`.
- [`omarchy-lock`](omarchy-lock) holds `miyamoto.lock`, a clone of Omarchy's lock plugin re-skinned with the Ryoku qylock `clockwork/orbital` lock.

The [`omarchy-desktop-widget`](omarchy-desktop-widget) package is different: a standalone Quickshell config (its own systemd user service), not a clone. See [Desktop widget](#desktop-widget).

The [Leenium Omarchy theme](https://github.com/drunkleen/leenium.omarchy) is bundled as a submodule under `omarchy/.config/omarchy/themes/leenium.omarchy`.

## Requirements

The base installation requires:

- [Omarchy](https://omarchy.org/)
- Git
- GNU Stow
- `capitaine-cursors`

The configuration also expects several tools used by the shell setup, including Zsh, Starship, zoxide, fzf, fd, eza, bat, ripgrep, tmux, and Leenfetch. Some helper functions additionally use Docker, `yay`, `jq`, and desktop utilities such as `xdg-open`.

The desktop widget additionally requires `cava` (audio spectrum), `inter-font`, and `ttf-material-symbols-variable` (fonts).

## Installation

Clone the Omarchy branch into `~/dotfiles`:

```bash
git clone --recurse-submodules --branch omarchy https://github.com/drunkleen/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Preview all current packages before linking them:

```bash
stow --no --verbose fontconfig hypr nvim omarchy omarchy-bar omarchy-lock omarchy-desktop-widget terminal voxtype
```

Install all current packages:

```bash
stow fontconfig hypr nvim omarchy omarchy-bar omarchy-lock omarchy-desktop-widget terminal voxtype
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

### Fresh-machine walkthrough

Setting up from scratch on a new Omarchy install? Do the following in order.

1. Install the base tools (Omarchy already provides `quickshell`, `qt6-svg`, etc.):

   ```bash
   sudo pacman -S --needed git stow capitaine-cursors qt6-5compat cava inter-font ttf-material-symbols-variable
   ```

   Optional tools used by the shell/terminal config: `zsh`, `starship`, `zoxide`, `fzf`, `fd`, `eza`, `bat`, `ripgrep`, `tmux`, `jq`. The `voxtype` package needs the AUR `voxtype-bin`.

2. Clone the repository with its submodules:

   ```bash
   git clone --recurse-submodules --branch omarchy https://github.com/drunkleen/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

3. Back up anything Stow would collide with (it never overwrites):

   ```bash
   mv ~/.config/hypr ~/.config/hypr.pre-dotfiles 2>/dev/null || true
   mv ~/.config/omarchy/themes/leenium.omarchy ~/.config/omarchy/themes/leenium.omarchy.pre-dotfiles 2>/dev/null || true
   mv ~/.config/gtk-3.0/settings.ini ~/.config/gtk-3.0/settings.ini.pre-dotfiles 2>/dev/null || true
   mv ~/.config/gtk-4.0/settings.ini ~/.config/gtk-4.0/settings.ini.pre-dotfiles 2>/dev/null || true
   ```

   `~/.config/omarchy/shell.json` is not stowed (the `omarchy-bar` package manages it by copy), so it needs no backup.

4. Stow every package:

   ```bash
   cd ~/.dotfiles
   stow --no --verbose fontconfig hypr nvim omarchy omarchy-bar omarchy-lock omarchy-desktop-widget terminal voxtype
   stow fontconfig hypr nvim omarchy omarchy-bar omarchy-lock omarchy-desktop-widget terminal voxtype
   ```

5. Run the Omarchy setup helper from the unlocked graphical session:

   ```bash
   ./scripts/setup-omarchy-customizations
   ```

6. Verify: the top bar shows the `宮本` menu glyph and Chinese workspace numerals, `Super + Alt + Space` lists apps, `Super + Ctrl + L` shows the orbital lock and unlocks with your password, and the AIO desktop widget appears on the wallpaper (weather, clock, date, spectrum).

The lock theme requires `qt6-5compat`. If the `nvim` submodule fails to check out, its referenced commit has not been pushed to `drunkleen/tired.nvim` yet.

## Omarchy Setup

The repository includes a helper for the complete Omarchy customization:

```bash
cd ~/dotfiles
./scripts/setup-omarchy-customizations
```

Run it from an unlocked graphical Omarchy session. It:

1. Stows the `hypr`, `omarchy`, `omarchy-bar`, `omarchy-lock`, and `omarchy-desktop-widget` packages.
2. Warns if the desktop widget's runtime packages (`cava`, `inter-font`, `ttf-material-symbols-variable`) are missing.
3. Refreshes the user font cache.
4. Reloads the user systemd manager.
5. Enables and starts the fcitx5 resume monitor and the desktop widget service.
6. Applies the bar/shell config (`scripts/omarchy-bar apply`), which restarts the shell.
7. Sets `capitaine-cursors` as the Hyprland, GTK, and XCursor default at size 24.

If the Omarchy or Hyprland target files already exist, back them up before running the helper:

```bash
mv ~/.config/hypr ~/.config/hypr.pre-dotfiles
mv ~/.config/omarchy/plugins/miyamoto.menu ~/.config/omarchy/plugins/miyamoto.menu.pre-dotfiles 2>/dev/null || true
mv ~/.config/omarchy/plugins/miyamoto.workspaces ~/.config/omarchy/plugins/miyamoto.workspaces.pre-dotfiles 2>/dev/null || true
mv ~/.config/omarchy/plugins/miyamoto.lock ~/.config/omarchy/plugins/miyamoto.lock.pre-dotfiles 2>/dev/null || true
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

### Bar and lock customizations

The shell customizations are user-owned clones of Omarchy's built-in plugins, kept in the [`omarchy-bar`](omarchy-bar) and [`omarchy-lock`](omarchy-lock) packages:

- `miyamoto.menu` — the top-bar menu, with a custom `宮本` glyph and a fallback app library.
- `miyamoto.workspaces` — workspace pagination using Chinese numerals and a focused-accent color.
- `miyamoto.lock` — Omarchy's lock plugin re-skinned with the Ryoku qylock `clockwork/orbital` lock (clock, tick rings, password/FIDO field), while keeping Omarchy's PAM, fingerprint, idle, and suspend integration.

`~/.config/omarchy/shell.json` is owned by the `omarchy-bar` package and deployed with `scripts/omarchy-bar`.

### Desktop widget

[`omarchy-desktop-widget`](omarchy-desktop-widget) is a standalone Quickshell config that draws a Ryoku-style AIO card on a click-through bottom layer of the desktop (above the wallpaper, below windows):

- weather (Open-Meteo; configurable city, units, refresh)
- big weekday, clock (12/24-hour) and letter-spaced date
- live audio spectrum via `cava` over the PipeWire playback monitor
- optional now-playing line from MPRIS

Ink and accent follow the current Omarchy theme by default. It never captures input (empty layer input region), leaves Omarchy's shell/bar/Hyprland config untouched, and is covered by fullscreen windows.

Configuration lives in [`omarchy-desktop-widget/.config/omarchy-desktop-widget/config.toml`](omarchy-desktop-widget/.config/omarchy-desktop-widget/config.toml) — monitor selection, anchor/margins, scale, opacity, component toggles, clock format, fonts, ink/accent overrides, weather, spectrum, and media — and hot-reloads on save.

Manage it with:

```bash
systemctl --user status  omarchy-desktop-widget
systemctl --user restart omarchy-desktop-widget
systemctl --user stop    omarchy-desktop-widget
```

It is under the GPL-3.0 because it adapts Ryoku's widget; see [`NOTICE`](omarchy-desktop-widget/.config/omarchy-desktop-widget/NOTICE).

### Omarchy theme

The [Leenium Omarchy theme](omarchy/.config/omarchy/themes/leenium.omarchy) is a Git submodule. Its source repository is [drunkleen/leenium.omarchy](https://github.com/drunkleen/leenium.omarchy).

### Resume input fix

[`omarchy-fcitx5-resume.service`](omarchy/.config/systemd/user/omarchy-fcitx5-resume.service) runs a small D-Bus monitor that restarts Omarchy's managed fcitx5 service after resume. This avoids stale Wayland input grabs that can leave the lock screen unable to accept a password after suspend.

The service uses systemd's `%h` home-directory specifier, so it works without hard-coding a username.

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
stow fontconfig hypr nvim omarchy omarchy-bar omarchy-lock omarchy-desktop-widget terminal voxtype
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
