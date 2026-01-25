#!/bin/bash

set -e

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