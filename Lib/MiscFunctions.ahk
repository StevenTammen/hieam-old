WriteNestLevelIfApplicable_Opening(nestLevel)
{	
	actuallyNeedToWrite := (GetKeyState("F13") or GetKeyState("F15"))
	
	if(actuallyNeedToWrite)
	{
		IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel
		lastOpenPairDown := A_TickCount
		IniWrite, %lastOpenPairDown%, Status.ini, nestVars, lastOpenPairDown
	}
}

WriteNestLevelIfApplicable_Closing(nestLevel)
{	
	actuallyNeedToWrite := (GetKeyState("F13") or GetKeyState("F15"))
	
	if(actuallyNeedToWrite)
	{
		IniWrite, %nestLevel%, Status.ini, nestVars, nestLevel
	}
}


F13Keys_Number(num, lastRealKeyDown)
{
	F13Keys := GetSpecialCaseKeys(lastRealKeyDown)

	if(GetKeyState("F20"))
	{
		F13Keys := [num, "F13 Up"]
	}
	else if(GetKeyState("F21"))
	{			
		F13Keys.Push(num, "Space", "F13 Up")
	}
	else if(GetKeyState("F22"))
	{
		F13Keys.Push(num, "Space", "F21 Down", "F22 Up", "F13 Up")
	}
	else
	{
		F13Keys.Push("Space", num, "Space", "F21 Down", "F13 Up")
	}

	return F13Keys
}


F13Keys_Opening_PassThroughCap(openingChar, closingChar)
{
	if(GetKeyState("F20"))
	{
		F13Keys := [openingChar, "F13 Up"]
	}
	else
	{
		if(GetKeyState("F23"))
		{
			if(GetKeyState("F21"))
			{			
				F13Keys := [openingChar, ClosingChar, "Left", "F13 Up"]
			}
			else if(GetKeyState("F22"))
			{
				F13Keys := [openingChar, closingChar, "Left", "F13 Up"]
			}
			else
			{
				F13Keys := ["Space", openingChar, closingChar, "Left", "F21 Down", "F13 Up"]
			}
		}
		else
		{
			if(GetKeyState("F21"))
			{			
				F13Keys := [openingChar, ClosingChar, "Left", "F23 Down", "F13 Up"]
			}
			else if(GetKeyState("F22"))
			{
				F13Keys := [openingChar, closingChar, "Left", "F23 Down", "F13 Up"]
			}
			else
			{
				F13Keys := ["Space", openingChar, closingChar, "Left", "F21 Down", "F23 Down", "F13 Up"]
			}
		}
	}
	
	return F13Keys
}


F13Keys_Opening_NoCap(openingChar, closingChar)
{
	if(GetKeyState("F20"))
	{
		F13Keys := [openingChar, "F13 Up"]
	}
	else
	{
		if(GetKeyState("F23"))
		{
			if(GetKeyState("F21"))
			{			
				F13Keys := [openingChar, closingChar, "Left", "F13 Up"]
			}
			else if(GetKeyState("F22"))
			{
				F13Keys := [openingChar, closingChar, "Left", "F21 Down", "F13 Up", "F22 Up"]
			}
			else
			{
				F13Keys := ["Space", openingChar, closingChar, "Left", "F21 Down", "F13 Up"]
			}
		}
		else
		{
			if(GetKeyState("F21"))
			{			
				F13Keys := [openingChar, closingChar, "Left", "F23 Down", "F13 Up"]
			}
			else if(GetKeyState("F22"))
			{
				F13Keys := [openingChar, closingChar, "Left", "F21 Down", "F23 Down", "F13 Up", "F22 Up"]
			}
			else
			{
				F13Keys := ["Space", openingChar, closingChar, "Left", "F21 Down", "F23 Down", "F13 Up"]
			}
		}
	}

	return F13Keys
}


F13Keys_Closing(closingChar, nestLevel)
{
	if(GetKeyState("F23"))
	{
		if(nestLevel > 0)
		{
			if(GetKeyState("F21"))
			{			
				F13Keys := ["Backspace", "Right", "Space", "F13 Up"]
			}
			else if(GetKeyState("F22"))
			{
				F13Keys := ["Backspace", "Right", "Space", "F13 Up"]
			}
			else
			{
				F13Keys := ["Right", "Space", "F21 Down", "F13 Up"]
			}
		}
		else
		{
			if(GetKeyState("F21"))
			{			
				F13Keys := ["Backspace", "Right", "Space", "F23 Up", "F13 Up"]
			}
			else if(GetKeyState("F22"))
			{
				F13Keys := ["Backspace", "Right", "Space", "F23 Up", "F13 Up"]
			}
			else
			{
				F13Keys := ["Right", "Space", "F21 Down", "F23 Up", "F13 Up"]
			}
		}
	}
	else
	{
		F13Keys := [closingChar, "F13 Up"]
	}

	return F13Keys
}


