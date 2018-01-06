SendMode Input
#NoEnv
#SingleInstance force



; Import Functions
;-------------------------------------------------

#Include <dual/dual>
#Include <MiscFunctions>



; Change Masking Key
;-------------------------------------------------

#MenuMaskKey VK07  ; Prevents masked Hotkeys from sending LCtrls that can interfere with the script.
								; See https://autohotkey.com/docs/commands/_MenuMaskKey.htm



; Initialize Objects And Status Variables
;-------------------------------------------------

dual := new Dual


nestLevel := 0
IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel ; Store the nest level in an .ini file so it is accessible in the expand script

inQuote := false
IniWrite, %inQuote%, Status.ini, nestVars, inQuote ; Store the quote status in an .ini file so it is accessible in the expand script

lastOpenPairDown := A_TickCount
IniWrite, %lastOpenPairDown%, Status.ini, nestVars, lastOpenPairDown ; To allow for the deletion of paired characters as long as nothing else has been typed


command_PassThroughAutospacing := "none"
IniWrite, %command_PassThroughAutospacing%, Status.ini, commandVars, command_PassThroughAutospacing ; Enable passing through capitalization for commands as a block
																																							 ; (rather than capitalizing the first letter of the command).

inTextBox := false
IniWrite, %inTextBox%, Status.ini, commandVars, inTextBox ; A variable tracking whether or not commands are being entered into a separate window


lastEnterDown := A_TickCount ; To allow for Enters pressed close together to function differently from those pressed far apart

lastRealKeyDown := "" ; Track keypresses before layers are activated to use in place of A_PriorHotkey (which returns the layer key, not the actual prior key)




; Give Keys A Default Value
;-------------------------------------------------

#Include <dual/defaults>



; Remapping Setup
;-------------------------------------------------

#If true ; Wrap in #If to override defaults


;	   Layer Correspondences: High to Low Priority
;		  ----------------------------------------------
;		 | Num leader							|	F13 	|
;		  ----------------------------------------------
;		 | Shift leader							|	F14 	|
;		  ----------------------------------------------
;		 | Num hold								|	F15 	|
;		  ----------------------------------------------
;		 | Shift hold								|	F16 	|
;		  ----------------------------------------------
;		 | Punc after Num						|	F17 	|
;		  ----------------------------------------------
;		 | Command								|	F18 	|
;		  ----------------------------------------------
;		 | Vim										|	F19 	|
;		  ----------------------------------------------
;		 | No Autospacing						|	F20 	|
;		  ----------------------------------------------
;		 | Autospaced after punc			|	F21 	|
;		  ----------------------------------------------
;		 | Autospaced after .?!				|	F22 	|
;		  ----------------------------------------------
;		 | Nested punctuation					|	F23 	|
;		  ----------------------------------------------
;		 | Modify active win					|	F24? | 			TODO? ;;;;;;;;;;;;
;		  ----------------------------------------------
;
; 	   Priority: F13 > F14 > F15 > F16 > ... > F24


; The priority comes froms this function in dual.ahk:
;
;	sendSubKeySet(key, combinators=false) {
;		for combinator, resultingKey in combinators {
;			if (GetKeyState(combinator)) {
;				key := resultingKey
;				break
;			}
;		}
;
;		key := Dual.subKeySet(key)
;
;		for index, subKey in key {
;			Dual.sendInternal(subKey)
;		}
;	}
;
; In particular, the enumeration of associative array keys for the array "combinators" in the second line
; always proceeds from lowest FKey value to highest FKey value, so lower FKeys take priority.


;    TODO: Caps Lock
;    TODO: Num Lock
;    TODO: normal expand key behavior, text briefs
;    TODO: fix backspace and "(< etc. (backspace open and closed and reset F21/F22 state, nestLevel, and F23 state). Use A_PriorHotkey?

;    TODO: Fix "" behavior when closing quotes in editing.  ???
;    TODO: Fix Enter, Tab, etc. behavior when in vim mode (to only send Key)
;    TODO: put remap, expand, and window/tab/launch/desktop apps in windows startup sequence if not already there
;    TODO: test thoroughly

;    TODO: Figure out better way to check next characters for editing (" etc.?
;    TODO: Figure out why F20 Down has to be included in both remap and expand, not just remap.
;    TODO: Figure out why WinActivate on chrome class is necessary rather than using WinGetClass etc.
;		WinActivate, ahk_class Chrome_WidgetWin_1



; Top Row
;-------------------------------------------------

*Esc::
	
	nestLevel := 0
	IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel

	inQuote := false
	IniWrite, %inQuote%, Status.ini, nestVars, inQuote

	subscript_PassThroughCap := false
	IniWrite, %subscript_PassThroughCap%, Status.ini, nestVars, subscript_PassThroughCap

	superscript_PassThroughCap := false
	IniWrite, %superscript_PassThroughCap%, Status.ini, nestVars, superscript_PassThroughCap


	dual.reset()
	SendInput {Esc}

	return

*b::

	; ######## F13 Combinator ########
	
	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel + 1
	WriteNestLevelIfApplicable_Opening(nestLevel)

	F13Keys := F13Keys_Opening_NoCap("{", "}")


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("B")
	

	; ######## F15 Combinator ########

	F15Keys := F15Keys_Opening_NoCap("{", "}")
	
	
	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("B")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "b"
	shiftChar := "B"
	numChar := "{"
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["B", "F22 Up"]})
	
	return

