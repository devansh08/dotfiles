function _cd_listener --on-variable="PWD"
    # Parent Dirs
    set -g _parent_dirs (string escape (
    for dir in (string split / -- $PWD)
        set -la parts $dir
        string join / -- $parts
    end))

    # Virtualenv
    if path filter $_parent_dirs/venv/bin/activate.fish | read -l activate_file
        if test -z $VIRTUAL_ENV
            source $activate_file
        end
    else
        if functions -q deactivate
            deactivate
        end
    end
end
