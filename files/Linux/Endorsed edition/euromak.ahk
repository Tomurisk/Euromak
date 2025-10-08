Run, bash -c echo\ iVBORw0KGgoAAAANSUhEUgAAADAAAAAwAQMAAABtzGvEAAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAGUExURUdwTAAAAJ8qhFEAAAABdFJOUwBA5thmAAAAIUlEQVR42mOgEMgxsP///wMXxcD4gGHwU/L/f+CgSA8PAGNOMDE4Sm06AAAAAElFTkSuQmCC\ |\ base64\ -d\ |\ dd\ of=/tmp/lt.png\ bs=1\ status=none
Sleep, 50
Menu, Tray, Icon, /tmp/lt.png

Run, xinput --set-prop "SteelSeries SteelSeries Rival 3" "libinput Accel Speed" -0.90
Run, xmodmap ~/.Xmodmap

5::Numpad5

F20::
    Run, xdg-open Desktop/euromak2.ahk
    ExitApp
return