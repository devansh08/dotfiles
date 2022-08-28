function sudo --wraps=doas --description 'Alias doas to sudo; Ask for password again on failed auth upto 3 times'
    set -l count 1
    doas $argv
    if test $status -eq 1 -a $count -lt 3
        set -l count (math $count + 1)
        doas $argv
    end
end

