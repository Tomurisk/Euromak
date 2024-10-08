#NoEnv

Endkeys = {LControl}{RControl}{LAlt}{RAlt}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}
SetTitleMatchMode, RegEx
Menu, Tray, Icon, lt.ico

ro := false

CapsLock::
	ro:=!ro
	if (ro)
		Menu, Tray, Icon, ro.ico
	else
		Menu, Tray, Icon, lt.ico
return

F1::CapsLock
F2::SendInput +{Enter}

$::SendInput 4

+Enter::SendInput {U+0024}

RShift::SendInput {U+201e}
+RShift::SendInput % (ro == false) ? "{U+201c}" : "{U+201d}"

$4::
	KeysToLT := ["č", "š", "ž", "ą", "ė", "ę", "į", "ų", "ū", "Č", "Š", "Ž", "Ą", "Ė", "Ę", "Į", "Ų", "Ū"]
	
	KeysToRO := ["ă", "â", "î", "ș", "ț", "Ă", "Â", "Î", "Ș", "Ț"]
	
	LTInvokers := "itensoamrITENSOAMR"
	ROInvokers := "rentiRENTI"

	; -------------------------------------------------------------------------------

	LangKeys(key = "", Invokers = "", KeysToLang = "") {

	KeyIndex := InStr(Invokers, key, CaseSensitive := true)
		if (KeyIndex > 0)
			SendInput % KeysToLang[KeyIndex]
		else
			SendInput %key%
	}

	; -------------------------------------------------------------------------------

	Input, key, L1, %Endkeys%
	FoundPos := RegExMatch(ErrorLevel, "EndKey:(.*)", SubPat)
	
	if (FoundPos > 0) {
		key = {%SubPat1%}
		SendInput %key%
	}
	else if (key == "y" || key == "Y") {
		SendInput {U+2013}
	}
	else if (ro == false) {
		LangKeys(key, LTInvokers, KeysToLT)
	}
	else {
		LangKeys(key, ROInvokers, KeysToRO)
	}
return

#IfWinActive ahk_exe wacup.exe ahk_class Winamp
s::
MButton::
#IfWinActive

#IfWinExist ahk_exe wacup.exe
#l::
WinActivate, ahk_exe wacup.exe ahk_class Winamp v1.x
return
#IfWinExist ahk_exe wacup.exe