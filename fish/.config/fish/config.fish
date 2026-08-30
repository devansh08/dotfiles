# Keybinds
bind alt-backspace backward-kill-word
bind ctrl-left backward-word
bind ctrl-right forward-word
bind alt-left backward-token
bind alt-right forward-token

# Theme
while read -l key value
    set --global $key $value
end <~/.config/fish/themes/theme.theme 2>/dev/null

# Pure prompt
set -gx pure_check_for_new_release false
set -gx pure_enable_container_detection false
set -gx pure_begin_prompt_with_current_directory false
set -gx pure_enable_git true
set -gx pure_symbol_prompt "❯"
set -gx pure_symbol_git_staged "+"
set -gx pure_symbol_git_unstaged "!"
set -gx pure_symbol_trasker "✔"
set -gx pure_symbol_git_untracked "?"
set -gx pure_color_git_dirty $pure_color_primary
set -gx pure_symbol_git_stash "*"
set -gx pure_symbol_git_unpulled_commits "⇣"
set -gx pure_symbol_git_unpushed_commits "⇡"
set -gx pure_show_numbered_git_indicator true
set -gx pure_show_jobs true
set -gx pure_enable_virtualenv true
set -gx pure_enable_k8s false
set -gx pure_enable_nixdevshell false
set -gx pure_symbol_virtualenv_prefix ""
set -gx pure_enable_aws_profile false
set -gx pure_separate_prompt_on_error true
set -gx pure_show_exit_status true
set -gx pure_convert_exit_status_to_signal true
set -gx pure_symbol_exit_status_prefix "| "
set -gx pure_show_system_time false
set -gx pure_show_subsecond_command_duration true
set -gx pure_threshold_command_duration 3
set -gx pure_show_prefix_root_prompt true
set -gx pure_symbol_prefix_root_prompt "#"
set -gx pure_show_prefix_private_prompt true
set -gx pure_symbol_prefix_private_prompt "%"

# Greeting
set fish_greeting

# Env
set -gx EDITOR nvim
set -gx BROWSER librewolf

# Wayland env
set -gx QT_QPA_PLATFORM wayland
set -gx XCURSOR_THEME Bibata-Modern-Classic
set -gx WAYLAND_DISPLAY (basename (find /run/user/(id -u) -type s -name 'wayland-*' 2> /dev/null) 2> /dev/null)

# Path env
set -gx HOME /home/devansh
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx GOPATH $HOME/Temp/go

set -gx JAVA_HOME /usr/lib/jvm/default

set -gx ANDROID_HOME /opt/android-sdk
set -gx FLUTTER_HOME /opt/flutter

set -gx PATH $PATH $HOME/.local/bin $HOME/.bin $HOME/.local/share/node/bin $JAVA_HOME/bin $FLUTTER_HOME $ANDROID_HOME/cmdline-tools/latest/bin $ANDROID_HOME/platform-tools $ANDROID_HOME/build-tools $GOPATH/bin

# NVM
set -gx nvm_default_version lts
nvm use lts >/dev/null 2>&1

# BG listeners
_cd_listener
