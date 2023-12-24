function nvim --description 'alias nvim nvim --startuptime "/tmp/nvim-startup-"(date +%s)'
    command nvim --startuptime "/tmp/nvim-startup-"(date +%s) $argv

end
