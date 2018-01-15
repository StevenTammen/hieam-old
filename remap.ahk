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
;		 | Construct Hold						|	F15 	|
;		  ----------------------------------------------
;		 | Mouse Hold							|	F16 	|
;		  ----------------------------------------------
;		 | Num hold								|	F17 	|
;		  ----------------------------------------------
;		 | Shift hold								|	F18 	|
;		  ----------------------------------------------
;		 | Punc after Num						|	F19 	|
;		  ----------------------------------------------
;		 | Command								|	F20 	|
;		  ----------------------------------------------
;		 | No Autospacing						|	F21 	|
;		  ----------------------------------------------
;		 | Autospaced after punc			|	F22 	|
;		  ----------------------------------------------
;		 | Autospaced after .?!				|	F23 	|
;		  ----------------------------------------------
;		 | Nested punctuation					|	F24 	|
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

;    TODO: get normal text briefs working with terminating characters. Dynamic regex hotstrings with subroutines?
;    TODO: get normal text expansion with {Expd} working. E.g., u{Expd} --> you, instantly.
;    TODO: get Alt-F4 put in place for \-prefixed Esc
;    TODO: make \ into a dual role key with F21 for sequences of non-autospaced characters. Figure out how to deal with downKey and upKey differences 
;    TODO: make keys after a #@`~ on F16 layer act as if F17 was down, not F16.

;    TODO: window move/resize command layer
;    TODO: mouse layer: t-warp, warp, fast/slow
;    TODO: construct layer. Start off with Org mode and code constructs like while, switch, etc.
;    TODO: put remap, expand, and window scripts in windows startup sequence

;    TODO: Figure out why F21 Down would have to be included in both remap and expand, not just remap, to start non-autospaced. Initial key states across scripts?
;    TODO: Figure out why WinActivate on chrome class is necessary rather than using WinGetClass etc. (For script-internal window focusing)
;			WinActivate, ahk_class Chrome_WidgetWin_1



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
	

	; ######## F17 Combinator ########

	F17Keys := F17Keys_Opening_NoCap("{", "}")
	
	
	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("B")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "b"
	shiftChar := "B"
	numChar := "{"
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["B", "F23 Up"]})
	
	return

*y::

	; ######## F13 Combinator ########

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel + 1
	WriteNestLevelIfApplicable_Opening(nestLevel)
	
	F13Keys := F13Keys_Opening_PassThroughCap("[", "]")


	; ######## F14 Combinator ########

	F14Keys := F14Keys_Letter("Y")


	; ######## F17 Combinator ########
	
	F17Keys := F17Keys_Opening_PassThroughCap("[", "]")


	; ######## F18 Combinator ########

	F18Keys := F18Keys_Letter("Y")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "y"
	shiftChar := "Y"
	numChar := "["
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}


	dual.comboKey({F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["Y", "F23 Up"]})

	return

*o::

	; ######## F13 Combinator ########

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel - 1
	WriteNestLevelIfApplicable_Closing(nestLevel)

	F13Keys := F13Keys_Closing("]", nestLevel)


	; ######## F14 Combinator ########

	F14Keys := F14Keys_Letter("O")


	; ######## F17 Combinator ########
	
	F17Keys := F17Keys_Closing("]", nestLevel)


	; ######## F18 Combinator ########

	F18Keys := F18Keys_Letter("O")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "o"
	shiftChar := "O"
	numChar := "]"
	
	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}


	dual.comboKey({F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["O", "F23 Up"]})

	return

*u::

	; ######## F13 Combinator ########

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel - 1
	WriteNestLevelIfApplicable_Closing(nestLevel)

	F13Keys := F13Keys_Closing("}", nestLevel)


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("U")


	; ######## F17 Combinator ########
	
	F17Keys := F17Keys_Closing("}", nestLevel)


	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("U")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
		; ######## Backslash Escape ########

	baseChar := "u"
	shiftChar := "U"
	numChar := "}"
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}


	dual.comboKey({F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["U", "F23 Up"]})

	return