*y::

	; ######## F13 Combinator ########

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel + 1
	WriteNestLevelIfApplicable_Opening(nestLevel)
	
	F13Keys := F13Keys_Opening_PassThroughCap("[", "]")


	; ######## F14 Combinator ########

	F14Keys := F14Keys_Letter("Y")


	; ######## F15 Combinator ########
	
	F15Keys := F15Keys_Opening_PassThroughCap("[", "]")


	; ######## F16 Combinator ########

	F16Keys := F16Keys_Letter("Y")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "y"
	shiftChar := "Y"
	numChar := "["
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}


	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["Y", "F22 Up"]})

	return

*o::

	; ######## F13 Combinator ########

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel - 1
	WriteNestLevelIfApplicable_Closing(nestLevel)

	F13Keys := F13Keys_Closing("]", nestLevel)


	; ######## F14 Combinator ########

	F14Keys := F14Keys_Letter("O")


	; ######## F15 Combinator ########
	
	F15Keys := F15Keys_Closing("]", nestLevel)


	; ######## F16 Combinator ########

	F16Keys := F16Keys_Letter("O")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "o"
	shiftChar := "O"
	numChar := "]"
	
	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}


	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["O", "F22 Up"]})

	return

*u::

	; ######## F13 Combinator ########

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel - 1
	WriteNestLevelIfApplicable_Closing(nestLevel)

	F13Keys := F13Keys_Closing("}", nestLevel)


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("U")


	; ######## F15 Combinator ########
	
	F15Keys := F15Keys_Closing("}", nestLevel)


	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("U")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
		; ######## Backslash Escape ########

	baseChar := "u"
	shiftChar := "U"
	numChar := "}"
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}


	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["U", "F22 Up"]})

	return

*'::

	; ######## F14 Combinator ########

	if(GetKeyState("F20"))
	{
		F14Keys := ["!", "F14 Up"]
	}
	else if(GetKeyState("F21"))
	{			
		F14Keys := ["Backspace", "!", "Space", "F22 Down", "F21 Up", "F14 Up"]
	}
	else if(GetKeyState("F22"))
	{
		F14Keys := ["Backspace", "!", "Space", "F14 Up"]
	}
	else
	{
		F14Keys := ["!", "Space", "F22 Down", "F14 Up"]
	}
	

	; ######## F16 Combinator ########
	
	if(GetKeyState("F20"))
	{
		F16Keys := ["!"]
	}
	else if(GetKeyState("F21"))
	{			
		F16Keys := ["Backspace", "!", "Space", "F22 Down", "F21 Up"]
	}
	else if(GetKeyState("F22"))
	{
		F16Keys := ["Backspace", "!", "Space"]
	}
	else
	{
		F16Keys := ["!", "Space", "F22 Down"]
	}


	; ######## F17 Combinator ########

	F17Keys := []

	Loop % F16Keys.Length()
	{
	    	F17Keys.Push(F16Keys[A_Index])
	}

	F17Keys.Push("F17 Up")
	
	
	; ######## Backslash Escape ########

	baseChar := "'"
	shiftChar := "!"
	numChar := "'"
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F17Keys := ["Backspace", shiftChar, "F17 Up", "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: ["'", "F13 Up"], F14: F14Keys, F16: F16Keys, F17: F17Keys})

	return


;-----------------------------------


*k::

	; ######## F13 Combinator ########
	
	if(GetKeyState("F20"))
	{
		F13Keys := ["%", "F13 Up"]
	}
	else if(GetKeyState("F21"))
	{			
		F13Keys := ["Backspace", "%", "Space", "F13 Up"]
	}
	else if(GetKeyState("F22"))
	{
		F13Keys := ["Backspace", "%", "Space", "F21 Down", "F13 Up", "F22 Up"]
	}
	else
	{
		F13Keys := ["%", "Space", "F21 Down", "F13 Up"]
	}


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("K")


	; ######## F15 Combinator ########
	
	if(GetKeyState("F20"))
	{
		F15Keys := "%"
	}
	else if(GetKeyState("F21"))
	{			
		F15Keys := ["Backspace", "%", "Space"]
	}
	else if(GetKeyState("F22"))
	{
		F15Keys := ["Backspace", "%", "Space", "F21 Down", "F22 Up"]
	}
	else
	{
		F15Keys := ["%", "Space", "F21 Down"]
	}


	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("K")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
		; ######## Backslash Escape ########

	baseChar := "k"
	shiftChar := "K"
	numChar := "%"
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["K", "F22 Up"]})

	return

*d::

	; ######## F13 Combinator ########
	
	if(GetKeyState("F21"))
	{			
		F13Keys := ["/", "F13 Up", "F21 Up"]
	}
	else if(GetKeyState("F22"))
	{
		F13Keys := ["/", "F13 Up", "F22 Up"]
	}
	else
	{
		F13Keys := ["/", "F13 Up"]
	}


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("D")


	; ######## F15 Combinator ########
	
	if(GetKeyState("F21"))
	{			
		F15Keys := ["/", "F21 Up"]
	}
	else if(GetKeyState("F22"))
	{
		F15Keys := ["/", "F22 Up"]
	}
	else
	{
		F15Keys := "/"
	}

	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("D")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "d"
	shiftChar := "D"
	numChar := "/"
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["D", "F22 Up"]})

	return

*c::

	; ######## F13 Combinator ########
	
	if(GetKeyState("F20"))
	{
		F13Keys := ["-", "F13 Up"]
	}
	else if(GetKeyState("F21"))
	{			
		F13Keys := ["Backspace", "-", "F13 Up"]
	}
	else if(GetKeyState("F22"))
	{
		F13Keys := ["Backspace", "-", "F21 Down", "F13 Up", "F22 Up"]
	}
	else
	{
		F13Keys := ["-", "F21 Down", "F13 Up"]
	}


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("C")


	; ######## F15 Combinator ########
	
	if(GetKeyState("F20"))
	{
		F15Keys := "-"
	}
	else if(GetKeyState("F21"))
	{			
		F15Keys := ["Backspace", "-"]
	}
	else if(GetKeyState("F22"))
	{
		F15Keys := ["Backspace", "-", "F21 Down", "F22 Up"]
	}
	else
	{
		F15Keys := ["-", "F21 Down"]
	}


	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("C")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "c"
	shiftChar := "C"
	numChar := "-"
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["C", "F22 Up"]})

	return

