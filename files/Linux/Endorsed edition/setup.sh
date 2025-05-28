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

# Overwrite the vconsole.conf file with the specified configurations
sudo tee /etc/vconsole.conf > /dev/null <<EOL
KEYMAP=mod-dh-matrix-us
FONT=eurlatgr
XKBLAYOUT=us-colemak_dh_ortho
XKBMODEL=pc105
EOL

# Print a message indicating success
echo "Configuration written to /etc/vconsole.conf"

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