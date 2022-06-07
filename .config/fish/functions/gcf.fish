function gcf --wraps='git clean -df' --description 'alias gcf=git clean -df'
  git clean -df $argv; 
end
