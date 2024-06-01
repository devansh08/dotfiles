function grep --wraps=rg --wraps='rg -i' --description 'alias grep rg -i'
  rg -i $argv
end
