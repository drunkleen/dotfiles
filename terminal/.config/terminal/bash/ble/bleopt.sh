# ble.sh (Bash Line Editor) tuning
# Loaded by ~/.bashrc only when ble.sh is available.
# Only options valid for this ble.sh version (0.3.4) are set here.

# ---- Inline autosuggestions ----
# Suggest from history + file completion as you type (ble.sh autocomplete).
bleopt complete_auto_complete=1
bleopt complete_auto_delay=50
bleopt complete_auto_history=1

# ---- History ----
# Don't load the whole history lazily; keep point stable.
bleopt history_lazyload=0
bleopt history_preserve_point=1

# ---- Prompt ----
# Keep the starship prompt; just mark the end of the previous output.
bleopt prompt_eol_mark=''

# ---- Misc ----
bleopt allow_exit_with_jobs=1
bleopt edit_abell=1
