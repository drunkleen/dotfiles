# Japanese labels for the Omarchy bar

This package customizes two widgets in Omarchy’s own bar:

- `miyamoto.menu`: a **宮本** (Miyamoto) button opening the built-in Omarchy menu. Right-click opens a terminal.
- `miyamoto.workspaces`: Japanese workspace labels **一 二 三 四 五 六 七 八 九 十**, using Omarchy’s workspace behavior, including monitor blocks, wheel navigation, and clicking the current workspace to cycle layouts.

The package does not implement a bar or duplicate the menu. The workspace widget is a user-owned copy of Omarchy’s widget with its displayed labels changed.

## Install

Run from an unlocked graphical Omarchy session. Requirements are Omarchy, GNU Stow, `jq`, and the `Noto Sans CJK JP` font for the labels.

```bash
cd ~/.dotfiles
stow --simulate miyamoto.bar
stow miyamoto.bar
./scripts/miyamoto-bar diff
./scripts/miyamoto-bar apply
```

For the full desktop setup, follow the [repository README](../README.md). Installing this package alone does not enable the separate lock or desktop widget plugins.

## What apply changes

The helper reads the installed defaults at `${OMARCHY_PATH:-/usr/share/omarchy}/config/omarchy/shell.json`, copies their `bar` settings, and replaces only `omarchy.menu` and `omarchy.workspaces` with these two widgets. Other bar widgets, positions, clock formatting, and appearance match the installed Omarchy version. Previous custom bar overrides are removed.

Omarchy treats a user `shell.json` as a complete configuration, so the helper must write the bar settings into the live file; partial overrides do not inherit the remaining sections. There is no saved bar layout template in this repository.

Other top-level settings, including idle timeouts, dock settings, and enabled service plugins, are retained. The helper also removes old disable flags that would prevent the menu or Japanese widgets from working. It requires both widgets to be installed before applying anything.

Before changing an existing file, it creates `shell.json.backup.<timestamp>.<pid>` beside it. Changes hot-reload without restarting the shell. Running apply again with no changes is a no-op. Full-shell `capture` is no longer supported.

## After an Omarchy update

```bash
cd ~/.dotfiles
./scripts/miyamoto-bar diff
./scripts/miyamoto-bar apply
```

This picks up the installed bar defaults again. The workspace widget is a local copy, so upstream behavior changes may also require updating that copy; applying defaults alone does not update its QML code.

## Remove

First use Omarchy’s bar settings to replace `miyamoto.menu` and `miyamoto.workspaces` with the built-in menu and workspaces widgets. Then unlink the package:

```bash
cd ~/.dotfiles
stow --delete miyamoto.bar
```

Stow does not undo entries in the live shell configuration. Stop running `scripts/miyamoto-bar apply` if you want to keep the stock labels. For backup restoration, see the recovery steps in the repository README.
