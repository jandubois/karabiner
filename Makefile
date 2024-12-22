SHELL := /bin/bash

.phony: diff install open-web-app-install \
	browser-utils-install browser-utils-install-hardcoded browser-utils-diff

diff: karabiner.json
	colordiff -u ${HOME}/.config/karabiner/karabiner.json <(./kc-expand karabiner.json) | less -SR

CONFIG=${HOME}/.config/karabiner

install: karabiner.json
	./kc-expand karabiner.json > ${CONFIG}/karabiner.json.new
	mv ${CONFIG}/karabiner.json ${CONFIG}/karabiner.json.prev
	mv ${CONFIG}/karabiner.json.new ${CONFIG}/karabiner.json
	make browser-utils-diff

karabiner.json: karabiner.rb *.json.erb
	ruby karabiner.rb > karabiner.json

open-web-app-install:
	cp open-web-app.applescript ${HOME}/Dropbox/bin/open-web-app

BROWSER_UTILS=${HOME}/Library/Script\ Libraries/Browser\ Utilities.scpt
HYPERLINK_UTILS=${HOME}/Library/Script\ Libraries/Hyperlink\ Utilities.scpt

browser-utils-install: open-web-app-install
	mkdir -p ${HOME}/Library/Script\ Libraries
	osacompile -o ${BROWSER_UTILS} browser-utilities.applescript

hyperlink-utils-install:
	mkdir -p ${HOME}/Library/Script\ Libraries
	osacompile -o ${HYPERLINK_UTILS} hyperlink-utilities.applescript

# Temp file is needed because osacompile cannot read from /dev/fd/nn so `<(perl ...)` doesn't work
TEMFPILE=/tmp/browser-utils-hardcoded
browser-utils-install-hardcoded: open-web-app-install
	mkdir -p ${HOME}/Library/Script\ Libraries
	perl -pe 's/# // if s|BROWSER|substr(qx(./$$ARGV),0,-1)|e' browser-utilities.applescript > ${TEMFPILE}
	osacompile -o ${BROWSER_UTILS} ${TEMFPILE}
	rm ${TEMFPILE}

browser-utils-diff:
	# The decompiled script is missing the hashbang line, but appends an additional newline
	colordiff -u <(osadecompile ${BROWSER_UTILS} | sed 's/[[:space:]]*$$//') \
             <(tail -n +2 browser-utilities.applescript | sed 's/[[:space:]]*$$//'; echo)

hyperlink-utils-diff:
	# The decompiled script is missing the hashbang line, but appends an additional newline
	colordiff -u <(osadecompile ${HYPERLINK_UTILS} | sed 's/[[:space:]]*$$//') \
             <(tail -n +2 hyperlink-utilities.applescript | sed 's/[[:space:]]*$$//'; echo)
