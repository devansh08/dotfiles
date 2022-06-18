function gs --wraps='git status --untracked-files=all' --description 'alias gs=git status --untracked-files=all'
  git status --untracked-files=all $argv;
end