F13Keys_PuncCombinator(defaultKeys, F21Keys, F22Keys)
{
	F13Keys := []

	if(GetKeyState("F20"))
	{
		Loop % defaultKeys.Length()
		{
	    		F13Keys.Push(defaultKeys[A_Index])
		}

		F13Keys.Push("F13 Up")
	}
	else if(GetKeyState("F21"))
	{		
		Loop % F21Keys.Length()
		{
	    		F13Keys.Push(F21Keys[A_Index])
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
	if(GetKeyState("F21"))
	{			
		F14Keys := [letter, "F21 Up", "F14 Up"]
	}
	else if(GetKeyState("F22"))
	{
		F14Keys := [letter, "F22 Up", "F14 Up"]
	}
	else
	{
		F14Keys := [letter, "F14 Up"]
	}

	return F14Keys
}


F15Keys_Number(num, lastRealKeyDown)
{
	F15Keys := GetSpecialCaseKeys(lastRealKeyDown)

	if(GetKeyState("F20"))
	{
		F15Keys := num
	}
	else if(GetKeyState("F21"))
	{			
		F15Keys.Push(num, "Space")
	}
	else if(GetKeyState("F22"))
	{
		F15Keys.Push(num, "Space", "F21 Down", "F22 Up")
	}
	else
	{
		F15Keys.Push("Space", num, "Space", "F21 Down")
	}

	return F15Keys
}


F15Keys_Opening_PassThroughCap(openingChar, closingChar)
{
	if(GetKeyState("F20"))
	{
		F15Keys := openingChar
	}
	else
	{
		if(GetKeyState("F23"))
		{
			if(GetKeyState("F21"))
			{			
				F15Keys := [openingChar, ClosingChar, "Left"]
			}
			else if(GetKeyState("F22"))
			{
				F15Keys := [openingChar, closingChar, "Left"]
			}
			else
			{
				F15Keys := ["Space", openingChar, closingChar, "Left", "F21 Down"]
			}
		}
		else
		{
			if(GetKeyState("F21"))
			{			
				F15Keys := [openingChar, ClosingChar, "Left", "F23 Down"]
			}
			else if(GetKeyState("F22"))
			{
				F15Keys := [openingChar, closingChar, "Left", "F23 Down"]
			}
			else
			{
				F15Keys := ["Space", openingChar, closingChar, "Left", "F21 Down", "F23 Down"]
			}
		}
	}

	return F15Keys
}


F15Keys_Opening_NoCap(openingChar, closingChar)
{
	if(GetKeyState("F20"))
	{
		F15Keys := openingChar
	}
	else
	{
		if(GetKeyState("F23"))
		{
			if(GetKeyState("F21"))
			{			
				F15Keys := [openingChar, closingChar, "Left"]
			}
			else if(GetKeyState("F22"))
			{
				F15Keys := [openingChar, closingChar, "Left", "F21 Down", "F22 Up"]
			}
			else
			{
				F15Keys := ["Space", openingChar, closingChar, "Left", "F21 Down"]
			}

		}
		else
		{
			if(GetKeyState("F21"))
			{			
				F15Keys := [openingChar, closingChar, "Left", "F23 Down"]
			}
			else if(GetKeyState("F22"))
			{
				F15Keys := [openingChar, closingChar, "Left", "F21 Down", "F23 Down", "F22 Up"]
			}
			else
			{
				F15Keys := ["Space", openingChar, closingChar, "Left", "F21 Down", "F23 Down"]
			}
		}
	}

	return F15Keys
}


F15Keys_Closing(closingChar, nestLevel)
{
	if(GetKeyState("F23"))
	{
		if(nestLevel > 0)
		{
			if(GetKeyState("F21"))
			{			
				F15Keys := ["Backspace", "Right", "Space"]
			}
			else if(GetKeyState("F22"))
			{
				F15Keys := ["Backspace", "Right", "Space"]
			}
			else
			{
				F15Keys := ["Right", "Space", "F21 Down"]
			}
		}
		else
		{
			if(GetKeyState("F21"))
			{			
				F15Keys := ["Backspace", "Right", "Space", "F23 Up"]
			}
			else if(GetKeyState("F22"))
			{
				F15Keys := ["Backspace", "Right", "Space", "F23 Up"]
			}
			else
			{
				F15Keys := ["Right", "Space", "F21 Down", "F23 Up"]
			}
		}
	}
	else
	{
		F15Keys := closingChar
	}

	return F15Keys
}


F16Keys_Letter(letter)
{
	if(GetKeyState("F21"))
	{			
		F16Keys := [letter, "F21 Up"]
	}
	else if(GetKeyState("F22"))
	{
		F16Keys := [letter, "F22 Up"]
	}
	else
	{
		F16Keys := letter
	}

	return F16Keys
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

	F21IsDown := GetKeyState("F21")


	specialCaseKeys := []

	if((lastKey = "c") and F21IsDown)
	{
		specialCaseKeys.Push("Backspace", "–")   ; replace hyphens with en dashes between numbers
	}
	else
	{
		for i, value in ["h", "i", "e", "a", "w", "m", "t", "s", "r", "n", "2"]
		{
			if((lastKey = value) and F21IsDown) ; The keys above will only be a number if F21 is down. We don't want a leading space for these
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
		
		; Add space to deal with the {Backspace} if F22 down in expand.ahk
		SendInput {Space}{F22 Down}
	}

	IniRead, superscript_PassThroughCap, Status.ini, nestVars, superscript_PassThroughCap
	if(superscript_PassThroughCap)
	{
		superscript_PassThroughCap := false
		IniWrite, %superscript_PassThroughCap%, Status.ini, nestVars, superscript_PassThroughCap

		; Add space to deal with the {Backspace} if F22 down in expand.ahk
		SendInput {Space}{F22 Down}
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

	if(command_PassThroughAutospacing = "F21")
	{
		SendInput {F21 Down}
	}
	else if(command_PassThroughAutospacing = "F22")
	{
		SendInput {F22 Down}
	}
	
	SendInput {F18 Up}

	if(!inTextBox)
	{
		SendInput {Enter}
	}

	return
}







GetLastKey(lastRealKeyDown)
{
	lastKey := A_PriorHotkey
	
	if((lastKey = "*1") or (lastKey = "*1 Up") or (lastKey = "*2") or (lastKey = "*2 Up"))
	{
		lastKey := lastRealKeyDown
	}
	else
	{
		lastKey := Dual.cleanKey(lastKey)
	}
	
	return lastKey
}

SendEscapedChar(baseChar, shiftChar, numChar)
{
	if(GetKeyState("F13") or GetKeyState("F15"))
	{
		SendInput numChar
	}
	else if(GetKeyState("F14") or GetKeyState("F16"))
	{
		SendInput shiftChar
	}
	else
	{
		SendInput baseChar
	}
	
	return
}








TwoCharsBackIsDigit()
{
	clipboardCache := Clipboard
	SendInput {Left}
	GetLastChar()
	SendInput {Right}{Right}

	if Clipboard is digit
	{
		Clipboard := clipboardCache
		return true
	}
	else
	{
		Clipboard := clipboardCache
		return false
	}
}


TwoCharsBackEquals(c)
{
	clipboardCache := Clipboard
	SendInput {Left}
	GetLastChar()
	SendInput {Right}{Right}

	if(Clipboard = c)
	{
		Clipboard := clipboardCache
		return true
	}
	else
	{
		Clipboard := clipboardCache
		return false
	}
}


LastCharEquals(c)
{
	clipboardCache := Clipboard
	GetLastChar()
	SendInput {Right}

	if(Clipboard = c)
	{
		Clipboard := clipboardCache
		return true
	}
	else
	{
		Clipboard := clipboardCache
		return false
	}
}



DeletePartialCommand(clipboardCache)
{
    GetLastChar()
    if !(Clipboard = "\")
    {
	SendInput {Backspace}
        DeletePartialCommand(clipboardCache)
    }
    else
    {
        SendInput {Backspace}
        Clipboard := clipboardCache
    }
   
   return
}


Unshift()
{
	if(GetKeyState("F16") = 1)
	{
		SendInput {F16 Up}
	}
}