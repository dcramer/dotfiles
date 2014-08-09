set path (dirname (status -f))

# virtualfish
set -g VIRTUALFISH_COMPAT_ALIASES
. $path/virtualfish/virtual.fish
. $path/virtualfish/auto_activation.fish
. $path/virtualfish/global_requirements.fish
. $path/virtualfish/projects.fish
