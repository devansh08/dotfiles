function gl --wraps='git log' --wraps='git log --format="%C(yellow)%h%Creset %C(cyan)%an%Creset %C(green)%ai%Creset %s %C(auto)%d%Creset"' --description 'alias gl git log --format="%C(yellow)%h%Creset %C(cyan)%an%Creset %C(green)%ai%Creset %s %C(auto)%d%Creset"'
  git log --format="%C(yellow)%h%Creset %C(cyan)%an%Creset %C(green)%ai%Creset %s %C(auto)%d%Creset" $argv; 
end
