SHELL := /bin/bash

diff: karabiner.json
	colordiff -u ${HOME}/.config/karabiner/karabiner.json <(./kc-expand karabiner.json) | less -SR

install: karabiner.json
	cp ${HOME}/.config/karabiner/karabiner.json ${HOME}/.config/karabiner/karabiner.orig
	./kc-expand karabiner.json > ${HOME}/.config/karabiner/karabiner.json.new
	mv ${HOME}/.config/karabiner/karabiner.json ${HOME}/.config/karabiner/karabiner.json.prev
	mv ${HOME}/.config/karabiner/karabiner.json.new ${HOME}/.config/karabiner/karabiner.json
	cp open-chrome-app /usr/local/bin/

karabiner.json: karabiner.rb *.json.erb
	ruby karabiner.rb > karabiner.json
