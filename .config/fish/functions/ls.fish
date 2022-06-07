function ls --wraps='exa --color always --git --header --created --modified --time-style default --classify --group-directories-first --binary' --description 'alias ls=exa --color always --git --header --created --modified --time-style default --classify --group-directories-first --binary'
  exa --color always --git --header --created --modified --time-style default --classify --group-directories-first --binary $argv; 
end
