ro = false

5::Numpad5
F2::Send, +{Enter}

F20::
if ro = true
    ro = false
else
    ro = true
return

4::
if ro = false
    Send, 4
else
    Send, 5
return
