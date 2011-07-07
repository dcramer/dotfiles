#!/bin/bash

if [ `uname` == "Darwin" ]; then
  if [ -e "/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl" ]; then
    echo "Installing 'subl' command"
    ln -fs "/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl
  fi
fi

mkdir -p ~/.virtualenvs/

echo "Installing .bash_profile"
ln -fs `pwd`/bash/bashrc ~/.bash_profile

echo "Installing virtualenvwrapper hooks"
ln -fs `pwd`/virtualenvwrapper/* ~/.virtualenvs/

echo "Installing .pythonrc.py"
ln -fs `pwd`/dotfiles/python/pythonrc.py ~/.pythonrc.py