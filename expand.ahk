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
; ------------------- Text Briefs -------------------

; These are going to be quite complex. Dynamic regex hotstrings 
; may be necessary. Not a big priority for me right now.

;hotstrings("\b(W|w)o,", "%$1%ithout,")
;
;:*b0:wo1b::
;	KeyWait b
;	SendInput {Left 2}{Backspace 2}without{Right 2}
;	return
;
;#If (GetKeyState("F22") or GetKeyState("F23"))
;
;:*?b0:wo1b::
;	KeyWait b
;	SendInput {Left 2}{Backspace 2}without{Right 2}
;	return
;
;#If

; ------------------- Named Entities -------------------

#If (GetKeyState("F20"))

:*?:nike=::
	SendInput {Backspace}
	SendInput tammen@nike.cs.uga.edu
	EndCommandMode()
	return
:*?:pi=::
	SendInput {Backspace}
	SendInput π
	EndCommandMode()
	return
	
#If
																			  
; ------------------- Commands -------------------

#If (GetKeyState("F20"))

:*?:sleep=::
	SendInput {Backspace}
	EndCommandMode()
	DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
	return
	
#If


; ------------------- Nested Punctuation -------------------

#If (GetKeyState("F24"))

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
		if(GetKeyState("F22"))
		{			
			SendInput {Backspace}{Right}{Space}
		}
		else if(GetKeyState("F23"))
		{
			SendInput {Backspace}{Right}{Space}
		}
		else
		{
			SendInput {Right}{Space}{F22 Down}
		}
	}
	else
	{
		if(GetKeyState("F22"))
		{			
			SendInput {Backspace}{Right}{Space}{F24 Up}
		}
		else if(GetKeyState("F23"))
		{
			SendInput {Backspace}{Right}{Space}{F24 Up}
		}
		else
		{
			SendInput {Right}{Space}{F22 Down}{F24 Up}
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
		if(GetKeyState("F22"))
		{			
			SendInput {Right}.{Space}{F23 Down}{F22 Up}
		}
		else if(GetKeyState("F23"))
		{
			SendInput {Right}.{Space}
		}
		else
		{
			SendInput {Right}.{Space}{F23 Down}
		}
	}
	else
	{
		if(GetKeyState("F22"))
		{			
			SendInput {Right}.{Space}{F23 Down}{F22 Up}{F24 Up}
		}
		else if(GetKeyState("F23"))
		{
			SendInput {Right}.{Space}{F24 Up}
		}
		else
		{
			SendInput {Right}.{Space}{F23 Down}{F24 Up}
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
		if(GetKeyState("F22"))
		{			
			SendInput {Right},{Space}
		}
		else if(GetKeyState("F23"))
		{
			SendInput {Right},{Space}{F22 Down}{F23 Up}
		}
		else
		{
			SendInput {Right},{Space}{F22 Down}
		}
	}
	else
	{
		if(GetKeyState("F22"))
		{			
			SendInput {Right},{Space}{F24 Up}
		}
		else if(GetKeyState("F23"))
		{
			SendInput {Right},{Space}{F22 Down}{F23 Up}{F24 Up}
		}
		else
		{
			SendInput {Right},{Space}{F22 Down}{F24 Up}
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
		if(GetKeyState("F22"))
		{			
			SendInput {Backspace 2}{Right}:{Space}
		}
		else if(GetKeyState("F23"))
		{
			SendInput {Backspace 2}{Right}:{Space}{F22 Down}{F23 Up}
		}
		else
		{
			SendInput {Backspace 2}{Right}:{Space}{F22 Down}
		}
	}
	else
	{
		if(GetKeyState("F22"))
		{			
			SendInput {Backspace 2}{Right}:{Space}{F24 Up}
		}
		else if(GetKeyState("F23"))
		{
			SendInput {Backspace 2}{Right}:{Space}{F22 Down}{F23 Up}{F24 Up}
		}
		else
		{
			SendInput {Backspace 2}{Right}:{Space}{F22 Down}{F24 Up}
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
		if(GetKeyState("F22"))
		{			
			SendInput {Backspace 3}{Right};{Space}
		}
		else if(GetKeyState("F23"))
		{
			SendInput {Backspace 3}{Right};{Space}{F22 Down}{F23 Up}
		}
		else
		{
			SendInput {Backspace 3}{Right};{Space}{F22 Down}
		}
	}
	else
	{
		if(GetKeyState("F22"))
		{			
			SendInput {Backspace 3}{Right};{Space}{F24 Up}
		}
		else if(GetKeyState("F23"))
		{
			SendInput {Backspace 3}{Right};{Space}{F22 Down}{F23 Up}{F24 Up}
		}
		else
		{
			SendInput {Backspace 3}{Right};{Space}{F22 Down}{F24 Up}
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
		if(GetKeyState("F22"))
		{			
			SendInput {Backspace 2}{Right}—
		}
		else if(GetKeyState("F23"))
		{
			SendInput {Backspace 2}{Right}—{F22 Down}{F23 Up}
		}
		else
		{
			SendInput {Backspace 2}{Right}—{F22 Down}
		}
	}
	else
	{
		if(GetKeyState("F22"))
		{			
			SendInput {Backspace 2}{Right}—{F24 Up}
		}
		else if(GetKeyState("F23"))
		{
			SendInput {Backspace 2}{Right}—{F22 Down}{F23 Up}{F24 Up}
		}
		else
		{
			SendInput {Backspace 2}{Right}—{F22 Down}{F24 Up}
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
		if(GetKeyState("F22"))
		{			
			SendInput {Backspace 3}{Right}?{Space}{F23 Down}{F22 Up}
		}
		else if(GetKeyState("F23"))
		{
			SendInput {Backspace 3}{Right}?{Space}
		}
		else
		{
			SendInput {Backspace 3}{Right}?{Space}{F23 Down}
		}
	}
	else
	{
		if(GetKeyState("F22"))
		{			
			SendInput {Backspace 3}{Right}?{Space}{F23 Down}{F22 Up}{F24 Up}
		}
		else if(GetKeyState("F23"))
		{
			SendInput {Backspace 3}{Right}?{Space}{F24 Up}
		}
		else
		{
			SendInput {Backspace 3}{Right}?{Space}{F23 Down}{F24 Up}
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
		if(GetKeyState("F22"))
		{			
			SendInput {Backspace 3}{Right}{!}{Space}{F23 Down}{F22 Up}
		}
		else if(GetKeyState("F23"))
		{
			SendInput {Backspace 3}{Right}{!}{Space}
		}
		else
		{
			SendInput {Backspace 3}{Right}{!}{Space}{F23 Down}
		}
	}
	else
	{
		if(GetKeyState("F22"))
		{			
			SendInput {Backspace 3}{Right}{!}{Space}{F23 Down}{F22 Up}{F24 Up}
		}
		else if(GetKeyState("F23"))
		{
			SendInput {Backspace 3}{Right}{!}{Space}{F24 Up}
		}
		else
		{
			SendInput {Backspace 3}{Right}{!}{Space}{F23 Down}{F24 Up}
		}
	}

	return

#If


; ------------------- Dealing With Colon Spacing -------------------

#If (!(GetKeyState("F21")) and (GetKeyState("F13") or GetKeyState("F17")) and !(GetKeyState("F20") or GetKeyState("F22") or GetKeyState("F23")))
:*?b0:2::
	KeyWait 2
	SendInput {Space}{F22 Down}
	return
#If

#If (!(GetKeyState("F21")) and (GetKeyState("F13") or GetKeyState("F17")) and (GetKeyState("F20")))
:*?b0:2::
	KeyWait 2
	SendInput {Backspace 2}:{F20 Up}
	return
#If

#If (!(GetKeyState("F21")) and (GetKeyState("F13") or GetKeyState("F17")) and (GetKeyState("F22")))
:*?b0:2::
	KeyWait 2
	SendInput {Backspace 2}:{Space}
	return
#If

#If ((!(GetKeyState("F21")) and GetKeyState("F13") or GetKeyState("F17")) and (GetKeyState("F23")))
:*?b0:2::
	KeyWait 2
	SendInput {Backspace 2}:{Space}{F22 Down}{F23 Up}
	return
#If


; ------------------- _{Spc}  *{Spc}  ^{Spc}  ={Spc}  {Spc}~ autospacing -------------------

#If (GetKeyState("F21"))

:*?b0:2,=::

	if(GetKeyState("F22"))
	{
		SendInput {Backspace 2}{Right}{{}{}}{Left}
	}
	else if(GetKeyState("F23"))
	{
		SendInput {Backspace 2}{Right}{{}{}}{Left}{F22 Down}{F23 Up}
		subscript_PassThroughCap := true
		IniWrite, %subscript_PassThroughCap%, Status.ini, nestVars, subscript_PassThroughCap
	}
	else
	{
		SendInput {Backspace 2}{Right}{{}{}}{Left}{F22 Down}
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
		SendInput {Right}{Space}{F24 Up}
	}

	return

:*?b0:1q=::

	if(GetKeyState("F22"))
	{
		SendInput {Backspace 2}{Right}{{}{}}{Left}
	}
	else if(GetKeyState("F23"))
	{
		SendInput {Backspace 2}{Right}{{}{}}{Left}{F22 Down}{F23 Up}
		superscript_PassThroughCap := true
		IniWrite, %superscript_PassThroughCap%, Status.ini, nestVars, superscript_PassThroughCap
	}
	else
	{
		SendInput {Backspace 2}{Right}{{}{}}{Left}{F22 Down}
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
		SendInput {Right}{Space}{F24 Up}
	}

	return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; TODO: {Spc}~ autospacing

#If

; ------------------- Desktop Switching -------------------

#If (GetKeyState("F14") and GetKeyState("F19"))

:*?b0:21h::
	KeyWait h
	SendInput {F14 Up}{F19 Up}!{F2}
	return
:*?b0:21i::
	KeyWait i
	SendInput {F14 Up}{F19 Up}!{F3}
	return
:*?b0:21e::
	KeyWait e
	SendInput {F14 Up}{F19 Up}!{F5}
	return
:*?b0:21a::
	KeyWait a
	SendInput {F14 Up}{F19 Up}!{F7}
	return
:*?b0:21w::
	KeyWait w
	SendInput {F14 Up}{F19 Up}!{F9}
	return
:*?b0:21m::
	KeyWait m
	SendInput {F14 Up}{F19 Up}!{F8}
	return
:*?b0:21t::
	KeyWait t
	SendInput {F14 Up}{F19 Up}!{F10}
	return
:*?b0:21s::
	KeyWait s
	SendInput {F14 Up}{F19 Up}!{F6}
	return
:*?b0:21r::
	KeyWait r
	SendInput {F14 Up}{F19 Up}^{F4}
	return
:*?b0:21n::
	KeyWait n
	SendInput {F14 Up}{F19 Up}!{F1}
	return

#If
