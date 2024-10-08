#NoEnv

Endkeys = {LControl}{RControl}{LAlt}{RAlt}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}
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
	;                 č			  š			  ž			  ą			  ė			  ę			  į			  ų			 ū
	KeysToLT := ["{U+010D}", "{U+0161}", "{U+017E}", "{U+0105}", "{U+0117}", "{U+0119}", "{U+012F}", "{U+0173}", "{U+016B}"
	;	   Č		  Š		      Ž		      Ą		      Ė		      Ę		      Į		      Ų		      Ū
	,"{U+010C}", "{U+0160}", "{U+017D}", "{U+0104}", "{U+0116}", "{U+0118}", "{U+012E}", "{U+0172}", "{U+016A}"]

	;				  ă			  â			  î			  ș			  ț           Ă			  Â			  Î			 Ș			 Ț
	KeysToRO := ["{U+0103}", "{U+00E2}", "{U+00EE}", "{U+0219}", "{U+021B}", "{U+0102}", "{U+00C2}", "{U+00CE}", "{U+0218}", "{U+021A}"]

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