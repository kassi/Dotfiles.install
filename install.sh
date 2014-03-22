#!/bin/bash
#
# Installation script for dotfiles repositories.
#
# * Checks out the repo given as an optional argument into ~/Library
#   or any other path (relative to your  home folder) given as
#   a second optional argument.
# * Creates all needed directories
# * Links all files unless they are already linked.
#   Existing regular files are backed up and replaced by the link.

repo="$1"
if [[ -z "$repo" ]]; then
  repo="dotfiles"
fi
name=$(basename $repo .git)
destination="$2"
if [[ -z "$destination" ]]; then
  destination="Systems"
fi
dest_path=~/$destination/$name

if [[ -e "$dest_path" ]]; then
  echo "Destination path '$dest_path' already exists."
  cd "$dest_path"
  if [[ $(git diff --shortstat 2> /dev/null | tail -n1) != "" ]]; then
    echo "Git repository is dirty. Skipping pull."
  else
    git pull --rebase
  fi
else
  # checkout
  #
  cd ~/$destination
  git clone $repo
fi

# strip /Users/Name/Library/Dotfiles[.private] from path
subpath() {
  echo "$1"| cut -d"/" -f6-
}

# link
#
cd ~

# First create all directories
for file in $(find $dest_path -name '.git' -prune  -o -type d -mindepth 1 -print); do
  path=$(subpath $file)
  if [[ -e "$path" ]]; then
    if [[ ! -d "$path" ]]; then
      echo "'$path' exists, but is not a directory. Aborting!"
      exit 1
    fi
  else
    mkdir -p "$path" && echo "Directory '$path' created"
  fi
done

# Then link all files given
for file in $(find $dest_path -name '.git' -prune -o -name 'README.md' -prune -o -type f -print); do
  path=$(subpath $file)

  if [[ -L "$path" ]]; then
    # if file exists as a link, ignore it
    target=$(readlink "$path")
    if [[ "$target" != "$file" ]]; then
      echo "Link '$path' already exists, pointing elsewhere ($target)"
    fi
    continue
  elif [[ -f "$path" ]]; then
    # if file exists as regular file, back it up
    mv "$path" "$path~" && echo "Regular file '$path' backed up to '$path~'"
  fi
  ln -s "$file" "$path" && echo "Link '$path' created"
done
