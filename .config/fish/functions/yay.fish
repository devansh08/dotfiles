function yay --description 'Wraps yay to add another option to download older package versions from cache or Arch Linux Archive (ALA)'

    set -l ORIG_ARGS $argv

    set -l PACMAN_CACHE_PATH "/var/cache/pacman/pkg"
    set -l ALA_URL "https://archive.archlinux.org/packages"

    argparse -i "s" "O" "n=" -- $argv

    set -l PACKAGE_NAME $argv
    set -l LATEST_LIMIT 5
    set -l PATT '[0-9:]+\..*'

    test -n "$_flag_n" && set -l LATEST_LIMIT $_flag_n

    if test -n "$_flag_O"
        if test -n "$_flag_s"
            set_color -o blue
            echo -n ":: "
            set_color -o white
            echo "Searching in local pacman cache..."
            echo

            echo "Packages in local cache:"
            set_color normal
            fd $PACKAGE_NAME $PACMAN_CACHE_PATH | sed -E "/\.sig\$/d;s/.*\/(.*)-($PATT)-.*\$/\1-\2/;/^$PACKAGE_NAME-$PATT/!d;s/(.*)-($PATT)/echo `fish -c 'set_color normal'`'\1'`fish -c 'set_color black'`'-\2'/e"
            set_color normal

            echo

            set_color -o blue
            echo -n ":: "
            set_color -o white
            echo "Searching on Arch Linux Archive..."
            echo
            set -l temp_file (mktemp)
            curl -sLo $temp_file $ALA_URL/(string sub -l 1 $PACKAGE_NAME)/$PACKAGE_NAME/

            echo "Latest $LATEST_LIMIT packages in Arch Linux Archive:"
            sed -E "/href=\".*[^g]\"/!d;/href=\"\.\.\/\"/d" $temp_file | tail -n $LATEST_LIMIT | sed -E "s/.*href=\"([^\"]*)\".*/\1/;s/(.*)-($PATT)-.*\$/\1-\2/;/^$PACKAGE_NAME-$PATT/!d;s/(.*)-($PATT)/echo `fish -c 'set_color normal'`'\1'`fish -c 'set_color black'`'-\2'/e"

            rm $temp_file
        else
            set_color -o blue
            echo -n ":: "
            set_color -o white
            echo "Searching for $PACKAGE_NAME in local pacman cache..."
            echo

            if test (ls -1 "$PACMAN_CACHE_PATH/$PACKAGE_NAME*" 2> /dev/null | wc -l) -eq 1
                set_color normal
                echo "$PACKAGE_NAME found in local cache..."
                echo
                echo "Running pacman to downgrade..."
                echo

                sudo pacman -U $PACMAN_CACHE_PATH/$PACKAGE_NAME*
            else
                echo "$PACKAGE_NAME not found in local cache..."
                echo
                set_color -o blue
                echo -n ":: "
                set_color -o white
                echo "Searching for $PACKAGE_NAME on Arch Linux Archive..."
                echo
                set -l temp_file (mktemp)
                set -l pack_name (echo $PACKAGE_NAME | sed -E "s/(.*)-$PATT/\1/")
                curl -sLo $temp_file $ALA_URL/(string sub -l 1 $pack_name)/$pack_name/

                set -l file_name (sed -E "/href=\".*[^g]\"/!d;/href=\"\.\.\/\"/d;/.*href=\"("$PACKAGE_NAME"[^\"]*)\".*/!d;s/.*href=\"("$PACKAGE_NAME"[^\"]*)\".*/\1/" $temp_file)
                if test -n "$file_name"
                    echo "$PACKAGE_NAME found on Arch Linux Archive..."
                    echo
                    echo "Downloading package archive file..."
                    echo
                    set -l package_file (mktemp)
                    curl -Lo $package_file $ALA_URL/(string sub -l 1 $pack_name)/$pack_name/$file_name
                    echo "Running pacman to downgrade..."
                    echo

                    sudo pacman -U $package_file

                    rm $package_file
                else
                    echo "$PACKAGE_NAME not found on Arch Linux Archive..."
                end

                rm $temp_file
            end
        end
    else
        /usr/bin/yay $ORIG_ARGS
    end
end