*'::

	; ######## F14 Combinator ########

	if(GetKeyState("F21"))
	{
		F14Keys := ["!", "F14 Up"]
	}
	else if(GetKeyState("F22"))
	{			
		F14Keys := ["Backspace", "!", "Space", "F23 Down", "F22 Up", "F14 Up"]
	}
	else if(GetKeyState("F23"))
	{
		F14Keys := ["Backspace", "!", "Space", "F14 Up"]
	}
	else
	{
		F14Keys := ["!", "Space", "F23 Down", "F14 Up"]
	}
	

	; ######## F18 Combinator ########
	
	if(GetKeyState("F21"))
	{
		F18Keys := ["!"]
	}
	else if(GetKeyState("F22"))
	{			
		F18Keys := ["Backspace", "!", "Space", "F23 Down", "F22 Up"]
	}
	else if(GetKeyState("F23"))
	{
		F18Keys := ["Backspace", "!", "Space"]
	}
	else
	{
		F18Keys := ["!", "Space", "F23 Down"]
	}


	; ######## F19 Combinator ########

	F19Keys := []

	Loop % F18Keys.Length()
	{
	    	F19Keys.Push(F18Keys[A_Index])
	}

	F19Keys.Push("F19 Up")
	
	
	; ######## Backslash Escape ########

	baseChar := "'"
	shiftChar := "!"
	numChar := "'"
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F19Keys := ["Backspace", shiftChar, "F19 Up", "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: ["'", "F13 Up"], F14: F14Keys, F18: F18Keys, F19: F19Keys})

	return


;-----------------------------------


*k::

	; ######## F13 Combinator ########
	
	if(GetKeyState("F21"))
	{
		F13Keys := ["%", "F13 Up"]
	}
	else if(GetKeyState("F22"))
	{			
		F13Keys := ["Backspace", "%", "Space", "F13 Up"]
	}
	else if(GetKeyState("F23"))
	{
		F13Keys := ["Backspace", "%", "Space", "F22 Down", "F13 Up", "F23 Up"]
	}
	else
	{
		F13Keys := ["%", "Space", "F22 Down", "F13 Up"]
	}


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("K")


	; ######## F17 Combinator ########
	
	if(GetKeyState("F21"))
	{
		F17Keys := "%"
	}
	else if(GetKeyState("F22"))
	{			
		F17Keys := ["Backspace", "%", "Space"]
	}
	else if(GetKeyState("F23"))
	{
		F17Keys := ["Backspace", "%", "Space", "F22 Down", "F23 Up"]
	}
	else
	{
		F17Keys := ["%", "Space", "F22 Down"]
	}


	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("K")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
		; ######## Backslash Escape ########

	baseChar := "k"
	shiftChar := "K"
	numChar := "%"
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["K", "F23 Up"]})

	return

*d::

	; ######## F13 Combinator ########
	
	if(GetKeyState("F22"))
	{			
		F13Keys := ["/", "F13 Up", "F22 Up"]
	}
	else if(GetKeyState("F23"))
	{
		F13Keys := ["/", "F13 Up", "F23 Up"]
	}
	else
	{
		F13Keys := ["/", "F13 Up"]
	}


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("D")


	; ######## F17 Combinator ########
	
	if(GetKeyState("F22"))
	{			
		F17Keys := ["/", "F22 Up"]
	}
	else if(GetKeyState("F23"))
	{
		F17Keys := ["/", "F23 Up"]
	}
	else
	{
		F17Keys := "/"
	}

	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("D")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "d"
	shiftChar := "D"
	numChar := "/"
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["D", "F23 Up"]})

	return

*c::

	; ######## F13 Combinator ########
	
	if(GetKeyState("F21"))
	{
		F13Keys := ["-", "F13 Up"]
	}
	else if(GetKeyState("F22"))
	{			
		F13Keys := ["Backspace", "-", "F13 Up"]
	}
	else if(GetKeyState("F23"))
	{
		F13Keys := ["Backspace", "-", "F22 Down", "F13 Up", "F23 Up"]
	}
	else
	{
		F13Keys := ["-", "F22 Down", "F13 Up"]
	}


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("C")


	; ######## F17 Combinator ########
	
	if(GetKeyState("F21"))
	{
		F17Keys := "-"
	}
	else if(GetKeyState("F22"))
	{			
		F17Keys := ["Backspace", "-"]
	}
	else if(GetKeyState("F23"))
	{
		F17Keys := ["Backspace", "-", "F22 Down", "F23 Up"]
	}
	else
	{
		F17Keys := ["-", "F22 Down"]
	}


	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("C")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "c"
	shiftChar := "C"
	numChar := "-"
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["C", "F23 Up"]})

	return

*l::

	; ######## F13 Combinator ########

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel + 1
	WriteNestLevelIfApplicable_Opening(nestLevel)
	
	F13Keys := F13Keys_Opening_PassThroughCap("*", "*")


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("L")


	; ######## F17 Combinator ########
	
	F17Keys := F17Keys_Opening_PassThroughCap("*", "*")


	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("L")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "l"
	shiftChar := "L"
	numChar := "*"
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["L", "F23 Up"]})

	return

*p::

	; ######## F13 Combinator ########

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel + 1
	WriteNestLevelIfApplicable_Opening(nestLevel)
	
	F13Keys := F13Keys_Opening_PassThroughCap("+", "+")


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("P")


	; ######## F17 Combinator ########
	
	F17Keys := F17Keys_Opening_PassThroughCap("+", "+")


	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("P")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "p"
	shiftChar := "P"
	numChar := "+"
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["P", "F23 Up"]})

	return

*q::

	; ######## F13 Combinator ########

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel + 1
	WriteNestLevelIfApplicable_Opening(nestLevel)
	
	F13Keys := F13Keys_Opening_PassThroughCap("^", "^")


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("Q")


	; ######## F17 Combinator ########
	
	F17Keys := F17Keys_Opening_PassThroughCap("^", "^")


	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("Q")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "q"
	shiftChar := "Q"
	numChar := "^"
	
	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["Q", "F23 Up"]})

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
		
		if(GetKeyState("F20"))
		{
			F22Keys := ["Backspace", "Enter"]
			F23Keys := ["Backspace", "Enter"]
		}
		
		dual.comboKey(["Enter", "F23 Down"], {F21: "Enter", F22: ["Backspace", "Enter", "F23 Down", "F22 Up"], F23: ["Backspace", "Enter"]})
	}

	lastEnterDown := currentEnterDown

	return