*l::

	; ######## F13 Combinator ########

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel + 1
	WriteNestLevelIfApplicable_Opening(nestLevel)
	
	F13Keys := F13Keys_Opening_PassThroughCap("*", "*")


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("L")


	; ######## F15 Combinator ########
	
	F15Keys := F15Keys_Opening_PassThroughCap("*", "*")


	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("L")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "l"
	shiftChar := "L"
	numChar := "*"
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["L", "F22 Up"]})

	return

*p::

	; ######## F13 Combinator ########

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel + 1
	WriteNestLevelIfApplicable_Opening(nestLevel)
	
	F13Keys := F13Keys_Opening_PassThroughCap("+", "+")


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("P")


	; ######## F15 Combinator ########
	
	F15Keys := F15Keys_Opening_PassThroughCap("+", "+")


	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("P")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "p"
	shiftChar := "P"
	numChar := "+"
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["P", "F22 Up"]})

	return

*q::

	; ######## F13 Combinator ########

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel + 1
	WriteNestLevelIfApplicable_Opening(nestLevel)
	
	F13Keys := F13Keys_Opening_PassThroughCap("^", "^")


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("Q")


	; ######## F15 Combinator ########
	
	F15Keys := F15Keys_Opening_PassThroughCap("^", "^")


	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("Q")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "q"
	shiftChar := "Q"
	numChar := "^"
	
	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["Q", "F22 Up"]})

	return



; Home Row
;-------------------------------------------------

*Enter::
	
	currentEnterDown := A_TickCount

	if((currentEnterDown - lastEnterDown) < 1000)
	{
		dual.comboKey()
	}
	else
	{
		; ######## Backslash Escape ########
		
		if(GetKeyState("F18"))
		{
			F21Keys := ["Backspace", "Enter"]
			F22Keys := ["Backspace", "Enter"]
		}
		
		dual.comboKey(["Enter", "F22 Down"], {F20: "Enter", F21: ["Backspace", "Enter", "F22 Down", "F21 Up"], F22: ["Backspace", "Enter"]})
	}

	lastEnterDown := currentEnterDown

	return

*h::

	; ######## Suppress Keypress If Switching Desktops ########

	if(GetKeyState("F14") and GetKeyState("F17"))
	{
		return
	}
	

	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_Number("2", lastRealKeyDown)


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("H")


	; ######## F15 Combinator ########
	
	F15Keys := F15Keys_Number("2", lastRealKeyDown)


	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("H")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "h"
	shiftChar := "H"
	numChar := "2"
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["H", "F22 Up"]})

	return

*i::

	; ######## Suppress Keypress If Switching Desktops ########

	if(GetKeyState("F14") and GetKeyState("F17"))
	{
		return
	}
	

	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_Number("3", lastRealKeyDown)


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("I")


	; ######## F15 Combinator ########
	
	F15Keys := F15Keys_Number("3", lastRealKeyDown)


	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("I")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "i"
	shiftChar := "I"
	numChar := "3"
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["I", "F22 Up"]})

	return

*e::

	; ######## Suppress Keypress If Switching Desktops ########

	if(GetKeyState("F14") and GetKeyState("F17"))
	{
		return
	}
	

	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_Number("5", lastRealKeyDown)


	; ######## F14 Combinator ########

	F14Keys := F14Keys_Letter("E")


	; ######## F15 Combinator ########
	
	F15Keys := F15Keys_Number("5", lastRealKeyDown)


	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("E")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "e"
	shiftChar := "E"
	numChar := "5"
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["E", "F22 Up"]})

	return

*a::

	; ######## Suppress Keypress If Switching Desktops ########

	if(GetKeyState("F14") and GetKeyState("F17"))
	{
		return
	}
	

	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_Number("7", lastRealKeyDown)


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("A")


	; ######## F15 Combinator ########
	
	F15Keys := F15Keys_Number("7", lastRealKeyDown)


	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("A")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "a"
	shiftChar := "A"
	numChar := "7"
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["A", "F22 Up"]})

	return

*.::

	; ######## F13 Combinator ########

	F13Keys := [".", "F13 Up"]


	; ######## F14 Combinator ########
	
	F14Keys := [".", "F14 Up"]


	; ######## F15 Combinator ########

	F15Keys := "."
	

	; ######## F16 Combinator ########
	
	F16Keys := "."


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Default Keys and F21 and F22 Combinators ########

	if(GetKeyState("F20"))
	{
		defaultKeys := ["."]
		F21Keys := ["."]
		F22Keys := ["."]
	}
	else
	{
		defaultKeys := [".", "Space", "F22 Down"]
		F21Keys := ["Backspace", ".", "Space", "F22 Down", "F21 Up"]
		F22Keys := ["Backspace", ".", "Space"]
	}
	
	; ######## Backslash Escape ########

	baseChar := "."
	shiftChar := "."
	numChar := "."
	
	

	if(GetKeyState("F18"))
	{
		defaultKeys := ["Backspace", baseChar, "F18 Up"]
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}


	dual.comboKey(defaultKeys, {F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F20: baseChar, F21: F21Keys, F22: F22Keys})

	return


;-----------------------------------


