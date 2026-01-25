#!/bin/bash

set -e

echo "=== Writing Euromak definitions ==="

LT_FILE="/usr/share/X11/xkb/symbols/lt"
RO_FILE="/usr/share/X11/xkb/symbols/ro"

# --- Append to lt if missing ---
if ! grep -Fq 'xkb_symbols "lt"' "$LT_FILE"; then
    printf "\n" | sudo tee -a "$LT_FILE" >/dev/null
    sudo tee -a "$LT_FILE" >/dev/null <<'EOF'
default partial alphanumeric_keys modifier_keys
xkb_symbols "cmk" {
    include "us(colemak_dh_ortho)"
    key <AE04> { [ F15, 4 ] };
};
EOF
fi

# --- Append to ro if missing ---
if ! grep -Fq 'xkb_symbols "cmk"' "$RO_FILE"; then
    printf "\n" | sudo tee -a "$RO_FILE" >/dev/null
    sudo tee -a "$RO_FILE" >/dev/null <<'EOF'
partial alphanumeric_keys modifier_keys
xkb_symbols "cmk" {
    include "us(colemak_dh_ortho)"
    key <AE04> { [ F16, 4 ] };
};
EOF
fi

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
if [ "$CURRENT" = "kz(basic)" ]; then
    setxkbmap -layout "lt(cmk),ro(cmk)"
else
    setxkbmap -layout "kz(basic)"
fi
EOF
chmod +x "$HOME/.local/bin/toggle-kz.sh"

read -p "Replace Kazakh letters with Ukrainian letters? (y/n): " replace_letters

if [[ "$replace_letters" == "y" ]]; then
    # Define the file path and backup directory
    FILE="/usr/share/X11/xkb/symbols/kz"
    BACKUP_DIR="/usr/share/X11/xkb/symbols"

    # Check if the backup file already exists
    if [ ! -f "$BACKUP_DIR/kz.bak" ]; then
        sudo cp "$FILE" "$BACKUP_DIR/kz.bak"
        echo "Backup created at $BACKUP_DIR/kz.bak"
    else
        echo "Backup already exists at $BACKUP_DIR/kz.bak"
    fi

    # Replace lines 35-39 with the new content, including four escaped spaces before each line
    sudo sed -i '35,39d' "$FILE"  # Delete lines 35-39
    sudo sed -i '35i\    key <AE08> { [ Ukrainian_ie,              Ukrainian_IE ] };' "$FILE"
    sudo sed -i '36i\    key <AE09> { [ Ukrainian_yi,              Ukrainian_YI ] };' "$FILE"
    sudo sed -i '37i\    key <AE10> { [ Ukrainian_ghe_with_upturn, Ukrainian_GHE_WITH_UPTURN ] };' "$FILE"
    sudo sed -i '38i\    key <AE11> { [ apostrophe,                emdash ] };' "$FILE"
    sudo sed -i '39i\    key <AE12> { [ Cyrillic_io,               Cyrillic_IO ] };' "$FILE"

    read -p "Kazakh letters have been replaced with Ukrainian letters."
fi

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

setxkbmap -layout "lt(cmk),ro(cmk)"
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
