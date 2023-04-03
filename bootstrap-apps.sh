
# Install Homebrew
if test ! $(which brew); then
  echo "Installing homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if test $? -ne 0; then
    echo "Homebrew installation failed. Try installing xcode command line tools and running the script again:"
    echo "  xcode-select --install"
    exit 1
  fi
fi

# homebrew installs
brew install --cask iterm2
brew install node
brew install yarn
brew install zsh
brew install maccy
brew install --cask raycast
brew install --cask rectangle
brew install exa

# Install Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

brew tap homebrew/cask-fonts
brew update
brew install --cask font-hack-nerd-font
