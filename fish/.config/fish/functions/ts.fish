function ts --wraps='source ~/.config/fish/config.fish && tide reload' --description 'alias ts source ~/.config/fish/config.fish && tide reload'
  source ~/.config/fish/config.fish && tide reload $argv
end
