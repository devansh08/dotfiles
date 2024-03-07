function _cd_listener --on-variable="PWD"
    # Parent Dirs
    set -g _parent_dirs (string escape (
    for dir in (string split / -- $PWD)
        set -la parts $dir
        string join / -- $parts
    end))

    # Virtualenv
    if path filter $_parent_dirs/venv/bin/activate.fish $_parent_dirs/.venv/bin/activate.fish | read -l activate_file
        if test -z $VIRTUAL_ENV
            source $activate_file
        end
    else
        if functions -q deactivate
            deactivate
        end
    end

    # NVM
    set -l node_version (nvm current)
    if path filter $_parent_dirs/.nvmrc | read -l nvmrc_path
        set -l nvmrc_node_version (cat $nvmrc_path)
        if ! test "$node_version" = "$nvmrc_node_version"
            if test (nvm ls | grep "$nvmrc_node_version")
                nvm use "$nvmrc_node_version" >/dev/null
            else
                nvm install "$nvmrc_node_version"
            end
        end
    end
end
