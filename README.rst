My various dotfiles (works on Ubuntu and OS X).

Heavily inspired by Armin Ronacher :)

You will need Armin's vcprompt for the bash prompt: https://bitbucket.org/mitsuhiko/vcprompt

::

    git clone git://github.com/dcramer/dotfiles.git && cd dotfiles && make install

Useful helpers
--------------

The ``bin/`` directory is symlinked into ``~/.bin`` by ``make install-user``.
One of the more useful maintenance scripts is ``disk-cleanup``:

::

    disk-cleanup
    disk-cleanup --run
    disk-cleanup --deep

On macOS, ``make install`` also installs ``~/Applications/Lock Screen.app``.
Spotlight indexes it, so ``Cmd-Space`` followed by ``lock`` provides a quick
Lock Screen launcher without logging out.

Docs
----

GitHub and commit-signing setup notes live in ``docs/github.md``.
