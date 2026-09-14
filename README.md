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
| [`leenfetch`](leenfetch) | `~/.config/leenfetch/` | Custom Leenfetch layout and modules |
| [`nvim`](nvim) | `~/.config/nvim/` | Neovim configuration from the `tired.nvim` Git submodule |
| [`omarchy`](omarchy) | `~/.config/omarchy/`, `~/.config/systemd/user/`, `~/.config/gtk-*`, `~/.icons/`, `~/.local/` | Lock screen, desktop clock, cursor, font, and resume input fix |
| [`shell`](terminal) | `~/.zshrc`, `~/.gitconfig`, `~/.config/terminal/` | Zsh setup and shared shell utilities |
| [`tmux`](tmux) | `~/.config/tmux/` | tmux keybindings, behavior, and theme |

Each package mirrors its destination below `$HOME`. The repository's [`.stowrc`](.stowrc) sets the Stow target to `~/` and enables restowing.

The two Omarchy plugins are maintained as separate Git submodules:

- [`drunkleen/omarchy.paperwidget`](https://github.com/drunkleen/omarchy.paperwidget) → `omarchy/.config/omarchy/plugins/omarchy.paperwidget`
- [`drunkleen/omarchy.pixlock`](https://github.com/drunkleen/omarchy.pixlock) → `omarchy/.config/omarchy/plugins/omarchy.pixlock`

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
stow --no --verbose fontconfig hypr leenfetch nvim omarchy shell tmux
```

Install all current packages:

```bash
stow fontconfig hypr leenfetch nvim omarchy shell tmux
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

The [`shell`](shell) package uses a small `.zshrc` that loads modular configuration from `~/.config/terminal/`:

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

The [`tmux`](tmux) package includes:

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

## Maintenance

Restow one package after changing it:

```bash
cd ~/dotfiles
stow hypr
```

Restow all current packages:

```bash
stow fontconfig hypr leenfetch nvim omarchy shell tmux
```

Remove a package's links without deleting the repository files:

```bash
stow --delete tmux
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
