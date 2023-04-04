# Pressing and holding a letter like 'e' should result in repeated 'e's being typed. This is not the default behavior for Mac keyboards.
# https://discussions.apple.com/thread/3646726#:~:text=Here%27s%20the%20fix%3A%201%20Open%20terminal.%202%20Type,-g%20ApplePressAndHoldEnabled%20-bool%20false%203%20Reboot%20your%20mac.
defaults write -g ApplePressAndHoldEnabled -bool false