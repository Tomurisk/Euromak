Run, bash -c echo\ iVBORw0KGgoAAAANSUhEUgAAADAAAAAwAQMAAABtzGvEAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAGUExURUdwTAAAAJ8qhFEAAAABdFJOUwBA5thmAAAAcUlEQVR42rXPsRHAIAgF0O9ZWLqAd1kjhUNZWjKaozgCA3gSwCILJDSvgf8P/DHXBpYilISUkWWghHnFiYJZwQrfaErr6EbDbTCqwrpnm04wLOVAzoZR8iHB7xJ5SiTPjMMbgvW97ZxlGElI6Vjfvv4AMLkyrlWz+8UAAAAASUVORK5CYII=\ |\ base64\ -d\ |\ dd\ of=/tmp/ro.png\ bs=1\ status=none
Sleep, 50
Menu, Tray, Icon, /tmp/ro.png

Run, xinput --set-prop "SteelSeries SteelSeries Rival 3" "libinput Accel Speed" -0.90
Run, xmodmap ~/.Xmodmap

5::Numpad5

F20::
    Run, xdg-open Desktop/euromak.ahk
    ExitApp
return

4::Send, 5
