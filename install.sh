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

if [ -e "$HOME/.bashrc" ]; then
  echo "WARNING: $HOME/.bashrc already exists, not symlinking to ~/.bash_profile"
else
  ln -fs ~/.bash_profile ~/.bashrc
fi

echo "Installing virtualenvwrapper hooks"
ln -fs `pwd`/virtualenvwrapper/* ~/.virtualenvs/

echo "Installing .pythonrc.py"
ln -fs `pwd`/python/pythonrc.py ~/.pythonrc.py

source ~/.bashrc