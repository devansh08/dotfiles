function gplr --wraps='git pull -r' --description 'alias gplr=git pull -r'
  git pull -r $argv; 
end
