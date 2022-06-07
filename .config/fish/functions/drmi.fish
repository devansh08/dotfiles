function drmi --wraps='docker rmi' --description 'alias drmi=docker rmi'
  docker rmi $argv; 
end
