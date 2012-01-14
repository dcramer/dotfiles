#!/usr/bin/env python

# Inspired by https://github.com/dag/dotfiles/blob/master/python/.pythonrc

import atexit
import os
import readline
import rlcompleter

readline.parse_and_bind('tab: complete')
history = os.path.expanduser("~/.pythonhist")

def save_history(history=history):
    import readline
    readline.write_history_file(history)

if os.path.exists(history):
    try:
        readline.read_history_file(history)
    except IOError:
        pass

atexit.register(save_history)
del os, atexit, readline, rlcompleter, save_history, history