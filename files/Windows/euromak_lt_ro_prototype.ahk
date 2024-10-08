#NoEnv

Endkeys = {LControl}{RControl}{LAlt}{RAlt}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}

ro := false

CapsLock::ro:=!ro

$`::SendInput {U+201e}

$~::SendInput % (ro == false) ? "{U+201c}" : "{U+201d}"

F1::CapsLock
F2::SendInput +{Enter}

$$::SendInput 4

+Enter::SendInput {U+0024}

RShift::SendInput {U+0060}
+RShift::SendInput {U+007E}

$4::
	Input, key, L1, %Endkeys%
	FoundPos := RegExMatch(ErrorLevel, "EndKey:(.*)", SubPat)
    if (FoundPos > 0) {
        key = {%SubPat1%}
        if (key != "{Backspace}") {
	        SendInput %key%
        }
    }
    if (key == "y") {
    	SendInput {U+2013}
    }
	else if (ro == false) {
		if (key == "i") { 		; č
			SendInput {U+010D}
		}
		else if (key == "t") {	; š
			SendInput {U+0161}
		}
		else if (key == "e") {	; ž
			SendInput {U+017E}
		}
		else if (key == "n") {	; ą
			SendInput {U+0105}
		}
		else if (key == "s") {	; ė
			SendInput {U+0117}
		}
		else if (key == "o") {	; ę
			SendInput {U+0119}
		}
		else if (key == "a") {	; į
			SendInput {U+012F}
		}
		else if (key == "m") {	; ų
			SendInput {U+0173}
		}
		else if (key == "r") {	; ū
			SendInput {U+016B}
		}
		

		else if (key == "I") {  ; Č
			SendInput {U+010C}
		}
		else if (key == "T") {	; Š
			SendInput {U+0160}
		}
		else if (key == "E") {	; Ž
			SendInput {U+017D}
		}
		else if (key == "N") {	; Ą
			SendInput {U+0104}
		}
		else if (key == "S") {	; Ė
			SendInput {U+0116}
		}
		else if (key == "O") {	; Ę
			SendInput {U+0118}
		}
		else if (key == "A") {	; Į
			SendInput {U+012E}
		}
		else if (key == "M") {	; Ų
			SendInput {U+0172}
		}
		else if (key == "R") {	; Ū
			SendInput {U+016A}
		}
		else {
			SendInput %key%
		}
	}
	else if (ro) {
		if (key == "r"){ 		; ă
			SendInput {U+0103}
		}
		else if (key == "e") {	; â
			SendInput {U+00e2}
		}
		else if (key == "n") {	; î
			SendInput {U+00ee}
		}
		else if (key == "t") {	; ș
			SendInput {U+0219}
		}
		else if (key == "i") {	; ț
			SendInput {U+021b}
		}

				
		else if (key == "R") {	; Ă
			SendInput {U+0102}
		}
		else if (key == "E") {	; Â
			SendInput {U+00C2}
		}
		else if (key == "N") {	; Î
			SendInput {U+00CE}
		}
		else if (key == "T") {	; Ș
			SendInput {U+0218}
		}
		else if (key == "I") {	; Ț
			SendInput {U+021A}
		}
		else {
			SendInput %key%
		}
	}
	return
