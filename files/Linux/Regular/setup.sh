#!/bin/bash

# Define an array of files to check and download
files=(.Xmodmap .xbindkeysrc)

# Check if each file already exists before copying
for file in "${files[@]}"; do
    if [ ! -f ~/"$file" ]; then
        cp "$file" ~
        echo "$file copied."
    else
        echo "$file already exists. Skipping."
    fi
done

# Handle .XCompose setup from keymap files
if [ ! -f ~/.XCompose ]; then
    echo "Looking for *keymap.txt files in script directory..."
    keymap_files=(*keymap.txt)

    if [ ${#keymap_files[@]} -eq 0 ]; then
        echo "No keymap files found."
    else
        echo "Select a keymap file to use as .XCompose:"
        for i in "${!keymap_files[@]}"; do
            echo "$((i+1))) ${keymap_files[$i]}"
        done

        read -p "Enter the number of the file to use: " selection
        index=$((selection-1))

        if [[ $index -ge 0 && $index -lt ${#keymap_files[@]} ]]; then
            cp "${keymap_files[$index]}" ~/.XCompose
            echo "${keymap_files[$index]} has been set as .XCompose."
        else
            echo "Invalid selection. No changes made."
        fi
    fi
else
    echo ".XCompose already exists. Skipping keymap setup."
fi

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
    packages=(xdotool xbindkeys)

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
    echo "Not running on Fedora. Skipping checks for xdotool, and xbindkeys."
fi

read -p "Setup complete!"
