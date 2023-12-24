function dpsa --wraps='docker ps -a' --description 'alias dpsa=docker ps -a'
    docker ps -a $argv
end
