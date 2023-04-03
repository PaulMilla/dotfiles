#!/bin/zsh
# Using expansion modifiers from zsh to get the path of the script
# For more info see http://zsh.sourceforge.net/Doc/Release/Expansion.html#Modifiers

home_dir="${0:a:h}/home"
echo "Mounting $home_dir to \$HOME directory: $HOME"

for filename in $home_dir/.*; do
    if [ -f $filename ]; then
        echo "Creating link for $filename..."
        ln -s -f $filename ~
    fi
done