#!/usr/bin/env python

# Inspired by https://github.com/dag/dotfiles/blob/master/python/.pythonrc

from __future__ import print_function

import os

def setup_history():
    import readline
    readline.parse_and_bind('tab: complete')
    history = os.path.expanduser("~/.pythonhist")

    if os.path.exists(history):
        try:
            readline.read_history_file(history)
        except IOError as e:
            print("Failed to read %r: %s" % (history, e))

    readline.set_history_length(1024 * 5)

    import atexit
    atexit.register(write_history(history))


def write_history(history):
    def wrapped():
        import readline
        readline.write_history_file(history)
    return wrapped


try:
    setup_history()
except ImportError:
    import traceback; traceback.print_exc()
