# Dotfiles.install

Installation script for dotfiles repositories.

## Usage

Assuming your Dotfiles repo under `git@github.com:kassi/Dotfiles.git`:

    curl -fsSL https://raw.github.com/kassi/Dotfiles.install/master/install.sh | bash -s git@github.com:kassi/Dotfiles.git

If you have https://hub.github.com/ installed and your repo is called `dotfiles`, a simple

    curl -fsSL https://raw.github.com/kassi/Dotfiles.install/master/install.sh | bash

will do.

If you do not want to clone your dotfiles repo into `~/System`, you can choose a different destination by giving a second optional argument like

    curl -fsSL https://raw.github.com/kassi/Dotfiles.install/master/install.sh | bash -s dotfiles lib

which will clone into `~/lib`.

## Documentation

This script is build to be Mac OS X specific, but will work with other linuxes as well. You may want to change the destination directory in this case.

The script will clone your repo, create necessary directories and link (nearly) all files found.

I picked up the idea of dividing the dotfiles in semantic parts from [holman/dotfiles](https://github.com/holman/dotfiles) and kept the `*.symlink` logic.
However, I added a little more sugar.

* on first level you'll find directories for different parts/tools/apps. Inside
    * any named `something.symlink` will be symlinked to
        * `$HOME/.something` if it's on top-level
        * the directory given if it's not
    * any directory named `something.dir` will be created as `$HOME/something`.
    * any file in `bin` will be symlinked to `$HOME/bin`
    * any file in `etc` will be symlinked to `$HOME/etc`
    * any file named in `something.bash` will be concatenated to `$HOME/.bash_something`
    * any install.sh will be executed inside the last step of the install script

## Why

Why do I need this?

Because I have several dotfiles repositories plus an additional system additions repository and all installations behave the same.
Some are public, another one is private and not on a public hoster (you may think of having your email address inside `.gitconfig` (public) or inside a `.gitconfig.private` (private repo), included by `.gitconfig`).

With this script I'm able to install those repos with ease.

## Intention

What do I want to achieve?

* A lot of files have to be linked to from `$HOME` as `.filename`
* Some directories may be linked to from `$HOME`
* Some files have to be linked to from `$HOME/bin`
* Some files event have to be linked to from somewhere else like `$HOME/Library/whatever` and those are not necessarily dot files.
* There are several repositories, each one
    * may define new `.filename`
    * may define `.filename` for file already linked to by another installer task
    * may define additional files for `bin` so that linking the directory instead of the files wouldn't work
    * may have their own install scripts

## Author

Karsten Silkenbäumer

[![endorse](http://api.coderwall.com/ksi/endorsecount.png)](http://coderwall.com/ksi)
