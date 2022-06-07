function drm --wraps='docker rm' --description 'alias drm=docker rm'
  docker rm $argv; 
end
