#!/usr/bin/env bash
# shellcheck shell=bash disable=SC1090,SC1091,SC2155

# Lets check which shell are running
if [ -n "$ZSH_VERSION" ]; then
  echo "This is probably not right for you, sourcing ~/.zshrc instead"
  source ~/.zshrc

elif [ -n "$BASH_VERSION" ]; then

  #--- LOAD DOTFILES ---------------------------------------------------------

  #   Load the shell dotfiles, and then some:
  #   * ~/.exports can be used to extend `$PATH`.
  #   * ~/.extra can be used for other settings you don’t want to commit.
  #   ------------------------------------------------------------
  for file in ~/.{exports,extra,functions,aliases,bash_prompt,}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
  done
  unset file

  #--- BASH HISTORY ----------------------------------------------------------
  # gotta tune that bash_history…

  # Enable history expansion with space
  # E.g. typing !!<space> will replace the !! with your last command
  bind Space:magic-space

  shopt -s histappend # Append to the Bash history file, rather than overwriting it
  shopt -s cmdhist    # Save multi-line commands as one command

  #--- BETTER `CD`'ING -------------------------------------------------------

  shopt -s nocaseglob           # Case-insensitive globbing (used in pathname expansion)
  shopt -s cdspell              # Autocorrect typos in path names when using `cd`
  shopt -s dirspell 2>/dev/null # Autocorrect on directory names to match a glob.

  # Enable some Bash 4 features when possible:
  # * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
  # * Recursive globbing, e.g. `echo **/*.txt`
  for option in autocd globstar; do
    shopt -s "$option" 2>/dev/null
  done

  #--- COMPLETION… -----------------------------------------------------------

  # Add tab completion for many Bash commands
  if which brew &>/dev/null && [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
    # Ensure existing Homebrew v1 completions continue to work
    export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
    source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
  elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion

  fi

  # Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
  [ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh

  # Add tab completion for `defaults read|write NSGlobalDomain`
  # You could just use `-g` instead, but I like being explicit
  complete -W "NSGlobalDomain" defaults

  # Add `killall` tab completion for common apps
  complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall

fi
