function kbj --wraps='kill -9 (jobs -p | tail -n +1)' --description 'alias kbj kill -9 (jobs -p | tail -n +1)'
  kill -9 (jobs -p | tail -n +1) $argv; 
end
