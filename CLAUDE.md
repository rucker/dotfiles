# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal dotfiles repository managed using [Dotfiles Manager](https://github.com/rucker/dotfiles-manager). The repository contains configuration files for bash, git, vim, tmux, IdeaVim, Emacs (Doom), and other Unix tools.

## Architecture

### Dotfiles Manager Integration

The repository uses a custom wrapper script (`dotfiles.sh`) around the Dotfiles Manager tool (`dfm`). The key architectural components:

1. **Source Files**: All dotfiles live in `src/` with numeric prefixes for ordering (e.g., `95-bashrc`, `97-bashrc`, `99-gitconfig`)
2. **OS-Specific Files**: Files with `_linux`, `_mac`, or `_win` suffixes are conditionally excluded based on the OS
3. **Local Overrides**: Files ending in `_local` are excluded from repository updates and can be used for machine-specific configurations
4. **Compilation**: The wrapper script compiles dotfiles from `src/` to both `$HOME` (as symlinks) and the repo root (as copies for version control)

### File Organization

- `src/95-bashrc` - Early bash configuration (sourced first)
- `src/97-bashrc` - Main bash configuration with custom functions and aliases
- `src/99-bashrc` - Late bash configuration (sourced last)
- `src/99-gitconfig` - Git configuration
- `src/scripts/sourced/` - Bash scripts sourced during shell initialization (e.g., git-prompt.sh, extract.sh)
- `src/doom.d/` - Doom Emacs configuration files (config.el, init.el, packages.el)
- `src/backups/` - Backup directory for dotfiles

Numbered prefixes control source order - lower numbers are sourced first.

### Key Functions in 97-bashrc

Custom bash functions defined:
- `git-clone`: Wraps `git clone` and automatically changes to the cloned directory
- `git-push`: Intelligent push that prompts to set upstream branch if needed
- `up [n]`: Navigate up n directories (default 1)
- `mkcd`: Create directory and cd into it
- `mvcd`: Move file(s) to directory and cd into it
- `latest [dir] [n]`: Show n most recently modified files in dir
- `psgrep`: Search running processes with color highlighting
- `__tmux-attach`: Auto-attach to tmux sessions on non-SSH login

## Common Commands

### Dotfiles Management

```bash
# Install dotfiles-manager and set up symlinks
./dotfiles.sh --install

# Update dotfiles from repo to home directory (with automatic git pull)
./dotfiles.sh --sync

# Update dotfiles without pulling latest changes
./dotfiles.sh --sync --no-pull

# Check which dotfiles would be updated
./dotfiles.sh --dry-run
```

Note: On macOS, requires GNU `readlink` and `realpath` from Homebrew's `coreutils` package.

### Git Aliases

The gitconfig defines these commonly-used aliases:
- `git lg [n]` - Show colorized graph log (default 20 commits)
- `git st` - Status
- `git co` - Checkout
- `git br` - Branch
- `git ls` - Show commit stats
- `git upd` - Stash, pull, stash pop
- `git cm` - Commit with message
- `git cam` - Commit all with message
- `git cane` - Commit amend without editing message

### Editing Dotfiles

When modifying dotfiles:
1. Edit files in `src/` directory (never edit the root copies directly)
2. For machine-specific config, create a `*_local` file (e.g., `src/95-bashrc_local`)
3. Run `./dotfiles.sh --sync` to update both home directory and repo root
4. Commit changes from the `src/` directory

## Configuration Details

### Bash Configuration Loading Order

1. `src/95-bashrc` - First
2. OS-specific bashrc (e.g., `src/96-bashrc_linux`)
3. `src/97-bashrc` - Main configuration
4. OS-specific late bashrc (e.g., `src/98-bashrc_mac`)
5. `src/99-bashrc` - Last
6. Local overrides (`*_local` files)
7. Scripts in `src/scripts/sourced/`

### Git Configuration

- Default editor: vim
- Default merge tool: vimdiff with diff3 conflict style
- Pull strategy: rebase
- Global gitexclude: `~/.gitexclude`
- Pager: `less -F` (auto-exit if one screen)

### Important Patterns

- The `__present` function checks if a command exists
- The `__do_alias` function creates aliases only if the command exists
- The `__running_in_docker` function detects Docker environments
- PS1 prompt includes timestamp, user@host, working directory, and git branch (if in a repo)
