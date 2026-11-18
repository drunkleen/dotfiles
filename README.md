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
sudo pacman -S --needed git stow python firefox zsh ghostty jq capitaine-cursors qt6-5compat cava inter-font ttf-material-symbols-variable
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

The setup helper detects every top-level Stow package and backs up conflicting destination files or links as `<name>-backup-YYYYMMDD-HHMMSS` before linking the repository versions. It leaves already-correct links and unrelated files intact, and never overwrites an existing backup. It then installs and applies Leenium through Omarchy, applies the bar, clones and installs Leenium Limine in a private temporary directory, installs the bundled `miyamoto.plymouth` theme, and enables `miyamoto.lock`. Desktop AIO installation and the existing font, cursor, resume-service, Ghostty, and Zsh setup follow.

Preview the full plan without changing files or running installers:

```bash
./scripts/setup-omarchy-customizations --dry-run
```

Run the actual setup **as your normal desktop user** in an unlocked graphical session. It requests sudo for the boot themes. Required tools include Python 3, GNU Stow, Git, jq, Omarchy, Limine (`limine` and `limine-update`), and Plymouth. The existing Limine/Plymouth configuration and any installed `miyamoto` Plymouth theme are backed up before installation. The Limine installer regenerates boot entries; Plymouth rebuilds initramfs. The script stops on errors, removes its temporary clone, and does not reboot or open the lock screen. Review backups before deleting them.

The Stow backup helper restores moved originals if its preflight fails. If a partially completed operation creates a destination that cannot safely be replaced, it prints the remaining backup path for manual recovery. Foreign symlinks at shared roots such as `~/.config` must be resolved explicitly. Setup also selects Ghostty as the default terminal and Zsh as the login shell; log out and back in after changing the login shell.

Install any additional packages you want separately:

```bash
stow --simulate fontconfig terminal nvim voxtype   # preview; omit packages you do not want
stow fontconfig terminal nvim voxtype              # install
fc-cache -f ~/.local/share/fonts
```

The setup helper installs and applies Leenium from its separate repository through Omarchy. To install or update just the theme, run:

```bash
./scripts/install-leenium-theme
```

Validate the Hyprland configuration after installation:

```bash
hyprctl reload
hyprctl configerrors
```

### Resolving Stow conflicts

The unified setup automatically backs up conflicts. Direct Stow commands and the update helper remain strict: a conflict aborts linking. To resolve one manually, inspect the conflicting path and move it to a backup. For example, if your existing Hyprland directory conflicts:

```bash
mv ~/.config/hypr ~/.config/hypr.pre-dotfiles-"$(date +%Y%m%d-%H%M%S)"
./scripts/setup-omarchy-customizations
```

Only move paths reported as conflicts; keep their backups until you have checked the installed configuration. Do not use `stow --adopt` to fix conflicts: it moves existing target files into the repository and can replace the configurations you intended to install.


### Default browser, terminal, and shell

| Preference | Default | How setup applies it |
| --- | --- | --- |
| Browser | Firefox | Stow links [`omarchy/.config/mimeapps.list`](omarchy/.config/mimeapps.list) |
| Terminal | Ghostty | Stow links [`omarchy/.config/xdg-terminals.list`](omarchy/.config/xdg-terminals.list), then [`scripts/setup-default-terminal`](scripts/setup-default-terminal) selects Ghostty through Omarchy |
| Login shell | Zsh | [`scripts/setup-default-shell`](scripts/setup-default-shell) updates the account's login shell |

Run setup as your normal desktop user. Both preference helpers require their application to be installed and skip the change when it is already applied. The shell helper also checks `/etc/shells` and requests authentication when needed. Log out and back in after changing the login shell; existing shells continue running until closed.

To apply individual preferences on an existing installation:

```bash
cd ~/.dotfiles
omarchy default browser firefox
./scripts/setup-default-terminal
./scripts/setup-default-shell
```

Verify the saved settings:

```bash
omarchy default browser                       # firefox
omarchy default terminal                      # ghostty
getent passwd "$(id -un)" | cut -d: -f7        # /usr/bin/zsh
```

Keep both preference files in the repository when committing or restoring dotfiles. The installed symlinks depend on them; missing targets can prevent the menu from saving preferences or cause fallback applications to open. Browser and terminal preference changes made through Omarchy save into these repository files. Review them before committing:

```bash
git diff -- omarchy/.config/mimeapps.list omarchy/.config/xdg-terminals.list
```

If an existing installation has regular files at `~/.config/mimeapps.list` or `~/.config/xdg-terminals.list`, review and merge any settings you want to keep into the corresponding repository files, back up the live files, and run `stow omarchy` to install the links. If a link is broken, restore its missing repository target from Git before rerunning setup.

## Packages

Each package mirrors its destination below `$HOME`. The repo's [`.stowrc`](.stowrc) sets the Stow target to `~/` and enables restowing.

