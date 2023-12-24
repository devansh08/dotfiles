#!/bin/fish

for f in $argv
    set FILE "$f"

    set file_name (path basename $FILE)
    set dir_name (path dirname $FILE | sed -e "s|$HOME/*||g")

    set link_name ""
    if test "$dir_name" != ""
        mkdir -p $dir_name
        set link_name "./$dir_name/$file_name"
    else
        set link_name "./$file_name"
    end

    if ! test -e "$link_name"
        ln "$FILE" "$link_name"
    end
end
