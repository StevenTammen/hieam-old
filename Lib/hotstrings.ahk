﻿; See https://autohotkey.com/board/topic/114764-regex-dynamic-hotstrings/

/*
    Function: HotStrings
        Dynamically adds regular expression hotstrings.

    Parameters:
        c - regular expression hotstring
        a - (optional) text to replace hotstring with or a label to goto,
            leave blank to remove hotstring definition from triggering an action

    Examples:
> hotstrings("(B|b)tw\s", "%$1%y the way") ; type 'btw' followed by space, tab or return
> hotstrings("i)omg", "oh my god!") ; type 'OMG' in any case, upper, lower or mixed
> hotstrings("\bcolou?r", "rgb(128, 255, 0);") ; '\b' prevents matching with anything before the word, e.g. 'multicololoured'

    License:
        - RegEx Dynamic Hotstrings: Modified version by Edd  
        - Original: <http://www.autohotkey.net/~polyethene/#hotstrings>
        - Dedicated to the public domain (CC0 1.0) <http://creativecommons.org/publicdomain/zero/1.0/>
*/

hotstrings(k, a = "", Options:="")
{
    static z, m = "~$", m_ = "*~$", s, t, w = 2000, sd, d = "Left,Right,Up,Down,Home,End,RButton,LButton", f = "!,+,^,#", f_="{,}"
    global $
    If z = ; init
    {
        RegRead, sd, HKCU, Control Panel\International, sDecimal
        Loop, 94
        {
            c := Chr(A_Index + 32)
            If A_Index between 33 and 58
                Hotkey, %m_%%c%, __hs
            else If A_Index not between 65 and 90
                Hotkey, %m%%c%, __hs
        }
        e = 0,1,2,3,4,5,6,7,8,9,Dot,Div,Mult,Add,Sub,Enter
        Loop, Parse, e, `,
            Hotkey, %m%Numpad%A_LoopField%, __hs
        e = BS,Shift,Space,Enter,Return,Tab,%d%
        Loop, Parse, e, `,
            Hotkey, %m%%A_LoopField%, __hs
        z = 1
    }
    If (a == "" and k == "") ; poll
    {
        q:=RegExReplace(A_ThisHotkey, "\*\~\$(.*)", "$1")
        q:=RegExReplace(q, "\~\$(.*)", "$1")
        If q = BS
        {
            If (SubStr(s, 0) != "}")
                StringTrimRight, s, s, 1
        }
        Else If q in %d%
            s =
        Else
        {
            If q = Shift
            return
            Else If q = Space
                q := " "
            Else If q = Tab
                q := "`t"
            Else If q in Enter,Return,NumpadEnter
                q := "`n"
            Else If (RegExMatch(q, "Numpad(.+)", n))
            {
                q := n1 == "Div" ? "/" : n1 == "Mult" ? "*" : n1 == "Add" ? "+" : n1 == "Sub" ? "-" : n1 == "Dot" ? sd : ""
                If n1 is digit
                    q = %n1%
            }
            Else If (GetKeyState("Shift") ^ !GetKeyState("CapsLock", "T"))
                StringLower, q, q
            s .= q
        }
        Loop, Parse, t, `n ; check
        {
            StringSplit, x, A_LoopField, `r
            If (RegExMatch(s, x1 . "$", $)) ; match
            {
                StringLen, l, $
                StringTrimRight, s, s, l
                if !(x3~="i)\bNB\b")        ; if No Backspce "NB"
                    SendInput, {BS %l%}
                If (IsLabel(x2))
                    Gosub, %x2%
                Else
                {
                    Transform, x0, Deref, %x2%
                    Loop, Parse, f_, `,
                        StringReplace, x0, x0, %A_LoopField%, ¥%A_LoopField%¥, All
                    Loop, Parse, f_, `,
                        StringReplace, x0, x0, ¥%A_LoopField%¥, {%A_LoopField%}, All
                    Loop, Parse, f, `,
                        StringReplace, x0, x0, %A_LoopField%, {%A_LoopField%}, All
                    SendInput, %x0%
                }
            }
        }
        If (StrLen(s) > w)
            StringTrimLeft, s, s, w // 2
    }
    Else ; assert
    {
        StringReplace, k, k, `n, \n, All ; normalize
        StringReplace, k, k, `r, \r, All
        Loop, Parse, t, `n
        {
            l = %A_LoopField%
            If (SubStr(l, 1, InStr(l, "`r") - 1) == k)
                StringReplace, t, t, `n%l%
        }
        If a !=
            t = %t%`n%k%`r%a%`r%Options%
    }
    Return
    __hs: ; event
    hotstrings("", "", Options)
    Return
}