| Package | Installed path | Purpose |
| --- | --- | --- |
| [`fontconfig`](fontconfig) | `~/.config/fontconfig/` | Font-family defaults and fallbacks |
| [`hypr`](hypr) | `~/.config/hypr/` | Omarchy-only Hyprland (Lua) configuration |
| [`miyamoto.bar`](miyamoto.bar) | `~/.config/omarchy/plugins/miyamoto.{menu,workspaces}/` | 宮本 menu button and Japanese workspace labels |
| [`miyamoto.lock`](miyamoto.lock) | `~/.config/omarchy/plugins/miyamoto.lock/` | Lock plugin re-skinned with the Ryoku qylock `clockwork/orbital` theme |
| [`nvim`](nvim) | `~/.config/nvim/` | Neovim configuration (Git submodule) |
| [`omarchy`](omarchy) | `~/.config/{gtk-*,mimeapps.list,xdg-terminals.list,systemd/user/}`, `~/.icons/`, `~/.local/bin/` | GTK settings, cursor, Firefox/Ghostty preferences, and the fcitx5 resume service |
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

The unified setup enables the lock plugin. Desktop AIO migration preserves its previous enabled state; fresh installations can enable the desktop widget separately:

```bash
omarchy plugin enable miyamoto.lock
omarchy plugin enable drunkleen.desktop-aio
omarchy restart shell
```

### Desktop AIO

[Drunkleen Desktop AIO](https://github.com/drunkleen/drunkleen.omarchy-desktop-aio)
is maintained in its own repository and installed as a Git-managed Omarchy plugin:

```bash
./scripts/install-desktop-aio
omarchy plugin enable drunkleen.desktop-aio
omarchy restart shell
```

Setup installs it automatically; plugin updates run through `omarchy plugin update`.
The installer preserves the old plugin's enabled state, migrates personal settings
and saved placement, and backs up the old deployment outside this repository.
Personal configuration lives at `~/.config/drunkleen.desktop-aio/config.toml`;
placement lives at `~/.local/state/drunkleen.desktop-aio/placement.json`.
Neither is part of the plugin Git checkout. See the standalone repository for
configuration, dependencies, licensing, and removal instructions.

### Theme

The theme is maintained outside this dotfiles repository. Run
[`scripts/install-leenium-theme`](scripts/install-leenium-theme) to execute:

```bash
omarchy theme install https://github.com/drunkleen/leenium.omarchy
```

Omarchy installs the theme in `~/.config/omarchy/themes/leenium.omarchy` and applies it. There is no theme submodule or Stow package in this repository.

### Cursor

The desktop uses the dark `capitaine-cursors` variant at size 24, applied through the Omarchy Hyprland environment, GTK 3/4, GNOME interface settings, and the XCursor fallback.

### Resume input fix

[`omarchy-fcitx5-resume.service`](omarchy/.config/systemd/user/omarchy-fcitx5-resume.service) runs a small D-Bus monitor that restarts Omarchy's managed fcitx5 service after resume, avoiding stale Wayland input grabs that can leave the lock screen unable to accept a password after suspend. It uses systemd's `%h` specifier, so no username is hard-coded.

### Ambient effects

Sakura petals, leaves, rain, and snow are provided by
[Desktop AIO](https://github.com/drunkleen/drunkleen.omarchy-desktop-aio).
Install it with [`scripts/install-desktop-aio`](scripts/install-desktop-aio),
then right-click the widget to configure Ambient Effects.

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

The desktop setup helper selects Ghostty as the default terminal and Zsh as the login shell; see [default browser, terminal, and shell](#default-browser-terminal-and-shell) for standalone commands and verification. Install the optional `terminal` Stow package above to use this repository's Zsh and terminal configuration. Changing the login shell leaves scripts with explicit Bash shebangs running under Bash.

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

New packages are detected and stowed automatically, and any new stow-managed user service is enabled. The update helper uses strict Stow conflict checks; a conflict stops the update before shell settings are applied. Use the unified setup helper when you want automatic conflict backups and boot-theme installation. Review detected packages before running it, since it includes optional packages too. The bar helper enables only its two widgets; the script reports other installed plugins that are not enabled. Enable optional services explicitly, or use `--enable-new` to enable all reported plugins.

The update helper does not run the default-terminal or login-shell helpers. Run the full setup helper or the individual preference helpers above to reapply Ghostty and Zsh. Restowing `omarchy` installs the browser and terminal preference files.

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
./scripts/stow-omarchy-packages miyamoto.bar miyamoto.lock
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

Unlinking a plugin package does not remove its entries from the live `shell.json`. Switch to the built-in menu, workspace widget, or lock plugin before unlinking their custom packages. Remove Desktop AIO with `omarchy plugin remove drunkleen.desktop-aio`.

## Notes

- This repository is personal and opinionated; paths, monitor settings, bindings, and service assumptions may need adjustment on another machine.
- The `hypr` package is supported only on Omarchy.
- Omarchy files under `/usr/share/omarchy` are dependencies, not vendored files; my customizations stay under `~/.config` and `~/.local`.
- The repository does not currently declare a separate license.

### Setup validation

```bash
python3 -m unittest discover -s tests -p 'test_*.py' -v
bash -n scripts/setup-omarchy-customizations
shellcheck scripts/setup-omarchy-customizations
```
