My various dotfiles (works on Ubuntu and OS X).

Heavily inspired by Armin Ronacher :)

You will need Armin's vcprompt for the bash prompt: https://bitbucket.org/mitsuhiko/vcprompt

::

    git clone git://github.com/dcramer/dotfiles.git && cd dotfiles && make install

Useful helpers
--------------

The ``bin/`` directory is symlinked into ``~/.bin`` by ``make install-user``.
``make install`` also installs a daily user crontab entry that runs
``dotfiles-update-user-deps`` to refresh dotagents and related user-level agent
tooling. Its output is written to ``~/.cache/dotfiles/update-user-deps.log``.
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
