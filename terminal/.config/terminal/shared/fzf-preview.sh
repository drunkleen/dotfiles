#!/usr/bin/env bash
# fzf preview helper: eza for dirs, bat for files. Used by both bash and zsh.
target="$1"
if [[ -d "$target" ]]; then
  eza -la --icons --group-directories-first "$target"
elif [[ -f "$target" ]]; then
  bat --color=always --style=numbers --line-range=:200 "$target"
else
  file --mime-type -b "$target"
fi