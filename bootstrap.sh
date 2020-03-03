#!/usr/bin/env bash
# shellcheck disable=SC2059
# shellcheck disable=SC2162

###############################################################################
# Strict Mode
###############################################################################
# Set strict mode -  via http://redsymbol.net/articles/unofficial-bash-strict-mode/
# Return value of a pipeline is the value of the last (rightmost) command to
# exit with a non-zero status, or zero if all commands in the pipeline exit
# successfully.

# Print a helpful message if a pipeline with non-zero exit code causes the
# script to exit as described above.
#trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR

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
readonly _PROGAUTH=""
readonly _PROGDATE=$(stat -f "%Sm" "$0" 2>/dev/null)          # for MacOS

# Reset
readonly col_reset="\x1b[0m" # Text Reset

# Foreground color
readonly col_green="\x1b[32m"
readonly col_yellow="\x1b[33m"
readonly col_red="\x1b[31m"

# Special characters
readonly char_succ="✔"
readonly char_fail="✖"

execute() {
	printf "\n ⇒ ${@/eval/} "
	if
		("$@ >/dev/null 2>&1") &
		spinner "$!"
	then
		ok
	else
		error
	fi
}

spinner() {
	local i sp n
	sp="\|/-"
	n=${#sp}
	while ps a | awk '{print $1}' | grep -q "${1}"; do
		sleep "0.75"
		#printf "\b${sp:i++%${#sp}:1}"
		printf "%s\b" "${sp:i++%n:1}"
	done
}
error() {
	printf "${col_red}${char_fail}${col_reset}"
}

ok() {
	printf "${col_green}${char_succ}${col_reset}"
}

###############################################################################
# Main script
###############################################################################

printf "================================================================================\n"
printf "=                            Setting up your Mac...                            =\n"
printf "================================================================================\n"
printf "Program: ${col_green}$_PROGFNAME${col_reset} by ${col_yellow}$_PROGAUTH${col_reset}\n"
printf "Updated: ${col_green}$_PROGDATE${col_reset}\n"

# Revoke any previous sudo access
sudo -k

# Ask for the administrator password upfront
printf "\nSome settings require sudo to change. "
sudo -v

# Please give me some answers
read  -p "Change hostname for ${HOSTNAME}: (Enter to skip):"  hostname
read  -p "Adding files to home folder may overwrite existing files. Are you sure? (y/N) " dotfiles

clear

# Coffee art
printf "$(base64 --decode <<<'H4sIAKGEWV4A/7VYPZPiMAzt7y9ccz8BloXdHUom5c4wTLrb6vpcfT9/rTiA9fRlxzkXMBDHfnqSniX/yuPn17/9n9+vH9PyW4w84fB+Pp5fDsfpmkf4Gi6wO++mr79Vm+KOz9kKlgYgK8DIDR0w5UK2DZuD9DA2PmxB+V9B3kctoF4wrl/ZqEDUHWPaiPbtzjJrO3VegKYZTIXO+E6LHm8EUsfpJX70dFuQdbG0kfucyFj+PN2Fb/n9Nn1eij+O79NlGIo/Pl6nWxrjDSbxKePIJszLihn2CgQL5t/SC2PamL9UIqNNcBFumynyVWxaYaNunhCXj/eHHTNo//YyDQMROY9hSCSXttB8tn5+AWZcrrjmY8W0po0G6TWZqeHFpWW2Gz2JPkzWI5McXUILZMu8QcczajD+clRjXA8lMNVjasRuQJmdCQ+nlv+dTnwOQCVvM/eL7OJsZIJdfpHdiFwk1s0FNEcxmQTD14fy8bwDW1LZ4uJOeGIsjq4ur7Lk5amaFQCT+/KZBkdJsAvZEIFBrzkxi8+JNkdQyXOMVlqOBdYsU73coHRKcrwBcc4PBPXE49GajdJJ6hG+edkVNsjklFW/Lt1mCKyyznUZ5lu9x/wD2zWVwjEQaDz0FpAdlqLSNPjVky9hqBehWlYblj6r8J5ihg7pNe7lzlWqLz8VsWYitRNyAyfN8rhapGvqlRWmO0tghiIxUnTDMsTjRJR6So7Jdqe9kQgltSZeZEGLZUxj1bq6LWo5qxsDIKy+RAva2FhunctuMGtZ3dFUhR1qM369PHE1SW25I/gtJc1cA4+j7Iyg1RbVy3oi7NNHEZzGZqGKQ5c/J93IZ7x453ISHKt+K2XKkuMIs9iJ1Mu5IrFZNGkrOgDrzMV4h4rJEVAVlNJV1fDpNxwOKbJtA2ubhamdzobI15rOoPnCm5DgBiy8wkCJqWiK8v1d5FfKiGW5wAZHWcwgr5UGpeK/MlJYCLYcwXCFoZCZ5Frcx91HbszpM32JlBAhjUETud1S1/oSv6Wj0eKDX85m45OxaAjdx/JbtHydJy7WHncWbreu3PsFt34rCtna+/e6O/ly0x/fsxsVXa8dAAA=' | gunzip)"
printf "\n  From this point on it should be an automated process, go grab a coffee! "

secs=$((5))
while [ $secs -gt 0 ]; do
	printf "%s\b" "$secs"
	sleep 1
	: $((secs--))
done
printf " \b"

# If we're using APFS, make a snapshot before doing anything.
# if    [[ -n "$(  mount | grep '/ (apfs')" ]]; then
# 	printf "\n\n${col_yellow}Taking local APFS snappshot${col_reset} "
# 	execute eval "sudo tmutil localsnapshot"
# fi

# disable sleep
printf "\n\n${col_yellow}Temporary disabling sleep${col_reset}"
execute eval "sudo pmset -a sleep 0"
execute eval "sudo pmset -a hibernatemode 0"
execute eval "sudo pmset -a disablesleep 1"
# Set hostname
if  [[ -n $hostname     ]]; then
	#Set computer name (as done via System Preferences → Sharing)
	printf "\n\n${col_yellow}Setting hostname to${col_reset} \"$hostname\""
	execute eval "sudo scutil --set ComputerName ${hostname} &&"
	execute eval "sudo scutil --set HostName ${hostname} &&"
	execute eval "sudo scutil --set LocalHostName ${hostname} &&"
	execute eval "sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string ${hostname}"

fi

# Check for Homebrew and install if we don't have it
printf "\n\n${col_yellow}Checking homebrew${col_reset} "
if test ! "$(command -v brew)"; then
	printf "\n ⇒  downloading and installing Homebrew "
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	if [[ $? != 0 ]]; then
		error "unable to install homebrew, script $0 abort!"
		exit 2
	fi
	brew analytics off
	ok
else
	printf "\n ⇒  Homebrew are already installed "
	ok
fi

# Check if this already is a git repository of my dot files
if git remote -v 2>/dev/null  | grep -q 'https://github.com/HansJoakimPersson/dotfiles'; then
	printf "\n\n${col_yellow}Pull in the latest version of this git repository${col_reset}"
	execute eval "git pull origin master"
else
	printf "\n\n${col_yellow}Clone the latest version of this git repository${col_reset}"
	execute eval "git clone https://github.com/HansJoakimPersson/dotfiles"
	#cd dotfiles
fi

# Install packages from homebrew
sh brew
exit
# Set up MacOS
printf "\n\n${col_yellow}Updating system configuration${col_reset}"
#sh macos

# Adding dotfiles to home folder
if  [[ $dotfiles =~ ^[y|yes|Y]$   ]]; then
	printf "\n\n${col_yellow}Adding dotfiles to home folder${col_reset}\n ⇒ "

	rsync --exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude "bootstrap.sh" \
		--exclude "README.md" \
		--exclude "brew" \
		--exclude "macos" \
		--exclude "LICENSE-MIT.txt" \
		--filter="+ .*" \
		--filter="- *" \
		-avh --no-perms -c --backup --backup-dir="backup_$(date +"%Y-%m-%d %H.%M.%S")" . ~/dofiles

	printf "\n${col_yellow}Loading new .bash_profile${col_reset}"
	execute eval "source ~/.bash_profile"
fi

# reenabling sleep
printf "\n\n${col_yellow}Reenabling sleep${col_reset}"
execute eval "sudo pmset -a sleep 1"
execute eval "sudo pmset -a hibernatemode 3"
execute eval "sudo pmset -a disablesleep 0"

printf "\n\nAll done, you should now reboot!\n\n"
