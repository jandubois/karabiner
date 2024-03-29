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
			
			# Fallback because on Ventura I don't seem to have any entries for https in the launchd config
			if theBrowser is the missing value then
				set theBrowser to "com.apple.safari"
			end if

			# If default browser is Choosy, use the first browser in Choosy config
			if theBrowser is "com.choosyosx.choosy" then
				set theChoosyPlistFile to thePreferencesFolder & "/com.choosyosx.Choosy.plist"
				set theBrowsers to the property list item "browsers" of the property list file theChoosyPlistFile
				set theBrowser to the value of the property list item "path" of the property list item 1 of theBrowsers
				# Convert "/Applications/Google Chrome.app" to "Google Chrome"
				tell me to set theBrowser to the name of the application theBrowser
			else
				# Convert "com.google.chrome" to "Google Chrome"
				tell me to set theBrowser to the name of the application id theBrowser
			end if
		end tell
	end if
end setDefaultBrowser

on defaultBrowser()
	setDefaultBrowser()
	return theBrowser
end defaultBrowser

on tabInfo()
	setDefaultBrowser()
	if theBrowser is "Google Chrome" then
		tell application "Google Chrome" to tell the front window's active tab
			set theTabInfo to {theTitle:title, theURL:URL}
		end tell
	end if
	if theBrowser is "Safari" then
		tell application "Safari" to tell the front window's current tab
			set theTabInfo to {theTitle:name, theURL:URL}
		end tell
	end if
	if theTitle of theTabInfo is "" then set theTitle of theTabInfo to theURL of theTabInfo
	return theTabInfo
end tabInfo

on tabTitle()
	return theTitle of the tabInfo()
end tabTitle

on tabURL()
	return theURL of the tabInfo()
end tabURL

on openURL(theURL)
	setDefaultBrowser()
	if theBrowser is "Google Chrome" then
		tell application "Google Chrome" to tell the front window
			repeat with theIndex from 1 to the count of the tabs
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

on setURL(theURL)
	setDefaultBrowser()
	if theBrowser is "Google Chrome" then
		tell application "Google Chrome" to set the URL of the front window's active tab to theURL
	else if theBrowser is "Safari" then
		tell application "Safari" to set the URL of the front window's current tab to theURL
	end if
end setURL
