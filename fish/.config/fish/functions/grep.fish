function grep --wraps=rg --wraps='rg -i --hidden' --description 'alias grep rg -i --hidden'
  rg -i --hidden $argv
end
