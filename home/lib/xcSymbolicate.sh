#!/bin/sh

# By using xcode to symbolicate crash logs, it will automatically use all available dSYMs on your mac at once
# https://developer.apple.com/documentation/xcode/adding-identifiable-symbol-names-to-a-crash-report#Symbolicate-the-crash-report-in-Xcode

# stack overflow: https://stackoverflow.com/a/30431450

# get our crashFile argument
crashFile="$1"

# check if crashFile exists
if [ ! -f "$crashFile" ]; then
    >&2 echo "crashFile could not be found."
    >&2 echo "Usage: xcSymbolicate.sh <crashFile>"
    exit 1
fi

# get crashFile name without extensions
crashFileName=$(basename "$crashFile" | sed 's/\.[^.]*$//')

# get the path from xcode-select
xcodeDevDir=$(xcode-select -p)

# get the parent directory of xcodeDevDir
xcodeContentsPath=$(dirname "$xcodeDevDir")

# get path for symbolicatecrash - this should work for XCode 8+
symbolicatecrash=$(realpath "$xcodeContentsPath/SharedFrameworks/DVTFoundation.framework/Versions/A/Resources/symbolicatecrash")

# check if symbolicatecrash exists
if [ ! -f "$symbolicatecrash" ]; then
    >&2 echo "symbolicatecrash could not be found. Please install XCode CLI tools."
    exit 1
fi

# symbolicatecrash needs DEVELOPER_DIR to be set
# if we want to provide a dSYM, we will need to add another parameter when calling `symbolicatecrash`
(set -x; DEVELOPER_DIR="$xcodeDevDir" "$symbolicatecrash" -v "$crashFile" > "$crashFileName-symbolicated.crash")

echo "\nThis uses debugging symbols from the dSYMs that are available in XCode.
To add more dSYMs, you can follow the guide here to download and install the msplaces.xcarchive file from ADO:
https://outlookweb.visualstudio.com/MicrosoftPlaces/_wiki/wikis/Microsoft%20Places%20Mobile/10487/Symbolicating-a-Crash-File"

output="File available at: $(realpath "$crashFileName-symbolicated.crash")"
# print outPath with yellow foreground color and reset color
echo "\n\033[33m$output\033[0m"
