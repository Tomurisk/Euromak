#!/bin/bash

# Define an array of files to check and download
files=(.XCompose .Xmodmap .ctrl_w.ahk .xbindkeysrc ahk_x11.AppImage)

# Check if each file already exists before copying or downloading
for file in "${files[@]}"; do
    if [ "$file" == "ahk_x11.AppImage" ]; then
        if [ ! -f ~/"$file" ]; then
            wget -P ~ https://github.com/phil294/AHK_X11/releases/download/1.0.5/ahk_x11.AppImage
            chmod +x ~/ahk_x11.AppImage
            echo "$file downloaded and made executable. Please open it and install via the GUI."
        else
            echo "$file already exists. Skipping."
        fi
    else
        if [ ! -f ~/"$file" ]; then
            cp "$file" ~
            echo "$file copied."
        else
            echo "$file already exists. Skipping."
        fi
    fi
done

# Define an array of files to copy to ~/Desktop
desktop_files=(euromak.ahk euromak2.ahk)

# Copy each file to ~/Desktop if it doesn't already exist
for file in "${desktop_files[@]}"; do
    if [ ! -f ~/Desktop/"$file" ]; then
        cp "$file" ~/Desktop/
        echo "$file copied to ~/Desktop."
    else
        echo "$file already exists in ~/Desktop. Skipping."
    fi
done

# Download and extract keymap if it doesn't already exist
if [ ! -f mod-dh-matrix-us.map.gz ]; then
    wget https://www.kernel.org/pub/linux/utils/kbd/kbd-2.7.1.tar.gz
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

# Prompt the user to add the Kazakh layout
read -p "Add Kazakh layout? (y/n): " add_kazakh

if [[ "$add_kazakh" == "y" ]]; then
    # Overwrite 00-keyboard.conf with both layouts
    sudo tee /etc/X11/xorg.conf.d/00-keyboard.conf > /dev/null <<EOF
Section "InputClass"
    Identifier "keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "us(colemak_dh_ortho),kz(basic)"
    Option "XkbOptions" "grp:alt_shift_toggle"
EndSection
EOF
    echo "/etc/X11/xorg.conf.d/00-keyboard.conf overwritten with both layouts."
else
    # Overwrite 00-keyboard.conf with only the Colemak layout
    sudo tee /etc/X11/xorg.conf.d/00-keyboard.conf > /dev/null <<EOF
Section "InputClass"
    Identifier "keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "us"
    Option "XkbVariant" "colemak_dh_ortho"
EndSection
EOF
    echo "/etc/X11/xorg.conf.d/00-keyboard.conf overwritten with Colemak layout only."
fi

# Check if running on Fedora and if fuse-libs, xdotool, and xbindkeys are installed
if [ -f /etc/fedora-release ]; then
    echo "Detected Fedora distribution."

    # Define an array of packages to check and install
    packages=(fuse-libs xdotool xbindkeys)

    # Check for each package
    for package in "${packages[@]}"; do
        if ! rpm -q "$package" &> /dev/null; then
            echo "$package is not installed. Installing now..."
            sudo dnf install "$package" -y
            echo "$package installed."
        else
            echo "$package is already installed. Skipping installation."
        fi
    done

else
    echo "Not running on Fedora. Skipping checks for fuse-libs, xdotool, and xbindkeys."
fi

echo "Setup complete!"
