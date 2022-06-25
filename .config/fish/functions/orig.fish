function orig --description 'Script to run given command using its actual binary path instead of its alias'
    set -l cmd $argv[1]
    set -l orig_cmd (which $cmd 2> /dev/null)

    if test -z $orig_cmd
        # Original command not found
        eval $argv
    else
        # Original command found
        # Run with remaining command line args
        eval $orig_cmd $argv[2..-1]
    end
end
