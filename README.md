# My Linux Dotfiles

Personal configuration for my Omarchy desktop and command-line environment, managed with [GNU Stow](https://www.gnu.org/software/stow/).

> [!IMPORTANT]
> The Hyprland configuration here is for **Omarchy only**. It imports Omarchy's Lua bootstrap and default modules from `/usr/share/omarchy`, so it is not a standalone Hyprland config and will not work correctly on a plain Hyprland install.

## Quick start

Clone the repository with its submodules:

```bash
git clone --recurse-submodules --branch omarchy https://github.com/drunkleen/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

Install the required packages (Omarchy already provides `quickshell` and `qt6-svg`):

```bash
sudo pacman -S --needed git stow jq capitaine-cursors qt6-5compat cava inter-font ttf-material-symbols-variable
```

If you cloned without `--recurse-submodules`, initialize the submodules before installing:

```bash
git submodule update --init --recursive
```

From an unlocked graphical Omarchy session, install the desktop customizations:

```bash
cd ~/.dotfiles
./scripts/setup-omarchy-customizations
```

The setup helper installs `hypr`, `omarchy`, `miyamoto.bar`, `miyamoto.lock`, `miyamoto.desktop-aio`, and `leenium.omarchy`. It checks Stow conflicts before linking, preserves an existing real Leenium theme directory as a timestamped backup, refreshes the font cache, enables the fcitx5 resume monitor, sets `capitaine-cursors` at size 24, and applies the Japanese menu button and workspace labels after installing the plugins. The bar helper backs up the live file, reads Omarchy’s installed bar defaults, and replaces only the menu/workspace widget IDs. The shell hot-reloads the result. Setup can be rerun after resolving a conflict or pulling changes.

Install any additional packages you want separately:

```bash
stow --simulate fontconfig terminal nvim voxtype   # preview; omit packages you do not want
stow fontconfig terminal nvim voxtype              # install
fc-cache -f ~/.local/share/fonts
```

The setup helper installs the theme files; to select the theme, run:

```bash
omarchy theme set leenium.omarchy
```

Validate the Hyprland configuration after installation:

```bash
hyprctl reload
hyprctl configerrors
```

### Resolving Stow conflicts

Stow refuses to replace existing files. A conflict aborts the link operation, so resolve it before applying the bar configuration. For each conflicting path, inspect it, move it to a backup, and rerun setup. For example, if your existing Hyprland directory conflicts:

```bash
mv ~/.config/hypr ~/.config/hypr.pre-dotfiles-"$(date +%Y%m%d-%H%M%S)"
./scripts/setup-omarchy-customizations
```

Only move paths reported as conflicts; keep their backups until you have checked the installed configuration. Do not use `stow --adopt` to fix conflicts: it moves existing target files into the repository and can replace the configurations you intended to install.

For the specific `leenium.omarchy` theme conflict, rerun setup directly. It preserves the installed directory at `~/.config/omarchy/themes/leenium.omarchy.backup.<timestamp>.<pid>` before linking the repository theme. If the conflict check fails elsewhere, it restores the original theme directory.

## Packages

Each package mirrors its destination below `$HOME`. The repo's [`.stowrc`](.stowrc) sets the Stow target to `~/` and enables restowing.

| Package | Installed path | Purpose |
| --- | --- | --- |
| [`fontconfig`](fontconfig) | `~/.config/fontconfig/` | Font-family defaults and fallbacks |
| [`hypr`](hypr) | `~/.config/hypr/` | Omarchy-only Hyprland (Lua) configuration |
| [`leenium.omarchy`](leenium.omarchy) | `~/.config/omarchy/themes/leenium.omarchy/` | Leenium Omarchy theme (Git submodule) |
| [`miyamoto.bar`](miyamoto.bar) | `~/.config/omarchy/plugins/miyamoto.{menu,workspaces}/` | 宮本 menu button and Japanese workspace labels |
| [`miyamoto.desktop-aio`](miyamoto.desktop-aio) | `~/.config/omarchy/plugins/miyamoto.desktop-aio/` | Ryoku-style AIO desktop `service` plugin (weather, clock, date, cava spectrum, now-playing) |
| [`miyamoto.lock`](miyamoto.lock) | `~/.config/omarchy/plugins/miyamoto.lock/` | Lock plugin re-skinned with the Ryoku qylock `clockwork/orbital` theme |
| [`miyamoto.sakura-rain`](miyamoto.sakura-rain) | `~/.config/sakura-rain/`, `~/.config/quickshell/sakura-rain/`, `~/.config/systemd/user/sakura-rain.service`, `~/.local/bin/sakura-rain` | Sakura petal overlay (3D depth, window avoidance, TOML config). Install with `scripts/sakura-rain-install` |
| [`nvim`](nvim) | `~/.config/nvim/` | Neovim configuration (Git submodule) |
| [`omarchy`](omarchy) | `~/.config/gtk-*`, `~/.icons/`, `~/.config/systemd/user/`, `~/.local/bin/` | GTK settings, cursor, and the fcitx5 resume service |
| [`terminal`](terminal) | `~/.zshrc`, `~/.gitconfig`, `~/.config/{terminal,alacritty,foot,ghostty,kitty,btop,leenfetch,tmux}/` | Zsh setup, shared shell utilities, terminal emulators, btop, Leenfetch, and tmux |
| [`voxtype`](voxtype) | `~/.config/voxtype/` | Whisper-based dictation daemon and hotkey tooling |

## What's customized

### Hyprland (Omarchy only)

[`hypr/.config/hypr/hyprland.lua`](hypr/.config/hypr/hyprland.lua) loads Omarchy's bootstrap from `$OMARCHY_PATH` or `/usr/share/omarchy`, Omarchy's default Lua configuration, my monitor/input/binding/appearance/autostart overrides, Omarchy's dynamic toggles, and custom screen-recording styling. The package also ships `hyprsunset`, XDG desktop portal, recording, and Lua language-server config. Do not install it on a non-Omarchy Hyprland system without rewriting its imports.

### Bar and lock

The bar uses two small customizations; the lock screen is a separate plugin:

- `miyamoto.menu` — a `宮本` button that opens Omarchy’s built-in menu.
- `miyamoto.workspaces` — Omarchy’s workspace widget with Japanese labels (`一` through `十`), retaining its monitor, scrolling, and layout controls.
- `miyamoto.lock` — Omarchy's lock plugin re-skinned with the Ryoku qylock `clockwork/orbital` lock (clock, tick rings, password/FIDO field), while keeping Omarchy's PAM, fingerprint, idle, and suspend integration.

`miyamoto.bar` contains only two widget customizations. It does not supply a bar implementation or a complete `shell.json`. `scripts/miyamoto-bar apply` removes old bar overrides, reads the complete bar settings from installed Omarchy defaults, and changes only the two widget IDs. All other bar sections, placement, appearance, and widgets match Omarchy. Omarchy requires a complete user configuration rather than merging partial overrides, so rerun the helper after an Omarchy update to pick up new defaults. The built-in menu opens behind the `宮本` button. Idle settings and service plugins are preserved. The live file is backed up before changes and hot-reloads without restarting the shell.

See [the bar package README](miyamoto.bar/README.md) for standalone installation, updates, and removal.

The setup helper installs the lock and desktop widget files but does not enable these optional services. Enable them separately if wanted:

```bash
omarchy plugin enable miyamoto.lock
omarchy plugin enable miyamoto.desktop-aio
omarchy restart shell
```

### Desktop AIO

[`miyamoto.desktop-aio`](miyamoto.desktop-aio) is a custom Omarchy `service` plugin that draws a Ryoku-style AIO card on a click-through bottom layer of the desktop (above the wallpaper, below windows): weather, a big weekday, a clock and date, a live `cava` spectrum, and an optional MPRIS now-playing line. Ink and accent follow the current theme, it never captures input, and fullscreen windows cover it.

It is enabled through `shell.json` and loaded in-process by `omarchy-shell` (no separate service). See [`miyamoto.desktop-aio/README.md`](miyamoto.desktop-aio/README.md) for its configuration and management, and [`NOTICE`](miyamoto.desktop-aio/.config/omarchy/plugins/miyamoto.desktop-aio/NOTICE) for its GPL-3.0 license.

### Theme

The [Leenium Omarchy theme](https://github.com/drunkleen/leenium.omarchy) is a Git submodule in its own [`leenium.omarchy`](leenium.omarchy) package, installed at `~/.config/omarchy/themes/leenium.omarchy`.

### Cursor

The desktop uses the dark `capitaine-cursors` variant at size 24, applied through the Omarchy Hyprland environment, GTK 3/4, GNOME interface settings, and the XCursor fallback.

### Resume input fix

[`omarchy-fcitx5-resume.service`](omarchy/.config/systemd/user/omarchy-fcitx5-resume.service) runs a small D-Bus monitor that restarts Omarchy's managed fcitx5 service after resume, avoiding stale Wayland input grabs that can leave the lock screen unable to accept a password after suspend. It uses systemd's `%h` specifier, so no username is hard-coded.

### Sakura Rain

A petal overlay on the wallpaper layer. Install and uninstall with
`scripts/sakura-rain-install` and `scripts/sakura-rain-uninstall`. Commands,
settings, presets and troubleshooting are in
[`miyamoto.sakura-rain/README.md`](miyamoto.sakura-rain/README.md).

## Shell environment

The [`terminal`](terminal) package uses a small `.zshrc` that loads modular configuration from `~/.config/terminal/`:

```text
terminal/.config/terminal/
├── shared/
│   ├── aliases.d/        # navigation, editor, containers
│   ├── functions.d/      # common, packages, containers, projects, notify, network, fzf, help
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

The shared layer provides navigation and editor aliases, package/AUR helpers, Docker helpers, project initializers, network utilities, notifications, fzf helpers, and the `shellhelp` command. Zsh adds history, completion, Starship, zoxide, fzf, autosuggestions, syntax highlighting, and Omarchy's environment bootstrap. Machine-specific values go in a local env file based on [`terminal/.env.example`](terminal/.env.example) — never commit tokens or credentials.

### Terminal emulators and tools

- [`alacritty`](terminal/.config/alacritty) — Alacritty configuration.
- [`foot`](terminal/.config/foot) — Foot terminal configuration.
- [`ghostty`](terminal/.config/ghostty) — Ghostty configuration.
- [`kitty`](terminal/.config/kitty) — `JetBrainsMono Nerd Font` at size 12, 14&nbsp;px padding, clipboard-friendly shortcuts; includes Omarchy's theming and overrides its defaults.
- [`btop`](terminal/.config/btop) — theme with a symlinked `current.theme` that follows the active Omarchy theme.
- [`leenfetch`](terminal/.config/leenfetch) — Leenfetch layout, modules, and flags.
- [`tmux`](terminal/.config/tmux) — `Ctrl+Space` prefix (plus `Ctrl+B`), vi copy mode, direct pane shortcuts, `Alt+1`…`Alt+9` windows, mouse, RGB, and clipboard. Reload with `tmux source-file ~/.config/tmux/tmux.conf`.

## Neovim

[`nvim/.config/tired.nvim`](nvim/.config/tired.nvim) is a Git submodule pointing to [drunkleen/tired.nvim](https://github.com/drunkleen/tired.nvim). The package also provides a `nvim → tired.nvim` link so Neovim loads this checkout from its standard `~/.config/nvim` location. Keeping it as a submodule lets the config retain its own history while still installing through this repo. Update it to the latest tracked commit with:

```bash
git submodule update --remote nvim/.config/tired.nvim
```

Review the resulting submodule commit change before committing it here.

## voxtype

The [`voxtype`](voxtype) package configures [Voxtype](https://github.com/ThatOneCalculator/voxtype), a Whisper-based dictation daemon. It writes an `idle`/`recording`/`transcribing` state file for external integrations, records from the default input at 16&nbsp;kHz, pauses MPRIS media while recording, and (optionally) notifies on events. The hotkey is bound in Hyprland (`Super + Ctrl + X` by default).

## Maintenance

### Updating everything

[`scripts/update-omarchy-customizations`](scripts/update-omarchy-customizations) pulls the repo and submodules, restows packages, applies the Japanese labels to the stock bar, and updates the theme:

```bash
cd ~/.dotfiles
./scripts/update-omarchy-customizations            # everything (dotfiles + plugins + theme)
./scripts/update-omarchy-customizations dotfiles   # pull + restow packages only
./scripts/update-omarchy-customizations plugins    # update plugins + apply Japanese labels
./scripts/update-omarchy-customizations theme      # update + refresh + re-apply the theme
```

New packages are detected and stowed automatically, and any new stow-managed user service is enabled. The update helper uses the same Stow conflict checks and theme backup handling as setup; a Stow conflict stops the update before shell settings are applied. Review detected packages before running it, since it includes optional packages too. The bar helper enables only its two widgets; the script reports other installed plugins that are not enabled. Enable optional services explicitly, or use `--enable-new` to enable all reported plugins.

Useful flags: `--no-pull` (skip network/submodule updates), `--dry-run` (print actions only), `--enable-new` (auto-enable reported plugins).

### Manual maintenance

```bash
cd ~/.dotfiles
stow hypr                          # restow one package after changing it
./scripts/setup-omarchy-customizations  # reinstall the desktop customizations
stow --delete voxtype              # unlink a package without deleting repo files
stow --no --verbose hypr           # preview what Stow would change
source ~/.zshrc                    # reload Zsh after changing shell files
```

For a custom set of packages that includes the theme, use the shared installer to get the theme backup and conflict checks:

```bash
./scripts/stow-omarchy-packages miyamoto.bar miyamoto.lock miyamoto.desktop-aio leenium.omarchy
```

This helper only installs links. Use the full setup helper for cursor settings, service enablement, and shell configuration deployment.

### Applying the Japanese bar labels

```bash
cd ~/.dotfiles
./scripts/miyamoto-bar diff       # preview stock bar restoration and Japanese labels
./scripts/miyamoto-bar apply      # apply after the plugins are installed
```

The bar helper manages only the menu button and workspace labels. Full-shell `capture` is no longer supported. Applying it restores the rest of the bar to Omarchy defaults by removing previous bar overrides. Lock and desktop widget enablement are independent of the bar helper.

### Recovering after a failed setup

If the menu button or workspace labels disappear, rerun setup to install their plugins and apply the stock bar with Japanese labels:

```bash
cd ~/.dotfiles
./scripts/setup-omarchy-customizations
omarchy plugin list
hyprctl configerrors
systemctl --user status omarchy-fcitx5-resume.service
```

For a missing lock or desktop widget, check `omarchy plugin list` and explicitly enable the desired service with the commands above. The bar helper preserves existing service settings.

If you need the shell settings from before an apply, inspect the backups and restore the chosen file (replace the placeholder with an actual filename):

```bash
ls -lt ~/.config/omarchy/shell.json.backup.*
cp "$HOME/.config/omarchy/shell.json.backup.<timestamp>.<pid>" ~/.config/omarchy/shell.json
omarchy restart shell
```

Unlinking a plugin package does not remove its entries from the live `shell.json`. Switch to the built-in menu, workspace widget, or lock plugin and disable the desktop widget through Omarchy before unlinking their custom packages.

## Notes

- This repository is personal and opinionated; paths, monitor settings, bindings, and service assumptions may need adjustment on another machine.
- The `hypr` package is supported only on Omarchy.
- Omarchy files under `/usr/share/omarchy` are dependencies, not vendored files; my customizations stay under `~/.config` and `~/.local`.
- The repository does not currently declare a separate license.
