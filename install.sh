#!/bin/bash

if [ `uname` == "Darwin" ]; then
  if [ -e "/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl" ]; then
    ln -fs "/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl
  fi
fi

mkdir -p ~/.virtualenvs/

ln -fs `pwd`/bash/bashrc ~/.bash_profile
ln -fs `pwd`/virtualenvwrapper/* ~/.virtualenvs/
ln -fs `pwd`/dotfiles/python/pythonrc.py ~/.pythonrc.py