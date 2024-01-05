
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
brew install --cask powershell
brew install --cask postman
brew install git-delta
brew install bat
brew install chruby
brew install --cask scroll-reverser
brew install --cask shottr
brew install --cask openinterminal
brew install --cask openinterminal-lite
brew install --cask openineditor-lite

# Install Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install PowerLevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Install better fonts
brew tap homebrew/cask-fonts
brew update
brew install --cask font-hack-nerd-font
