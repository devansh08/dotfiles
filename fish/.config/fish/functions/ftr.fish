function ftr
    set -l pwd (pwd) && cd ~/.local/share/tmux/resurrect && rm -f last && ln -s (/bin/ls -t1 tmux_resurrect_* | head -n 2 | tail -n 1) last && find . -type f -name 'tmux_resurrect*' -empty -delete $argv && cd $pwd
end
