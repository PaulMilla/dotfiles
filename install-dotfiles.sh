#!/bin/zsh
# Using expansion modifiers from zsh to get the path of the script
# For more info see http://zsh.sourceforge.net/Doc/Release/Expansion.html#Modifiers

git_root="${0:a:h}"
home_dir="$git_root/home"
echo "Mounting $home_dir to \$HOME directory: $HOME"

# if $filename is a file then create a link in the home directory
for filename in $home_dir/.*; do
    if [ -f $filename ]; then
        echo "Creating link for $filename..."
        ln -s -f $filename ~
    fi
done

# if $filename is a directory then loop over the files in the directory
for dirname in $home_dir/*; do
    if [ -d $dirname ]; then
        for file in $dirname/*; do
            echo "Creating link for $file..."
            ln -s -f $file ~/$(basename $dirname)
        done
    fi
done

echo ""
echo "Mounting custom settings..."

# Mount custom/karabiner-elements/paul.json to the karabiner complex_modifications folder
filename="$git_root/custom/karabiner-elements/paul.json"
target="$HOME/.config/karabiner/assets/complex_modifications/"
echo "Creating link for $filename to $target"
ln -s -f $filename $target