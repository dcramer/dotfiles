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

bootstrap-zsh:
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
ifdef IS_DARWIN
	brew install antidote
else
	git clone --depth=1 https://github.com/mattmc3/antidote.git ~/.antidote
endif

install-zsh:
	mkdir -p `pwd`/.oh-my-zsh/
	ln -fs `pwd`/zsh/zshrc ~/.zshrc
	# TODO(dcramer): there must be a better way to do specify my own theme?
	# [ -e ~/.oh-my-zsh ] && ln -fs `pwd`/zsh/themes/* ~/.oh-my-zsh/themes/
	mkdir -p ~/.config/zsh_custom/themes/
	ln -fs `pwd`/zsh/themes/* ~/.config/zsh_custom/themes/
	ln -fs `pwd`/zsh/zsh_plugins ~/.config/zsh_plugins
	# mkdir -p ~/.zsh-extras/
	# [ ! -e ~/.zsh-extras/zsh-autosuggestions ] && git clone git://github.com/tarruda/zsh-autosuggestions ~/.zsh-extras/zsh-autosuggestions

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
