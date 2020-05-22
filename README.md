# Dotfiles

This repository works helps me configure and maintain my Mac. It simplifies the effort of install my preferred MacOS flavour manually. Feel free to explore, learn and copy parts to your own dotfiles. Enjoy! :smile:

## Installation

**Warning:** If you want to give these dotfiles a try, you should first fork this repository, review the code, and remove things you don’t want or need. Don’t blindly use my settings unless you know what that entails. Use at your own risk!

To install and setup your MacOS:

```bash
bash <(curl -s https://raw.githubusercontent.com/HansJoakimPersson/dotfiles/master/bootstrap.sh)
```

To update, `cd` into your local `dotfiles` repository and rerun:

```bash
sh bootstrap.sh
```

The setup script is smart enough to back up your existing dotfiles into a
`~/dotfiles_old/` directory if you already have any dotfiles of the same name as the dotfile symlinks being created in your home directory.

### Add custom commands without creating a new fork

If `~/.extra` exists, it will be sourced along with the other files. You can use this to add a few custom commands without the need to fork this entire repository, or to add commands you don’t want to commit to a public repository.

My `~/.extra` looks something like this:

```bash
# Git credentials
# Not in the repository, to prevent people from accidentally committing under my name
GIT_AUTHOR_NAME="Joakim Persson"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
git config --global user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="mail@mailinator.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.email "$GIT_AUTHOR_EMAIL"
```

You could also use `~/.extra` to override settings, functions and aliases from my dotfiles repository. It’s probably better to [fork this repository](https://github.com/mathiasbynens/dotfiles/fork) instead, though.

## Aliases and Functions
To keep things easy, the `~/.bashrc` and `~/.bash_profile` files are extremely simple, and should never need to be modified. Instead, add your aliases, functions, settings, etc into corresponding file. They're all automatically sourced when a new shell is opened. Take a look, I have [a lot of aliases and functions](source). I even have a [fancy prompt](.bash_prompt) that shows the current directory, time and current git/svn repo status.

## ¯\\_(ツ)_/¯ Warning / Liability
> Warning:
The creator of this repo is not responsible if your machine ends up in a state you are not happy with. If you are concerned, look at the code to review everything this will do to your machine :)

## Feedback

Suggestions/improvements
[welcome](https://github.com/HansJoakimPersson/dotfiles/issues)!

## Thanks to…

I first got the idea for starting this project by visiting the [Github does dotfiles](https://dotfiles.github.io/) project. Both [Zach Holman](https://github.com/holman/dotfiles) and [Mathias Bynens](https://github.com/mathiasbynens/dotfiles) were great sources of inspiration.

* [Mathias Bynens](https://mathiasbynens.be/) and his [dotfiles repository](https://github.com/mathiasbynens/dotfiles) , which helped a lot with configuring macOS settings. Mathias’ macOS defaults script is legendary and many people include a version of his configuration file in their own macOS dotfiles.
* [Dries Vints](https://github.com/driesvints), his [dotfiles repository](https://github.com/driesvints/dotfiles) and associated [blog post](https://driesvints.com/blog/getting-started-with-dotfiles/)
*[Paul Irish](https://github.com/paulirish) and his [dotfiles repository](https://github.com/paulirish/dotfiles)
*[Zach Holman](https://github.com/holman), his [dotfiles repository](https://github.com/holman/dotfiles) and associated [blog post](https://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked/)
*[Peter T Bosse](https://github.com/ptb) and his [mac-setup.command](https://github.com/ptb/mac-setup/blob/develop/mac-setup.command), its massive!
* [Ben Alman](http://benalman.com/) and his [dotfiles repository](https://github.com/cowboy/dotfiles)

## License

The MIT License. Please see [the license file](license.md) for more information.
