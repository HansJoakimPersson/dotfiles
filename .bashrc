#!/usr/bin/env bash
# shellcheck shell=bash disable=SC1090,SC1091,SC2155

# ---[ LOAD DOTFILES ]----------------------------------------------------------
# Load the shell dotfiles, and then some:
# * ~/.exports can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{exports,extra,functions,aliases,bash_prompt,}; do
  [[ -r "$file" && -f "$file" ]] && source "$file"
done
unset file

# ---[ BASH Options ]-----------------------------------------------------------

# Prefer US English and use UTF-8.
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Optimize Bash history behavior
bind Space:magic-space      # Use space to trigger history expansion, e.g., !! <space>
shopt -s histappend cmdhist # Enhance history file and multi-line command handling

# Increase Bash history size. Allow 32³ entries; the default is 500.
export HISTSIZE='32768'
export HISTFILESIZE="${HISTSIZE}"
export HISTCONTROL='ignoreboth' # Omit duplicates and commands that begin with a space from history.

# Use standard ISO 8601 timestamp
# %F equivalent to %Y-%m-%d
# %T equivalent to %H:%M:%S (24-hours format)
export HISTTIMEFORMAT='%F %T'

# Don't record some commands
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"

# Improve directory navigation and typo correction
shopt -s nocaseglob cdspell   # Case-insensitive globbing and typo correction
shopt -s dirspell 2>/dev/null # Autocorrect on directory names

# Set timestyle for ls
export TIME_STYLE=long-iso

# Add color to terminal http://www.bigsoft.co.uk/blog/2008/04/11/configuring-ls_colors
export LS_COLORS='no=00:rs=0:fi=00:di=01;34:ln=32:mh=04;36:pi=04;01;36:so=04;33:do=04;01;36:bd=01;33:cd=33:or=31:mi=01;37;41:ex=01;36:su=01;04;37:sg=01;04;37:ca=01;37:tw=01;37;44:ow=01;04;34:st=04;37;44:*.7z=01;32:*.ace=01;32:*.alz=01;32:*.arc=01;32:*.arj=01;32:*.bz=01;32:*.bz2=01;32:*.cab=01;32:*.cpio=01;32:*.deb=01;32:*.dz=01;32:*.ear=01;32:*.gz=01;32:*.jar=01;32:*.lha=01;32:*.lrz=01;32:*.lz=01;32:*.lz4=01;32:*.lzh=01;32:*.lzma=01;32:*.lzo=01;32:*.rar=01;32:*.rpm=01;32:*.rz=01;32:*.sar=01;32:*.t7z=01;32:*.tar=01;32:*.taz=01;32:*.tbz=01;32:*.tbz2=01;32:*.tgz=01;32:*.tlz=01;32:*.txz=01;32:*.tz=01;32:*.tzo=01;32:*.tzst=01;32:*.war=01;32:*.xz=01;32:*.z=01;32:*.Z=01;32:*.zip=01;32:*.zoo=01;32:*.zst=01;32:*.aac=32:*.au=32:*.flac=32:*.m4a=32:*.mid=32:*.midi=32:*.mka=32:*.mp3=32:*.mpa=32:*.mpeg=32:*.mpg=32:*.ogg=32:*.opus=32:*.ra=32:*.wav=32:*.3des=01;35:*.aes=01;35:*.gpg=01;35:*.pgp=01;35:*.doc=32:*.docx=32:*.dot=32:*.odg=32:*.odp=32:*.ods=32:*.odt=32:*.otg=32:*.otp=32:*.ots=32:*.ott=32:*.pdf=32:*.ppt=32:*.pptx=32:*.xls=32:*.xlsx=32:*.app=01;36:*.bat=01;36:*.btm=01;36:*.cmd=01;36:*.com=01;36:*.exe=01;36:*.reg=01;36:*~=02;37:*.bak=02;37:*.BAK=02;37:*.log=02;37:*.log=02;37:*.old=02;37:*.OLD=02;37:*.orig=02;37:*.ORIG=02;37:*.swo=02;37:*.swp=02;37:*.bmp=32:*.cgm=32:*.dl=32:*.dvi=32:*.emf=32:*.eps=32:*.gif=32:*.jpeg=32:*.jpg=32:*.JPG=32:*.mng=32:*.pbm=32:*.pcx=32:*.pgm=32:*.png=32:*.PNG=32:*.ppm=32:*.pps=32:*.ppsx=32:*.ps=32:*.svg=32:*.svgz=32:*.tga=32:*.tif=32:*.tiff=32:*.xbm=32:*.xcf=32:*.xpm=32:*.xwd=32:*.xwd=32:*.yuv=32:*.anx=32:*.asf=32:*.avi=32:*.axv=32:*.flc=32:*.fli=32:*.flv=32:*.gl=32:*.m2v=32:*.m4v=32:*.mkv=32:*.mov=32:*.MOV=32:*.mp4=32:*.mpeg=32:*.mpg=32:*.nuv=32:*.ogm=32:*.ogv=32:*.ogx=32:*.qt=32:*.rm=32:*.rmvb=32:*.swf=32:*.vob=32:*.webm=32:*.wmv=32:'

