#!/bin/fish

set -l dir $argv[1]

if test -d $dir
	for path in (tree -aif --noreport $dir)
		if ! test -d $path
			rm $path
			ln ~/$path $path
		end
	end
else
	rm $dir
	ln ~/$dir $dir
end