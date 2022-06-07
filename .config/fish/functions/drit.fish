function drit --wraps='docker run -it' --description 'alias drit=docker run -it'
  docker run -it $argv; 
end
