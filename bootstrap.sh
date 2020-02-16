#!/usr/bin/env bash

###############################################################################
# Strict Mode
###############################################################################

# Set strict mode -  via http://redsymbol.net/articles/unofficial-bash-strict-mode/
# Return value of a pipeline is the value of the last (rightmost) command to
# exit with a non-zero status, or zero if all commands in the pipeline exit
# successfully.

# Print a helpful message if a pipeline with non-zero exit code causes the
# script to exit as described above.
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR

# Exit immediately if a pipeline returns non-zero.
# Append "|| true" if you expect an error.
set -o errexit
# Allow the above trap be inherited by all functions in the script.
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Return value of a pipeline is the value of the last (rightmost) command to
# exit with a non-zero status, or zero if all commands in the pipeline exit
# successfully.
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
#set -o xtrace

# Set $IFS to only newline and tab.
#
# http://www.dwheeler.com/essays/filenames-in-shell.html
IFS=$'\n\t'

###############################################################################
# Globals
###############################################################################

# Set magic variables for current file, directory, os, etc.
readonly _PROGFNAME=$(basename "${0}") # Set to the program's basename.
readonly _PROGAUTH="cert@polisen.se"
readonly _PROGDATE=$(stat -f "%Sm" "$0" 2>/dev/null)          # for MacOS

# Reset
readonly reset="\x1b[0m" # Text Reset

# Foreground color
readonly green="\x1b[32m"
readonly yellow="\x1b[33m"

# Special characters
readonly char_succ="✔"

echo -e "Program: ${green}$_PROGFNAME${reset} by ${yellow}$_PROGAUTH${reset}"
echo -e "Updated: ${green}$_PROGDATE${reset}\n"

###############################################################################
# Main script
###############################################################################

echo -e '=============================================='
echo -e '=           ${yellow}Setting up your Mac...${reset}           ='
echo -e '=============================================='

# Revoke any previous sudo access
sudo -k

# Ask for the administrator password upfront
echo
echo -n 'Some settings require sudo to change. '
sudo -v

# Please give me some answers
read  -p "Change hostname for this computer (Enter to skip): " hostname
read  -p "Adding dotfiles to home folder may overwrite existing files. Are you sure? (y/n) " dotfiles

echo
echo "From this point on it should be an automated process,\n ☕☕☕ go grab a coffee! ☕☕☕\n\n"

# If we're using APFS, make a snapshot before doing anything.
if   [[ -n "$(  mount | grep '/ (apfs')" ]]; then
	echo "Taking local APFS snappshot\n"
	sudo tmutil localsnapshot
	echo -e "Done ${green}${char_succ}${reset}"
fi

# Set hostname
if  [[ -n $hostname     ]]; then
	#Set computer name (as done via System Preferences → Sharing)
	echo "Setting hostname to $hostname"
	sudo scutil --set ComputerName "$hostname" &&
		sudo scutil --set HostName "$hostname" &&
		sudo scutil --set LocalHostName "$hostname" &&
		sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$hostname"
	echo -e "Done ${green}${char_succ}${reset}"
fi

echo -e '=============================================='
echo -e '=            ${yellow}Adding prerequisites${reset}            ='
echo -e '=============================================='

# disable sleep
echo "Temporary disabling sleep"
sudo pmset -a sleep 0
sudo pmset -a hibernatemode 0
sudo pmset -a disablesleep 1

# Check for Homebrew and install if we don't have it
echo "Checking for Homebrew"
if test ! "$(which brew)"; then
	echo "Downloading and installing Homebrew"
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	echo -e "Done ${green}${char_succ}${reset}"
fi

# Check if this already is a git repository of my dot files
if git remote -v 2>/dev/null  | grep -q 'https://github.com/HansJoakimPersson/dotfiles'; then
	echo "Pull in the latest version of this git repository"
	# cd "$(dirname "${BASH_SOURCE}")" || exit
	git pull origin master
	echo -e "Done ${green}${char_succ}${reset}"
else
	echo "Clone the latest version of this git repository"
	# cd "$(dirname "${BASH_SOURCE}")" || exit
	git clone https://github.com/HansJoakimPersson/dotfiles
	cd dotfiles
	echo -e "Done ${green}${char_succ}${reset}"
fi

# Install packages from homebrew
echo -e '=============================================='
echo -e '=        ${yellow}Installing Homebrew packages${reset}        ='
echo -e '=============================================='
sh brew
echo -e "Done ${green}${char_succ}${reset}"

# Set up MacOS
echo -e '=============================================='
echo -e '=           ${yellow}Setting macOS defaults${reset}           ='
echo -e '=============================================='
sh macos
echo -e "Done ${green}${char_succ}${reset}"

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

if  [[ $dotfiles =~ ^[Yy]$   ]]; then
	doIt
fi
unset doIt

echo -e "Done ${green}${char_succ}${reset}"

# disable sleep
echo "Reenabling sleep"
sudo pmset -a sleep 1
sudo pmset -a hibernatemode 3
sudo pmset -a disablesleep 0

echo -e "All done ${green}${char_succ}${reset}, you should now reboot"
