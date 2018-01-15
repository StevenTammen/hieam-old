WriteNestLevelIfApplicable_Opening(nestLevel)
{	
	actuallyNeedToWrite := (GetKeyState("F13") or GetKeyState("F17"))
	
	if(actuallyNeedToWrite)
	{
		IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel
		lastOpenPairDown := A_TickCount
		IniWrite, %lastOpenPairDown%, Status.ini, nestVars, lastOpenPairDown
	}
}

WriteNestLevelIfApplicable_Closing(nestLevel)
{	
	actuallyNeedToWrite := (GetKeyState("F13") or GetKeyState("F17"))
	
	if(actuallyNeedToWrite)
	{
		IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel
	}
}


F13Keys_Number(num, lastRealKeyDown)
{
	F13Keys := GetSpecialCaseKeys(lastRealKeyDown)

	if(GetKeyState("F21"))
	{
		F13Keys := [num, "F13 Up"]
	}
	else if(GetKeyState("F22"))
	{			
		F13Keys.Push(num, "Space", "F13 Up")
	}
	else if(GetKeyState("F23"))
	{
		F13Keys.Push(num, "Space", "F22 Down", "F23 Up", "F13 Up")
	}
	else
	{
		F13Keys.Push("Space", num, "Space", "F22 Down", "F13 Up")
	}

	return F13Keys
}


F13Keys_Opening_PassThroughCap(openingChar, closingChar)
{
	if(GetKeyState("F21"))
	{
		F13Keys := [openingChar, "F13 Up"]
	}
	else
	{
		if(GetKeyState("F24"))
		{
			if(GetKeyState("F22"))
			{			
				F13Keys := [openingChar, ClosingChar, "Left", "F13 Up"]
			}
			else if(GetKeyState("F23"))
			{
				F13Keys := [openingChar, closingChar, "Left", "F13 Up"]
			}
			else
			{
				F13Keys := ["Space", openingChar, closingChar, "Left", "F22 Down", "F13 Up"]
			}
		}
		else
		{
			if(GetKeyState("F22"))
			{			
				F13Keys := [openingChar, ClosingChar, "Left", "F24 Down", "F13 Up"]
			}
			else if(GetKeyState("F23"))
			{
				F13Keys := [openingChar, closingChar, "Left", "F24 Down", "F13 Up"]
			}
			else
			{
				F13Keys := ["Space", openingChar, closingChar, "Left", "F22 Down", "F24 Down", "F13 Up"]
			}
		}
	}
	
	return F13Keys
}


F13Keys_Opening_NoCap(openingChar, closingChar)
{
	if(GetKeyState("F21"))
	{
		F13Keys := [openingChar, "F13 Up"]
	}
	else
	{
		if(GetKeyState("F24"))
		{
			if(GetKeyState("F22"))
			{			
				F13Keys := [openingChar, closingChar, "Left", "F13 Up"]
			}
			else if(GetKeyState("F23"))
			{
				F13Keys := [openingChar, closingChar, "Left", "F22 Down", "F13 Up", "F23 Up"]
			}
			else
			{
				F13Keys := ["Space", openingChar, closingChar, "Left", "F22 Down", "F13 Up"]
			}
		}
		else
		{
			if(GetKeyState("F22"))
			{			
				F13Keys := [openingChar, closingChar, "Left", "F24 Down", "F13 Up"]
			}
			else if(GetKeyState("F23"))
			{
				F13Keys := [openingChar, closingChar, "Left", "F22 Down", "F24 Down", "F13 Up", "F23 Up"]
			}
			else
			{
				F13Keys := ["Space", openingChar, closingChar, "Left", "F22 Down", "F24 Down", "F13 Up"]
			}
		}
	}

	return F13Keys
}


