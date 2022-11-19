#!/usr/bin/fish

set -l file $argv[1]
set -l dir (realpath $file | sed -e "s#$HOME/##g" -e 's#/[^/]*$##g')

mkdir -p $dir

ln (realpath $file) ./$dir/(basename $file)
