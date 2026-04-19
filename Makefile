IS_DARWIN := $(filter Darwin,$(shell uname))
IS_WSL := $(shell grep -qi microsoft /proc/version 2>/dev/null && echo 1)

install-user: install-virtualenvwrapper install-pythonrc \
		 install-bin install-git install-hg \
		 install-nuget install-zsh install-claude install-codex install-dotagents

install-global: install-user

install-git:
	ln -fs `pwd`/git/gitconfig ~/.gitconfig

install-hg:
	ln -fs `pwd`/hg/hgrc ~/.hgrc

install-bin:
	mkdir -p ~/.bin/
	ln -fs `pwd`/bin/* ~/.bin/

install-virtualenvwrapper:
	mkdir -p ~/.virtualenvs/
	ln -fs `pwd`/virtualenvwrapper/* ~/.virtualenvs/

install-pythonrc:
	ln -fs `pwd`/python/pythonrc.py ~/.pythonrc.py

install-fish:
	mkdir -p ~/.config/fish/
	ln -fs `pwd`/fish/config.fish ~/.config/fish/config.fish

install-zinit:
	mkdir -p ~/.local/share/zinit
	[ -d ~/.local/share/zinit/zinit.git/.git ] || git clone --depth=1 https://github.com/zdharma-continuum/zinit.git ~/.local/share/zinit/zinit.git
	zsh -lc 'source "$(CURDIR)/zsh/zinit_plugins.zsh"; source "$${XDG_DATA_HOME:-$$HOME/.local/share}/zinit/zinit.git/zinit.zsh"; dotfiles_prime_zinit_plugins'

bootstrap-zsh: install-zinit

install-zsh: install-zinit
	ln -fs `pwd`/zsh/zprofile ~/.zprofile
	ln -fs `pwd`/zsh/zshrc ~/.zshrc
	mkdir -p ~/.config/zsh_custom/themes/
	ln -fs `pwd`/zsh/themes/* ~/.config/zsh_custom/themes/

install-nuget:
	mkdir -p ~/.nuget
	wget -O ~/.nuget/nuget.exe https://dist.nuget.org/win-x86-commandline/latest/nuget.exe

install-ssh:
ifneq ($(or $(IS_DARWIN),$(IS_WSL)),)
	mkdir -p ~/.ssh
	ln -fs `pwd`/ssh/config ~/.ssh/config
	chmod 600 ~/.ssh/config
endif

install-claude:
	mkdir -p ~/.claude
	ln -fs `pwd`/claude/settings.json ~/.claude/settings.json
	ln -fs `pwd`/claude/statusline.sh ~/.claude/statusline.sh
	chmod +x ~/.claude/statusline.sh

install-codex:
	mkdir -p ~/.codex
	ln -fs `pwd`/codex/config.toml ~/.codex/config.toml

install-dotagents:
	pnpm dlx @sentry/dotagents --user install
