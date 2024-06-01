function okular-reopen --description 'Script to save open Okular files and reopen them after closing Okular'
    set -l OKULAR_LIST_FILE '/home/devansh/.okular.lst'
    argparse -i s o -- $argv

    if test -n "$_flag_s"
        set -l INSTANCE_NAMES (qdbus | grep -i okular | string trim)
        rm $OKULAR_LIST_FILE

        for instance_name in $INSTANCE_NAMES
            set -l OPEN_FILES (qdbus $instance_name | grep -E '^/okular[0-9]*$')

            if test ! -z "$OPEN_FILES"
                for i in $OPEN_FILES
                    set -l file_name (qdbus $instance_name $i org.kde.okular.currentDocument)
                    if test -e "$file_name"
                        echo $file_name >>$OKULAR_LIST_FILE
                    end
                end
            end
        end

        cat $OKULAR_LIST_FILE
    end

    if test -n "$_flag_o"
        okular (cat $OKULAR_LIST_FILE) &
    end
end
