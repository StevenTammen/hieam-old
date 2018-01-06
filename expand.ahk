SendMode Input
#NoEnv
#SingleInstance force



; Import Functions
;-------------------------------------------------

#Include <MiscFunctions>



; Change Masking Key
;-------------------------------------------------

#MenuMaskKey VK07  ; Prevents masked Hotkeys from sending LCtrls that can interfere with the script.
								; See https://autohotkey.com/docs/commands/_MenuMaskKey.htm



; Initialize Objects And Status Variables
;-------------------------------------------------

subscript_PassThroughCap := false
IniWrite, %subscript_PassThroughCap%, Status.ini, nestVars, subscript_PassThroughCap ; Enable passing through capitalization for subscripts as a block
																															 ; (rather than capitalizing the first letter of the subscript).
																															 ; Stored in Status.ini to allow for resetting with Esc.

superscript_PassThroughCap := false
IniWrite, %superscript_PassThroughCap%, Status.ini, nestVars, superscript_PassThroughCap ; Enable passing through capitalization for superscripts as a block
																																  ; (rather than capitalizing the first letter of the superscript).
																																  ; Stored in Status.ini to allow for resetting with Esc.


; ------------------- Commands -------------------

#If (GetKeyState("F18"))

:*?:jc=::
	SendInput {Backspace}Jesus Christ
	EndCommandMode()
	return
	
#If


; ------------------- Nested Punctuation -------------------

#If (GetKeyState("F23"))

