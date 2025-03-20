#!/bin/bash

# Check if .XCompose already exists before copying
if [ ! -f ~/.XCompose ]; then
    cp .XCompose ~
    echo ".XCompose copied."
else
    echo ".XCompose already exists. Skipping."
fi

# Check if .Xmodmap already exists before copying
if [ ! -f ~/.Xmodmap ]; then
    cp .Xmodmap ~
    echo ".Xmodmap copied."
else
    echo ".Xmodmap already exists. Skipping."
fi

# Create ~/.euromak directory if it doesn't exist
if [ ! -d ~/.euromak ]; then
    mkdir -p ~/.euromak
    echo "Directory ~/.euromak created."
fi

# Copy euromak.ahk if it doesn't already exist
if [ ! -f ~/.euromak/euromak.ahk ]; then
    cp euromak.ahk ~/.euromak
    echo "euromak.ahk copied."
else
    echo "euromak.ahk already exists. Skipping."
fi

# Download ahk_x11.AppImage if it doesn't already exist
if [ ! -f ~/.euromak/ahk_x11.AppImage ]; then
    wget -P ~/.euromak https://github.com/phil294/AHK_X11/releases/download/1.0.4/ahk_x11.AppImage
    chmod +x ~/.euromak/ahk_x11.AppImage
    echo "ahk_x11.AppImage downloaded and made executable."
else
    echo "ahk_x11.AppImage already exists. Skipping."
fi

# Download and extract keymap if it doesn't already exist
if [ ! -f mod-dh-matrix-us.map.gz ]; then
    wget https://web.git.kernel.org/pub/scm/linux/kernel/git/legion/kbd.git/snapshot/kbd-2.7.1.tar.gz
    tar --strip-components=5 -xvzf kbd-2.7.1.tar.gz kbd-2.7.1/data/keymaps/i386/colemak/mod-dh-matrix-us.map
    gzip mod-dh-matrix-us.map
    echo "Keymap mod-dh-matrix-us.map downloaded and compressed."
else
    echo "Keymap mod-dh-matrix-us.map.gz already exists. Skipping."
fi

# Create directory for keymaps if it doesn't exist
if [ ! -d /usr/share/kbd/keymaps/i386/ ]; then
    sudo mkdir -p /usr/share/kbd/keymaps/i386/
    echo "Directory /usr/share/kbd/keymaps/i386/ created."
fi

# Copy keymap file if it doesn't already exist
if [ ! -f /usr/share/kbd/keymaps/i386/mod-dh-matrix-us.map.gz ]; then
    sudo cp mod-dh-matrix-us.map.gz /usr/share/kbd/keymaps/i386/
    echo "Keymap mod-dh-matrix-us.map.gz copied to /usr/share/kbd/keymaps/i386/."
else
    echo "Keymap mod-dh-matrix-us.map.gz already exists in /usr/share/kbd/keymaps/i386/. Skipping."
fi

# Create or overwrite /etc/rc.local
sudo tee /etc/rc.local > /dev/null <<EOF
#!/bin/bash
loadkeys /usr/share/kbd/keymaps/i386/mod-dh-matrix-us
exit 0
EOF
echo "/etc/rc.local updated."

# Create directory for X11 config if it doesn't exist
if [ ! -d /etc/X11/xorg.conf.d ]; then
    sudo mkdir -p /etc/X11/xorg.conf.d
    echo "Directory /etc/X11/xorg.conf.d created."
fi

# Overwrite 00-keyboard.conf
sudo tee /etc/X11/xorg.conf.d/00-keyboard.conf > /dev/null <<EOF
Section "InputClass"
    Identifier "keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "us"
    Option "XkbVariant" "colemak_dh_ortho"
EndSection
EOF
echo "/etc/X11/xorg.conf.d/00-keyboard.conf overwritten."

# Add to autostart for major desktop environments (for some reason broken, just run manually from desktop)

#GNOME and KDE Plasma (XDG autostart)
#AUTOSTART_DIR=~/.config/autostart
#mkdir -p "$AUTOSTART_DIR"
#AUTOSTART_FILE="$AUTOSTART_DIR/euromak.desktop"
#if [ ! -f "$AUTOSTART_FILE" ]; then
#    cat > "$AUTOSTART_FILE" <<EOF
#[Desktop Entry]
#Type=Application
#Exec=$HOME/.euromak/ahk_x11.AppImage $HOME/.euromak/euromak.ahk
#Hidden=false
#NoDisplay=false
#X-GNOME-Autostart-enabled=true
#Name=Euromak
#Comment=Autostart AHK X11 with Euromak
#EOF
#    chmod +x "$AUTOSTART_FILE"
#    echo "Autostart entry created and made executable for GNOME/KDE."
#else
#    echo "Autostart entry already exists for GNOME/KDE. Skipping."
#fi

# Add shortcut to Desktop
DESKTOP_DIR=~/Desktop
mkdir -p "$DESKTOP_DIR"
DESKTOP_FILE="$DESKTOP_DIR/euromak.desktop"
if [ ! -f "$DESKTOP_FILE" ]; then
    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Exec=$HOME/.euromak/ahk_x11.AppImage $HOME/.euromak/euromak.ahk
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Euromak
Comment=Shortcut for AHK X11 with Euromak
EOF
    chmod +x "$DESKTOP_FILE"
    echo "Desktop shortcut created and made executable."
else
    echo "Desktop shortcut already exists. Skipping."
fi

# Check if running on Fedora and if fuse-libs is installed
if [ -f /etc/fedora-release ]; then
    echo "Detected Fedora distribution."
    if ! rpm -q fuse-libs &> /dev/null; then
        echo "fuse-libs is not installed. Installing now..."
        sudo dnf install fuse-libs -y
        echo "fuse-libs installed."
    else
        echo "fuse-libs is already installed. Skipping installation."
    fi
else
    echo "Not running on Fedora. Skipping fuse-libs check."
fi

echo "Setup complete!"