*h::

	; ######## Suppress Keypress If Switching Desktops ########

	if(GetKeyState("F14") and GetKeyState("F19"))
	{
		return
	}
	

	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_Number("2", lastRealKeyDown)


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("H")
	
	
	; ######## F16 Combinator ########
	
	F16Keys := "#"


	; ######## F17 Combinator ########
	
	F17Keys := F17Keys_Number("2", lastRealKeyDown)


	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("H")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "h"
	shiftChar := "H"
	numChar := "2"
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F16Keys := ["Backspace", "#", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F16: F16Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["H", "F23 Up"]})

	return

*i::

	; ######## Suppress Keypress If Switching Desktops ########

	if(GetKeyState("F14") and GetKeyState("F19"))
	{
		return
	}
	

	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_Number("3", lastRealKeyDown)


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("I")

	
	; ######## F16 Combinator ########
	
	F16Keys := "@"
	

	; ######## F17 Combinator ########
	
	F17Keys := F17Keys_Number("3", lastRealKeyDown)


	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("I")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "i"
	shiftChar := "I"
	numChar := "3"
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F16Keys := ["Backspace", "@", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F16: F16Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["I", "F23 Up"]})

	return

*e::

	; ######## Suppress Keypress If Switching Desktops ########

	if(GetKeyState("F14") and GetKeyState("F19"))
	{
		return
	}
	

	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_Number("5", lastRealKeyDown)


	; ######## F14 Combinator ########

	F14Keys := F14Keys_Letter("E")


	; ######## F17 Combinator ########
	
	F17Keys := F17Keys_Number("5", lastRealKeyDown)


	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("E")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "e"
	shiftChar := "E"
	numChar := "5"
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["E", "F23 Up"]})

	return

*a::

	; ######## Suppress Keypress If Switching Desktops ########

	if(GetKeyState("F14") and GetKeyState("F19"))
	{
		return
	}
	

	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_Number("7", lastRealKeyDown)


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("A")


	; ######## F17 Combinator ########
	
	F17Keys := F17Keys_Number("7", lastRealKeyDown)


	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("A")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "a"
	shiftChar := "A"
	numChar := "7"
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["A", "F23 Up"]})

	return

*.::

	; ######## F13 Combinator ########

	F13Keys := [".", "F13 Up"]


	; ######## F14 Combinator ########
	
	F14Keys := [".", "F14 Up"]


	; ######## F17 Combinator ########

	F17Keys := "."
	

	; ######## F18 Combinator ########
	
	F18Keys := "."


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Default Keys and F22 and F23 Combinators ########

	if(GetKeyState("F21"))
	{
		defaultKeys := ["."]
		F22Keys := ["."]
		F23Keys := ["."]
	}
	else
	{
		defaultKeys := [".", "Space", "F23 Down"]
		F22Keys := ["Backspace", ".", "Space", "F23 Down", "F22 Up"]
		F23Keys := ["Backspace", ".", "Space"]
	}
	
	; ######## Backslash Escape ########

	baseChar := "."
	shiftChar := "."
	numChar := "."
	
	

	if(GetKeyState("F20"))
	{
		defaultKeys := ["Backspace", baseChar, "F20 Up"]
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}


	dual.comboKey(defaultKeys, {F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F21: baseChar, F22: F22Keys, F23: F23Keys})

	return


;-----------------------------------


*m::

	; ######## Suppress Keypress If Switching Desktops ########

	if(GetKeyState("F14") and GetKeyState("F19"))
	{
		return
	}
	

	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_Number("8", lastRealKeyDown)


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("M")
	
	
	; ######## F16 Combinator ########

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel + 1
	
	actuallyNeedToWrite := (GetKeyState("F16"))
	
	if(actuallyNeedToWrite)
	{
		IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel
		lastOpenPairDown := A_TickCount
		IniWrite, %lastOpenPairDown%, Status.ini, nestVars, lastOpenPairDown
	}
	
	F16Keys := F16Keys_Opening_NoCap("``", "``")


	; ######## F17 Combinator ########
	
	F17Keys := F17Keys_Number("8", lastRealKeyDown)


	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("M")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "m"
	shiftChar := "M"
	numChar := "8"
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F16Keys := ["Backspace", "``", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F16: F16Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["M", "F23 Up"]})

	return

*t::

	; ######## Suppress Keypress If Switching Desktops ########

	if(GetKeyState("F14") and GetKeyState("F19"))
	{
		return
	}
	

	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_Number("0", lastRealKeyDown)


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("T")


	; ######## F17 Combinator ########
	
	F17Keys := F17Keys_Number("0", lastRealKeyDown)


	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("T")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "t"
	shiftChar := "T"
	numChar := "0"
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["T", "F23 Up"]})

	return

*s::

	; ######## Suppress Keypress If Switching Desktops ########

	if(GetKeyState("F14") and GetKeyState("F19"))
	{
		return
	}
	

	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_Number("6", lastRealKeyDown)


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("S")


	; ######## F17 Combinator ########
	
	F17Keys := F17Keys_Number("6", lastRealKeyDown)


	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("S")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "s"
	shiftChar := "S"
	numChar := "6"
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["S", "F23 Up"]})

	return