# Let there be color in grep!
export GREP_OPTIONS='--color=always'

# Set Default Editor (change 'Nano' to the editor of your choice)
export EDITOR='/usr/bin/nano'

# Set default blocksize for ls, df, du http://hints.macworld.com/comment.php?mode=view&cid=24491
export BLOCKSIZE='1k'

# Enable Bash 4 specific features, if available
if [[ ${BASH_VERSINFO[0]} -ge 4 ]]; then
  for option in autocd globstar; do
    shopt -s "$option" 2>/dev/null
  done
fi

# ---[ MAN PAGES ]--------------------------------------------------------------

# Don’t clear the screen after quitting a manual page.
export MANPAGER='less -X'

# highlighting inside manpages and elsewhere
export LESS_TERMCAP_mb=$(tput bold; tput setaf 2)               # begin blinking
export LESS_TERMCAP_md=$(tput bold; tput setaf 12)               # begin bold
export LESS_TERMCAP_me=$(tput sgr0)                             # end mode
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4) # begin standout-mode - info box
export LESS_TERMCAP_se=$(tput rmso;tput sgr0)                   # end standout-mode
export LESS_TERMCAP_us=$(tput smul; tput setaf 2)               # begin underline
export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)                  # end underline

# ---[ COMPLETION… ]------------------------------------------------------------
# Check if Homebrew is installed and if the bash_completion script is available and readable.
if command -v brew &>/dev/null && [[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]]; then

  # Ensure existing Homebrew v1 completions continue to work
  export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
  # Add tab completion support for many Bash commands installed via Homebrew.
  source "$(brew --prefix)/etc/profile.d/bash_completion.sh"

# If Homebrew isn't present, or its bash_completion isn't available,
# then check for the standard bash_completion file commonly found in Linux systems.
elif [[ -f /etc/bash_completion ]]; then
  source /etc/bash_completion
fi

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[[ -e "$HOME/.ssh/config" ]] && complete -o "default" -o "nospace" -W "$(awk '$1 == "Host" { for (i = 2; i <= NF; i++) if ($i !~ /\?|\*/) print $i }' ~/.ssh/config)" scp sftp ssh

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults

# `killall` tab completion for common apps
complete -o "nospace" -W "$(uname | grep -q 'Darwin' && echo "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" || echo "gnome-terminal nautilus")" killall

# ---[ FZF ]--------------------------------------------------------------------
# This section is dedicated to setting up fzf (a command-line fuzzy finder)
# For more information on fzf, see: https://github.com/junegunn/fzf

# Check if fzf command is available on the system
if command -v fzf >/dev/null 2>&1; then

  # Determine the parent directory of where fzf binary is located
  FZF_PATH=$(dirname "$(dirname "$(command -v fzf)")")

  # Add the 'bin' directory of FZF_PATH to the PATH variable, if it's not already there
  if [[ ! "$PATH" == *${FZF_PATH}/bin* ]]; then
    PATH="${PATH:+${PATH}:}/${FZF_PATH}/bin"
  fi

  # Load fzf auto-completion
  source "$(brew --prefix)/opt/fzf/shell/completion.bash" 2>/dev/null

  # Load the fzf key-bindings to enable special keyboard shortcuts for fzf
  source "$(brew --prefix)/opt/fzf/shell/key-bindings.bash"
fi