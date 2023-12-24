function vimx --wraps='touch $1 && chmod u+x $1 && vim $1' --wraps='touch $argv && chmod u+x $argv && vim' --description 'alias vimx=touch $argv && chmod u+x $argv && vim'
    touch $argv && chmod u+x $argv && vim $argv
end
