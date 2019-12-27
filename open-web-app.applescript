#!/usr/bin/osascript

on run theArgs
	if (count of theArgs) is 0 then set theArgs to {"--browser"}
	set theURL to item 1 of theArgs
	
	tell script "Browser Utilities"
		if (count of theArgs) > 1 then setBrowser(item 2 of theArgs)
		if theURL is "--browser" then return defaultBrowser()
		if theURL is "--markdown" then return tabMarkdown()
		if theURL is "--title" then return tabTitle()
		if theURL is "--url" then return tabURL()
		openURL(theURL)
	end tell
end run
