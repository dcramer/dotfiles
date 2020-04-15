install-user: install-bash install-virtualenvwrapper install-pythonrc \
		 install-subl install-bin install-vcprompt install-git install-hg \
		 install-fish install-nuget install-ssh

install-global: install-user install-ssh

install-vcprompt:
	@rm -rf /tmp/vcprompt
	@mkdir -p /tmp/vcprompt
	@cd /tmp/vcprompt && curl -OL https://bitbucket.org/mitsuhiko/vcprompt/get/default.tar.gz && \
	    tar zxf default.tar.gz && cd mitsuhiko-* && make && \
	    echo "Installing vcprompt to /usr/local/bin/vcprompt" && sudo mv vcprompt /usr/local/bin/vcprompt
	@rm -rf /tmp/vcprompt

install-git:
	ln -fs `pwd`/git/gitconfig ~/.gitconfig
	curl -o ~/.git-completion.bash https://github.com/git/git/raw/master/contrib/completion/git-completion.bash -OL

install-hg:
	ln -fs `pwd`/hg/hgrc ~/.hgrc

install-bin:
	mkdir -p ~/.bin/
	ln -fs `pwd`/bin/* ~/.bin/

install-bash:
	ln -fs `pwd`/bash/bashrc ~/.bash_profile
	ln -fs ~/.bash_profile ~/.bashrc

install-virtualenvwrapper:
	mkdir -p ~/.virtualenvs/
	ln -fs `pwd`/virtualenvwrapper/* ~/.virtualenvs/

install-pythonrc:
	ln -fs `pwd`/python/pythonrc.py ~/.pythonrc.py

install-subl:
ifeq ($(shell uname),Darwin)
	ln -fs `pwd`/sublimetext3/Packages/User/* ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/
	ln -fs "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl
endif

install-fish:
	mkdir -p ~/.config/fish/
	ln -fs `pwd`/fish/config.fish ~/.config/fish/config.fish

install-zsh:
	ln -fs `pwd`/zsh/zshrc ~/.zshrc
	# TODO(dcramer): there must be a better way to do specify my own theme?
	[ -e ~/.oh-my-zsh ] && ln -fs `pwd`/zsh/themes/* ~/.oh-my-zsh/themes/
	mkdir -p ~/.config/
	ln -fs `pwd`/zsh/zsh_plugins ~/.config/zsh_plugins
	# mkdir -p ~/.zsh-extras/
	# [ ! -e ~/.zsh-extras/zsh-autosuggestions ] && git clone git://github.com/tarruda/zsh-autosuggestions ~/.zsh-extras/zsh-autosuggestions

install-nuget:
	mkdir -p ~/.nuget
	wget -O ~/.nuget/nuget.exe https://dist.nuget.org/win-x86-commandline/latest/nuget.exe

install-ssh:
ifeq ($(shell uname),Darwin)
	sudo cp ssh/* /etc/ssh/
	sudo chmod 755 /etc/ssh/ssh_config
	sudo chmod 644 /etc/ssh/sshd_config
endif
