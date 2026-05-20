IS_DARWIN := $(filter Darwin,$(shell uname))
IS_WSL := $(shell grep -qi microsoft /proc/version 2>/dev/null && echo 1)
GIT_LOCAL_CONFIG ?= $(HOME)/.gitconfig.local
GIT_SIGNING_KEY ?= $(HOME)/.ssh/id_ed25519.pub
GIT_ALLOWED_SIGNERS ?= $(HOME)/.ssh/git_allowed_signers
GIT_SIGNING_KEY_TITLE ?= $(shell hostname) git signing

install-user: install-virtualenvwrapper install-pythonrc \
		 install-bin install-git install-hg \
		 install-nuget install-zsh install-claude install-dotagents

install-global: install-user

install-git:
	ln -fs `pwd`/git/gitconfig ~/.gitconfig

configure-git-signing:
	@test -f "$(GIT_SIGNING_KEY)" || (echo "Missing SSH public key: $(GIT_SIGNING_KEY)"; exit 1)
	git config --file "$(GIT_LOCAL_CONFIG)" --replace-all user.signingkey "$(GIT_SIGNING_KEY)"
	git config --file "$(GIT_LOCAL_CONFIG)" --replace-all gpg.ssh.allowedSignersFile "$(GIT_ALLOWED_SIGNERS)"
	@mkdir -p "$(dir $(GIT_ALLOWED_SIGNERS))"
	@awk -v email="$$(git config user.email)" '{print email, $$0}' "$(GIT_SIGNING_KEY)" > "$(GIT_ALLOWED_SIGNERS)"
	@echo "Configured Git signing key in $(GIT_LOCAL_CONFIG): $(GIT_SIGNING_KEY)"
	@echo "Configured SSH allowed signers file: $(GIT_ALLOWED_SIGNERS)"
	@echo "Add it to GitHub as a signing key with:"
	@echo "  gh ssh-key add $(GIT_SIGNING_KEY) --type signing --title \"$(GIT_SIGNING_KEY_TITLE)\""

setup-git-signing: configure-git-signing add-github-signing-key load-git-signing-key

add-github-signing-key:
	@if ! command -v gh >/dev/null 2>&1; then \
		echo "GitHub CLI is not installed; skipping GitHub signing key registration."; \
		echo "Add it later with:"; \
		echo "  gh ssh-key add $(GIT_SIGNING_KEY) --type signing --title \"$(GIT_SIGNING_KEY_TITLE)\""; \
	else \
		key="$$(awk '{print $$1 " " $$2}' "$(GIT_SIGNING_KEY)")"; \
		if gh api /user/ssh_signing_keys --jq '.[].key' 2>/dev/null | grep -Fx "$$key" >/dev/null; then \
			echo "GitHub signing key already exists: $(GIT_SIGNING_KEY_TITLE)"; \
		elif ! gh ssh-key add "$(GIT_SIGNING_KEY)" --type signing --title "$(GIT_SIGNING_KEY_TITLE)"; then \
			echo ""; \
			echo "If GitHub reported a missing scope, run:"; \
			echo "  gh auth refresh -h github.com -s admin:ssh_signing_key"; \
			echo "Then rerun:"; \
			echo "  make setup-git-signing"; \
			exit 1; \
		fi; \
	fi

load-git-signing-key:
ifeq ($(IS_DARWIN),Darwin)
	ssh-add --apple-use-keychain "$(patsubst %.pub,%,$(GIT_SIGNING_KEY))"
else
	ssh-add "$(patsubst %.pub,%,$(GIT_SIGNING_KEY))"
endif

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

install-dotagents:
	mkdir -p ~/.agents
	ln -fs `pwd`/agents/agents.toml ~/.agents/agents.toml
	pnpm dlx @sentry/dotagents --user install
