function fsf --wraps='cat /var/lib/mlocate/mlocate.txt | fzf' --description 'alias fsf=cat /var/lib/mlocate/mlocate.txt | fzf'
commandline --current-token --replace (cat /var/lib/mlocate/mlocate.txt | fzf --tac $argv);
end
