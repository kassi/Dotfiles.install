# Dotfiles.install

Installation script for dotfiles repositories.

## Usage

Assuming your Dotfiles repo under `git@github.com:kassi/Dotfiles.git`:

    curl -fsSL https://raw.github.com/kassi/Dotfiles.install/master/install.sh | bash -s git@github.com:kassi/Dotfiles.git

If you have https://hub.github.com/ installed and your repo is called `dotfiles`, a simple

    curl -fsSL https://raw.github.com/kassi/Dotfiles.install/master/install.sh | bash

will do.

If you do not want to clone your dotfiles repo into `~/Library`, you can choose a different destination by giving a second optional argument like

    curl -fsSL https://raw.github.com/kassi/Dotfiles.install/master/install.sh | bash -s dotfiles lib

which will clone into `~/lib`.

## Documentation

This script is build to be Mac OS X specific, but will work with other linuxes as well. You may want to change the destination directory in this case.

The script will clone your repo, create necessary directories and link (nearly) all files found.

If files already exists as regular files, they will be moved to a backed up version and the link will be created.

If files already exists as a link nothing will change.
It will print out a message if the existing symbolic link doesn't point to the same file.

## Why

Why do I need this?

Because I have two dotfiles repositories and both installations behave the same.
One is public, another one is private and not on a public hoster.

You may think of having your email address inside .gitconfig (public) or inside a .gitconfig.private (private repo), included by .gitconfig.

With this script I'm able to install those repos with ease.

## Author

Karsten Silkenbäumer

[![endorse](http://api.coderwall.com/ksi/endorsecount.png)](http://coderwall.com/ksi)
