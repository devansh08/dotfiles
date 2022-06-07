function dexit --wraps='docker exec -it' --description 'alias dexit=docker exec -it'
  docker exec -it $argv; 
end
