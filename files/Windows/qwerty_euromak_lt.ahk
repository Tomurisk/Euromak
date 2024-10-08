Endkeys = {LControl}{RControl}{LAlt}{RAlt}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}

e::f
r::p
t::b
y::j
u::l
i::u
o::y
p::;

s::r
d::s
f::t
h::m
j::n
k::e
l::i
`;::o

v::d
b::v
n::k
m::h

F1::CapsLock
F2::SendInput +{Enter}

$::SendInput 4

+Enter::SendInput {U+0024}

RShift::SendInput {U+201e}
+RShift::SendInput % (ro == false) ? "{U+201c}" : "{U+201d}"

$4::
	;						č			š			ž			ą			ė			ę			į			ų			ū
	KeysToLTLower := ["{U+010D}", "{U+0161}", "{U+017E}", "{U+0105}", "{U+0117}", "{U+0119}", "{U+012F}", "{U+0173}", "{U+016B}"]
	;						Č			Š			Ž			Ą			Ė			Ę			Į			Ų			Ū
	KeysToLTUpper := ["{U+010C}", "{U+0160}", "{U+017D}", "{U+0104}", "{U+0116}", "{U+0118}", "{U+012E}", "{U+0172}", "{U+016A}"]

	LTInvokers := "itensoamr"

	Input, key, L1, %Endkeys%
	FoundPos := RegExMatch(ErrorLevel, "EndKey:(.*)", SubPat)
	
	if (FoundPos > 0) {
		key = {%SubPat1%}
		SendInput %key%
	}
	else if (key == "y") {
		SendInput {U+2013}
	}
	else {
		KeyIndex := InStr(LTInvokers, key, CaseSensitive := true)	
		if (KeyIndex > 0) {
			SendInput % KeysToLTLower[KeyIndex]
		}
	; Lower upper-case letters and check them if they are present in invokers 
		else if (KeyIndex <= 0) {
			StringLower TKey, key

			KeyIndex := InStr(LTInvokers, TKey, CaseSensitive := true)

			if (KeyIndex > 0) {
				SendInput % KeysToLTUpper[KeyIndex]
			}
	; If neither upper-case nor lower-case letters are present in invokers, send key
			else {
				SendInput %key%
			}
		}
	}
	
	return