*r::

	; ######## Suppress Keypress If Switching Desktops ########

	if(GetKeyState("F14") and GetKeyState("F19"))
	{
		return
	}
	

	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_Number("4", lastRealKeyDown)


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("R")


	; ######## F17 Combinator ########
	
	F17Keys := F17Keys_Number("4", lastRealKeyDown)


	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("R")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "r"
	shiftChar := "R"
	numChar := "4"
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["R", "F23 Up"]})

	return

*n::

	; ######## Suppress Keypress If Switching Desktops ########

	if(GetKeyState("F14") and GetKeyState("F19"))
	{
		return
	}
	

	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_Number("1", lastRealKeyDown)


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("N")
	
	
	; ######## F16 Combinator ########

	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel + 1
	
	actuallyNeedToWrite := (GetKeyState("F16"))
	
	if(actuallyNeedToWrite)
	{
		IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel
		lastOpenPairDown := A_TickCount
		IniWrite, %lastOpenPairDown%, Status.ini, nestVars, lastOpenPairDown
	}
	
	F16Keys := F16Keys_Opening_PassThroughCap("~", "~")


	; ######## F17 Combinator ########
	
	F17Keys := F17Keys_Number("1", lastRealKeyDown)


	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("N")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "n"
	shiftChar := "N"
	numChar := "1"
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F16Keys := ["Backspace", "~", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F16: F16Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["N", "F23 Up"]})

	return

*v::

	; ######## F13 Combinator ########
	
	if(GetKeyState("F21"))
	{
		F13Keys := ["|", "F13 Up"]
	}
	else if(GetKeyState("F22"))
	{			
		F13Keys := ["|", "Space", "F13 Up"]
	}
	else if(GetKeyState("F23"))
	{
		F13Keys := ["|", "Space", "F22 Down", "F13 Up", "F23 Up"]
	}
	else
	{
		F13Keys := ["Space", "|", "Space", "F22 Down", "F13 Up"]
	}


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("V")


	; ######## F17 Combinator ########
	
	if(GetKeyState("F21"))
	{
		F17Keys := "|"
	}
	else if(GetKeyState("F22"))
	{			
		F17Keys := ["|", "Space"]
	}
	else if(GetKeyState("F23"))
	{
		F17Keys := ["|", "Space", "F22 Down", "F23 Up"]
	}
	else
	{
		F17Keys := ["Space", "|", "Space", "F22 Down"]
	}


	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("V")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "v"
	shiftChar := "V"
	numChar := "|"
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["V", "F23 Up"]})

	return



; Bottom Row
;-------------------------------------------------

*Tab::dual.comboKey()

*x::

	; ######## F13 Combinator ########
	
	if(GetKeyState("F21"))
	{
		F13Keys := ["$", "F13 Up"]
	}
	else if(GetKeyState("F22"))
	{			
		F13Keys := ["$", "F13 Up"]
	}
	else if(GetKeyState("F23"))
	{
		F13Keys := ["$", "F22 Down", "F13 Up", "F23 Up"]
	}
	else
	{
		F13Keys := ["Space", "$", "F22 Down", "F13 Up"]
	}


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("X")


	; ######## F17 Combinator ########
	
	if(GetKeyState("F21"))
	{
		F17Keys := "$"
	}
	else if(GetKeyState("F22"))
	{			
		F17Keys := "$"
	}
	else if(GetKeyState("F23"))
	{
		F17Keys := ["$", "F22 Down", "F23 Up"]
	}
	else
	{
		F17Keys := ["Space", "$", "F22 Down"]
	}


	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("X")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "x"
	shiftChar := "X"
	numChar := "$"
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["X", "F23 Up"]})

	return