F13Keys_Closing(closingChar, nestLevel)
{
	if(GetKeyState("F24"))
	{
		if(nestLevel > 0)
		{
			if(GetKeyState("F22"))
			{			
				F13Keys := ["Backspace", "Right", "Space", "F13 Up"]
			}
			else if(GetKeyState("F23"))
			{
				F13Keys := ["Backspace", "Right", "Space", "F13 Up"]
			}
			else
			{
				F13Keys := ["Right", "Space", "F22 Down", "F13 Up"]
			}
		}
		else
		{
			if(GetKeyState("F22"))
			{			
				F13Keys := ["Backspace", "Right", "Space", "F24 Up", "F13 Up"]
			}
			else if(GetKeyState("F23"))
			{
				F13Keys := ["Backspace", "Right", "Space", "F24 Up", "F13 Up"]
			}
			else
			{
				F13Keys := ["Right", "Space", "F22 Down", "F24 Up", "F13 Up"]
			}
		}
	}
	else
	{
		F13Keys := [closingChar, "F13 Up"]
	}

	return F13Keys
}


F13Keys_PuncCombinator(defaultKeys, F22Keys, F23Keys)
{
	F13Keys := []

	if(GetKeyState("F21"))
	{
		Loop % defaultKeys.Length()
		{
	    		F13Keys.Push(defaultKeys[A_Index])
		}

		F13Keys.Push("F13 Up")
	}
	else if(GetKeyState("F22"))
	{		
		Loop % F22Keys.Length()
		{
	    		F13Keys.Push(F22Keys[A_Index])
		}

		F13Keys.Push("F13 Up")
	}
	else if(GetKeyState("F23"))
	{
		Loop % F23Keys.Length()
		{
	    		F13Keys.Push(F23Keys[A_Index])
		}

		F13Keys.Push("F13 Up")
	}
	else
	{
		Loop % defaultKeys.Length()
		{
	    		F13Keys.Push(defaultKeys[A_Index])
		}

		F13Keys.Push("F13 Up")
	}

	return F13Keys
}


F14Keys_Letter(letter)
{
	if(GetKeyState("F22"))
	{			
		F14Keys := [letter, "F22 Up", "F14 Up"]
	}
	else if(GetKeyState("F23"))
	{
		F14Keys := [letter, "F23 Up", "F14 Up"]
	}
	else
	{
		F14Keys := [letter, "F14 Up"]
	}

	return F14Keys
}


F16Keys_Opening_PassThroughCap(openingChar, closingChar)
{
	if(GetKeyState("F21"))
	{
		F16Keys := [openingChar]
	}
	else
	{
		if(GetKeyState("F24"))
		{
			if(GetKeyState("F22"))
			{			
				F16Keys := [openingChar, ClosingChar, "Left"]
			}
			else if(GetKeyState("F23"))
			{
				F16Keys := [openingChar, closingChar, "Left"]
			}
			else
			{
				F16Keys := ["Space", openingChar, closingChar, "Left", "F22 Down"]
			}
		}
		else
		{
			if(GetKeyState("F22"))
			{			
				F16Keys := [openingChar, ClosingChar, "Left", "F24 Down"]
			}
			else if(GetKeyState("F23"))
			{
				F16Keys := [openingChar, closingChar, "Left", "F24 Down"]
			}
			else
			{
				F16Keys := ["Space", openingChar, closingChar, "Left", "F22 Down", "F24 Down"]
			}
		}
	}
	
	return F16Keys
}


