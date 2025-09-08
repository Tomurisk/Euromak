#NoEnv

Endkeys = {LControl}{RControl}{LAlt}{RAlt}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}

$5::

$4::
	Input, key, L1, %Endkeys%
	FoundPos := RegExMatch(ErrorLevel, "EndKey:(.*)", SubPat)
    if (FoundPos > 0) {
        key = {%SubPat1%}
        SendInput %key%
    }
    if (key == "y") {
    	SendInput {U+2013}
    }
	else {
		if (key == "i") {
			SendInput č
		}
		else if (key == "t") {
			SendInput š
		}
		else if (key == "e") {
			SendInput ž
		}
		else if (key == "n") {
			SendInput ą
		}
		else if (key == "s") {
			SendInput ė
		}
		else if (key == "o") {
			SendInput ę
		}
		else if (key == "a") {
			SendInput į
		}
		else if (key == "m") {
			SendInput ų
		}
		else if (key == "r") {
			SendInput ū
		}
		

		else if (key == "I") {
			SendInput Č
		}
		else if (key == "T") {
			SendInput Š
		}
		else if (key == "E") {
			SendInput Ž
		}
		else if (key == "N") {
			SendInput Ą
		}
		else if (key == "S") {
			SendInput Ė
		}
		else if (key == "O") {
			SendInput Ę
		}
		else if (key == "A") {
			SendInput Į
		}
		else if (key == "M") {
			SendInput Ų
		}
		else if (key == "R") {
			SendInput Ū
		}
		else {
			SendInput %key%
		}
	}
	return
