function ct --wraps='tree -a -I "node_modules" -I ".git" -I ".idea" -I ".vscode" .' --description 'alias ct tree -a -I "node_modules" -I ".git" -I ".idea" -I ".vscode" .'
    tree -a -I node_modules -I ".git" -I ".idea" -I ".vscode" . $argv
end
