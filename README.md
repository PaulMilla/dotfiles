# Paul Milla's DotFiles

## Installation

A collection of dotfiles for configuration and settings for various apps/tools.

Since this has a submodule you should clone with the --recursive flag

```bash
# HTTPS auth
git clone --recursive https://github.com/PaulMilla/dotfiles.git

# SSH auth
git clone --recursive git@github.com:PaulMilla/dotfiles.git
```

The master branch holds the most generic and cross-platform settings while long-lived branches hold more OS-specific settings.

To install from PowerShell:

```posh
& .\bootstrap.ps1
```

## Bootstrap Scripts

To install system-specific apps see the bootstrap submodule

## Thanks to…

* @[Jay Harris](http://twitter.com/jayharris/) for his [Windows dotfiles](https://github.com/jayharris/dotfiles-windows), which this repositry is modeled after
* @[Mathias Bynens](http://mathiasbynens.be/) for his [OS X dotfiles](http://mths.be/dotfiles), which Jay Harris' repository is modeled after.