:*?:`t::

	IniRead, inQuote, Status.ini, nestVars, inQuote
	if(inQuote)
	{
		inQuote := false
		IniWrite, %inQuote%, Status.ini, nestVars, inQuote
	}

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel - 1
	IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel

	DealWithSubscriptAndSuperscriptPassThrough_Tab()

	if(nestLevel > 0)
	{
		if(GetKeyState("F21"))
		{			
			SendInput {Backspace}{Right}{Space}
		}
		else if(GetKeyState("F22"))
		{
			SendInput {Backspace}{Right}{Space}
		}
		else
		{
			SendInput {Right}{Space}{F21 Down}
		}
	}
	else
	{
		if(GetKeyState("F21"))
		{			
			SendInput {Backspace}{Right}{Space}{F23 Up}
		}
		else if(GetKeyState("F22"))
		{
			SendInput {Backspace}{Right}{Space}{F23 Up}
		}
		else
		{
			SendInput {Right}{Space}{F21 Down}{F23 Up}
		}
	}

	return

:*?: .::

	IniRead, inQuote, Status.ini, nestVars, inQuote
	if(inQuote)
	{
		inQuote := false
		IniWrite, %inQuote%, Status.ini, nestVars, inQuote
	}

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel - 1
	IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel

	DealWithSubscriptAndSuperscriptPassThrough()

	if(nestLevel > 0)
	{
		if(GetKeyState("F21"))
		{			
			SendInput {Right}.{Space}{F22 Down}{F21 Up}
		}
		else if(GetKeyState("F22"))
		{
			SendInput {Right}.{Space}
		}
		else
		{
			SendInput {Right}.{Space}{F22 Down}
		}
	}
	else
	{
		if(GetKeyState("F21"))
		{			
			SendInput {Right}.{Space}{F22 Down}{F21 Up}{F23 Up}
		}
		else if(GetKeyState("F22"))
		{
			SendInput {Right}.{Space}{F23 Up}
		}
		else
		{
			SendInput {Right}.{Space}{F22 Down}{F23 Up}
		}
	}

	return

:*?: ,::

	IniRead, inQuote, Status.ini, nestVars, inQuote
	if(inQuote)
	{
		inQuote := false
		IniWrite, %inQuote%, Status.ini, nestVars, inQuote
	}

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel - 1
	IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel

	DealWithSubscriptAndSuperscriptPassThrough()

	if(nestLevel > 0)
	{
		if(GetKeyState("F21"))
		{			
			SendInput {Right},{Space}
		}
		else if(GetKeyState("F22"))
		{
			SendInput {Right},{Space}{F21 Down}{F22 Up}
		}
		else
		{
			SendInput {Right},{Space}{F21 Down}
		}
	}
	else
	{
		if(GetKeyState("F21"))
		{			
			SendInput {Right},{Space}{F23 Up}
		}
		else if(GetKeyState("F22"))
		{
			SendInput {Right},{Space}{F21 Down}{F22 Up}{F23 Up}
		}
		else
		{
			SendInput {Right},{Space}{F21 Down}{F23 Up}
		}
	}

	return
	
:*?b0: 12::

	KeyWait 2

	IniRead, inQuote, Status.ini, nestVars, inQuote
	if(inQuote)
	{
		inQuote := false
		IniWrite, %inQuote%, Status.ini, nestVars, inQuote
	}

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel - 1
	IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel

	DealWithSubscriptAndSuperscriptPassThrough()

	if(nestLevel > 0)
	{
		if(GetKeyState("F21"))
		{			
			SendInput {Backspace 2}{Right}:{Space}
		}
		else if(GetKeyState("F22"))
		{
			SendInput {Backspace 2}{Right}:{Space}{F21 Down}{F22 Up}
		}
		else
		{
			SendInput {Backspace 2}{Right}:{Space}{F21 Down}
		}
	}
	else
	{
		if(GetKeyState("F21"))
		{			
			SendInput {Backspace 2}{Right}:{Space}{F23 Up}
		}
		else if(GetKeyState("F22"))
		{
			SendInput {Backspace 2}{Right}:{Space}{F21 Down}{F22 Up}{F23 Up}
		}
		else
		{
			SendInput {Backspace 2}{Right}:{Space}{F21 Down}{F23 Up}
		}
	}

	return

:*?b0: 2-::

	IniRead, inQuote, Status.ini, nestVars, inQuote
	if(inQuote)
	{
		inQuote := false
		IniWrite, %inQuote%, Status.ini, nestVars, inQuote
	}

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel - 1
	IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel

	DealWithSubscriptAndSuperscriptPassThrough()

	if(nestLevel > 0)
	{
		if(GetKeyState("F21"))
		{			
			SendInput {Backspace 3}{Right};{Space}
		}
		else if(GetKeyState("F22"))
		{
			SendInput {Backspace 3}{Right};{Space}{F21 Down}{F22 Up}
		}
		else
		{
			SendInput {Backspace 3}{Right};{Space}{F21 Down}
		}
	}
	else
	{
		if(GetKeyState("F21"))
		{			
			SendInput {Backspace 3}{Right};{Space}{F23 Up}
		}
		else if(GetKeyState("F22"))
		{
			SendInput {Backspace 3}{Right};{Space}{F21 Down}{F22 Up}{F23 Up}
		}
		else
		{
			SendInput {Backspace 3}{Right};{Space}{F21 Down}{F23 Up}
		}
	}

	return

:*?b0: 2/::

	IniRead, inQuote, Status.ini, nestVars, inQuote
	if(inQuote)
	{
		inQuote := false
		IniWrite, %inQuote%, Status.ini, nestVars, inQuote
	}

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel - 1
	IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel

	DealWithSubscriptAndSuperscriptPassThrough()

	if(nestLevel > 0)
	{
		if(GetKeyState("F21"))
		{			
			SendInput {Backspace 2}{Right}—
		}
		else if(GetKeyState("F22"))
		{
			SendInput {Backspace 2}{Right}—{F21 Down}{F22 Up}
		}
		else
		{
			SendInput {Backspace 2}{Right}—{F21 Down}
		}
	}
	else
	{
		if(GetKeyState("F21"))
		{			
			SendInput {Backspace 2}{Right}—{F23 Up}
		}
		else if(GetKeyState("F22"))
		{
			SendInput {Backspace 2}{Right}—{F21 Down}{F22 Up}{F23 Up}
		}
		else
		{
			SendInput {Backspace 2}{Right}—{F21 Down}{F23 Up}
		}
	}

	return
	
:*?b0: 2``::

	IniRead, inQuote, Status.ini, nestVars, inQuote
	if(inQuote)
	{
		inQuote := false
		IniWrite, %inQuote%, Status.ini, nestVars, inQuote
	}

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel - 1
	IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel

	DealWithSubscriptAndSuperscriptPassThrough()

	if(nestLevel > 0)
	{
		if(GetKeyState("F21"))
		{			
			SendInput {Backspace 3}{Right}?{Space}{F22 Down}{F21 Up}
		}
		else if(GetKeyState("F22"))
		{
			SendInput {Backspace 3}{Right}?{Space}
		}
		else
		{
			SendInput {Backspace 3}{Right}?{Space}{F22 Down}
		}
	}
	else
	{
		if(GetKeyState("F21"))
		{			
			SendInput {Backspace 3}{Right}?{Space}{F22 Down}{F21 Up}{F23 Up}
		}
		else if(GetKeyState("F22"))
		{
			SendInput {Backspace 3}{Right}?{Space}{F23 Up}
		}
		else
		{
			SendInput {Backspace 3}{Right}?{Space}{F22 Down}{F23 Up}
		}
	}

	return

:*?b0: 2'::

	IniRead, inQuote, Status.ini, nestVars, inQuote
	if(inQuote)
	{
		inQuote := false
		IniWrite, %inQuote%, Status.ini, nestVars, inQuote
	}

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel - 1
	IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel

	DealWithSubscriptAndSuperscriptPassThrough()

	if(nestLevel > 0)
	{
		if(GetKeyState("F21"))
		{			
			SendInput {Backspace 3}{Right}{!}{Space}{F22 Down}{F21 Up}
		}
		else if(GetKeyState("F22"))
		{
			SendInput {Backspace 3}{Right}{!}{Space}
		}
		else
		{
			SendInput {Backspace 3}{Right}{!}{Space}{F22 Down}
		}
	}
	else
	{
		if(GetKeyState("F21"))
		{			
			SendInput {Backspace 3}{Right}{!}{Space}{F22 Down}{F21 Up}{F23 Up}
		}
		else if(GetKeyState("F22"))
		{
			SendInput {Backspace 3}{Right}{!}{Space}{F23 Up}
		}
		else
		{
			SendInput {Backspace 3}{Right}{!}{Space}{F22 Down}{F23 Up}
		}
	}

	return

#If


; ------------------- Dealing With Colon Spacing -------------------

#If (!(GetKeyState("F20")) and (GetKeyState("F13") or GetKeyState("F15")) and !(GetKeyState("F18") or GetKeyState("F21") or GetKeyState("F22")))
:*?b0:2::
	KeyWait 2
	SendInput {Space}{F21 Down}
	return
#If

#If (!(GetKeyState("F20")) and (GetKeyState("F13") or GetKeyState("F15")) and (GetKeyState("F18")))
:*?b0:2::
	KeyWait 2
	SendInput {Backspace 2}:{F18 Up}
	return
#If

#If (!(GetKeyState("F20")) and (GetKeyState("F13") or GetKeyState("F15")) and (GetKeyState("F21")))
:*?b0:2::
	KeyWait 2
	SendInput {Backspace 2}:{Space}
	return
#If

#If ((!(GetKeyState("F20")) and GetKeyState("F13") or GetKeyState("F15")) and (GetKeyState("F22")))
:*?b0:2::
	KeyWait 2
	SendInput {Backspace 2}:{Space}{F21 Down}{F22 Up}
	return
#If


; ------------------- _{Spc}  *{Spc}  ^{Spc}  ={Spc}  {Spc}~ autospacing -------------------

#If (GetKeyState("F20"))

:*?b0:2,=::

	if(GetKeyState("F21"))
	{
		SendInput {Backspace 2}{Right}{{}{}}{Left}
	}
	else if(GetKeyState("F22"))
	{
		SendInput {Backspace 2}{Right}{{}{}}{Left}{F21 Down}{F22 Up}
		subscript_PassThroughCap := true
		IniWrite, %subscript_PassThroughCap%, Status.ini, nestVars, subscript_PassThroughCap
	}
	else
	{
		SendInput {Backspace 2}{Right}{{}{}}{Left}{F21 Down}
	}

	return

:*?:1l ::

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel - 1
	IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel

	if(nestLevel > 0)
	{
		SendInput {Right}{Space}
	}
	else
	{
		SendInput {Right}{Space}{F23 Up}
	}

	return

:*?b0:1q=::

	if(GetKeyState("F21"))
	{
		SendInput {Backspace 2}{Right}{{}{}}{Left}
	}
	else if(GetKeyState("F22"))
	{
		SendInput {Backspace 2}{Right}{{}{}}{Left}{F21 Down}{F22 Up}
		superscript_PassThroughCap := true
		IniWrite, %superscript_PassThroughCap%, Status.ini, nestVars, superscript_PassThroughCap
	}
	else
	{
		SendInput {Backspace 2}{Right}{{}{}}{Left}{F21 Down}
	}

	return

:*?:1g ::

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel - 1
	IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel

	if(nestLevel > 0)
	{
		SendInput {Right}{Space}
	}
	else
	{
		SendInput {Right}{Space}{F23 Up}
	}

	return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TODO: {Spc}~ autospacing

#If

; ------------------- Desktop Switching -------------------

#If (GetKeyState("F14") and GetKeyState("F17"))

:*?b0:21h::
	KeyWait h
	SendInput {F14 Up}{F17 Up}!{F2}
	return
:*?b0:21i::
	KeyWait i
	SendInput {F14 Up}{F17 Up}!{F3}
	return
:*?b0:21e::
	KeyWait e
	SendInput {F14 Up}{F17 Up}!{F5}
	return
:*?b0:21a::
	KeyWait a
	SendInput {F14 Up}{F17 Up}!{F7}
	return
:*?b0:21w::
	KeyWait w
	SendInput {F14 Up}{F17 Up}!{F9}
	return
:*?b0:21m::
	KeyWait m
	SendInput {F14 Up}{F17 Up}!{F8}
	return
:*?b0:21t::
	KeyWait t
	SendInput {F14 Up}{F17 Up}!{F10}
	return
:*?b0:21s::
	KeyWait s
	SendInput {F14 Up}{F17 Up}!{F6}
	return
:*?b0:21r::
	KeyWait r
	SendInput {F14 Up}{F17 Up}^{F4}
	return
:*?b0:21n::
	KeyWait n
	SendInput {F14 Up}{F17 Up}!{F1}
	return

#If
