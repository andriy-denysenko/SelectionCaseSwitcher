; TODO: key combination for each character case
; TODO: switch CapsLock on on UPPER, off on the rest
; TODO: create menu item to turn on CapsLock toggling

#SingleInstance, force

IconFilename := SubStr(A_ScriptFullPath, 1, StrLen(A_ScriptFullPath) - 3) "ico"
if(!A_IsCompiled)
{
	Menu, Tray, Icon, %IconFilename%
}

Menu, Tray, NoStandard
Menu, Tray, Add, About, ShowHelp
Menu, Tray, Add
Menu, Tray, Add, Exit, ExitScript

VersionNumber = 0.0.1
ScriptName = Selection Case Switcher
Author = Andriy Denysenko
Email = denysenko.andriy@gmail.com

HelpMessage =
(
Switches character case of the selected text virtually in any window.

ScrollLock toggles between:

lower case
Title Case
Sentence case
UPPER CASE

Shift + ScrollLock inverts the case of all selected characters like this:

Inverted Case <-> iNVERTED cASE
)

Gui, Add, Link,, Author: %Author% <a href="%Email%">%Email%</a>
Gui, Add, text,, %HelpMessage%
Gui, Add, Button, gCloseHelp, OK

return

ScrollLock::
	s=
	s:= Selection_Copy()
	/*
	; Enable ScrollLock to switch CapsLock state when no text is selected
	if(s == "")
	{
		; OutputDebug, Selection is empty
		if(GetKeyState("CapsLock", "T"))
		{
			SetCapsLockState, Off
		}
		else
		{
			SetCapsLockState, On
		}
		; OutputDebug, Sent CapsLock
		return
	}
	*/
	rxUpper = ^\p{Lu}{2,}
	rxLower = ^\p{Ll}+
	rxTitle = ^\p{Lu}\p{Ll}+(\s\p{Lu}\p{Ll}+)+
	rxSentence = ^\p{Lu}\p{Ll}+(\s\p{Ll}+)*
	
	if(RegExMatch(s, rxUpper))
	{
		Text_Case := "{:L}"
	}
	else if(RegExMatch(s, rxLower))
	{
		Text_Case := "{:T}"
	}
	else if(RegExMatch(s, rxTitle))
	{
		Text_Case := ""
	}
	else if(RegExMatch(s, rxSentence))
	{
		Text_Case := "{:U}"
	}
	
	if(Text_Case != "")
	{
		r := Format(Text_Case, s)
	}
	else
	{
		r := String_ToSentenceCase(s)
	}
	Selection_Paste(r)
return

+ScrollLock::
	s=
	s:= Selection_Copy()
	/*
	; Enable ScrollLock to switch CapsLock state when no text is selected
	if(s == "")
	{
		; OutputDebug, Selection is empty
		if(GetKeyState("CapsLock", "T"))
		{
			SetCapsLockState, Off
		}
		else
		{
			SetCapsLockState, On
		}
		; OutputDebug, Sent CapsLock
		return
	}
	*/
	r := String_InvertCase(s)
	Selection_Paste(r)
return

Selection_Copy( showWarning = false )
{
	result := CtrlInsert( showWarning )		
	Return result
}

CtrlInsert( showWarning = false )
{
	cbCopy := ClipboardAll
	Clipboard=
	SendInput, ^{Insert}
	ClipWait, 0.5
	
	If ErrorLevel
	{
		if %showWarning%
		{
			MsgBox, The attempt to copy text onto the clipboard failed.
			Return
		}
	}
	else
	{
		if Clipboard=
			if %showWarning%
			{
  			MsgBox, MsgBox, The attempt to copy text onto the clipboard failed.
				Return
			}
	}
	result:=Clipboard
	Clipboard:=cbCopy
	Return result
}

Selection_Paste(s)
{
	cb := ClipboardAll
	Clipboard := s
	Send, +{Ins}
	Clipboard = cb
}

String_ToSentenceCase(s)
{
	if(StrLen(s) = 0)
		return ""
	result := Format("{:U}", SubStr(s, 1, 1))
	if(StrLen(s) > 1)
	{
		result .= Format("{:L}", SubStr(s, 2))
	}
	return result
}

String_InvertCase(s)
{
	rxUpper = \p{Lu}
	rxLower = \p{Ll}
	
	result := ""
	
	Loop, Parse, s
	{
		if(RegExMatch(A_LoopField, rxUpper))
		{
			result .= Format("{:L}", A_LoopField)
		}
		else
		{
			result .= Format("{:U}", A_LoopField)
		}
	}
	return result
}

ShowHelp:
	Gui, Show, AutoSize, %ScriptName% v%VersionNumber%
return

CloseHelp:
	Gui, Show, Hide
return

ExitScript:
	ExitApp