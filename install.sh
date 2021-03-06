#!/bin/bash
#
# Bootstrapper for installation
# A lot of functionality taken from https://github.com/holman/dotfiles/blob/master/script/bootstrap
#
# Defaults
path="System"
repo="dotfiles"
#

usage() {
  printf "%b" "
Usage

  bootstrap.sh [options] [actions]

or remotely

  curl -fsSL https://raw.github.com/kassi/Dotfiles.bootstrap/master/bootstrap.sh | bash -s [options] [actions]

Options

  --path <path>

    The destination path where the files will be written to.
    Defaults to $path.

  --repo <repo>

    The repository to fetch instructions from.
    Defaults to '$repo', but this is only working with a set up hub tool,
    which is most likely not the case when setting up a machine like this.

  -n | --dry-run

    Do not write, just print what would be done.

Actions

  help    - Show this info
  link    - Links all the (dot)files.
  install - Runs all installations (brew, cask, indivual install.sh)
  brew    - Bundle only Brewfile
  cask    - Bundle only Caskfile
  "
}

# set -e

info() { printf "  [ \033[00;34m..\033[0m ] $1\n"; }
user() { printf "\r  [ \033[0;33m?\033[0m ] $1 "; }
fail() { printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"; exit; }
success() { printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"; }

declare -a actions
dry=''

parse_params() {
  while (( $# > 0 )); do
    token="$1"
    shift
    case "$token" in
      (-n|--dry-run)
        dry="1"
        ;;
      (--path)
        if [[ -n "${1:-}" ]]; then
          path="$1"
          shift
        else
          fail "--path must be followed by a path."
        fi
        ;;
      (--repo)
        if [[ -n "${1:-}" ]]; then
          repo="$1"
          shift
        else
          fail "--repo must be followed by a repository."
        fi
        ;;
      (link|install|brew|cask)
        actions+=("$token")
        ;;
      (help)
        usage
        exit 0
        ;;
      (*)
        usage
        exit 1
        ;;
    esac
  done
  if [[ -z "${actions[@]}" ]]; then
    actions+=(link install)
  fi
  containsElement "install" "${actions[@]}" && actions+=(brew cask installer)
}

containsElement() {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

parse_params "$@"

echo "path: $path"
echo "repo: $repo"
echo "actions: ${actions[@]}"

NAME="$(basename "$repo" .git)"

if [[ "$path" == "." ]]; then
  DESTINATION_DIR=$(pwd)
else
  DESTINATION_DIR="$HOME/$path"
fi
DESTINATION_PATH="$DESTINATION_DIR/$NAME"
# BASH_FILE_PATH="$DESTINATION_DIR/bash"


link_file () {
  local src=$1 dst=$2

  # strip leading $HOME if destination is in home directory
  dst_dir=$(dirname $dst)
  if [[ $dst_dir == $HOME ]]; then
    src=${src/#$HOME\//}
  fi

  local overwrite= backup= skip=
  local actions=

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]
  then

    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
    then

      local currentSrc="$(readlink $dst)"

      if [ "$currentSrc" == "$src" ]
      then

        skip=true;

      else

        user "File already exists: $(basename "$dst"), what do you want to do? [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 actions

        case "$actions" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac

      fi

    fi

    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [ "$overwrite" == "true" ]
    then
      rm -rf "$dst"
      success "removed $dst"
    fi

    if [ "$backup" == "true" ]
    then
      mv "$dst" "${dst}.backup"
      success "moved $dst to ${dst}.backup"
    fi

    if [ "$skip" == "true" ]
    then
      success "skipped $src"
    fi
  fi

  if [ "$skip" != "true" ]  # "false" or empty
  then
    ln -s "$src" "$dst"
    success "linked $src to $dst"
  fi
}

setup_destination () {
  info "Setting up dotfiles system into $DESTINATION_PATH"
  if [[ -e "$DESTINATION_PATH" ]]; then
    info "Destination path '$DESTINATION_PATH' already exists."
    cd "$DESTINATION_PATH"
    if [[ $(git diff --shortstat 2> /dev/null | tail -n1) != "" ]]; then
      info "Git repository is dirty. Skipping pull."
    else
      if [[ -z $dry ]]; then
        git pull --rebase
        success "pulled $DESTINATION_PATH"
      fi
    fi
  else
    cd "$DESTINATION_DIR"
    if [[ -z $dry ]]; then
      git clone $repo
      success "cloned repository"
    fi
  fi
}

install_dotfiles () {
  containsElement "link" "${actions[@]}" || return 0
  info "Linking files"

  local overwrite_all=false backup_all=false skip_all=false

  OIFS="$IFS"
  IFS=$'\n'
  for dir in $(find "$DESTINATION_PATH" -mindepth 1 -maxdepth 1 -type d); do
    if [[ $(basename "$dir") == ".git" ]]; then continue; fi
    for file in $(find "$dir" -type f); do
      base=${file/#$dir\//}
      if [[ "$base" == "install.sh" ]]; then continue; fi
      base_path=$(dirname "$base")
      file_name=$(basename "$base")
      if [[ "$base_path" == "." ]]; then base_path=""; fi

      if [[ -n "$base_path" ]]; then
        if [[ ! -d "$HOME/$base_path" ]]; then
          if [[ -f "$HOME/$base_path" ]]; then
            fail "directory '$HOME/$base_path' can't be created, because it exists a a file"
          else
            if [[ -n $dry ]]; then
              info "mkdir -p $HOME/$base_path"
            else
              mkdir -p "$HOME/$base_path"
            fi
          fi
        fi
      fi

      if [[ -n $dry ]]; then
        info "Link '$base_path/$file_name' to '~/$base_path'"
      else
        link_file "$file" "$HOME/$base_path/$file_name"
        success "linked '~/$base_path/$file_name' -> '$base_path/$file_name'"
      fi
    done
  done
  IFS="$OIFS"
  info "linked files"
}

install_brewfiles () {
  file="$1"
  if [[ -e "$DESTINATION_PATH/$file" ]]; then
    user "Continue with bundling $file? [y]es or [n]o?"
    read -n 1 answer
    echo
    case "$answer" in
      y)
        info "Bundling $file"
        brew bundle "$DESTINATION_PATH/$file"
        success "bundled $file"
        ;;
    esac
  fi
}

install_individual_files () {
  for script in $(find "$DESTINATION_PATH" -type f -name 'install.sh'); do
    user "Continue with installing $script? [y]es or [n]o?"
    read -n 1 answer
    echo
    case "$answer" in
      y)
        info "Running $script"
        pushd .
        source $script
        popd
        ;;
    esac
  done
}

actions() {
  setup_destination
  install_dotfiles
  containsElement "brew" "${actions[@]}" && install_brewfiles Brewfile
  containsElement "cask" "${actions[@]}" && install_brewfiles Caskfile
  install_individual_files
}
actions
