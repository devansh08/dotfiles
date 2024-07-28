function kbj --wraps='jobs -p | tail -n +1 | xargs -I % kill -9 %' --description 'alias kbj jobs -p | tail -n +1 | xargs -I % kill -9 %'
    jobs -p | tail -n +1 | xargs -I % kill -9 % $argv
end
