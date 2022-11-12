function glf --wraps='git log --format="%C(yellow)%h%Creset %C(cyan)%an%Creset %C(green)%ai%Creset %s %C(auto)%d%Creset" | fzf --preview="git show --color=always -p {1}" --layout=reverse' --description 'alias glf git log --format="%C(yellow)%h%Creset %C(cyan)%an%Creset %C(green)%ai%Creset %s %C(auto)%d%Creset" | fzf --preview="git show --color=always -p {1}" --layout=reverse'
  git log --format="%C(yellow)%h%Creset %C(cyan)%an%Creset %C(green)%ai%Creset %s %C(auto)%d%Creset" | fzf --preview="git show --color=always -p {1}" --layout=reverse $argv; 
end
