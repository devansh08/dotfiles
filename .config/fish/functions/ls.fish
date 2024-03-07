function ls --wraps='eza --color always --git --header --created --modified --time-style default --classify --group-directories-first --binary' --description 'alias ls=eza --color always --git --header --created --modified --time-style default --classify --group-directories-first --binary'
    eza --color always --git --header --created --modified --time-style default --classify --group-directories-first --binary $argv
end
