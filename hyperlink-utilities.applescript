#!/usr/bin/osascript

on markdownLink(theLink)
	return "[" & theTitle of theLink & "](" & theURL of theLink & ")"
end markdownLink

on setClipboardToHyperlink(theLink)
	if theURL of theLink is "" then
		set the clipboard to theTitle
	else
		set theHTML to quoted form of ("<font face=\"Helvetica Neue\"><a href=\"" & theURL of theLink & "\">" & theTitle of theLink & "</a></font>")
		do shell script "/bin/echo -n " & theHTML & " | textutil -format html -inputencoding UTF-8 -convert rtf -stdin -stdout | pbcopy -Prefer rtf"
		
		set theRtfData to «class RTF » of (the clipboard as record)
		set theMarkdownText to markdownLink(theLink)
		set the clipboard to {Unicode text:theMarkdownText, «class RTF »:theRtfData}
	end if
end setClipboardToHyperlink

on parseHyperlink(theLink)
	# XXX no error checking; theLink must be "[Some Title](some-url)"
	set theDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "]("
	set theTitle to text 2 thru -1 of first text item of theLink
	set theURL to text 1 thru -2 of the second text item of theLink
	set AppleScript's text item delimiters to theDelimiters
	return {theTitle:theTitle, theURL:theURL}
end parseHyperlink

on getMailHyperlink()
	tell application "Mail" to tell item 1 of (get selection)
		set theSubject to do shell script "/usr/bin/perl -MCGI -e 'print CGI::escapeHTML(shift)' " & quoted form of the (subject as string)
		set theSender to do shell script "/usr/bin/perl -MCGI -e 'for (@ARGV) { s/(.*?) <.*/$1/; print CGI::escapeHTML($_) }' " & quoted form of the (sender as string)
		set theMsgId to do shell script "/usr/bin/perl -MCGI -e 'print CGI::escapeHTML(shift)' " & quoted form of the (message id as string)
		
		if (theSubject is not "") and (theSender is not "") and (theMsgId is not "") then
			set theTitle to theSubject & " from " & theSender
			set theURL to "message://%3C" & theMsgId & "%3E"
			return {theTitle:theTitle, theURL:theURL}
		end if
	end tell
end getMailHyperlink

on openOmnifocusQuickEntry(theLink)
	tell application "OmniFocus" to tell quick entry
		set theNote to theTitle of theLink
		try
			set theName to theSelection of theLink
		on error
			set theName to the missing value
		end try
		if theName is the missing value then set theName to theNote
		
		set theTask to make new inbox task with properties {name:theName, note:theNote}
		tell the note of theTask
			set the value of the first paragraph's style's attribute "link" to theURL of theLink
		end tell
		
		if theName is not equal to theNote then
			set note expanded of the first tree to true
		end if
		open
	end tell
end openOmnifocusQuickEntry