*m::

	; ######## Suppress Keypress If Switching Desktops ########

	if(GetKeyState("F14") and GetKeyState("F17"))
	{
		return
	}
	

	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_Number("8", lastRealKeyDown)


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("M")


	; ######## F15 Combinator ########
	
	F15Keys := F15Keys_Number("8", lastRealKeyDown)


	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("M")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "m"
	shiftChar := "M"
	numChar := "8"
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["M", "F22 Up"]})

	return

*t::

	; ######## Suppress Keypress If Switching Desktops ########

	if(GetKeyState("F14") and GetKeyState("F17"))
	{
		return
	}
	

	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_Number("0", lastRealKeyDown)


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("T")


	; ######## F15 Combinator ########
	
	F15Keys := F15Keys_Number("0", lastRealKeyDown)


	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("T")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "t"
	shiftChar := "T"
	numChar := "0"
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["T", "F22 Up"]})

	return

*s::

	; ######## Suppress Keypress If Switching Desktops ########

	if(GetKeyState("F14") and GetKeyState("F17"))
	{
		return
	}
	

	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_Number("6", lastRealKeyDown)


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("S")


	; ######## F15 Combinator ########
	
	F15Keys := F15Keys_Number("6", lastRealKeyDown)


	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("S")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "s"
	shiftChar := "S"
	numChar := "6"
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["S", "F22 Up"]})

	return

*r::

	; ######## Suppress Keypress If Switching Desktops ########

	if(GetKeyState("F14") and GetKeyState("F17"))
	{
		return
	}
	

	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_Number("4", lastRealKeyDown)


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("R")


	; ######## F15 Combinator ########
	
	F15Keys := F15Keys_Number("4", lastRealKeyDown)


	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("R")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "r"
	shiftChar := "R"
	numChar := "4"
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["R", "F22 Up"]})

	return

*n::

	; ######## Suppress Keypress If Switching Desktops ########

	if(GetKeyState("F14") and GetKeyState("F17"))
	{
		return
	}
	

	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_Number("1", lastRealKeyDown)


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("N")


	; ######## F15 Combinator ########
	
	F15Keys := F15Keys_Number("1", lastRealKeyDown)


	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("N")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "n"
	shiftChar := "N"
	numChar := "1"
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["N", "F22 Up"]})

	return

*v::

	; ######## F13 Combinator ########
	
	if(GetKeyState("F20"))
	{
		F13Keys := ["|", "F13 Up"]
	}
	else if(GetKeyState("F21"))
	{			
		F13Keys := ["|", "Space", "F13 Up"]
	}
	else if(GetKeyState("F22"))
	{
		F13Keys := ["|", "Space", "F21 Down", "F13 Up", "F22 Up"]
	}
	else
	{
		F13Keys := ["Space", "|", "Space", "F21 Down", "F13 Up"]
	}


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("V")


	; ######## F15 Combinator ########
	
	if(GetKeyState("F20"))
	{
		F15Keys := "|"
	}
	else if(GetKeyState("F21"))
	{			
		F15Keys := ["|", "Space"]
	}
	else if(GetKeyState("F22"))
	{
		F15Keys := ["|", "Space", "F21 Down", "F22 Up"]
	}
	else
	{
		F15Keys := ["Space", "|", "Space", "F21 Down"]
	}


	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("V")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "v"
	shiftChar := "V"
	numChar := "|"
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["V", "F22 Up"]})

	return



; Bottom Row
;-------------------------------------------------

*Tab::dual.comboKey()

*x::

	; ######## F13 Combinator ########
	
	if(GetKeyState("F20"))
	{
		F13Keys := ["$", "F13 Up"]
	}
	else if(GetKeyState("F21"))
	{			
		F13Keys := ["$", "F13 Up"]
	}
	else if(GetKeyState("F22"))
	{
		F13Keys := ["$", "F21 Down", "F13 Up", "F22 Up"]
	}
	else
	{
		F13Keys := ["Space", "$", "F21 Down", "F13 Up"]
	}


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("X")


	; ######## F15 Combinator ########
	
	if(GetKeyState("F20"))
	{
		F15Keys := "$"
	}
	else if(GetKeyState("F21"))
	{			
		F15Keys := "$"
	}
	else if(GetKeyState("F22"))
	{
		F15Keys := ["$", "F21 Down", "F22 Up"]
	}
	else
	{
		F15Keys := ["Space", "$", "F21 Down"]
	}


	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("X")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "x"
	shiftChar := "X"
	numChar := "$"
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["X", "F22 Up"]})

	return

