#!/usr/bin/osascript

global theBrowser

on run
	return defaultBrowser()
end run

on setBrowser(theDesiredBrowser)
	set theBrowser to theDesiredBrowser
end setBrowser

on setDefaultBrowser()
	# Make sure theBrowser variable has been created
	try
		set theBrowser to theBrowser
	on error
		set theBrowser to the missing value
	end try
	
	if theBrowser is the missing value then
		# Determining the default browser from launch services config takes about 0.3s.
		# So consider hard-coding the value once you have made up your mind...
		# The following line is edited by `make browers-utils-install-hardcoded`:
		# set theBrowser to "BROWSER"
	end if
	
	if theBrowser is the missing value then
		tell application "System Events"
			# Look for https handler in launch services to determine default browser
			set thePreferencesFolder to the POSIX path of the (path to the preferences folder from the user domain)
			set theLaunchServicesPlistFile to thePreferencesFolder & "/com.apple.LaunchServices/com.apple.launchservices.secure.plist"
			set theHandlers to the property list item "LSHandlers" of the property list file theLaunchServicesPlistFile
			repeat with theHandler in the property list items of theHandlers
				try
					set theURLScheme to the value of the property list item "LSHandlerURLScheme" of theHandler
					if theURLScheme is "https" then
						set theBrowser to the value of the property list item "LSHandlerRoleAll" of theHandler
						exit repeat
					end if
				end try
			end repeat
			
			# If default browser is Choosy, use the first browser in Choosy config
			if theBrowser is "com.choosyosx.choosy" then
				set theChoosyPlistFile to thePreferencesFolder & "/com.choosyosx.Choosy.plist"
				set theBrowsers to the property list item "browsers" of the property list file theChoosyPlistFile
				set theBrowser to the value of the property list item "path" of the property list item 1 of theBrowsers
				# Convert "/Applications/Google Chrome.app" to "Google Chrome"
				tell me to set theBrowser to the name of the application theBrowser
			else
				# Convert "com.google.chrome" to "Google Chrome"
				tell me to set theBrowser to the name of application id theBrowser
			end if
		end tell
	end if
end setDefaultBrowser

on defaultBrowser()
	setDefaultBrowser()
	return theBrowser
end defaultBrowser

on tabTitle()
	setDefaultBrowser()
	if theBrowser is "Google Chrome" then
		tell application "Google Chrome" to tell the front window's active tab
			return the title
		end tell
	end if
	if theBrowser is "Safari" then
		tell application "Safari" to tell the front window's current tab
			return the name
		end tell
	end if
end tabTitle

on tabURL()
	setDefaultBrowser()
	if theBrowser is "Google Chrome" then
		tell application "Google Chrome" to tell the front window's active tab
			return the URL
		end tell
	end if
	if theBrowser is "Safari" then
		tell application "Safari" to tell the front window's current tab
			return the URL
		end tell
	end if
end tabURL

on tabMarkdown()
	return "[" & tabTitle() & "](" & tabURL() & ")"
end tabMarkdown

on openURL(theURL)
	setDefaultBrowser()
	if theBrowser is "Google Chrome" then
		tell application "Google Chrome" to tell the front window
			repeat with theIndex from 1 to count of the tabs
				set theTab to tab theIndex
				if theTab's URL starts with theURL then
					set the active tab index to theIndex
					activate
					return
				end if
			end repeat
		end tell
	else if theBrowser is "Safari" then
		tell application "Safari" to tell the front window
			repeat with theTab in the tabs
				if theTab's URL starts with theURL then
					set the current tab to theTab
					activate
					return
				end if
			end repeat
		end tell
	end if
	do shell script "open -a " & the quoted form of theBrowser & " " & the quoted form of theURL
end openURL