# Paul Milla's DotFiles

## Installation

A collection of dotfiles for configuration and settings for various apps/tools.

```bash
git clone https://github.com/PaulMilla/dotfiles.git # HTTPS auth
git clone git@github.com:PaulMilla/dotfiles.git     # SSH auth
```

The master branch holds the most generic and cross-platform settings while long-lived branches hold more OS-specific settings.

To install from PowerShell:

```posh
& .\Mount-DotFiles.ps1
```

## Making changes

If you are a future me try to make changes under my personal github account (PaulMilla)

To do this inside a specific repo first navigate under the repo folder (/github/dotfiles)
and then set the name + email like so:

```sh
git config user.name "Paul Milla"
git config user.email "PaulMilla@users.noreply.github.com"
# Email is set using github noreply emails to enable privacy
```

If there is already some commits under the wrong git account you can amend the author like so:

```sh
git commit --amend --reset-author --no-edit
```

## Bootstrap Scripts

To install system-specific apps see the bootstrap submodule

## Thanks to…

* @[Jay Harris](http://twitter.com/jayharris/) for his [Windows dotfiles](https://github.com/jayharris/dotfiles-windows), which this repositry is modeled after
* @[Mathias Bynens](http://mathiasbynens.be/) for his [OS X dotfiles](http://mths.be/dotfiles), which Jay Harris' repository is modeled after.
