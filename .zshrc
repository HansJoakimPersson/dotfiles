#!/usr/bin/env zsh

# ---[ LOAD DOTFILES ]----------------------------------------------------------
# Load various configuration files
for file in ~/.{path,extra,functions,aliases}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# ---[ Prompt ]-----------------------------------------------------------
# Primary prompt with git info
PROMPT='%~$%F{green}${vcs_info_msg_0_}%f=> '

# Secondary prompt
RPROMPT='%F{yellow}→ %f'

# ---[ ZSH Options ]------------------------------------------------------------

# Autocorrect command typos
export SPROMPT="Correct $fg[red]%R$reset_color to $fg[green]%r$reset_color? [Yes, No, Abort, Edit] "
setopt CORRECT # Enable more controlled command auto-correction

# General settings
setopt AUTO_CD              # Allows changing directories without 'cd'
setopt EXTENDED_GLOB        # Enables advanced pattern matching
setopt CD_ABLE_VARS         # Variables can be directories in paths
setopt MULTIOS              # Multiple I/O streams for one command
setopt NO_BEEP              # Prevents terminal beep on errors
setopt CLOBBER              # Overwrite files with redirection instead of appending
setopt INTERACTIVE_COMMENTS # Allows comments in interactive shell with '#'

# History settings
setopt APPEND_HISTORY         # Appends commands to the history list
setopt EXTENDED_HISTORY       # Records timestamps of commands
setopt HIST_EXPIRE_DUPS_FIRST # Older duplicate commands are removed first
setopt HIST_FIND_NO_DUPS      # No consecutive duplicates in history
setopt HIST_IGNORE_DUPS       # Ignores repeated commands in history
setopt HIST_IGNORE_SPACE      # Commands starting with space aren't saved in history
setopt HIST_NO_FUNCTIONS      # Functions aren't added to history
setopt HIST_NO_STORE          # Commands aren't automatically stored in history
setopt HIST_REDUCE_BLANKS     # Removes extra blanks from saved commands
setopt HIST_SAVE_NO_DUPS      # No duplicates in saved history file
setopt HIST_VERIFY            # Show expanded history before execution
setopt INC_APPEND_HISTORY     # Commands are immediately appended to history file
setopt NO_HIST_BEEP           # No beep when accessing history
setopt SHARE_HISTORY          # Shares history across all active sessions

HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history # Location of history file
HISTSIZE=100000                         # Max commands in memory
SAVEHIST=100000                         # Max commands saved to history file

# ---[ Plugins and Completion System ]-----------------------------------

# Initialize Zsh's built-in completion system
autoload -Uz compinit -C && compinit -C
zmodload -i zsh/complist

# Configure completion system
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh_cache/
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'l:|=* r:|=*'
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix

# ---[ Autosuggestions ]-------------------------------------------------
# Assumes zsh-autosuggestions plugin is installed
FILE=/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
if [ -f "$FILE" ]; then
  bindkey $'^[[A' up-line-or-search
  bindkey $'^[[B' down-line-or-search
  source "$FILE"
fi

# ---[ Syntax Highlighting ]---------------------------------------------
# Assumes zsh-syntax-highlighting plugin is installed
FILE=/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
if [ -f "$FILE" ]; then
  export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/usr/local/share/zsh-syntax-highlighting/highlighters
  source "$FILE"
fi

# ---[ FZF Setup ]-------------------------------------------------------
if command -v fzf >/dev/null 2>&1; then
  FZF_PATH=$(dirname "$(dirname "$(command -v fzf)")")
  if [[ ! "$PATH" == *${FZF_PATH}/bin* ]]; then
    PATH="${PATH:+${PATH}:}/${FZF_PATH}/bin"
  fi
  [[ $- == *i* ]] && source "$(brew --prefix)/opt/fzf/shell/completion.zsh" 2>/dev/null
  source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
fi

# ---[ Git Prompt via vcs_info ]------------------------------------------------

# Autoload zsh add-zsh-hook and vcs_info functions
autoload -Uz add-zsh-hook vcs_info

# Enable substitution in the prompt.
setopt prompt_subst

# Run vcs_info just before a prompt is displayed (precmd)
add-zsh-hook precmd vcs_info

# Configure vcs_info
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr ' *'
zstyle ':vcs_info:*' stagedstr ' +'
zstyle ':vcs_info:git:*' formats       '(%b%u%c)'
zstyle ':vcs_info:git:*' actionformats '(%b|%a%u%c)'

#   Powerlevel10k theme
#   ------------------------------------------------------------
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc. Initialization code that may require console input (password prompts, [y/n] confirmations, etc.) must go above this block; everything else may go below.
#if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#fi

# FILE=/usr/local/opt/powerlevel10k/powerlevel10k.zsh-theme
# if [ -f "$FILE" ]; then
# source "$FILE"

# # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# POWERLEVEL9K_TIME_ICON=''
# #POWERLEVEL9K_VCS_BACKGROUND='70'
# POWERLEVEL9K_VCS_GIT_GITHUB_ICON=''
# POWERLEVEL9K_VCS_GIT_ICON=''

# fi
