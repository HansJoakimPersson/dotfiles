#  ---------------------------------------------------------------------------
#
#  Description:  This file holds all my zsh configurations
#
#  Sections:
#  1.  ZHS CONFIGURATION

#
#  ---------------------------------------------------------------------------

#   -------------------------------
#   1. ZHS CONFIGURATION
#   -------------------------------

#	Load the shell dotfiles
#   ------------------------------------------------------------
# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,exports,aliases,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

#   Change Prompt
#   ------------------------------------------------------------
PROMPT="%~$ => "
RPROMPT="%*"

#	Shell History
#   ------------------------------------------------------------

HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
SAVEHIST=100000
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY      # share history across multiple zsh sessions
setopt APPEND_HISTORY     # append to history
setopt INC_APPEND_HISTORY # adds commands as they are typed, not at shell exit
setopt HIST_VERIFY

#	Automatic CD
#   ------------------------------------------------------------

setopt AUTO_CD

#	Case Insensitive Globbing
#   ------------------------------------------------------------

setopt NO_CASE_GLOB

# 	Command Auto-Correction.
#   ------------------------------------------------------------
export SPROMPT="Correct $fg[red]%R$reset_color to $fg[green]%r$reset_color? [Yes, No, Abort, Edit] "
setopt CORRECT

#	Command Completions
#   ------------------------------------------------------------

# 	case insensitive path-completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# 	partial completion suggestions
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix

autoload -Uz compinit && compinit

#	Autosuggestions
#   ------------------------------------------------------------
FILE=/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

if [ -f "$FILE" ]; then
	bindkey $'^[[A' up-line-or-search   # up arrow
	bindkey $'^[[B' down-line-or-search # down arrow
	source "$FILE"
fi

#	Syntax highlighting
#   ------------------------------------------------------------
FILE=/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

if [ -f "$FILE" ]; then
	export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/usr/local/share/zsh-syntax-highlighting/highlighters
	source "$FILE"
fi
