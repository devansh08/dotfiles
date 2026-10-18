function gsi --wraps='git stash --include-untracked' --description 'alias gsi=git stash --include-untracked'
    git stash $argv
end