*-::

	; ######## F14 Combinator ########

	if(GetKeyState("F21"))
	{
		F14Keys := [";", "F14 Up"]
	}
	else if(GetKeyState("F22"))
	{			
		F14Keys := ["Backspace", ";", "Space", "F14 Up"]
	}
	else if(GetKeyState("F23"))
	{
		F14Keys := ["Backspace", ";", "Space", "F22 Down", "F23 Up", "F14 Up"]
	}
	else
	{
		F14Keys := [";", "Space", "F22 Down", "F14 Up"]
	}


	; ######## F18 Combinator ########
	
	if(GetKeyState("F21"))
	{
		F18Keys := [";"]
	}
	else if(GetKeyState("F22"))
	{			
		F18Keys := ["Backspace", ";", "Space"]
	}
	else if(GetKeyState("F23"))
	{
		F18Keys := ["Backspace", ";", "Space", "F22 Down", "F23 Up"]
	}
	else
	{
		F18Keys := [";", "Space", "F22 Down"]
	}


	; ######## F19 Combinator ########

	F19Keys := []

	Loop % F18Keys.Length()
	{
	    	F19Keys.Push(F18Keys[A_Index])
	}

	F19Keys.Push("F19 Up")


	; ######## Default Keys and F22 and F23 Combinators ########

	if(GetKeyState("F21"))
	{
		defaultKeys := [""""]
		F22Keys := [""""]
		F23Keys := [""""]
	}
	else
	{
		IniRead, inQuote, Status.ini, nestVars, inQuote
		IniRead, nestLevel, Status.ini, nestVars, nestLevel

		if(inQuote)
		{
			inQuote := false
			nestLevel := nestLevel - 1
			
			actuallyNeedToWrite := !(GetKeyState("F14") or GetKeyState("F18") or (GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17"))))
			
			if(actuallyNeedToWrite)
			{
				IniWrite, %inQuote%, Status.ini, nestVars, inQuote
				IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel
			}
		
			if(nestLevel > 0)
			{
				defaultKeys := ["Right", "Space", "F22 Down"]
				F22Keys := ["Backspace", "Right", "Space"]
				F23Keys := ["Backspace", "Right", "Space"]
			}
			else
			{
				defaultKeys := ["Right", "Space", "F22 Down", "F24 Up"]
				F22Keys := ["Backspace", "Right", "Space", "F24 Up"]
				F23Keys := ["Backspace", "Right", "Space" "F24 Up"]
			}
		}
		else
		{
			inQuote := true
			nestLevel := nestLevel + 1
			
			actuallyNeedToWrite := !(GetKeyState("F14") or GetKeyState("F18") or (GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17"))))
			
			if(actuallyNeedToWrite)
			{
				IniWrite, %inQuote%, Status.ini, nestVars, inQuote
				IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel
				lastOpenPairDown := A_TickCount
				IniWrite, %lastOpenPairDown%, Status.ini, nestVars, lastOpenPairDown
			}
	
			if(GetKeyState("F24"))
			{
				defaultKeys := ["Space", """", """", "Left", "F22 Down"]
				F22Keys := ["""", """", "Left"]
				F23Keys := ["""", """", "Left"]
			}
			else
			{
				defaultKeys := ["Space", """", """", "Left", "F22 Down", "F24 Down"]
				F22Keys := ["""", """", "Left", "F24 Down"]
				F23Keys := ["""", """", "Left", "F24 Down"]
			}
		}
	}


	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_PuncCombinator(defaultKeys, F22Keys, F23Keys)


	; ######## F17 Combinator ########
	
	if(GetKeyState("F21"))
	{
		F17Keys := """"
	}
	else if(GetKeyState("F22"))
	{			
		F17Keys := F22Keys
	}
	else if(GetKeyState("F23"))
	{
		F17Keys := F23Keys
	}
	else
	{
		F17Keys := defaultKeys
	}

	
	; ######## Backslash Escape ########

	baseChar := """"
	shiftChar := ";"
	numChar := """"
	
	
	
	if(GetKeyState("F20"))
	{
		defaultKeys := ["Backspace", baseChar, "F20 Up"]
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F19Keys := ["Backspace", shiftChar, "F19 Up", "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}
	

	dual.comboKey(defaultKeys, {F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F19: F19Keys, F21: baseChar, F22: F22Keys, F23: F23Keys})

	return

*/::

	; ######## F14 Combinator ########

	if(GetKeyState("F21"))
	{
		F14Keys := ["—", "F14 Up"]
	}
	else if(GetKeyState("F22"))
	{			
		F14Keys := ["Backspace", "—", "F14 Up"]
	}
	else if(GetKeyState("F23"))
	{
		F14Keys := ["Backspace", "—", "F22 Down", "F23 Up", "F14 Up"]
	}
	else
	{
		F14Keys := ["—", "F22 Down", "F14 Up"]
	}


	; ######## F18 Combinator ########
	
	if(GetKeyState("F21"))
	{
		F18Keys := ["—"]
	}
	else if(GetKeyState("F22"))
	{			
		F18Keys := ["Backspace", "—"]
	}
	else if(GetKeyState("F23"))
	{
		F18Keys := ["Backspace", "—", "F22 Down", "F23 Up"]
	}
	else
	{
		F18Keys := ["—", "F22 Down"]
	}


	; ######## F19 Combinator ########

	F19Keys := []

	Loop % F18Keys.Length()
	{
	    	F19Keys.Push(F18Keys[A_Index])
	}

	F19Keys.Push("F19 Up")


	; ######## Default Keys and F22 and F23 Combinators ########

	if(GetKeyState("F24"))
	{
		IniRead, nestLevel, Status.ini, nestVars, nestLevel
		nestLevel := nestLevel - 1
		
		actuallyNeedToWrite := !(GetKeyState("F14") or GetKeyState("F18") or (GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17"))))
			
		if(actuallyNeedToWrite)
		{
			IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel
		}
	
		if(nestLevel > 0)

		{
			defaultKeys := ["Right", "Space", "F22 Down"]
			F22Keys := ["Backspace", "Right", "Space"]
			F23Keys := ["Backspace", "Right", "Space"]
		}
		else
		{
			defaultKeys := ["Right", "Space", "F22 Down", "F24 Up"]
			F22Keys := ["Backspace", "Right", "Space", "F24 Up"]
			F23Keys := ["Backspace", "Right", "Space" "F24 Up"]
		}
	}
	else
	{
		defaultKeys := [")"]
		F22Keys := [")"]
		F23Keys := [")"]
	}


	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_PuncCombinator(defaultKeys, F22Keys, F23Keys)


	; ######## F17 Combinator ########
	
	if(GetKeyState("F21"))
	{
		F17Keys := ")"
	}
	else if(GetKeyState("F22"))
	{			
		F17Keys := F22Keys
	}
	else if(GetKeyState("F23"))
	{
		F17Keys := F23Keys
	}
	else
	{
		F17Keys := defaultKeys
	}
	
	
	; ######## Backslash Escape ########

	baseChar := ")"
	shiftChar := "—"
	numChar := ")"
	
	

	if(GetKeyState("F20"))
	{
		defaultKeys := ["Backspace", baseChar, "F20 Up"]
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F19Keys := ["Backspace", shiftChar, "F19 Up", "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}


	dual.comboKey(defaultKeys, {F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F19: F19Keys, F21: baseChar, F22: F22Keys, F23: F23Keys})

	return

*,::

	; ######## F14 Combinator ########

	if(GetKeyState("F21"))
	{
		F14Keys := ["_", "F14 Up"]
	}
	else
	{
			IniRead, nestLevel, Status.ini, nestVars, nestLevel
			nestLevel := nestLevel + 1
			
			actuallyNeedToWrite := GetKeyState("F14") or GetKeyState("F18") or (GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))

			if(actuallyNeedToWrite)
			{
				IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel
				lastOpenPairDown := A_TickCount
				IniWrite, %lastOpenPairDown%, Status.ini, nestVars, lastOpenPairDown
			}
			
		if(GetKeyState("F24"))
		{
			if(GetKeyState("F22"))
			{			
				F14Keys := ["_", "_", "Left", "F14 Up"]
			}
			else if(GetKeyState("F23"))
			{
				F14Keys := ["_", "_", "Left", "F14 Up"]
			}
			else
			{
				F14Keys := ["Space", "_", "_", "Left", "F22 Down", "F14 Up"]
			}
		}
		else
		{
			if(GetKeyState("F22"))
			{			
				F14Keys := ["_", "_", "Left", "F24 Down", "F14 Up"]
			}
			else if(GetKeyState("F23"))
			{
				F14Keys := ["_", "_", "Left", "F24 Down", "F14 Up"]
			}
			else
			{
				F14Keys := ["Space", "_", "_", "Left", "F22 Down", "F24 Down", "F14 Up"]
			}
		}
	}


	; ######## F18 Combinator ########

	if(GetKeyState("F21"))
	{
		F14Keys := ["_"]
	}
	else
	{
			IniRead, nestLevel, Status.ini, nestVars, nestLevel
			nestLevel := nestLevel + 1
			
			actuallyNeedToWrite := GetKeyState("F14") or GetKeyState("F18") or (GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))

			if(actuallyNeedToWrite)
			{
				IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel
				lastOpenPairDown := A_TickCount
				IniWrite, %lastOpenPairDown%, Status.ini, nestVars, lastOpenPairDown
			}
			
		if(GetKeyState("F24"))
		{
			if(GetKeyState("F22"))
			{			
				F18Keys := ["_", "_", "Left"]
			}
			else if(GetKeyState("F23"))
			{
				F18Keys := ["_", "_", "Left"]
			}
			else
			{
				F18Keys := ["Space", "_", "_", "Left", "F22 Down"]
			}
		}
		else
		{
			if(GetKeyState("F22"))
			{			
				F18Keys := ["_", "_", "Left", "F24 Down"]
			}
			else if(GetKeyState("F23"))
			{
				F18Keys := ["_", "_", "Left", "F24 Down"]
			}
			else
			{
				F18Keys := ["Space", "_", "_", "Left", "F22 Down", "F24 Down"]
			}
		}
	}


	; ######## F19 Combinator ########
	
	F19Keys := []

	Loop % F18Keys.Length()
	{
	    	F19Keys.Push(F18Keys[A_Index])
	}

	F19Keys.Push("F19 Up")


	; ######## Default Keys and F22 and F23 Combinators ########

	if(GetKeyState("F21"))
	{
		defaultKeys := [","]
		F22Keys := [","]
		F23Keys := [","]
	}
	else
	{	
		defaultKeys := [",", "Space", "F22 Down"]
		F22Keys := ["Backspace", ",", "Space"]
		F23Keys := ["Backspace", ",", "F22 Down", "F23 Up"]
	}


	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_PuncCombinator(defaultKeys, F22Keys, F23Keys)


	; ######## F17 Combinator ########
	
	if(GetKeyState("F21"))
	{
		F17Keys := ","
	}
	else if(GetKeyState("F22"))
	{			
		F17Keys := F22Keys
	}
	else if(GetKeyState("F23"))
	{
		F17Keys := F23Keys
	}
	else
	{
		F17Keys := defaultKeys
	}
	
	
	; ######## Backslash Escape ########

	baseChar := ","
	shiftChar := "_"
	numChar := ","
	
	

	if(GetKeyState("F20"))
	{
		defaultKeys := ["Backspace", baseChar, "F20 Up"]
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F19Keys := ["Backspace", shiftChar, "F19 Up", "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}


	dual.comboKey(defaultKeys, {F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F19: F19Keys, F21: baseChar, F22: F22Keys, F23: F23Keys})

	return

*`::

	; ######## F14 Combinator ########

	if(GetKeyState("F21"))
	{
		F14Keys := ["?", "F14 Up"]
	}
	else if(GetKeyState("F22"))
	{			
		F14Keys := ["Backspace", "?", "Space", "F23 Down", "F22 Up", "F14 Up"]
	}
	else if(GetKeyState("F23"))
	{
		F14Keys := ["Backspace", "?", "Space", "F14 Up"]
	}
	else
	{
		F14Keys := ["?", "Space", "F23 Down", "F14 Up"]
	}


	; ######## F18 Combinator ########

	if(GetKeyState("F21"))
	{
		F18Keys := ["?"]
	}
	else if(GetKeyState("F22"))
	{			
		F18Keys := ["Backspace", "?", "Space", "F23 Down", "F22 Up"]
	}
	else if(GetKeyState("F23"))
	{
		F18Keys := ["Backspace", "?", "Space"]
	}
	else
	{
		F18Keys := ["?", "Space", "F23 Down"]
	}


	; ######## F19 Combinator ########

	F19Keys := []

	Loop % F18Keys.Length()
	{
	    	F19Keys.Push(F18Keys[A_Index])
	}

	F19Keys.Push("F19 Up")


	; ######## Default Keys and F22 and F23 Combinators ########

	if(GetKeyState("F21"))
	{
		defaultKeys := ["("]
		F22Keys := ["("]
		F23Keys := ["("]
	}
	else
	{
		IniRead, nestLevel, Status.ini, nestVars, nestLevel
		nestLevel := nestLevel + 1
		
		actuallyNeedToWrite := !(GetKeyState("F14") or GetKeyState("F18") or (GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17"))))
			
		if(actuallyNeedToWrite)
		{
			IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel
			lastOpenPairDown := A_TickCount
			IniWrite, %lastOpenPairDown%, Status.ini, nestVars, lastOpenPairDown
		}
		
		if(GetKeyState("F24"))
		{
			defaultKeys := ["Space", "(", ")", "Left", "F22 Down"]
			F22Keys := ["(", ")", "Left"]
			F23Keys := ["(", ")", "Left"]
		}
		else
		{
			defaultKeys := ["Space", "(", ")", "Left", "F22 Down", "F24 Down"]
			F22Keys := ["(", ")", "Left", "F24 Down"]
			F23Keys := ["(", ")", "Left", "F24 Down"]
		}
	}


	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_PuncCombinator(defaultKeys, F22Keys, F23Keys)


	; ######## F17 Combinator ########
	
	if(GetKeyState("F21"))
	{
		F17Keys := "("
	}
	else if(GetKeyState("F22"))
	{			
		F17Keys := F22Keys
	}
	else if(GetKeyState("F23"))
	{
		F17Keys := F23Keys
	}
	else
	{
		F17Keys := defaultKeys
	}

	
	; ######## Backslash Escape ########

	baseChar := "("
	shiftChar := "?"
	numChar := "("
	
	

	if(GetKeyState("F20"))
	{
		defaultKeys := ["Backspace", baseChar, "F20 Up"]
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F19Keys := ["Backspace", shiftChar, "F19 Up", "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}
	

	dual.comboKey(defaultKeys, {F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F19: F19Keys, F21: baseChar, F22: F22Keys, F23: F23Keys})

	return


;-----------------------------------


*w::

	; ######## Suppress Keypress If Switching Desktops ########

	if(GetKeyState("F14") and GetKeyState("F19"))
	{
		return
	}
	

	; ######## F13 Combinator ########
	
	F13Keys := F13Keys_Number("9", lastRealKeyDown)


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("W")


	; ######## F17 Combinator ########
	
	F17Keys := F17Keys_Number("9", lastRealKeyDown)


	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("W")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "w"
	shiftChar := "W"
	numChar := "9"
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["W", "F23 Up"]})

	return

*g::

	; ######## F13 Combinator ########
	
	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel + 1
	WriteNestLevelIfApplicable_Opening(nestLevel)
	
	F13Keys := F13Keys_Opening_NoCap("=", "=")


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("G")


	; ######## F17 Combinator ########
	
	F17Keys := F17Keys_Opening_NoCap("=", "=")


	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("G")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "g"
	shiftChar := "G"
	numChar := "="
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["G", "F23 Up"]})

	return

*f::

	; ######## F13 Combinator ########
	
	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel + 1
	WriteNestLevelIfApplicable_Opening(nestLevel)
	
	F13Keys := F13Keys_Opening_NoCap("<", ">")


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("F")


	; ######## F17 Combinator ########
	
	F17Keys := F17Keys_Opening_NoCap("<", ">")


	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("F")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "f"
	shiftChar := "F"
	numChar := "<"
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["F", "F23 Up"]})

	return

*j::

	; ######## F13 Combinator ########
	
	IniRead, nestLevel, Status.ini, nestVars, nestLevel
	nestLevel := nestLevel - 1
	WriteNestLevelIfApplicable_Closing(nestLevel)

	F13Keys := F13Keys_Closing(">", nestLevel)


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("J")


	; ######## F17 Combinator ########
	
	F17Keys := F17Keys_Closing(">", nestLevel)


	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("J")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "j"
	shiftChar := "J"
	numChar := ">"
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["J", "F23 Up"]})

	return

*z::

	; ######## F13 Combinator ########
	
	if(GetKeyState("F21"))
	{
		F13Keys := ["&", "F13 Up"]
	}
	else if(GetKeyState("F22"))
	{			
		F13Keys := ["&", "F13 Up"]
	}
	else if(GetKeyState("F23"))
	{
		F13Keys := ["&", "F22 Down", "F13 Up", "F23 Up"]
	}
	else
	{
		F13Keys := ["Space", "&", "F22 Down", "F13 Up"]
	}


	; ######## F14 Combinator ########
	
	F14Keys := F14Keys_Letter("Z")


	; ######## F17 Combinator ########
	
	if(GetKeyState("F21"))
	{
		F17Keys := "&"
	}
	else if(GetKeyState("F22"))
	{			
		F17Keys := "&"
	}
	else if(GetKeyState("F23"))
	{
		F17Keys := ["&", "F22 Down", "F23 Up"]
	}
	else
	{
		F17Keys := ["Space", "&", "F22 Down"]
	}


	; ######## F18 Combinator ########
	
	F18Keys := F18Keys_Letter("Z")


	; ######## F19 Combinator ########

	if(GetKeyState("F19") and !(GetKeyState("F13") or GetKeyState("F17")))
	{
		SendInput {F19 Up}
	}
	
	
	; ######## Backslash Escape ########

	baseChar := "z"
	shiftChar := "Z"
	numChar := "&"
	
	

	if(GetKeyState("F20"))
	{
		F13Keys := ["Backspace", numChar, "F13 Up", "F20 Up"]
		F14Keys := ["Backspace", shiftChar, "F14 Up", "F20 Up"]
		F17Keys := ["Backspace", numChar, "F20 Up"]
		F18Keys := ["Backspace", shiftChar, "F20 Up"]
		F22Keys := ["Backspace", baseChar, "F20 Up", "F22 Up"]
		F23Keys := ["Backspace", baseChar, "F20 Up", "F23 Up"]
	}

	
	dual.comboKey({F13: F13Keys, F14: F14Keys, F17: F17Keys, F18: F18Keys, F22: [A_ThisHotkey, "F22 Up"], F23: ["Z", "F23 Up"]})

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


	; ######## F20 Combinator ########

	;;;;;;;; TODO: Window Commands

	return
	

*Space::
*Space Up::
	dual.combine("F16", A_ThisHotkey, settings = false, {F14: "", F22: "", F23:""})
	return

*1::

	lastKey := A_PriorHotkey
	if(lastKey != "*1 Up")
	{
		lastRealKeyDown := Dual.cleanKey(lastKey)
	}
	

	dual.combine("F17", "F13 Down", settings = false, {F13: "F17 Down", F14: "", F17: "F17 Up"})

	return

*1 Up::

	lastKey := A_PriorHotkey

	if(lastKey != "*1")
	{
		lastRealKeyDown := Dual.cleanKey(lastKey)
	}


	dual.combine("F17", "F13 Down", settings = false, {F13: "F17 Down", F14: "", F17: "F17 Up"})

	SendInput {F19 Down}
	
	return


*LCtrl::
*RCtrl::dual.comboKey("F21 Down", {F21: "F21 Up"})


*2::

	lastKey := A_PriorHotkey
	if(lastKey != "*2 Up")
	{
		lastRealKeyDown := Dual.cleanKey(lastKey)
	}


	; ######## F22 Combinator ########

	F22Keys := ["F22 Up", "F14 Down"]


	; ######## F23 Combinator ########

	F23Keys := ["F23 Up", "F14 Down"]
	

	dual.combine("F18", "F14 Down", settings = false, {F13: [":", "F13 Up"], F14: "F18 Down", F17: ":", F18: "F18 Up", F22: F22Keys, F23: F23Keys})
	
	return

*2 Up::

	lastKey := A_PriorHotkey

	if(lastKey != "*2")
	{
		lastRealKeyDown := Dual.cleanKey(lastKey)
	}


	dual.combine("F18", "F14 Down")

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
			SendInput {Backspace}{Delete}{F24 Up}
		}
	
		return
	}


	dual.comboKey({F22: ["Backspace", "Backspace", "F22 Up"], F23: ["Backspace", "Backspace", "F23 Up"]})

	return

*\::

	if(GetKeyState("F22"))
	{
		command_PassThroughAutospacing := "F22"
	}
	else if(GetKeyState("F23"))
	{
		command_PassThroughAutospacing := "F23"
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
		defaultKeys := ["\", "F20 Down"]
		F22Keys := ["\", "F20 Down", "F22 Up"]
		F23Keys := ["\", "F20 Down", "F23 Up"]
	}
	else 
	{
		defaultKeys := "F20 Down"
		F22Keys := ["F20 Down", "F22 Up"]
		F23Keys := ["F20 Down", "F23 Up"]
	}

	if(GetKeyState("F14"))
	{
		SendInput {F14 Up}
	}


	dual.comboKey(defaultKeys, {F22: F22Keys, F23: F23Keys})

	if(!inTextBox)
	{
		InputBox, command, Enter Command
	}	

	return
	
	
	
	
#If
