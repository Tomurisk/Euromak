#!/bin/bash

set -e

# Switch to script's directory
cd "$(dirname "$0")"

# Define an array of files to check and download
files=(.XCompose .Xmodmap .xbindkeysrc ahk_x11.AppImage)

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
KEYMAP=us-colemak_dh_ortho
FONT=eurlatgr
EOL

# Print a message indicating success
echo "Configuration overwritten at /etc/vconsole.conf"

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

    # Prompt for replacing Kazakh letters with Ukrainian letters
    read -p "Replace Kazakh letters with Ukrainian letters? (y/n): " replace_letters

    # If the user chooses to replace letters, run the replacement script
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

        echo "Kazakh letters have been replaced with Ukrainian letters."
    fi
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

read -p "Setup complete!"