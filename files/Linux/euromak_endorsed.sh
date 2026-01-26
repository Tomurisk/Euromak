#!/bin/bash

set -e

echo "=== Writing Euromak definitions ==="

sudo tee /usr/share/X11/xkb/symbols/emk >/dev/null << 'EOF'
partial alphanumeric_keys modifier_keys
xkb_symbols "lt" {
    include "us(colemak_dh_ortho)"
    key <AE04> { [ F15, 4 ] };
};

partial alphanumeric_keys modifier_keys
xkb_symbols "ro" {
    include "us(colemak_dh_ortho)"
    key <AE04> { [ F16, 4 ] };
};

partial alphanumeric_keys modifier_keys
xkb_symbols "kz" {
    include "kz(basic)"
    key <AE08> { [ Ukrainian_ie,              Ukrainian_IE,              8, asterisk ] };
    key <AE09> { [ Ukrainian_yi,              Ukrainian_YI,              9, parenleft ] };
    key <AE10> { [ Ukrainian_ghe_with_upturn, Ukrainian_GHE_WITH_UPTURN, 0, parenright ] };
    key <AE11> { [ apostrophe,                emdash,                    minus, underscore ] };
    key <AE12> { [ Cyrillic_io,               Cyrillic_IO,               equal, plus ] };
};
EOF

echo "=== Writing ~/.XCompose ==="

tee "$HOME/.XCompose" >/dev/null << 'EOF'
<F15> <i> : "č"
<F15> <t> : "š"
<F15> <e> : "ž"
<F15> <n> : "ą"
<F15> <s> : "ė"
<F15> <o> : "ę"
<F15> <a> : "į"
<F15> <m> : "ų"
<F15> <r> : "ū"

<F15> <I> : "Č"
<F15> <T> : "Š"
<F15> <E> : "Ž"
<F15> <N> : "Ą"
<F15> <S> : "Ė"
<F15> <O> : "Ę"
<F15> <A> : "Į"
<F15> <M> : "Ų"
<F15> <R> : "Ū"

<F15> <y> : "–"
<F15> <Y> : "–"

<F15> <9> : "„"
<F15> <0> : "“"

<F15> : ""

<F16> <r> : "ă"
<F16> <e> : "â"
<F16> <n> : "î"
<F16> <t> : "ș"
<F16> <i> : "ț"

<F16> <R> : "Ă"
<F16> <E> : "Â"
<F16> <N> : "Î"
<F16> <T> : "Ș"
<F16> <I> : "Ț"

<F16> <y> : "–"
<F16> <Y> : "–"

<F16> <9> : "„"
<F16> <0> : "”"

<F16> <k> : "«"
<F16> <h> : "»"

<F16> : ""
EOF

echo "=== Writing ~/.xbindkeysrc ==="

tee "$HOME/.xbindkeysrc" >/dev/null << 'EOF'
"sleep 0.2; xdotool key ctrl+w"
    c:193

"~/.local/bin/toggle-kz.sh"
    m:0x14 + c:49
EOF

echo "=== Writing /etc/X11/xorg.conf.d/00-keyboard.conf ==="
sudo mkdir -p /etc/X11/xorg.conf.d
sudo tee /etc/X11/xorg.conf.d/00-keyboard.conf >/dev/null << 'EOF'
Section "InputClass"
    Identifier "keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "us"
    Option "XkbVariant" "colemak_dh_ortho"
    Option "XkbOptions" "grp:alt_shift_toggle"
EndSection
EOF

echo "=== Writing ~/.local/bin/toggle-kz.sh ==="
mkdir -p "$HOME/.local/bin"
tee "$HOME/.local/bin/toggle-kz.sh" >/dev/null << 'EOF'
#!/bin/bash

# Get current layout
CURRENT=$(setxkbmap -query | awk '/layout/ {print $2}')

# If already in kz, switch back to your normal layouts
if [ "$CURRENT" = "emk(kz)" ]; then
    setxkbmap -layout "emk(lt),emk(ro)"
else
    setxkbmap -layout "emk(kz)"
fi
EOF
chmod +x "$HOME/.local/bin/toggle-kz.sh"

echo "=== Dollar sign ==="
mkdir -p ~/.xkb/symbols
tee ~/.xkb/symbols/custom >/dev/null <<'EOF'
xkb_symbols "rshift_to_dollar" {
    key <RTSH> { [ dollar ] };
};
EOF

echo "=== Writing ~/.local/bin/startup.sh ==="
tee "$HOME/.local/bin/startup.sh" >/dev/null << 'EOF'
#!/bin/bash

setxkbmap -layout "emk(lt),emk(ro)"
setxkbmap -print \
  | sed 's/\(xkb_symbols.*\)"/\1+custom(rshift_to_dollar)"/' \
  | xkbcomp -I$HOME/.xkb -xkm - :0
xbindkeys
xinput --set-prop "SteelSeries SteelSeries Rival 3" "libinput Accel Speed" -0.90
EOF
chmod +x "$HOME/.local/bin/startup.sh"

echo "=== Done ==="
echo "Add $HOME/.local/bin/startup.sh to autostart"
echo "Install xbindkeys and xdotool"
read -p "Reboot or re-login for XKB changes to apply."
