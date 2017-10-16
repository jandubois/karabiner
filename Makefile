SHELL := /bin/bash

diff: karabiner.json
	colordiff -u <(./kc-expand karabiner.json) ${HOME}/.config/karabiner/karabiner.json | less -SR

install: karabiner.json
	cp ${HOME}/.config/karabiner/karabiner.json ${HOME}/.config/karabiner/karabiner.orig
	./kc-expand karabiner.json > ${HOME}/.config/karabiner/karabiner.json
	cp open-chrome-app /usr/local/bin/

karabiner.json: karabiner.rb
	ruby karabiner.rb > karabiner.json
