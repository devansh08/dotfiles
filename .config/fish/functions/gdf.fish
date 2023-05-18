function gdf --wraps='git diff --name-only --relative | fzf --preview="git diff --color=always {1}" --layout=reverse' --description 'alias gdf git diff --name-only | fzf --preview="git diff --color=always {1}" --layout=reverse'
  git diff --name-only --relative | fzf --preview="git diff --color=always {1}" --layout=reverse $argv
end
