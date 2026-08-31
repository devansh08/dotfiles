function _pure_prompt_git_dirty
    set --local git_staged_count 0
    set --local git_unstaged_count 0
    set --local git_untracked_count 0

    # Parse porcelain output: "[staged][unstaged] filename"
    for line in (command git status --porcelain --ignore-submodules 2>/dev/null)
        if test -z "$line"
            continue
        end

        set --local staged_char (string sub --length 1 --start 1 -- "$line")
        set --local unstaged_char (string sub --length 1 --start 2 -- "$line")

        if test "$staged_char" = "?"
            # Untracked: both chars are '?'
            set git_untracked_count (math $git_untracked_count + 1)
        else if test "$staged_char" != " "
            # Staged: first column is not space and not '?'
            set git_staged_count (math $git_staged_count + 1)
        else if test "$unstaged_char" != " "
            # Unstaged: first column is space, second is not
            set git_unstaged_count (math $git_unstaged_count + 1)
        end
    end

    set --local result ""
    if test $git_staged_count -gt 0
        set result "$result $pure_symbol_git_staged$git_staged_count"
    end
    if test $git_unstaged_count -gt 0
        set result "$result $pure_symbol_git_unstaged$git_unstaged_count"
    end
    if test $git_untracked_count -gt 0
        set result "$result $pure_symbol_git_untracked$git_untracked_count"
    end

    if test -n "$result"
        set --local git_dirty_color (_pure_set_color $pure_color_git_dirty)
        echo "$git_dirty_color$result"
    else
        echo ""
    end
end
