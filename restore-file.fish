#!/bin/fish

for f in $argv
    set orig_file (echo "$f" | sed -e "s|^./|$HOME/|g")
    if ! test -e "$orig_file"
        set dir_path (path dirname "$orig_file")
        mkdir -p "$dir_path"

        cat "$f" >"$orig_file"

        rm "$f"
        ln "$orig_file" "$f"
    end
end
