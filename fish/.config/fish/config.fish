if status --is-interactive
    bind alt-backspace backward-kill-word
    fish_config theme choose "Catppuccin Mocha"

    set fish_greeting

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

    set -gx EZA_COLORS (cat $HOME/.config/eza/colors)
    set -gx LSCOLORS Gxfxcxdxbxegedabagacad
    set -gx LS_COLORS (cat $HOME/.config/ls/colors)

    _cd_listener
end