F16Keys_Opening_NoCap(openingChar, closingChar)
{
	if(GetKeyState("F21"))
	{
		F16Keys := [openingChar]
	}
	else
	{
		if(GetKeyState("F24"))
		{
			if(GetKeyState("F22"))
			{			
				F16Keys := [openingChar, closingChar, "Left"]
			}
			else if(GetKeyState("F23"))
			{
				F16Keys := [openingChar, closingChar, "Left", "F22 Down", "F23 Up"]
			}
			else
			{
				F16Keys := ["Space", openingChar, closingChar, "Left", "F22 Down"]
			}
		}
		else
		{
			if(GetKeyState("F22"))
			{			
				F16Keys := [openingChar, closingChar, "Left", "F24 Down"]
			}
			else if(GetKeyState("F23"))
			{
				F16Keys := [openingChar, closingChar, "Left", "F22 Down", "F24 Down", "F23 Up"]
			}
			else
			{
				F16Keys := ["Space", openingChar, closingChar, "Left", "F22 Down", "F24 Down"]
			}
		}
	}

	return F16Keys
}


F17Keys_Number(num, lastRealKeyDown)
{
	F17Keys := GetSpecialCaseKeys(lastRealKeyDown)

	if(GetKeyState("F21"))
	{
		F17Keys := num
	}
	else if(GetKeyState("F22"))
	{			
		F17Keys.Push(num, "Space")
	}
	else if(GetKeyState("F23"))
	{
		F17Keys.Push(num, "Space", "F22 Down", "F23 Up")
	}
	else
	{
		F17Keys.Push("Space", num, "Space", "F22 Down")
	}

	return F17Keys
}


F17Keys_Opening_PassThroughCap(openingChar, closingChar)
{
	if(GetKeyState("F21"))
	{
		F17Keys := openingChar
	}
	else
	{
		if(GetKeyState("F24"))
		{
			if(GetKeyState("F22"))
			{			
				F17Keys := [openingChar, ClosingChar, "Left"]
			}
			else if(GetKeyState("F23"))
			{
				F17Keys := [openingChar, closingChar, "Left"]
			}
			else
			{
				F17Keys := ["Space", openingChar, closingChar, "Left", "F22 Down"]
			}
		}
		else
		{
			if(GetKeyState("F22"))
			{			
				F17Keys := [openingChar, ClosingChar, "Left", "F24 Down"]
			}
			else if(GetKeyState("F23"))
			{
				F17Keys := [openingChar, closingChar, "Left", "F24 Down"]
			}
			else
			{
				F17Keys := ["Space", openingChar, closingChar, "Left", "F22 Down", "F24 Down"]
			}
		}
	}

	return F17Keys
}


F17Keys_Opening_NoCap(openingChar, closingChar)
{
	if(GetKeyState("F21"))
	{
		F17Keys := openingChar
	}
	else
	{
		if(GetKeyState("F24"))
		{
			if(GetKeyState("F22"))
			{			
				F17Keys := [openingChar, closingChar, "Left"]
			}
			else if(GetKeyState("F23"))
			{
				F17Keys := [openingChar, closingChar, "Left", "F22 Down", "F23 Up"]
			}
			else
			{
				F17Keys := ["Space", openingChar, closingChar, "Left", "F22 Down"]
			}

		}
		else
		{
			if(GetKeyState("F22"))
			{			
				F17Keys := [openingChar, closingChar, "Left", "F24 Down"]
			}
			else if(GetKeyState("F23"))
			{
				F17Keys := [openingChar, closingChar, "Left", "F22 Down", "F24 Down", "F23 Up"]
			}
			else
			{
				F17Keys := ["Space", openingChar, closingChar, "Left", "F22 Down", "F24 Down"]
			}
		}
	}

	return F17Keys
}


F17Keys_Closing(closingChar, nestLevel)
{
	if(GetKeyState("F24"))
	{
		if(nestLevel > 0)
		{
			if(GetKeyState("F22"))
			{			
				F17Keys := ["Backspace", "Right", "Space"]
			}
			else if(GetKeyState("F23"))
			{
				F17Keys := ["Backspace", "Right", "Space"]
			}
			else
			{
				F17Keys := ["Right", "Space", "F22 Down"]
			}
		}
		else
		{
			if(GetKeyState("F22"))
			{			
				F17Keys := ["Backspace", "Right", "Space", "F24 Up"]
			}
			else if(GetKeyState("F23"))
			{
				F17Keys := ["Backspace", "Right", "Space", "F24 Up"]
			}
			else
			{
				F17Keys := ["Right", "Space", "F22 Down", "F24 Up"]
			}
		}
	}
	else
	{
		F17Keys := closingChar
	}

	return F17Keys
}


