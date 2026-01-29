#!/bin/bash

set -e

echo "=== Writing Euromak definitions ==="
sudo tee /usr/share/X11/xkb/symbols/emk >/dev/null << 'EOF'
partial alphanumeric_keys modifier_keys
xkb_symbols "lt" {
    include "us(colemak_dh_ortho)"
    key <AE04> { [ F15, 4 ] };
    key <CAPS> { [ Caps_Lock ] };
};

partial alphanumeric_keys modifier_keys
xkb_symbols "ro" {
    include "us(colemak_dh_ortho)"
    key <AE04> { [ F16, 4 ] };
    key <CAPS> { [ Caps_Lock ] };
};

partial alphanumeric_keys modifier_keys
xkb_symbols "ua" {
    include "ua"
    key <AE04> { [ F17, 4 ] };
};

xkb_symbols "rshift_to_dollar" {
    key <RTSH> { [ dollar ] };
};

xkb_symbols "rshift_to_semicolon" {
    key <RTSH> { [ semicolon ] };
};
EOF

LAYOUTS="emk(lt),emk(ro)"
CYR="emk(ua)"

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

<F15> <5> : "€"

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

<F16> <5> : "€"

<F16> <9> : "„"
<F16> <0> : "”"

<F16> <parenleft> : "«"
<F16> <parenright> : "»"

<F16> : ""

<F17> <Cyrillic_o> : "ы"
<F17> <Cyrillic_ve> : "қ"
<F17> <Cyrillic_a> : "ғ"
<F17> <Ukrainian_i> : "ң"
<F17> <Cyrillic_el> : "ұ"
<F17> <Cyrillic_zhe> : "ә"
<F17> <Cyrillic_er> : "ө"
<F17> <Cyrillic_de> : "ү"
<F17> <Cyrillic_ef> : "э"
<F17> <Cyrillic_pe> : "ъ"
<F17> <Cyrillic_ie> : "ё"
<F17> <Cyrillic_ghe> : "ґ"
<F17> <Cyrillic_en> : "һ"
<F17> <Cyrillic_ya> : "ћ"
<F17> <Cyrillic_shorti> : "ј"
<F17> <Cyrillic_te> : "љ"
<F17> <Cyrillic_softsign> : "њ"
<F17> <Cyrillic_be> : "ђ"
<F17> <Cyrillic_yu> : "џ"

<F17> <Cyrillic_O> : "Ы"
<F17> <Cyrillic_VE> : "Қ"
<F17> <Cyrillic_A> : "Ғ"
<F17> <Ukrainian_I> : "Ң"
<F17> <Cyrillic_EL> : "Ұ"
<F17> <Cyrillic_ZHE> : "Ә"
<F17> <Cyrillic_ER> : "Ө"
<F17> <Cyrillic_DE> : "Ү"
<F17> <Cyrillic_EF> : "Э"
<F17> <Cyrillic_PE> : "Ъ"
<F17> <Cyrillic_IE> : "Ё"
<F17> <Cyrillic_GHE> : "Ґ"
<F17> <Cyrillic_EN> : "Һ"
<F17> <Cyrillic_YA> : "Ћ"
<F17> <Cyrillic_SHORTI> : "Ј"
<F17> <Cyrillic_TE> : "Љ"
<F17> <Cyrillic_SOFTSIGN> : "Њ"
<F17> <Cyrillic_BE> : "Ђ"
<F17> <Cyrillic_YU> : "Џ"

<F17> <Cyrillic_shcha> : "—"
<F17> <Cyrillic_SHCHA> : "—"

<F17> <9> : "«"
<F17> <0> : "»"

<F17> <parenleft> : "„"
<F17> <parenright> : "“"

<F17> : ""
EOF

echo "=== Writing ~/.xbindkeysrc ==="
tee "$HOME/.xbindkeysrc" >/dev/null << 'EOF'
"sleep 0.2; xdotool key ctrl+w"
    c:193

"~/.local/bin/toggle-cyr.sh"
    m:0x14 + c:49
EOF

echo "=== Setting up system base keyboard ==="
# Detect Debian
if grep -qi "debian" /etc/os-release; then
    echo "Debian detected — using /etc/default/keyboard instead of Xorg config."
    sudo tee /etc/default/keyboard >/dev/null << 'EOF'
XKBMODEL="pc105"
XKBLAYOUT="us"
XKBVARIANT="colemak_dh_ortho"
XKBOPTIONS="grp:alt_shift_toggle"
BACKSPACE="guess"
EOF
else
    echo "Non-Debian system detected — writing Xorg keyboard config."
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
fi

echo "=== Writing ~/.local/bin/toggle-cyr.sh ==="
mkdir -p "$HOME/.local/bin"
tee "$HOME/.local/bin/toggle-cyr.sh" >/dev/null << EOF
#!/bin/bash

# Get current layout
CURRENT=\$(setxkbmap -query | awk '/layout/ {print \$2}')

# If already in Cyrillic, switch back to your normal layouts
if [ "\$CURRENT" = "$CYR" ]; then
    setxkbmap -layout "$LAYOUTS"
    setxkbmap -print \\
      | sed 's/\(xkb_symbols.*\)"/\1+emk(rshift_to_dollar)"/' \\
      | xkbcomp -xkm - :0
else
    setxkbmap -layout "$CYR"
    setxkbmap -print \\
      | sed 's/\(xkb_symbols.*\)"/\1+emk(rshift_to_semicolon)"/' \\
      | xkbcomp -xkm - :0
fi
EOF
chmod +x "$HOME/.local/bin/toggle-cyr.sh"

echo "=== Dollar sign ==="
mkdir -p ~/.xkb/symbols

echo "=== Writing ~/.local/bin/startup.sh ==="
tee "$HOME/.local/bin/startup.sh" >/dev/null << EOF
#!/bin/bash

setxkbmap -layout "$LAYOUTS"
setxkbmap -print \\
  | sed 's/\(xkb_symbols.*\)"/\1+emk(rshift_to_dollar)"/' \\
  | xkbcomp -xkm - :0
xbindkeys
xinput --set-prop "SteelSeries SteelSeries Rival 3" "libinput Accel Speed" -0.90
EOF
chmod +x "$HOME/.local/bin/startup.sh"

echo "=== Done ==="
echo -e "\e[91mAdd $HOME/.local/bin/startup.sh to autostart\e[0m"
echo "Install xbindkeys and xdotool"
read -p "Reboot or re-login for XKB changes to apply."
