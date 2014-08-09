# Path to your oh-my-fish.
set fish_path $HOME/.oh-my-fish

# Theme
set fish_theme edan

# Enable plugins
set fish_plugins git brew python sublime rvm node

# virtualfish
set vfishpath (dirname (status -f))

set -g VIRTUALFISH_COMPAT_ALIASES
. $vfishpath/virtualfish/virtual.fish
. $vfishpath/virtualfish/auto_activation.fish
. $vfishpath/virtualfish/global_requirements.fish
. $vfishpath/virtualfish/projects.fish

# Load oh-my-fish configuration.
. $fish_path/oh-my-fish.fish
