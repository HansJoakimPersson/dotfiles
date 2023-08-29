#!/usr/bin/env bash
# shellcheck shell=bash disable=SC1090

# Lets check which shell are running
if [[ -n "$ZSH_VERSION" ]]; then
  echo "This is probably not right for you, sourcing ~/.zshrc instead"
  source ~/.zshrc

elif [[ -n "$BASH_VERSION" ]]; then
  # Source the .bashrc if it exists
  [[ -f ~/.bashrc ]] && source ~/.bashrc
fi