*-::

	; ######## F14 Combinator ########

	if(GetKeyState("F20"))
	{
		F14Keys := [";", "F14 Up"]
	}
	else if(GetKeyState("F21"))
	{			
		F14Keys := ["Backspace", ";", "Space", "F14 Up"]
	}
	else if(GetKeyState("F22"))
	{
		F14Keys := ["Backspace", ";", "Space", "F21 Down", "F22 Up", "F14 Up"]
	}
	else
	{
		F14Keys := [";", "Space", "F21 Down", "F14 Up"]
	}


	; ######## F16 Combinator ########
	
	if(GetKeyState("F20"))
	{
		F16Keys := [";"]
	}
	else if(GetKeyState("F21"))
	{			
		F16Keys := ["Backspace", ";", "Space"]
	}
	else if(GetKeyState("F22"))
	{
		F16Keys := ["Backspace", ";", "Space", "F21 Down", "F22 Up"]
	}
	else
	{
		F16Keys := [";", "Space", "F21 Down"]
	}


	; ######## F17 Combinator ########

	F17Keys := []

	Loop % F16Keys.Length()
	{
	    	F17Keys.Push(F16Keys[A_Index])
	}

	F17Keys.Push("F17 Up")


	; ######## Default Keys and F21 and F22 Combinators ########

	if(GetKeyState("F20"))
	{
		defaultKeys := [""""]
		F21Keys := [""""]
		F22Keys := [""""]
	}
	else
	{
		IniRead, inQuote, Status.ini, nestVars, inQuote
		IniRead, nestLevel, Status.ini, nestVars, nestLevel

		if(inQuote)
		{
			inQuote := false
			nestLevel := nestLevel - 1
			
			actuallyNeedToWrite := !(GetKeyState("F14") or GetKeyState("F16") or (GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15"))))
			
			if(actuallyNeedToWrite)
			{
				IniWrite, %inQuote%, Status.ini, nestVars, inQuote
				IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel
			}
		
			if(nestLevel > 0)
			{
				defaultKeys := ["Right", "Space", "F21 Down"]
				F21Keys := ["Backspace", "Right", "Space"]
				F22Keys := ["Backspace", "Right", "Space"]
			}
			else
			{
				defaultKeys := ["Right", "Space", "F21 Down", "F23 Up"]
				F21Keys := ["Backspace", "Right", "Space", "F23 Up"]
				F22Keys := ["Backspace", "Right", "Space" "F23 Up"]
			}
		}
		else
		{
			inQuote := true
			nestLevel := nestLevel + 1
			
			actuallyNeedToWrite := !(GetKeyState("F14") or GetKeyState("F16") or (GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15"))))
			
			if(actuallyNeedToWrite)
			{
				IniWrite, %inQuote%, Status.ini, nestVars, inQuote
				IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel
				lastOpenPairDown := A_TickCount
				IniWrite, %lastOpenPairDown%, Status.ini, nestVars, lastOpenPairDown
			}
	
			if(GetKeyState("F23"))
			{
				defaultKeys := ["Space", """", """", "Left", "F21 Down"]
				F21Keys := ["""", """", "Left"]
				F22Keys := ["""", """", "Left"]
			}
			else
			{
				defaultKeys := ["Space", """", """", "Left", "F21 Down", "F23 Down"]
				F21Keys := ["""", """", "Left", "F23 Down"]
				F22Keys := ["""", """", "Left", "F23 Down"]
			}
		}
	}


	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_PuncCombinator(defaultKeys, F21Keys, F22Keys)


	; ######## F15 Combinator ########
	
	if(GetKeyState("F20"))
	{
		F15Keys := """"
	}
	else if(GetKeyState("F21"))
	{			
		F15Keys := F21Keys
	}
	else if(GetKeyState("F22"))
	{
		F15Keys := F22Keys
	}
	else
	{
		F15Keys := defaultKeys
	}

	
	; ######## Backslash Escape ########

	baseChar := """"
	shiftChar := ";"
	numChar := """"
	
	
	
	if(GetKeyState("F18"))
	{
		defaultKeys := ["Backspace", baseChar, "F18 Up"]
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F17Keys := ["Backspace", shiftChar, "F17 Up", "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}
	

	dual.comboKey(defaultKeys, {F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F17: F17Keys, F20: baseChar, F21: F21Keys, F22: F22Keys})

	return

*/::

	; ######## F14 Combinator ########

	if(GetKeyState("F20"))
	{
		F14Keys := ["—", "F14 Up"]
	}
	else if(GetKeyState("F21"))
	{			
		F14Keys := ["Backspace", "—", "F14 Up"]
	}
	else if(GetKeyState("F22"))
	{
		F14Keys := ["Backspace", "—", "F21 Down", "F22 Up", "F14 Up"]
	}
	else
	{
		F14Keys := ["—", "F21 Down", "F14 Up"]
	}


	; ######## F16 Combinator ########
	
	if(GetKeyState("F20"))
	{
		F16Keys := ["—"]
	}
	else if(GetKeyState("F21"))
	{			
		F16Keys := ["Backspace", "—"]
	}
	else if(GetKeyState("F22"))
	{
		F16Keys := ["Backspace", "—", "F21 Down", "F22 Up"]
	}
	else
	{
		F16Keys := ["—", "F21 Down"]
	}


	; ######## F17 Combinator ########

	F17Keys := []

	Loop % F16Keys.Length()
	{
	    	F17Keys.Push(F16Keys[A_Index])
	}

	F17Keys.Push("F17 Up")


	; ######## Default Keys and F21 and F22 Combinators ########

	if(GetKeyState("F23"))
	{
		IniRead, nestLevel, Status.ini, nestVars, nestLevel
		nestLevel := nestLevel - 1
		
		actuallyNeedToWrite := !(GetKeyState("F14") or GetKeyState("F16") or (GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15"))))
			
		if(actuallyNeedToWrite)
		{
			IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel
		}
	
		if(nestLevel > 0)

		{
			defaultKeys := ["Right", "Space", "F21 Down"]
			F21Keys := ["Backspace", "Right", "Space"]
			F22Keys := ["Backspace", "Right", "Space"]
		}
		else
		{
			defaultKeys := ["Right", "Space", "F21 Down", "F23 Up"]
			F21Keys := ["Backspace", "Right", "Space", "F23 Up"]
			F22Keys := ["Backspace", "Right", "Space" "F23 Up"]
		}
	}
	else
	{
		defaultKeys := [")"]
		F21Keys := [")"]
		F22Keys := [")"]
	}


	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_PuncCombinator(defaultKeys, F21Keys, F22Keys)


	; ######## F15 Combinator ########
	
	if(GetKeyState("F20"))
	{
		F15Keys := ")"
	}
	else if(GetKeyState("F21"))
	{			
		F15Keys := F21Keys
	}
	else if(GetKeyState("F22"))
	{
		F15Keys := F22Keys
	}
	else
	{
		F15Keys := defaultKeys
	}
	
	
	; ######## Backslash Escape ########

	baseChar := ")"
	shiftChar := "—"
	numChar := ")"
	
	

	if(GetKeyState("F18"))
	{
		defaultKeys := ["Backspace", baseChar, "F18 Up"]
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F17Keys := ["Backspace", shiftChar, "F17 Up", "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}


	dual.comboKey(defaultKeys, {F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F17: F17Keys, F20: baseChar, F21: F21Keys, F22: F22Keys})

	return

*,::

	; ######## F14 Combinator ########

	if(GetKeyState("F20"))
	{
		F14Keys := ["_", "F14 Up"]
	}
	else
	{
			IniRead, nestLevel, Status.ini, nestVars, nestLevel
			nestLevel := nestLevel + 1
			
			actuallyNeedToWrite := GetKeyState("F14") or GetKeyState("F16") or (GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))

			if(actuallyNeedToWrite)
			{
				IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel
				lastOpenPairDown := A_TickCount
				IniWrite, %lastOpenPairDown%, Status.ini, nestVars, lastOpenPairDown
			}
			
		if(GetKeyState("F23"))
		{
			if(GetKeyState("F21"))
			{			
				F14Keys := ["_", "_", "Left", "F14 Up"]
			}
			else if(GetKeyState("F22"))
			{
				F14Keys := ["_", "_", "Left", "F14 Up"]
			}
			else
			{
				F14Keys := ["Space", "_", "_", "Left", "F21 Down", "F14 Up"]
			}
		}
		else
		{
			if(GetKeyState("F21"))
			{			
				F14Keys := ["_", "_", "Left", "F23 Down", "F14 Up"]
			}
			else if(GetKeyState("F22"))
			{
				F14Keys := ["_", "_", "Left", "F23 Down", "F14 Up"]
			}
			else
			{
				F14Keys := ["Space", "_", "_", "Left", "F21 Down", "F23 Down", "F14 Up"]
			}
		}
	}


	; ######## F16 Combinator ########

	if(GetKeyState("F20"))
	{
		F14Keys := ["_"]
	}
	else
	{
			IniRead, nestLevel, Status.ini, nestVars, nestLevel
			nestLevel := nestLevel + 1
			
			actuallyNeedToWrite := GetKeyState("F14") or GetKeyState("F16") or (GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))

			if(actuallyNeedToWrite)
			{
				IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel
				lastOpenPairDown := A_TickCount
				IniWrite, %lastOpenPairDown%, Status.ini, nestVars, lastOpenPairDown
			}
			
		if(GetKeyState("F23"))
		{
			if(GetKeyState("F21"))
			{			
				F16Keys := ["_", "_", "Left"]
			}
			else if(GetKeyState("F22"))
			{
				F16Keys := ["_", "_", "Left"]
			}
			else
			{
				F16Keys := ["Space", "_", "_", "Left", "F21 Down"]
			}
		}
		else
		{
			if(GetKeyState("F21"))
			{			
				F16Keys := ["_", "_", "Left", "F23 Down"]
			}
			else if(GetKeyState("F22"))
			{
				F16Keys := ["_", "_", "Left", "F23 Down"]
			}
			else
			{
				F16Keys := ["Space", "_", "_", "Left", "F21 Down", "F23 Down"]
			}
		}
	}


	; ######## F17 Combinator ########
	
	F17Keys := []

	Loop % F16Keys.Length()
	{
	    	F17Keys.Push(F16Keys[A_Index])
	}

	F17Keys.Push("F17 Up")


	; ######## Default Keys and F21 and F22 Combinators ########

	if(GetKeyState("F20"))
	{
		defaultKeys := [","]
		F21Keys := [","]
		F22Keys := [","]
	}
	else
	{	
		defaultKeys := [",", "Space", "F21 Down"]
		F21Keys := ["Backspace", ",", "Space"]
		F22Keys := ["Backspace", ",", "F21 Down", "F22 Up"]
	}


	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_PuncCombinator(defaultKeys, F21Keys, F22Keys)


	; ######## F15 Combinator ########
	
	if(GetKeyState("F20"))
	{
		F15Keys := ","
	}
	else if(GetKeyState("F21"))
	{			
		F15Keys := F21Keys
	}
	else if(GetKeyState("F22"))
	{
		F15Keys := F22Keys
	}
	else
	{
		F15Keys := defaultKeys
	}
	
	
	; ######## Backslash Escape ########

	baseChar := ","
	shiftChar := "_"
	numChar := ","
	
	

	if(GetKeyState("F18"))
	{
		defaultKeys := ["Backspace", baseChar, "F18 Up"]
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F17Keys := ["Backspace", shiftChar, "F17 Up", "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}


	dual.comboKey(defaultKeys, {F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F17: F17Keys, F20: baseChar, F21: F21Keys, F22: F22Keys})

	return

*`::

	; ######## F14 Combinator ########

	if(GetKeyState("F20"))
	{
		F14Keys := ["?", "F14 Up"]
	}
	else if(GetKeyState("F21"))
	{			
		F14Keys := ["Backspace", "?", "Space", "F22 Down", "F21 Up", "F14 Up"]
	}
	else if(GetKeyState("F22"))
	{
		F14Keys := ["Backspace", "?", "Space", "F14 Up"]
	}
	else
	{
		F14Keys := ["?", "Space", "F22 Down", "F14 Up"]
	}


	; ######## F16 Combinator ########

	if(GetKeyState("F20"))
	{
		F16Keys := ["?"]
	}
	else if(GetKeyState("F21"))
	{			
		F16Keys := ["Backspace", "?", "Space", "F22 Down", "F21 Up"]
	}
	else if(GetKeyState("F22"))
	{
		F16Keys := ["Backspace", "?", "Space"]
	}
	else
	{
		F16Keys := ["?", "Space", "F22 Down"]
	}


	; ######## F17 Combinator ########

	F17Keys := []

	Loop % F16Keys.Length()
	{
	    	F17Keys.Push(F16Keys[A_Index])
	}

	F17Keys.Push("F17 Up")


	; ######## Default Keys and F21 and F22 Combinators ########

	if(GetKeyState("F20"))
	{
		defaultKeys := ["("]
		F21Keys := ["("]
		F22Keys := ["("]
	}
	else
	{
		IniRead, nestLevel, Status.ini, nestVars, nestLevel
		nestLevel := nestLevel + 1
		
		actuallyNeedToWrite := !(GetKeyState("F14") or GetKeyState("F16") or (GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15"))))
			
		if(actuallyNeedToWrite)
		{
			IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel
			lastOpenPairDown := A_TickCount
			IniWrite, %lastOpenPairDown%, Status.ini, nestVars, lastOpenPairDown
		}
		
		if(GetKeyState("F23"))
		{
			defaultKeys := ["Space", "(", ")", "Left", "F21 Down"]
			F21Keys := ["(", ")", "Left"]
			F22Keys := ["(", ")", "Left"]
		}
		else
		{
			defaultKeys := ["Space", "(", ")", "Left", "F21 Down", "F23 Down"]
			F21Keys := ["(", ")", "Left", "F23 Down"]
			F22Keys := ["(", ")", "Left", "F23 Down"]
		}
	}


	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_PuncCombinator(defaultKeys, F21Keys, F22Keys)


	; ######## F15 Combinator ########
	
	if(GetKeyState("F20"))
	{
		F15Keys := "("
	}
	else if(GetKeyState("F21"))
	{			
		F15Keys := F21Keys
	}
	else if(GetKeyState("F22"))
	{
		F15Keys := F22Keys
	}
	else
	{
		F15Keys := defaultKeys
	}

	
	; ######## Backslash Escape ########

	baseChar := "("
	shiftChar := "?"
	numChar := "("
	
	

	if(GetKeyState("F18"))
	{
		defaultKeys := ["Backspace", baseChar, "F18 Up"]
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F17Keys := ["Backspace", shiftChar, "F17 Up", "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}
	

	dual.comboKey(defaultKeys, {F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F17: F17Keys, F20: baseChar, F21: F21Keys, F22: F22Keys})

	return


;-----------------------------------


*w::

	; ######## Suppress Keypress If Switching Desktops ########

	if(GetKeyState("F14") and GetKeyState("F17"))
	{
		return
	}
	

	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_Number("9", lastRealKeyDown)


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("W")


	; ######## F15 Combinator ########
	
	F15Keys := F15Keys_Number("9", lastRealKeyDown)


	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("W")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "w"
	shiftChar := "W"
	numChar := "9"
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["W", "F22 Up"]})

	return

*g::

	; ######## F13 Combinator ########
	
	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel + 1
	WriteNestLevelIfApplicable_Opening(nestLevel)
	
	F13Keys := F13Keys_Opening_NoCap("=", "=")


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("G")


	; ######## F15 Combinator ########
	
	F15Keys := F15Keys_Opening_NoCap("=", "=")


	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("G")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "g"
	shiftChar := "G"
	numChar := "="
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["G", "F22 Up"]})

	return

*f::

	; ######## F13 Combinator ########
	
	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel + 1
	WriteNestLevelIfApplicable_Opening(nestLevel)
	
	F13Keys := F13Keys_Opening_NoCap("<", ">")


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("F")


	; ######## F15 Combinator ########
	
	F15Keys := F15Keys_Opening_NoCap("<", ">")


	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("F")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "f"
	shiftChar := "F"
	numChar := "<"
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["F", "F22 Up"]})

	return

*j::

	; ######## F13 Combinator ########
	
	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel - 1
	WriteNestLevelIfApplicable_Closing(nestLevel)

	F13Keys := F13Keys_Closing(">", nestLevel)


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("J")


	; ######## F15 Combinator ########
	
	F15Keys := F15Keys_Closing(">", nestLevel)


	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("J")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "j"
	shiftChar := "J"
	numChar := ">"
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["J", "F22 Up"]})

	return

*z::

	; ######## F13 Combinator ########
	
	if(GetKeyState("F20"))
	{
		F13Keys := ["&", "F13 Up"]
	}
	else if(GetKeyState("F21"))
	{			
		F13Keys := ["&", "F13 Up"]
	}
	else if(GetKeyState("F22"))
	{
		F13Keys := ["&", "F21 Down", "F13 Up", "F22 Up"]
	}
	else
	{
		F13Keys := ["Space", "&", "F21 Down", "F13 Up"]
	}


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("Z")


	; ######## F15 Combinator ########
	
	if(GetKeyState("F20"))
	{
		F15Keys := "&"
	}
	else if(GetKeyState("F21"))
	{			
		F15Keys := "&"
	}
	else if(GetKeyState("F22"))
	{
		F15Keys := ["&", "F21 Down", "F22 Up"]
	}
	else
	{
		F15Keys := ["Space", "&", "F21 Down"]
	}


	; ######## F16 Combinator ########
	
	F16Keys := F16Keys_Letter("Z")


	; ######## F17 Combinator ########

	if(GetKeyState("F17") and !(GetKeyState("F13") or GetKeyState("F15")))
	{
		SendInput {F17 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "z"
	shiftChar := "Z"
	numChar := "&"
	
	

	if(GetKeyState("F18"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F18 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F18 Up"]
		F15Keys := ["Backspace", numChar, "F18 Up"]
		F16Keys := ["Backspace", shiftChar, "F18 Up"]
		F21Keys := ["Backspace", baseChar, "F18 Up", "F21 Up"]
		F22Keys := ["Backspace", baseChar, "F18 Up", "F22 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F15: F15Keys, F16: F16Keys, F21: [A_ThisHotkey, "F21 Up"], F22: ["Z", "F22 Up"]})

	return

*Del::dual.comboKey()



; Thumbs
;-------------------------------------------------

*=::

	; ######## F14 Combinator ########

	if(GetKeyState("F14"))
	{
		SendInput ^+,{F14 Up}
		return
	}


	; ######## F18 Combinator ########

;;;;;;;; TODO: Window Commands

;	if(Dual.cleanKey(A_PriorHotkey) = "\")
;	{
;		IniRead, command_PassThroughAutospacing, Status.ini, commandVars, command_PassThroughAutospacing
;		IniRead, inTextBox, Status.ini, commandVars, inTextBox
;
;		if(command_PassThroughAutospacing = "F21")
;		{
;			SendInput {F21 Down}
;		}
;		else if(command_PassThroughAutospacing = "F22")
;		{
;			SendInput {F22 Down}
;		}
;
;		if(!inTextBox)
;		{
;			SendInput {F18 Up}{Enter}
;		}
;		else
;		{
;			SendInput {Backspace}
;		}
;
;
;		SendInput {F24 Down}
;
;		return
;	}

	return
	

*Space::

	if(GetKeyState("F14")) ; Suppressing keypress when used to open window switcher
	{
		return
	}
	
	if(GetKeyState("F21") or GetKeyState("F22")) ; Suppressing keypress when pressing space would lead to a typo around punc
	{
		return
	}
	

	dual.comboKey()

	return

*1::

	lastKey := A_PriorHotkey
	if(lastKey != "*1 Up")
	{
		lastRealKeyDown := Dual.cleanKey(lastKey)
	}
	

	dual.combine("F15", "F13 Down", settings = false, {F13: "F15 Down", F14: "", F15: "F15 Up"})

	return

*1 Up::

	lastKey := A_PriorHotkey

	if(lastKey != "*1")
	{
		lastRealKeyDown := Dual.cleanKey(lastKey)
	}


	dual.combine("F15", "F13 Down", settings = false, {F13: "F15 Down", F14: "", F15: "F15 Up"})

	SendInput {F17 Down}
	
	return


*LCtrl::
*RCtrl::

	defaultKeys := ["F19 Down", "F20 Down"]
	F19Keys := ["F19 Up", "F20 Up"]

	dual.comboKey(defaultKeys, {F19: F19Keys})

	return
	


*2::

	lastKey := A_PriorHotkey
	if(lastKey != "*2 Up")
	{
		lastRealKeyDown := Dual.cleanKey(lastKey)
	}


	; ######## F21 Combinator ########

	F21Keys := ["F21 Up", "F14 Down"]


	; ######## F22 Combinator ########

	F22Keys := ["F22 Up", "F14 Down"]
	

	dual.combine("F16", "F14 Down", settings = false, {F13: [":", "F13 Up"], F14: "F16 Down", F15: ":", F16: "F16 Up", F21: F21Keys, F22: F22Keys})
	
	return

*2 Up::

	lastKey := A_PriorHotkey

	if(lastKey != "*2")
	{
		lastRealKeyDown := Dual.cleanKey(lastKey)
	}


	dual.combine("F16", "F14 Down")

	return

*Backspace::

	; ######## F13 Combinator ########

	if(GetKeyState("F13"))
	{
		SendInput !{Space}{F13 Up}
		return
	}
	
	IniRead, lastOpenPairDown, Status.ini, nestVars, lastOpenPairDown
	timeOfLastHotkey := A_TickCount - A_TimeSincePriorHotkey
	
	if((timeOfLastHotKey - lastOpenPairDown) < 50)
	{
		IniRead, nestLevel, Status.ini, nestVars, nestLevel
		nestLevel := nestLevel - 1
		IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel
		
		if(nestLevel > 0)
		{
			SendInput {Backspace}{Delete}
		}
		else
		{
			SendInput {Backspace}{Delete}{F23 Up}
		}
	
		return
	}


	dual.comboKey({F21: ["Backspace", "Backspace", "F21 Up"], F22: ["Backspace", "Backspace", "F22 Up"]})

	return

*\::

	if(GetKeyState("F21"))
	{
		command_PassThroughAutospacing := "F21"
	}
	else if(GetKeyState("F22"))
	{
		command_PassThroughAutospacing := "F22"
	}
	else
	{
		command_PassThroughAutospacing := "none"
	}

	IniWrite, %command_PassThroughAutospacing%, Status.ini, commandVars, command_PassThroughAutospacing

	inTextBox := InTextBox()
	IniWrite, %inTextBox%, Status.ini, commandVars, inTextBox
	
	if(inTextBox)
	{
		defaultKeys := ["\", "F18 Down"]
		F21Keys := ["\", "F18 Down", "F21 Up"]
		F22Keys := ["\", "F18 Down", "F22 Up"]
	}
	else 
	{
		defaultKeys := "F18 Down"
		F21Keys := ["F18 Down", "F21 Up"]
		F22Keys := ["F18 Down", "F22 Up"]
	}

	if(GetKeyState("F14"))
	{
		SendInput {F14 Up}
	}


	dual.combine("F20", defaultKeys, settings = false, {F21: F21Keys, F22: F22Keys})

	if(!inTextBox)
	{
		InputBox, command, Enter Command
	}	

	return
	
*\ Up::
	
	if(inTextBox)
	{
		defaultKeys := ["\", "F18 Down"]
	}
	else 
	{
		defaultKeys := "F18 Down"
	}
	
	
	dual.combine("F20", defaultKeys)
	
	return

	
#If
