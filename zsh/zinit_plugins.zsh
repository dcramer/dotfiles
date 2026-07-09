# Shared Zinit plugin declarations for shell startup and bootstrap.

dotfiles_load_zinit_plugins() {
  (( ${+functions[zinit]} )) || return

  # The OMZ git plugin relies on helpers from the git library.
  zinit snippet OMZL::git.zsh

  zinit snippet OMZP::git
  zinit snippet OMZP::command-not-found
  zinit snippet OMZP::docker
  zinit snippet OMZP::dotenv
  zinit snippet OMZP::pip
  zinit snippet OMZP::python
  zinit snippet OMZP::pyenv
  zinit snippet OMZP::sudo
  zinit snippet OMZP::vscode
  zinit snippet OMZP::z

  zinit light zsh-users/zsh-completions
  zinit light zsh-users/zsh-history-substring-search
  zinit light zsh-users/zsh-autosuggestions
}

dotfiles_load_zinit_syntax_highlighting() {
  (( ${+functions[zinit]} )) || return
  (( ${+functions[_zsh_highlight]} )) && return
  zinit light zsh-users/zsh-syntax-highlighting
}

dotfiles_prime_zinit_plugins() {
  dotfiles_load_zinit_plugins
  dotfiles_load_zinit_syntax_highlighting
}
