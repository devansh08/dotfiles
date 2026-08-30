if status --is-interactive
    bind alt-backspace backward-kill-word
    bind ctrl-left backward-word
    bind ctrl-right forward-word
    bind alt-left backward-token
    bind alt-right forward-token

    fish_config theme choose theme

    set fish_greeting
set -gx pure_symbol_git_staged "+"
set -gx pure_symbol_git_unstaged "!"
set -gx pure_symbol_git_untracked "?"
set -gx pure_color_git_dirty $pure_color_primary
set -gx pure_symbol_git_stash "*"

    set -gx EDITOR nvim
    set -gx BROWSER librewolf

    set -gx HOME /home/devansh
    set -gx XDG_CONFIG_HOME $HOME/.config
    set -gx GOPATH $HOME/Temp/go

    set -gx JAVA_HOME /usr/lib/jvm/default

    set -gx ANDROID_HOME /opt/android-sdk
    set -gx FLUTTER_HOME /opt/flutter

    set -gx PATH $PATH $HOME/.local/bin $HOME/.bin $HOME/.local/share/node/bin $JAVA_HOME/bin $FLUTTER_HOME $ANDROID_HOME/cmdline-tools/latest/bin $ANDROID_HOME/platform-tools $ANDROID_HOME/build-tools $GOPATH/bin

    set -gx QT_QPA_PLATFORM wayland
    set -gx XCURSOR_THEME Bibata-Modern-Classic
    set -gx WAYLAND_DISPLAY (basename (find /run/user/(id -u) -type s -name 'wayland-*' 2> /dev/null) 2> /dev/null)

    set -gx nvm_default_version lts
    nvm use lts >/dev/null 2>&1

    _cd_listener
end
