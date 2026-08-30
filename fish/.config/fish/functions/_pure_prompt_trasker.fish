function _pure_prompt_trasker
    set --local active_tasks (echo "ls ACTIVE" | trasker 2> /dev/null | rg --color=never -v "^>" | wc -l)

    if test "$active_tasks" != 0
        set --local trasker_color (_pure_set_color $pure_color_normal)
        echo "$trasker_color$pure_symbol_trasker$active_tasks "
    end
end
