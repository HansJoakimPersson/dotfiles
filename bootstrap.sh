#!/usr/bin/env bash

echo "Setting up your Mac..."

# Ask for the administrator password upfront
sudo -v

  # If we're using APFS, make a snapshot before doing anything.
  if [[ ! -z "$(mount | grep '/ (apfs')" ]]; then
    sudo tmutil enable
    sudo tmutil localsnapshot
  fi

# Check for Homebrew and install if we don't have it
echo "Checking for Homebrew"
if test ! $(which brew); then
	echo "Downloading and installing Homebrew"
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Check if this already is a git repository of my dot files
if git remote -v 2> /dev/null | grep -q 'https://github.com/HansJoakimPersson/dotfiles'; then
	echo "Pull in the latest version"
	cd "$(dirname "${BASH_SOURCE}")" || exit
	git pull origin master
else
	echo "Clone the latest version"
	cd "$(dirname "${BASH_SOURCE}")" || exit
	git clone https://github.com/HansJoakimPersson/dotfiles
	cd dotfiles
fi

# Set hostname
read -p "Change hostname for this computer (Enter to skip): " hostname

if [[ ! -z "$hostname" ]]; then
	# Set computer name (as done via System Preferences → Sharing)
  sudo scutil --set ComputerName "$hostname" && \
  sudo scutil --set HostName "$hostname" && \
  sudo scutil --set LocalHostName "$hostname" && \
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$hostname"
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
		-avh --no-perms . ~
	source ~/.bash_profile
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt
else
	read -p -r "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
	echo ""
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt
	fi
fi
unset doIt