F18Keys_Letter(letter)
{
	if(GetKeyState("F22"))
	{			
		F18Keys := [letter, "F22 Up"]
	}
	else if(GetKeyState("F23"))
	{
		F18Keys := [letter, "F23 Up"]
	}
	else
	{
		F18Keys := letter
	}

	return F18Keys
}


GetSpecialCaseKeys(lastRealKeyDown)
{
	lastKey := A_PriorHotkey

	if((lastKey = "*1") or (lastKey = "*1 Up"))
	{
		lastKey := lastRealKeyDown
	}
	else
	{
		lastKey := Dual.cleanKey(lastKey)
	}

	F22IsDown := GetKeyState("F22")


	specialCaseKeys := []

	if((lastKey = "c") and F22IsDown)
	{
		specialCaseKeys.Push("Backspace", "–")   ; replace hyphens with en dashes between numbers
	}
	else
	{
		for i, value in ["h", "i", "e", "a", "w", "m", "t", "s", "r", "n", "2"]
		{
			if((lastKey = value) and F22IsDown) ; The keys above will only be a number if F22 is down. We don't want a leading space for these
			{
				specialCaseKeys.Push("Backspace")
			}
		}
	}
	
	return specialCaseKeys
}


DealWithSubscriptAndSuperscriptPassThrough_Tab()
{
	IniRead, subscript_PassThroughCap, Status.ini, nestVars, subscript_PassThroughCap
	if(subscript_PassThroughCap)
	{
		subscript_PassThroughCap := false
		IniWrite, %subscript_PassThroughCap%, Status.ini, nestVars, subscript_PassThroughCap
		
		; Add space to deal with the {Backspace} if F23 down in expand.ahk
		SendInput {Space}{F23 Down}
	}

	IniRead, superscript_PassThroughCap, Status.ini, nestVars, superscript_PassThroughCap
	if(superscript_PassThroughCap)
	{
		superscript_PassThroughCap := false
		IniWrite, %superscript_PassThroughCap%, Status.ini, nestVars, superscript_PassThroughCap

		; Add space to deal with the {Backspace} if F23 down in expand.ahk
		SendInput {Space}{F23 Down}
	}
}


DealWithSubscriptAndSuperscriptPassThrough()
{
	subscript_PassThroughCap := false
	IniWrite, %subscript_PassThroughCap%, Status.ini, nestVars, subscript_PassThroughCap
		
	superscript_PassThroughCap := false
	IniWrite, %superscript_PassThroughCap%, Status.ini, nestVars, superscript_PassThroughCap
}


GetLastChar()
{
	Clipboard :=
	SendInput, +{Left}^c
	ClipWait, 0.1
}


InTextBox()
{
	clipboardCache := Clipboard

	; Try to highlight the character to the left:
	; if something gets highlighted, then we are definitely in a text box.
	GetLastChar()

	if (Clipboard = "")
	{
		Clipboard := clipboardCache
		return false
	}
	else
	{
		Clipboard := clipboardCache
		SendInput {Right}
		return true
	}
}


EndCommandMode()
{
	IniRead, command_PassThroughAutospacing, Status.ini, commandVars, command_PassThroughAutospacing
	IniRead, inTextBox, Status.ini, commandVars, inTextBox

	if(command_PassThroughAutospacing = "F22")
	{
		SendInput {F22 Down}
	}
	else if(command_PassThroughAutospacing = "F23")
	{
		SendInput {F23 Down}
	}
	
	SendInput {F20 Up}

	if(!inTextBox)
	{
		SendInput {Enter}
	}

	return
}