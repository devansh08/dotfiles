#!/bin/sh

CONFIG_DIR=~/.config/kitty
SESSIONS_DIR=$CONFIG_DIR/sessions

cd $SESSIONS_DIR

for file in *.kitty; do
  name="${file%.kitty}"
  kitty -o allow_remote_control=yes --name "$name" --session sessions/$file &
done
