# Profile for the Visual Studio Code Shell, only.
# Layered on top of Profile.ps1
# ===========

# VS Code for some reason maps ctrl+backspace tto ctrl+w, and when we try and ctrl+backspace
# in the VS Code terminal we instead get the characters ^W
Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardKillWord