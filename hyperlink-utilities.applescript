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
		set theName to theTitle of theLink
		set theTask to make new inbox task with properties {name:theName, note:theName}
		tell the note of theTask
			set the value of attribute "link" of the style of paragraph 1 to theURL of theLink
		end tell
		open
	end tell
end openOmnifocusQuickEntry

