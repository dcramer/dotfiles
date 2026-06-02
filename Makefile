IS_DARWIN := $(filter Darwin,$(shell uname))
IS_WSL := $(shell grep -qi microsoft /proc/version 2>/dev/null && echo 1)
GIT_LOCAL_CONFIG ?= $(HOME)/.gitconfig.local
GIT_SIGNING_KEY ?= $(HOME)/.ssh/id_ed25519.pub
GIT_ALLOWED_SIGNERS ?= $(HOME)/.ssh/git_allowed_signers
GIT_SIGNING_KEY_TITLE ?= $(shell hostname) git signing
MACOS_LOCK_SCREEN_APP ?= $(HOME)/Applications/Lock Screen.app
MACOS_LOCK_SCREEN_SOURCE_APP := $(CURDIR)/macos/apps/Lock Screen.app
MACOS_LOCK_SCREEN_HELPER := $(MACOS_LOCK_SCREEN_APP)/Contents/MacOS/lock-screen-helper
MACOS_LSREGISTER := /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister

install: install-user

install-user: install-virtualenvwrapper install-pythonrc \
		 install-bin install-git install-hg \
		 install-nuget install-zsh install-claude install-dotagents \
		 install-macos-lock-screen

install-global: install-user

install-git:
	ln -fs `pwd`/git/gitconfig ~/.gitconfig

configure-git-signing:
	@test -f "$(GIT_SIGNING_KEY)" || (echo "Missing SSH public key: $(GIT_SIGNING_KEY)"; exit 1)
	git config --file "$(GIT_LOCAL_CONFIG)" --replace-all user.signingkey "$(GIT_SIGNING_KEY)"
	git config --file "$(GIT_LOCAL_CONFIG)" --replace-all gpg.ssh.allowedSignersFile "$(GIT_ALLOWED_SIGNERS)"
	git config --file "$(GIT_LOCAL_CONFIG)" --replace-all commit.gpgsign true
	git config --file "$(GIT_LOCAL_CONFIG)" --replace-all tag.gpgSign true
	@mkdir -p "$(dir $(GIT_ALLOWED_SIGNERS))"
	@awk -v email="$$(git config user.email)" '{print email, $$0}' "$(GIT_SIGNING_KEY)" > "$(GIT_ALLOWED_SIGNERS)"
	@echo "Configured Git signing key in $(GIT_LOCAL_CONFIG): $(GIT_SIGNING_KEY)"
	@echo "Configured SSH allowed signers file: $(GIT_ALLOWED_SIGNERS)"
	@echo "Add it to GitHub as a signing key with:"
	@echo "  gh ssh-key add $(GIT_SIGNING_KEY) --type signing --title \"$(GIT_SIGNING_KEY_TITLE)\""

repair-git-signing: install-git load-git-signing-key configure-git-signing check-git-signing

setup-git-signing: install-git load-git-signing-key configure-git-signing add-github-signing-key check-git-signing

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
	@test -f "$(patsubst %.pub,%,$(GIT_SIGNING_KEY))" || (echo "Missing SSH private key: $(patsubst %.pub,%,$(GIT_SIGNING_KEY))"; exit 1)
ifeq ($(IS_DARWIN),Darwin)
	ssh-add --apple-use-keychain "$(patsubst %.pub,%,$(GIT_SIGNING_KEY))"
else
	ssh-add "$(patsubst %.pub,%,$(GIT_SIGNING_KEY))"
endif

check-git-signing:
	@status=0; \
	gpg_format="$$(git config --get gpg.format 2>/dev/null || true)"; \
	if [ "$$gpg_format" = "ssh" ]; then \
		echo "ok: gpg.format=ssh"; \
	else \
		echo "missing: gpg.format=ssh"; \
		status=1; \
	fi; \
	commit_signing="$$(git config --bool --get commit.gpgsign 2>/dev/null || true)"; \
	if [ "$$commit_signing" = "true" ]; then \
		echo "ok: commit.gpgsign=true"; \
	else \
		echo "missing: commit.gpgsign=true"; \
		status=1; \
	fi; \
	tag_signing="$$(git config --bool --get tag.gpgsign 2>/dev/null || true)"; \
	if [ "$$tag_signing" = "true" ]; then \
		echo "ok: tag.gpgSign=true"; \
	else \
		echo "missing: tag.gpgSign=true"; \
		status=1; \
	fi; \
	signing_key="$$(git config --get user.signingkey 2>/dev/null || true)"; \
	signing_key_path="$$signing_key"; \
	case "$$signing_key" in "~/"*) signing_key_path="$(HOME)/$${signing_key#~/}";; esac; \
	if [ -n "$$signing_key" ] && [ -f "$$signing_key_path" ]; then \
		echo "ok: user.signingkey=$$signing_key"; \
	else \
		echo "missing: user.signingkey file"; \
		status=1; \
	fi; \
	allowed_signers="$$(git config --get gpg.ssh.allowedSignersFile 2>/dev/null || true)"; \
	allowed_signers_path="$$allowed_signers"; \
	case "$$allowed_signers" in "~/"*) allowed_signers_path="$(HOME)/$${allowed_signers#~/}";; esac; \
	if [ -n "$$allowed_signers" ] && [ -f "$$allowed_signers_path" ]; then \
		echo "ok: gpg.ssh.allowedSignersFile=$$allowed_signers"; \
	else \
		echo "missing: gpg.ssh.allowedSignersFile"; \
		status=1; \
	fi; \
	if ssh-add -l >/dev/null 2>&1; then \
		echo "ok: SSH agent has identities"; \
	else \
		echo "missing: SSH agent identity; run make load-git-signing-key"; \
		status=1; \
	fi; \
	exit $$status

verify-git-signing: check-git-signing
	@tmp="$$(mktemp -d)"; \
	trap 'rm -rf "$$tmp"' EXIT INT TERM; \
	git -C "$$tmp" init -q; \
	git -C "$$tmp" commit --allow-empty -m "test signed commit" >/dev/null; \
	git -C "$$tmp" log --show-signature -1 --format="ok: signed test commit %h (%G?)"

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

install-macos-lock-screen:
ifeq ($(IS_DARWIN),Darwin)
	@mkdir -p "$(HOME)/Applications"
	@/usr/bin/ditto "$(MACOS_LOCK_SCREEN_SOURCE_APP)" "$(MACOS_LOCK_SCREEN_APP)"
	@chmod +x "$(MACOS_LOCK_SCREEN_APP)/Contents/MacOS/lock-screen"
	@if command -v clang >/dev/null 2>&1; then \
		clang -F /System/Library/PrivateFrameworks -framework login \
			-o "$(MACOS_LOCK_SCREEN_HELPER)" "$(CURDIR)/macos/lock-screen/lock-screen.c"; \
	else \
		echo "clang not found; Lock Screen.app will use display-sleep fallback."; \
	fi
	@/usr/bin/plutil -lint "$(MACOS_LOCK_SCREEN_APP)/Contents/Info.plist" >/dev/null
	@if [ -x "$(MACOS_LSREGISTER)" ]; then \
		"$(MACOS_LSREGISTER)" -f "$(MACOS_LOCK_SCREEN_APP)" >/dev/null 2>&1 || true; \
	fi
	@echo "Installed $(MACOS_LOCK_SCREEN_APP)"
	@echo "Use Spotlight: Cmd-Space, type Lock Screen, Return."
else
	@true
endif

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
	npx --yes agent-browser@latest install
