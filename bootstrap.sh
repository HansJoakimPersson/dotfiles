#!/usr/bin/env bash

echo "Setting up your Mac..."

# Check for Homebrew and install if we don't have it
if [ -x "$(command -v brew)" ]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Check for Git and install if we don't have it
if ! [ -x "$(command -v git)" ]; then
  echo 'installing git...' >&2
  brew install git
  
  # Clone the latest version 
  git clone https://github.com/HansJoakimPersson/dotfiles
  
  else
  
  # Pull in the latest version 
	cd "$(dirname "${BASH_SOURCE}")" || exit;
	git pull origin master;
fi

# Install packages from homebrew 
sh brew

# Set up MacOS 
sh macos

# Adding dotfiles to home folder 
function doIt() {
	rsync --exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude "bootstrap.sh" \
		--exclude "README.md" \
		--exclude "brew" \
		--exclude "macos" \
		--exclude "LICENSE-MIT.txt" \
		-avh --no-perms . ~;
	source ~/.bash_profile;
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt;
else
	read -p -r "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt;
	fi;
fi;
unset doIt;
