function gdsf --wraps='git diff --staged --name-only --relative | fzf --preview="git diff --staged --color=always {1}" --layout=reverse' --description 'alias gdsf git diff --staged --name-only | fzf --preview="git diff --staged --color=always {1}" --layout=reverse'
    git diff --staged --name-only --relative | fzf --preview="git diff --staged --color=always {1}" --layout=reverse $argv
end
